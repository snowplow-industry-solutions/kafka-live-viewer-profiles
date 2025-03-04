package com.snowplowanalytics.liveviewerprofile.service;

import static org.assertj.core.api.Assertions.assertThat;

import java.time.Instant;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicReference;

import org.apache.kafka.clients.consumer.ConsumerConfig;
import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.apache.kafka.common.errors.TimeoutException;
import org.apache.kafka.common.serialization.StringDeserializer;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.kafka.KafkaException;
import org.springframework.kafka.core.DefaultKafkaConsumerFactory;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.kafka.listener.ContainerProperties;
import org.springframework.kafka.listener.KafkaMessageListenerContainer;
import org.springframework.kafka.listener.MessageListener;
import org.springframework.kafka.support.SendResult;
import org.springframework.kafka.test.EmbeddedKafkaBroker;
import org.springframework.kafka.test.utils.KafkaTestUtils;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.snowplowanalytics.liveviewerprofile.model.VideoEvent;

import lombok.extern.slf4j.Slf4j;

@Slf4j
public abstract class BaseKafkaConsumerTest {

    @Value("${spring.kafka.bootstrap-servers:localhost:9092}")
    private String brokers;

    @Value("${spring.kafka.consumer.topics:test-topic}")
    private String topic;

    @Value("${spring.kafka.consumer.group-id:test-consumer-group}")
    private String groupId;

    @Value("${spring.kafka.consumer.auto-commit:false}")
    private String autoCommit;

    @Value("${spring.kafka.consumer.auto-offset-reset:earliest}")
    private String autoOffsetReset;

    @Value("${spring.kafka.consumer.timeout-to-write:5}")
    private int timeoutToWrite;

    @Value("${spring.kafka.consumer.timeout-to-read:10}")
    private int timeoutToRead;

    @Value("${spring.kafka.consumer.request-timeout-ms:5000}")
    private String requestTimeoutMs;

    @Value("${spring.kafka.consumer.max-block-ms:5000}")
    private String maxBlockMs;

    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private KafkaTemplate<String, String> kafkaTemplate;

    protected void runKafkaTest(Map<String, Object> consumerProps) throws Exception {
        log.info("Starting Kafka test on topic {}", topic);
       
        kafkaTemplate.getProducerFactory().updateConfigs(Map.of(
            "request.timeout.ms", requestTimeoutMs,
            "max.block.ms", maxBlockMs
        ));

        DefaultKafkaConsumerFactory<String, String> consumerFactory = new DefaultKafkaConsumerFactory<>(consumerProps);
        ContainerProperties containerProps = new ContainerProperties(topic);

        VideoEvent expectedEvent = VideoEvent.builder()
                .viewerId("039e8653-5d30-4135-a273-86d42ce7ea1b")
                .collectorTstamp(Instant.parse("2024-11-17T10:10:56.957Z"))
                .eventId("143f9cb9-3db9-4e99-8d67-c8aea075d190")
                .eventName("pause_event")
                .videoTs(126.1057090)
                .adsClicked(0)
                .adsSkipped(4)
                .adId(0)
                .status(VideoStateMachine.State.WATCHING_AD)
                .build();

        final AtomicReference<VideoEvent> receivedEvent = new AtomicReference<>();
        final CountDownLatch latch = new CountDownLatch(1);

        MessageListener<String, String> listener = new MessageListener<String, String>() {
            @Override
            public void onMessage(ConsumerRecord<String, String> record) {
                try {
                    log.info("Message received: {}", record.value());
                    VideoEvent event = objectMapper.readValue(record.value(), VideoEvent.class);
                    receivedEvent.set(event);
                    latch.countDown();
                } catch (Exception e) {
                    log.error("Error processing message", e);
                }
            }
        };

        containerProps.setMessageListener(listener);

        KafkaMessageListenerContainer<String, String> container = new KafkaMessageListenerContainer<>(consumerFactory,
                containerProps);
        container.start();
        Thread.sleep(1000);
        
        try {
            String message = objectMapper.writeValueAsString(expectedEvent);
            log.info("Sending message to topic {}: {}", topic, message);

            try {
                CompletableFuture<SendResult<String, String>> future = kafkaTemplate.send(topic, message);
                SendResult<String, String> result = future.get(timeoutToWrite, TimeUnit.SECONDS);
                log.info("Message sent successfully to partition {} with offset {}", 
                    result.getRecordMetadata().partition(), 
                    result.getRecordMetadata().offset());
            } catch (KafkaException e) {
                log.error("Received a KafkaException while sending message to Kafka");
                if (e.getCause() instanceof TimeoutException) {
                    log.error("Timeout while sending message to Kafka");
                }
                throw e;
            } catch (RuntimeException e) {
                log.error("Received a {} exception while sending message to Kafka", e.getClass().getName());
                throw e;
            }

            log.info("Waiting for message (timeout in {} seconds)...", timeoutToRead);            
            if (!latch.await(timeoutToRead, TimeUnit.SECONDS)) {
                throw new AssertionError("Message not received within timeout");
            }
            
            VideoEvent actualEvent = receivedEvent.get();
            assertThat(actualEvent).isEqualTo(expectedEvent);
            log.info("Test passed");
        } finally {
            container.stop();
            log.info("Container stopped");
        }
    }

    protected Map<String, Object> getBaseConsumerProps(EmbeddedKafkaBroker broker) {
        Map<String, Object> props = new HashMap<>();
        if (broker == null) {
            log.info("Using default brokers: {}", brokers);
            props = KafkaTestUtils.consumerProps(brokers, groupId, autoCommit);
        } else {
            log.info("Using embedded broker: {}", broker.getBrokersAsString());
            props = KafkaTestUtils.consumerProps(groupId, autoCommit, broker);
        }

        props.put("request.timeout.ms", requestTimeoutMs);
        props.put("max.block.ms", maxBlockMs);

        props.put(ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class);
        props.put(ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class);
        props.put(ConsumerConfig.AUTO_OFFSET_RESET_CONFIG, autoOffsetReset);

        return props;
    }

} 