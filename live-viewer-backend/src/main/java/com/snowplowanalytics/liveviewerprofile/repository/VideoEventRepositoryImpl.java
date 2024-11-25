package com.snowplowanalytics.liveviewerprofile.repository;

import java.util.Comparator;
import java.util.List;
import java.util.stream.StreamSupport;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.env.Environment;
import org.springframework.stereotype.Repository;

import com.snowplowanalytics.liveviewerprofile.model.VideoEvent;

import io.awspring.cloud.dynamodb.DynamoDbTemplate;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import software.amazon.awssdk.enhanced.dynamodb.model.PageIterable;

@Repository
@RequiredArgsConstructor
@Slf4j
public class VideoEventRepositoryImpl implements VideoEventRepository {

    @Autowired
    private final DynamoDbTemplate dynamoDbTemplate;

    @Autowired
    private Environment env;

    @Override
    public List<VideoEvent> getVideoEvents() {
       final PageIterable<VideoEvent> payments = dynamoDbTemplate.scanAll(VideoEvent.class);
    return StreamSupport.stream(payments.spliterator(), false)
        .flatMap(page -> page.items().stream())
        .sorted(Comparator.comparingDouble(VideoEvent::getVideoTs))
        .toList();
    }

    @Override
    public VideoEvent saveVideoEvent(VideoEvent videoEvent) {
        log.debug("THE FOLLOWING DEBUG INFORMATION MUST BE REMOVED!");
        log.debug(String.format("spring.cloud.aws.credentials.access-key=%s",
            env.getProperty("spring.cloud.aws.credentials.access-key")));
        log.debug(String.format("spring.cloud.aws.credentials.secret-key=%s",
            env.getProperty("spring.cloud.aws.credentials.secret-key")));
        log.debug(String.format("spring.cloud.aws.dynamodb.region=%s",
            env.getProperty("spring.cloud.aws.dynamodb.region")));
        return dynamoDbTemplate.save(videoEvent);
    }

}
