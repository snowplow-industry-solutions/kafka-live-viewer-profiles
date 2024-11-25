package com.snowplowanalytics.liveviewerprofile.config;

import java.util.Map;

import com.snowplowanalytics.liveviewerprofile.model.VideoEvent;

import io.awspring.cloud.dynamodb.DynamoDbTableNameResolver;
import software.amazon.awssdk.annotations.NotNull;

public class VideoEventDynamoDbTableNameResolver implements DynamoDbTableNameResolver{

    @NotNull @Override
    public <T> String resolve(Class<T> clazz) {
        return classTableNameMap().get(clazz);
    }

    private Map<Class<?>, String> classTableNameMap() {
        return Map.of(VideoEvent.class, "video_events");
    }
}
