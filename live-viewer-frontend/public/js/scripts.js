const connectionUrl = "ws://localhost:8180/ws"
const connectionTestInterval = 2000
const messageBox = document.getElementById("message-box")
const messageCountSpan = document.getElementById("message-count")
const viewerCountSpan = document.getElementById("viewer-count")
const viewerIdColors = {}
const colorPalette = [
    '#6AE9F4', '#DCC3F6', '#FEC0B1', '#FD5F37', "#FFB6C1",
    "#FFD700", "#87CEFA", "#90EE90", "#FFA07A", "#9370DB",
]

const h1Title = document.querySelector(".container .header h1")
h1Title.textContent = document.title

let openStatusReported = false
let closeStatusReported = false
let messageCount = 0
let currentColorIndex = 0
let reconnectTimer

function getColorForViewerId(viewerId) {
    if (!viewerIdColors[viewerId]) {
        viewerIdColors[viewerId] = colorPalette[currentColorIndex]
        currentColorIndex = (currentColorIndex + 1) % colorPalette.length
        updateViewerCount()
    }
    return viewerIdColors[viewerId]
}

function updateViewerCount() {
    viewerCountSpan.textContent = Object
      .keys(viewerIdColors)
      .filter(key => key != 'systemMsg')
      .length
}

function filteredMessageData({ viewer_id, status, adId, video_ts, adsClicked, adsSkipped }) {
    return { viewer_id, status, adId, video_ts, adsClicked, adsSkipped };
}

function addMessageBox(event, textContent) {
    const messageData = textContent || JSON.parse(event.data)
    messageCount++
    messageCountSpan.textContent = messageCount

    const messageElement = document.createElement("div")
    messageElement.className = "message"
    messageElement.style.backgroundColor = getColorForViewerId(
        messageData.viewer_id || 'systemMsg')

    const titleElement = document.createElement("div")
    titleElement.className = "message-title"
    titleElement.textContent = `Message #${messageCount}`

    const contentElement = document.createElement("div")
    contentElement.className = "message-content"
    contentElement.textContent = textContent || JSON.stringify(
      filteredMessageData(messageData), null, 2)

    messageElement.appendChild(titleElement)
    messageElement.appendChild(contentElement)

    messageBox.insertBefore(messageElement, messageBox.firstChild)
}

function wsOnMessage(event) {
    addMessageBox(event)
}

function wsOnOpen(event) {
    if (!openStatusReported) {
        addMessageBox(null, `WebSocket connection is up! 😃`)
        openStatusReported = true
    }
    closeStatusReported = false
}

function wsOnClose() {
    if (!closeStatusReported) {
        addMessageBox(null, `WebSocket connection is down! 😢`)
        closeStatusReported = true
    }
    openStatusReported = false
    tryToReconnect()
}

function wsOnError(error) {
    addMesssageBox(null, `WebSocket error: ${error}`)
    //tryToReconnect()
}

function tryToReconnect() {
    clearTimeout(reconnectTimer)
    reconnectTimer = setTimeout(() => {
        setWsHandlers(new WebSocket(connectionUrl))
        console.log(`Trying to reconnect with ${connectionUrl} in ${connectionTestInterval} ms ...`)
    }, connectionTestInterval)
}

function setWsHandlers(ws) {
    ws.onmessage = wsOnMessage
    ws.onopen = wsOnOpen
    ws.onclose = wsOnClose
    ws.onError = wsOnError
}

setWsHandlers(new WebSocket(connectionUrl))
