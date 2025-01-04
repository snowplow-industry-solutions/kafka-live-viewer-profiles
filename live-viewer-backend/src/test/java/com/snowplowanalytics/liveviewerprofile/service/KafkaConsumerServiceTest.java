package com.snowplowanalytics.liveviewerprofile.service;

import static org.assertj.core.api.Assertions.assertThat;

import java.time.Instant;
import java.util.Map;
import java.util.concurrent.BlockingQueue;
import java.util.concurrent.LinkedBlockingQueue;

import org.apache.kafka.clients.consumer.ConsumerConfig;
import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.apache.kafka.common.serialization.StringDeserializer;
import org.junit.jupiter.api.Disabled;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.kafka.core.DefaultKafkaConsumerFactory;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.kafka.listener.ContainerProperties;
import org.springframework.kafka.listener.KafkaMessageListenerContainer;
import org.springframework.kafka.listener.MessageListener;
import org.springframework.kafka.test.EmbeddedKafkaBroker;
import org.springframework.kafka.test.context.EmbeddedKafka;
import org.springframework.kafka.test.utils.KafkaTestUtils;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.snowplowanalytics.liveviewerprofile.model.VideoEvent;

@Disabled // TODO: Fix this test
@SpringBootTest
@EmbeddedKafka(partitions = 1, topics = { "test-topic" })
class KafkaConsumerServiceTest {

    private static final String TOPIC = "test-topic";

    @Autowired
    private KafkaTemplate<String, String> kafkaTemplate;

    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private EmbeddedKafkaBroker embeddedKafkaBroker;

    @Test
    void testKafkaConsumerProcessesVideoEvent() throws Exception {
        Map<String, Object> consumerProps = KafkaTestUtils.consumerProps(
                "test-group",
                "true",
                embeddedKafkaBroker);
        consumerProps.put(ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class);
        consumerProps.put(ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class);

        DefaultKafkaConsumerFactory<String, String> consumerFactory = new DefaultKafkaConsumerFactory<>(consumerProps);
        ContainerProperties containerProps = new ContainerProperties(TOPIC);

        BlockingQueue<ConsumerRecord<String, String>> records = new LinkedBlockingQueue<>();

        MessageListener<String, String> messageListener = records::offer;
        containerProps.setMessageListener(messageListener);

        KafkaMessageListenerContainer<String, String> container = new KafkaMessageListenerContainer<>(consumerFactory,
                containerProps);
        container.start();

        try {
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

            String message = objectMapper.writeValueAsString(expectedEvent);

            kafkaTemplate.send(TOPIC, message);

            ConsumerRecord<String, String> receivedRecord = records.take();

            VideoEvent actualEvent = objectMapper.readValue(receivedRecord.value(), VideoEvent.class);

            assertThat(actualEvent).isEqualTo(expectedEvent);
        } finally {
            container.stop();
        }
    }
}
