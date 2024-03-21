let host = window.location.host;
let rootPath = `http://${host}`;
let gateway = `ws://${host}/ws`;
let websocket;

let streamIntervelID = null;

let imgStream = document.getElementById("stream");
let streamCtn = document.getElementById("stream-container");
let btnStream = document.getElementById("toggle-stream");


btnStream.addEventListener("click", (e) => {
    if (!websocket || websocket.readyState == WebSocket.CLOSED) {
        startStream();
    } else {
        if (websocket.readyState == WebSocket.OPEN) {
            stopStream();
        }
    }
});

function startStream() {
    initWebSocket();

    streamIntervelID = setInterval(() => {
        websocket.send('GI');
    }, 100);


    btnStream.textContent = "Stop Stream";
    streamCtn.classList.remove("hidden");
}

function stopStream() {
    websocket.close();
    clearInterval(streamIntervelID);

    btnStream.textContent = "Start Stream";
    streamCtn.classList.add("hidden");
}

document.getElementById("close-stream").addEventListener("click", (e) => {
    if (websocket.readyState == WebSocket.OPEN) {
        stopStream();
    }
});


function initWebSocket() {
    console.log('Trying to open a WebSocket connection…');
    websocket = new WebSocket(gateway);

    websocket.onopen = (e) => {
        console.log('Connection opened');
    };

    websocket.onclose = (e) => {
        console.log('Connection closed');
    };

    websocket.onmessage = onMessageWebSocket;
}

function onMessageWebSocket(event) {
    console.log("Receive data");
    console.log(event.data);
    console.log(typeof event.data);

    if (typeof event.data === 'object') {
        let blob = event.data;
        const imageUrl = URL.createObjectURL(blob, { type: 'image/jpeg' });
        imgStream.src = imageUrl;
    }
}




document.addEventListener("DOMContentLoaded", async (e) => {
    let response = await fetch(rootPath + "/wifi-info", { method: "GET" });
    let json = await response.json();

    console.log("GET /wifi-info");
    console.log(json);

    document.getElementById("wifi-name").textContent = json.name;
});