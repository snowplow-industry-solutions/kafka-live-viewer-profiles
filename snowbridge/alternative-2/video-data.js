function main(input) {
  const spData = input.Data

  const defaultValues = {
    adsSkipped: 0,
    adsClicked: 0,
    contentWatched: 0,
    adId: 0,
    currentTime: 0,
    paused: null,
    ended: null,
  }

  const {
    event_id,
    event_name,
    collector_tstamp
  } = spData

  const user_id = spData.user_id || spData.domain_userid || 'PoC user'

  const {
    contentWatched = defaultValues.contentWatched,
    adsClicked = defaultValues.adsClicked,
    adsSkipped = defaultValues.adsSkipped,
  } = spData.contexts_com_snowplowanalytics_snowplow_media_session_1?.[0] || {}

  const {
    adId = defaultValues.adId,
  } = spData.contexts_com_snowplowanalytics_snowplow_media_ad_1?.[0] || {}

  const {
    currentTime = defaultValues.currentTime,
    paused = defaultValues.paused,
    ended = defaultValues.ended,
  } = spData.contexts_com_snowplowanalytics_snowplow_media_player_2?.[0] || {}
  
  return {
    Data: {
      collector_tstamp,
      event_id,
      event_name,
      viewer_id: user_id,    
      adsClicked,
      adsSkipped,
      adId,
      video_ts: currentTime,
    }
  }
}
