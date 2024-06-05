#ifndef IMAGE_RECOGNIZER
#define IMAGE_RECOGNIZER

#include <WebSocketsClient.h>

class ImageRecognizer
{
private:
  WebSocketsClient webSocket;
  
  // Handler when receiving data from server
  void (*handlerData)(String) = NULL;
  
  void onWebSocketEvent(WStype_t type, uint8_t* payload, size_t length) {
    if (type == WStype_DISCONNECTED) {
      Serial.println("WebSocket client disconnected");
    } else if (type == WStype_CONNECTED) {
      Serial.println("WebSocket client connected");
    } else if (type == WStype_TEXT) {
      Serial.print("Received data from WebSocket server: ");
      String data = String((char*)payload);
      Serial.println(data);

      // Call handler
      if (handlerData != NULL) {
        handlerData(data);
      }
    }
  }
public:
  void begin(String websocketServerAddress, int port) {
    webSocket.begin(websocketServerAddress, port);
    webSocket.onEvent([this] (WStype_t type, uint8_t * payload, size_t length) {
      this->onWebSocketEvent(type, payload, length);
    });

    // try ever 5000 again if connection has failed
    webSocket.setReconnectInterval(5000);
  }

  void addHandler(void (*handler)(String)) {
    handlerData = handler;
  }

  bool sendImage(camera_fb_t* fb) {
    return webSocket.sendBIN(fb->buf, fb->len);
  }

  void loop() {
    // Xử lý các sự kiện WebSocket
    webSocket.loop();
  }
};

#endif
