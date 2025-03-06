package com.snowplowanalytics.liveviewerprofile.service;

import org.junit.jupiter.api.Tag;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;

@SpringBootTest
@ActiveProfiles({ "test-kafka", "test-kafka-integration" })
@Tag("integration")
class KafkaConsumerServiceIntegrationTest extends BaseKafkaConsumerTest {

    @Test
    void testKafkaConsumerProcessesVideoEvent() throws Exception {
        runKafkaTest(getBaseConsumerProps(null));
    }
} 