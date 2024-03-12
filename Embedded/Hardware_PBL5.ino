#define CAMERA_MODEL_AI_THINKER
#include "esp_camera.h"
#include <WiFi.h>
#include <HTTPClient.h>
#include "camera_pins.h"
#include "Arduino.h"
#include <ArduinoJson.h>

#define LED_BUILTIN 33
#define SOUND_VELOCITY 0.034 // 0.034cm/us

// http://localhost:8000/detect
const char* ssid = "TUHOC_KHU_A";
const char* password = "";
const String apiEndpoint = "http://10.10.3.59:8000/detect/";

// Pins for ultrasonic sensor
const int trigPin = 12; // PWM trigger
const int echoPin = 13; // PWM Output 0-25000US, Every 50US represent 1cm

void startCameraServer();
void setupLedFlash(int pin);

void initCamera() {
  // Stores the camera configuration parameters
  camera_config_t config;
  config.ledc_channel = LEDC_CHANNEL_0;
  config.ledc_timer = LEDC_TIMER_0;
  config.pin_d0 = Y2_GPIO_NUM;
  config.pin_d1 = Y3_GPIO_NUM;
  config.pin_d2 = Y4_GPIO_NUM;
  config.pin_d3 = Y5_GPIO_NUM;
  config.pin_d4 = Y6_GPIO_NUM;
  config.pin_d5 = Y7_GPIO_NUM;
  config.pin_d6 = Y8_GPIO_NUM;
  config.pin_d7 = Y9_GPIO_NUM;
  config.pin_xclk = XCLK_GPIO_NUM;
  config.pin_pclk = PCLK_GPIO_NUM;
  config.pin_vsync = VSYNC_GPIO_NUM;
  config.pin_href = HREF_GPIO_NUM;
  config.pin_sscb_sda = SIOD_GPIO_NUM;
  config.pin_sscb_scl = SIOC_GPIO_NUM;
  config.pin_pwdn = PWDN_GPIO_NUM;
  config.pin_reset = RESET_GPIO_NUM;
  config.xclk_freq_hz = 10000000;
  config.pixel_format = PIXFORMAT_JPEG; //YUV422,GRAYSCALE,RGB565,JPEG

  // Select lower framesize if the camera doesn't support PSRAM
  config.frame_size = FRAMESIZE_QVGA; //FRAMESIZE_ + QVGA|CIF|VGA|SVGA|XGA|SXGA|UXGA
  if(psramFound()){
    config.jpeg_quality = 15; //0-63 lower number means higher quality
    config.fb_count = 2;
  } else {
    config.jpeg_quality = 20;
    config.fb_count = 1;
  }

  // Initialize the Camera
  esp_err_t err = esp_camera_init(&config);
  if (err != ESP_OK) {
    Serial.printf("Camera init failed with error 0x%x", err);
    return;
  }
}

bool connectWifi(int timeoutInMilis = 15000) {
  unsigned long timeStone = millis();
  // Connect to Wi-Fi
  Serial.print("Connecting to WiFi");
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    if (millis() - timeStone > timeoutInMilis) 
      return false;
    
    Serial.print(".");
    delay(1000);
  }

  return true;
}

void showResult(String json){
  DynamicJsonDocument doc(1024);
  deserializeJson(doc, json);
  JsonObject data = doc["data"];

  for (JsonPair kv : data) {
    const char* obstacle = kv.key().c_str();
    unsigned quantity = kv.value().as<int>();

    Serial.print("Obstacle: ");
    Serial.print(obstacle);
    Serial.print(", quantity: ");
    Serial.println(quantity);
  }
}

// Post image fb to apiEndpoint via form-data with key "image"
int postHttpRequest(camera_fb_t* fb, const String* endpoint, HTTPClient* httpClient) {
  // Create the request
  httpClient->begin(*endpoint);
  httpClient->addHeader("Content-Type", "multipart/form-data; boundary=--------------------------697881354623426881025817");
  
  String requestBody = "";
  requestBody += "----------------------------697881354623426881025817\r\n";
  requestBody += "Content-Disposition: form-data; name=\"image\"; filename=\"image.jpg\"\r\n";
  requestBody += "Content-Type: image/jpeg\r\n\r\n";
  requestBody += String(reinterpret_cast<const char*>(fb->buf), fb->len);
  requestBody += "\r\n----------------------------697881354623426881025817--\r\n";

  // Send the POST request with the manually constructed request body
  int responseCode = httpClient->POST(requestBody);
  return responseCode;
}

int getDistanceFromObstacle() {
  //Clears the trigPin
  digitalWrite(trigPin, LOW); 
  delayMicroseconds (2);
  // Sets the trigPin on HIGH state for 10 micro seconds
  digitalWrite(trigPin, HIGH);
  delayMicroseconds (10);
  digitalWrite(trigPin, LOW);

  // Reads the echoPin, returns the sound wave travel time in microseconds
  unsigned long duration= pulseIn(echoPin, HIGH); // us
  // Calculating the distance
  float distance = duration * SOUND_VELOCITY / 2; 

  return distance;
}

void recognizeObstacle() {
  // Capture the image
  Serial.println("Capturing image");
  camera_fb_t* fb = esp_camera_fb_get();
  if (!fb) {
    Serial.println("Camera capture failed");
    delay(1000);
    return;
  }

  // Upload the captured image to the web server
  if (WiFi.status() == WL_CONNECTED) {
    Serial.println("Sending request to server");

    HTTPClient httpClient;
    int responseCode = postHttpRequest(fb, &apiEndpoint, &httpClient);
    
    if (responseCode > 0) {
      String jsonResponse = httpClient.getString();
      Serial.print("Image upload successful, server response: ");
      Serial.println(jsonResponse);
      showResult(jsonResponse);
    } else {
      Serial.print("Image upload failed, error code: ");
      Serial.println(responseCode);
      Serial.print("Details: ");
      Serial.println(httpClient.errorToString(responseCode));
    }

    httpClient.end();
  } else {
    Serial.println("WiFi not connected, image upload skipped");
  }
  esp_camera_fb_return(fb);
}

void setup() {
  Serial.begin(115200);

  // Turn on the built-in LED
  pinMode(LED_BUILTIN, OUTPUT);
  digitalWrite(LED_BUILTIN, LOW);

  // Set pin mode for ultrasonic sensor
  pinMode(trigPin, OUTPUT);
  pinMode(echoPin, INPUT);

  // Connect wifi
  if (!connectWifi()) {
    Serial.println("Wifi connection timeout!");
  } else {
    Serial.println("Wifi connected");
  }
  // Set up camera
  initCamera();

// Setup LED FLash (pin 4)
  setupLedFlash(LED_GPIO_NUM);

  startCameraServer();
  Serial.print("Camera Ready! Use 'http://");
  Serial.print(WiFi.localIP());
  Serial.println("' to connect");
}

void loop() {
  int disFromObs = getDistanceFromObstacle();
  Serial.print("Distance from obstacle : ");
  Serial.print(disFromObs);
  Serial.println(" (cm)");

  if (disFromObs < 100) {
    Serial.println("Start recognization");
    recognizeObstacle();
    delay(2000);
  }

  delay(20);
}



