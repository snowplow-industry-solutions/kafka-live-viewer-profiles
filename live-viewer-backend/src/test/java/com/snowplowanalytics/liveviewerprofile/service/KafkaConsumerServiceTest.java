package com.snowplowanalytics.liveviewerprofile.service;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.kafka.test.EmbeddedKafkaBroker;
import org.springframework.kafka.test.context.EmbeddedKafka;
import org.springframework.test.context.ActiveProfiles;

@SpringBootTest
@EmbeddedKafka(partitions = 1, topics = { "${spring.kafka.consumer.topics}" })
@ActiveProfiles("test-kafka")
class KafkaConsumerServiceTest extends BaseKafkaConsumerTest {

    @Autowired
    private EmbeddedKafkaBroker embeddedKafkaBroker;

    @Test
    void testKafkaConsumerProcessesVideoEvent() throws Exception {
        runKafkaTest(getBaseConsumerProps(embeddedKafkaBroker));
    }
}
