package com.snowplowanalytics.liveviewerprofile.service;

import java.util.HashMap;
import java.util.Map;
import java.util.function.Function;

import org.springframework.stereotype.Service;

import com.snowplowanalytics.liveviewerprofile.model.VideoEvent;

@Service
public class VideoStateMachine {

    public enum State {
        WATCHING_VIDEO,
        PAUSED_VIDEO,
        WATCHING_AD,
        COMPLETED_VIDEO
    }

    private final Map<String, State> viewerVideoStates = new HashMap<>();

    private final Map<State, Function<String, State>> stateTransitions = Map.of(
        State.WATCHING_VIDEO, this::handleWatchingVideo,
        State.PAUSED_VIDEO, this::handlePausedVideo,
        State.WATCHING_AD, this::handleWatchingAd,
        State.COMPLETED_VIDEO, state -> State.COMPLETED_VIDEO
    );

    public State handleEvent(VideoEvent videoEvent) {
        return viewerVideoStates.compute(videoEvent.viewerId(), (k, currentState) -> {
            if (currentState == null) {
                currentState = State.WATCHING_VIDEO;
            }
            return stateTransitions.get(currentState).apply(videoEvent.eventName());
        });
    }

    private State handleWatchingVideo(String event) {
        return switch (event) {
            case "pause_event" -> State.PAUSED_VIDEO;
            case "ad_break_start_event" -> State.WATCHING_AD;
            case "end_event" -> State.COMPLETED_VIDEO;
            case "ping_event" -> State.WATCHING_VIDEO;
            default -> State.WATCHING_VIDEO;
        };
    }

    private State handlePausedVideo(String event) {
        return "play_event".equals(event) ? State.WATCHING_VIDEO : State.PAUSED_VIDEO;
    }

    private State handleWatchingAd(String event) {
        return switch (event) {
            case "ad_break_end_event" -> State.WATCHING_VIDEO;
            case "end_event" -> State.COMPLETED_VIDEO;
            case "ping_event" -> State.WATCHING_AD;
            default -> State.WATCHING_AD;
        };
    }

    public State getCurrentState(String viewerId) {
        return viewerVideoStates.getOrDefault(viewerId, State.WATCHING_VIDEO);
    }

    public State getCurrentState(VideoEvent videoEvent) {
        return getCurrentState(videoEvent.viewerId());
    }
}
