#include "Wifi.h"

unsigned int Wifi::wifiMode = WIFI_MODE_STA;  // WIFI_MODE_AP, WIFI_MODE_STA
String Wifi::localPassword = DEFAULT_LOCAL_PASSWORD;

// Configuration file name
const char* Wifi::PUBLIC_WIFI_CONF_FILE = "/public-wifi-config.txt";
const char* Wifi::LOCAL_WIFI_CONF_FILE = "/local-wifi-config.txt";

// Station config
const char* Wifi::DEFAULT_SSID = "5 AE Siêu Nhân";
const char* Wifi::DEFAULT_PASSWORD = "0364651600";

// Access Point config
const char* Wifi::LOCAL_SSID = "Obstacle Recognizer";
const char* Wifi::DEFAULT_LOCAL_PASSWORD = "12345678";
