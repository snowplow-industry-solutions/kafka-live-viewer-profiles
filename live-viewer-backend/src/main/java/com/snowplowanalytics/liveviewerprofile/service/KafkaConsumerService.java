package com.snowplowanalytics.liveviewerprofile.service;

import java.util.HashMap;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Profile;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.snowplowanalytics.liveviewerprofile.model.VideoEvent;
import com.snowplowanalytics.liveviewerprofile.repository.VideoEventRepository;
import com.snowplowanalytics.liveviewerprofile.service.VideoStateMachine.State;
import com.snowplowanalytics.liveviewerprofile.websocket.WebSocketHandler;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@RequiredArgsConstructor
@Profile("!test-kafka")
@Slf4j
public class KafkaConsumerService {

    private final WebSocketHandler webSocketHandler;
    private final ObjectMapper objectMapper;
    private final VideoStateMachine videoStateMachine;
    
    @Autowired
    private final VideoEventRepository videoEventRepository;
    
    private final Map<String, State> lastStatusByViewer = new HashMap<>();

    @KafkaListener(topics = "${spring.kafka.consumer.topics}", groupId = "${spring.kafka.consumer.group-id}")
    public void listen(String message) {
        try {
            VideoEvent videoEvent = objectMapper.readValue(message, VideoEvent.class);
            videoStateMachine.handleEvent(videoEvent);

            String viewerId = videoEvent.getViewerId();
            State currentStatus = videoStateMachine.getCurrentState(videoEvent);
            State lastStatus = lastStatusByViewer.get(viewerId);

            VideoEvent updatedVideoEvent = new VideoEvent(
                viewerId,
                videoEvent.getCollectorTstamp(),
                videoEvent.getEventId(),
                videoEvent.getEventName(),
                videoEvent.getVideoTs(),
                videoEvent.getAdsClicked(),
                videoEvent.getAdsSkipped(),
                videoEvent.getAdId(),
                currentStatus);

            if (lastStatus == null || !lastStatus.equals(currentStatus)) {
                lastStatusByViewer.put(viewerId, currentStatus);
                log.debug("Status for viewer {} is now {}", viewerId, currentStatus);
                String json = objectMapper.writeValueAsString(updatedVideoEvent);
                webSocketHandler.broadcast(json);
                videoEventRepository.saveVideoEvent(updatedVideoEvent);
            }
        } catch (Exception e) {
            log.error("Error processing message: " + message, e);
        }
    }
}
