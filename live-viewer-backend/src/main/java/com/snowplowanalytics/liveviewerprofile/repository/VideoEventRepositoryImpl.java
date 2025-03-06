package com.snowplowanalytics.liveviewerprofile.repository;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Repository;

import com.snowplowanalytics.liveviewerprofile.model.VideoEvent;

import lombok.RequiredArgsConstructor;
import software.amazon.awssdk.core.pagination.sync.SdkIterable;
import software.amazon.awssdk.enhanced.dynamodb.DynamoDbTable;
import software.amazon.awssdk.enhanced.dynamodb.model.ScanEnhancedRequest;

@Repository
@RequiredArgsConstructor
@Profile("!test-kafka")
public class VideoEventRepositoryImpl implements VideoEventRepository {

    @Autowired
    private final DynamoDbTable<VideoEvent> videoEventsTable;

    @Override
    public List<VideoEvent> getVideoEvents() {
        ScanEnhancedRequest request = ScanEnhancedRequest.builder().build();
        SdkIterable<VideoEvent> shipments = videoEventsTable.scan(request).items();
        return shipments.stream().toList();
    }

    @Override
    public VideoEvent saveVideoEvent(VideoEvent videoEvent) {
        videoEventsTable.putItem(videoEvent);
        return videoEvent;
    }

}