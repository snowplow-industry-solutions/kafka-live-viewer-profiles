const ws = new WebSocket("ws://localhost:8180/ws");
const messageBox = document.getElementById("message-box");
const messageCountSpan = document.getElementById("message-count");
const viewerCountSpan = document.getElementById("viewer-count");

let messageCount = 0;
const viewerIdColors = {};
const colorPalette = [
    "#FFB6C1", "#FFD700", "#87CEFA", "#90EE90", "#FFA07A",
    "#9370DB", "#FF69B4", "#40E0D0", "#F08080", "#B0C4DE"
];
let currentColorIndex = 0;

function getColorForViewerId(viewerId) {
    if (!viewerIdColors[viewerId]) {
        viewerIdColors[viewerId] = colorPalette[currentColorIndex];
        currentColorIndex = (currentColorIndex + 1) % colorPalette.length;
        updateViewerCount();
    }
    return viewerIdColors[viewerId];
}

function updateViewerCount() {
    viewerCountSpan.textContent = Object.keys(viewerIdColors).length;
}

ws.onmessage = (event) => {
    const messageData = JSON.parse(event.data);
    messageCount++;
    messageCountSpan.textContent = messageCount;

    const messageElement = document.createElement("div");
    messageElement.className = "message";
    messageElement.style.backgroundColor = getColorForViewerId(messageData.viewer_id || "unknown");

    const titleElement = document.createElement("div");
    titleElement.className = "message-title";
    titleElement.textContent = `Message #${messageCount}`;

    const contentElement = document.createElement("div");
    contentElement.className = "message-content";
    contentElement.textContent = JSON.stringify(messageData, null, 2);

    messageElement.appendChild(titleElement);
    messageElement.appendChild(contentElement);

    messageBox.insertBefore(messageElement, messageBox.firstChild);
};

ws.onopen = () => {
    console.log("WebSocket connection opened");
};

ws.onclose = () => {
    console.log("WebSocket connection closed");
};

ws.onerror = (error) => {
    console.error("WebSocket error:", error);
};