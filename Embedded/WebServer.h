#include <ArduinoJson.h>
#include "SPIFFS.h"
#include "ESPAsyncWebServer.h"

class WebServer
{
  private:
    // Create AsyncWebServer object on port 80
    AsyncWebServer server;

    // Create a WebSocket object
    AsyncWebSocket ws;

    void printRequestInfo(AsyncWebServerRequest *request) {
      Serial.printf("%s %s\n", request->methodToString(), request->url());
      
      // List all collected headers
      int headers = request->headers();
      for(int i=0; i < headers; i++){
        AsyncWebHeader* h = request->getHeader(i);
        Serial.printf("%s: %s\n", h->name().c_str(), h->value().c_str());
      }
      Serial.println();
    }

    void websocketEventHandler(AsyncWebSocket *server, AsyncWebSocketClient *client, AwsEventType type, void *arg, uint8_t *data, size_t len) {
      switch (type) {
        case WS_EVT_CONNECT:
          Serial.printf("WebSocket client #%u connected from %s\n", client->id(), client->remoteIP().toString().c_str());
          break;
        case WS_EVT_DISCONNECT:
          Serial.printf("WebSocket client #%u disconnected\n", client->id());
          break;
        case WS_EVT_DATA:
            handleWebSocketMessage(client->id(), arg, data, len);
            break;
        case WS_EVT_PONG:
        case WS_EVT_ERROR:
         break;
      }
    }

    void handleWebSocketMessage(uint32_t clientId, void *arg, uint8_t *data, size_t len) {
      AwsFrameInfo *info = (AwsFrameInfo*)arg;
      if (info->final && info->index == 0 && info->len == len && info->opcode == WS_TEXT) {
        data[len] = 0;
        String message = (char*)data;
        Serial.println(message);
    
        if (message == "GET IMG") {
          // Capture and send image to client
          camera_fb_t* fb = esp_camera_fb_get();
          if (!fb) {
            ws.text(clientId, "Error: failed to capture the image!");
          } else {
            ws.binary(clientId, fb->buf, fb->len);
          }
    
          esp_camera_fb_return(fb);
        }
      }
    }

    WebServer() : server(80), ws("/ws") {
      
    }
    static WebServer _instance;
  public:
    static void start() {
      _instance.startWebServer();
      _instance.startWebSocket();
    }
    
    void startWebServer() {
      // CORS config
      DefaultHeaders::Instance().addHeader("Access-Control-Allow-Origin", "*");
      server.onNotFound([&](AsyncWebServerRequest *request) {
        printRequestInfo(request);
        if (request->method() == HTTP_OPTIONS) {
          request->send(200);
        } else {
          request->send(404);
        }
      });
      
      server.on("/", HTTP_GET, [&](AsyncWebServerRequest *request){
        printRequestInfo(request);
        request->send(SPIFFS, "/index.html", "text/html");
      });
    
      server.on("/wifi-info", HTTP_GET, [&](AsyncWebServerRequest *request){
        printRequestInfo(request);
        
        AsyncResponseStream *response = request->beginResponseStream("application/json");
        
        JsonDocument wifiInfo;
        String name = "";
        if (wifiMode & WIFI_MODE_STA) {
          name = WiFi.SSID();
        } else {
          name = WiFi.softAPSSID();
        }
        wifiInfo["name"] = name;
    
        serializeJson(wifiInfo, *response);
        request->send(response);
      });
    
      server.serveStatic("/", SPIFFS, "/");
      
      server.begin();
    }

    void startWebSocket() {
      ws.onEvent(websocketEventHandler);
      server.addHandler(&ws);
    }
};
