package com.snowplowanalytics.liveviewerprofile.repository;

import java.util.Collections;
import java.util.List;

import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Repository;

import com.snowplowanalytics.liveviewerprofile.model.VideoEvent;

@Repository
@Profile("test-kafka")
public class NoOpVideoEventRepository implements VideoEventRepository {
    @Override
    public VideoEvent saveVideoEvent(VideoEvent event) {
        return event;
    }

    @Override
    public List<VideoEvent> getVideoEvents() {
        return Collections.emptyList();
    }
} 