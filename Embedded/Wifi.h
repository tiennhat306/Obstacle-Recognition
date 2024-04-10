#include <WiFi.h>

class Wifi
{
public:
  static bool connectWifi(int timeoutInMilis = 10000) {
    unsigned long timeStone = millis();
  
    // Try reading wifi config file to get ssid and password
    String ssid, password;
    if (getWifiCredential(ssid, password)) {
      Serial.print("Connecting to WiFi");
    } else {
      Serial.print("Try connecting wifi by using default credentials");
    }
    
    WiFi.begin(ssid, password);
    while (WiFi.status() != WL_CONNECTED) {
      if (millis() - timeStone > timeoutInMilis) 
        return false;
      
      Serial.print(".");
      delay(1000);
    }
    Serial.println();
  
    wifiMode = WIFI_MODE_STA;
    return true;
  }
  static bool initAccessPointMode() {
    // Khởi tạo ESP32 trong chế độ AP
    if (!WiFi.softAP(localSsid, localPassword)) return false;
  
    // Cấu hình địa chỉ IP của Access Point (tùy chọn)
    IPAddress ip(192, 168, 1, 1);
    IPAddress gateway(192, 168, 1, 1);
    IPAddress subnet(255, 255, 255, 0);
    if (!WiFi.softAPConfig(ip, gateway, subnet)) return false;
  
    wifiMode = WIFI_MODE_AP;
    
    return true;
  }
  bool connectWifi(int timeoutInMilis = 10000) {
    unsigned long timeStone = millis();
  
    // Try reading wifi config file to get ssid and password
    String ssid, password;
    if (getWifiCredential(ssid, password)) {
      Serial.print("Connecting to WiFi");
    } else {
      Serial.print("Try connecting wifi by using default credentials");
    }
    
    WiFi.begin(ssid, password);
    while (WiFi.status() != WL_CONNECTED) {
      if (millis() - timeStone > timeoutInMilis) 
        return false;
      
      Serial.print(".");
      delay(1000);
    }
    Serial.println();
  
    wifiMode = WIFI_MODE_STA;
    return true;
  }
  bool getWifiCredential(String& ssid, String& password) {
    // Read file config to get ssid and password
    String jsonStr = FileOperation::readFile(PUBLIC_WIFI_CONF_FILE);
    JsonDocument doc;
    DeserializationError error = deserializeJson(doc, jsonStr);
  
    if (jsonStr == "" || error) {
      Serial.print("ConnectWifi(): deserializeJson() failed - ");
      Serial.println(error.c_str());
  
      ssid = DEFAULT_SSID;
      password = DEFAULT_PASSWORD;
      return false;
    } 
    
    ssid = doc["name"].as<String>();
    password = doc["password"].as<String>();
    return true;
  }
}
