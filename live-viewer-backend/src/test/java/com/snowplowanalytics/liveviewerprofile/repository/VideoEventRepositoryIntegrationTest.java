package com.snowplowanalytics.liveviewerprofile.repository;

import static org.assertj.core.api.Assertions.assertThat;
import static org.testcontainers.containers.localstack.LocalStackContainer.Service.DYNAMODB;

import java.time.Instant;
import java.util.List;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Tag;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;
import org.testcontainers.containers.localstack.LocalStackContainer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;
import org.testcontainers.utility.DockerImageName;

import com.snowplowanalytics.liveviewerprofile.model.VideoEvent;
import software.amazon.awssdk.enhanced.dynamodb.DynamoDbEnhancedClient;
import software.amazon.awssdk.enhanced.dynamodb.DynamoDbTable;
import software.amazon.awssdk.enhanced.dynamodb.TableSchema;

@Testcontainers
@SpringBootTest
@Tag("integration")
class VideoEventRepositoryIntegrationTest {

    @SuppressWarnings("resource")
    @Container
    static final LocalStackContainer localstack = new LocalStackContainer(DockerImageName.parse("localstack/localstack"))
            .withServices(DYNAMODB)
            .withExposedPorts(4566);

    @DynamicPropertySource
    static void registerProperties(DynamicPropertyRegistry registry) {
        registry.add("spring.cloud.aws.dynamodb.endpoint", () -> localstack.getEndpointOverride(DYNAMODB));
        registry.add("spring.cloud.aws.region.static", () -> localstack.getRegion());
        registry.add("spring.cloud.aws.credentials.access-key", localstack::getAccessKey);
        registry.add("spring.cloud.aws.credentials.secret-key", localstack::getSecretKey);
    }

    @Autowired
    private VideoEventRepository videoEventRepository;

    @Autowired
    private DynamoDbEnhancedClient dynamoDbEnhancedClient;

    @BeforeEach
    void setUp() {
        DynamoDbTable<VideoEvent> table = dynamoDbEnhancedClient.table("video_events", TableSchema.fromBean(VideoEvent.class));
        table.scan().items().forEach(table::deleteItem);
    }

    @Test
    void testSaveAndCountVideoEvents() {
        videoEventRepository.saveVideoEvent(VideoEvent.builder()
                .viewerId("viewer1")
                .eventId("123")
                .collectorTstamp(Instant.now())
                .build());

        videoEventRepository.saveVideoEvent(VideoEvent.builder()
                .viewerId("viewer2")
                .eventId("456")
                .collectorTstamp(Instant.now())
                .build());

        List<VideoEvent> savedEvents = videoEventRepository.getVideoEvents();
        assertThat(savedEvents).hasSize(2);
    }
}