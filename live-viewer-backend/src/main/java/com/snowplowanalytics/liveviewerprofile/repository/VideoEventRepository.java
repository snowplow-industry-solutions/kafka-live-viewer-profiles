package com.snowplowanalytics.liveviewerprofile.repository;

import java.util.List;

import com.snowplowanalytics.liveviewerprofile.model.VideoEvent;

public interface VideoEventRepository {
    List<VideoEvent> getVideoEvents();
    VideoEvent saveVideoEvent(VideoEvent videoEvent);
}
