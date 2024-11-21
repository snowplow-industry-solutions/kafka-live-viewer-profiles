package com.snowplowanalytics.liveviewerprofile.service;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.Mockito.ignoreStubs;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import com.snowplowanalytics.liveviewerprofile.model.VideoEvent;

public class VideoStateMachineTest {

    private VideoStateMachine machine;
    private String viewerId = "viewer123";

    @BeforeEach
    public void setUp() {
        machine = new VideoStateMachine();
    }

    private VideoEvent videoEvent(String eventName) {
        return new VideoEvent(0, null, null, eventName, viewerId, 0, 0, 0, null);
    }

    @Test
    public void testInitialState() {
        assertEquals(VideoStateMachine.State.WATCHING_VIDEO, machine.getCurrentState(viewerId));
    }

    @Test
    public void testPauseEvent() {
        machine.handleEvent(videoEvent("pause_event"));
        assertEquals(VideoStateMachine.State.PAUSED_VIDEO, machine.getCurrentState(viewerId));
    }

    @Test
    public void testPlayEventFromPaused() {
        machine.handleEvent(videoEvent("pause_event"));
        machine.handleEvent(videoEvent("play_event"));
        assertEquals(VideoStateMachine.State.WATCHING_VIDEO, machine.getCurrentState(viewerId));
    }

    @Test
    public void testAdBreakStartEvent() {
        machine.handleEvent(videoEvent("ad_break_start_event"));
        assertEquals(VideoStateMachine.State.WATCHING_AD, machine.getCurrentState(viewerId));
    }

    @Test
    public void testAdBreakEndEvent() {
        machine.handleEvent(videoEvent("ad_break_start_event"));
        machine.handleEvent(videoEvent("ad_break_end_event"));
        assertEquals(VideoStateMachine.State.WATCHING_VIDEO, machine.getCurrentState(viewerId));
    }

    @Test
    public void testEndEventFromWatchingVideo() {
        machine.handleEvent(videoEvent("end_event"));
        assertEquals(VideoStateMachine.State.COMPLETED_VIDEO, machine.getCurrentState(viewerId));
    }

    @Test
    public void testEndEventFromWatchingAd() {
        machine.handleEvent(videoEvent("ad_break_start_event"));
        machine.handleEvent(videoEvent("end_event"));
        assertEquals(VideoStateMachine.State.COMPLETED_VIDEO, machine.getCurrentState(viewerId));
    }

    @Test
    public void testPingEventInWatchingVideo() {
        machine.handleEvent(videoEvent("ping_event"));
        assertEquals(VideoStateMachine.State.WATCHING_VIDEO, machine.getCurrentState(viewerId));
    }

    @Test
    public void testPingEventInWatchingAd() {
        machine.handleEvent(videoEvent("ad_break_start_event"));
        machine.handleEvent(videoEvent("ping_event"));
        assertEquals(VideoStateMachine.State.WATCHING_AD, machine.getCurrentState(viewerId));
    }

    @Test
    public void testPingEventDoesNotAffectPausedVideo() {
        machine.handleEvent(videoEvent("pause_event"));
        machine.handleEvent(videoEvent("ping_event"));
        assertEquals(VideoStateMachine.State.PAUSED_VIDEO, machine.getCurrentState(viewerId));
    }

    @Test
    public void testPingEventDoesNotAffectCompletedVideo() {
        machine.handleEvent(videoEvent("end_event"));
        machine.handleEvent(videoEvent("ping_event"));
        assertEquals(VideoStateMachine.State.COMPLETED_VIDEO, machine.getCurrentState(viewerId));
    }
}
