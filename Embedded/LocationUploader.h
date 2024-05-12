#include "HardwareSerial.h"
#ifndef LOCATION_UPLOADER
#define LOCATION_UPLOADER

#define UPLOAD_ENDPOINT "https://us-central1-visionaid-dut210.cloudfunctions.net/app/api/update-location/"
#define DEVICE_KEY "Device1234"

#include <HTTPClient.h>

class LocationUploader
{
private:
  
public:
  static bool upload(double lat, double lng) {
    // Create the request
    HTTPClient httpClient;
    httpClient.begin(String(UPLOAD_ENDPOINT) + String(DEVICE_KEY));
    httpClient.addHeader("Content-Type", "application/json");

    String requestBody = String("{ \"latitude\": ") + String(lat,6) + ", \"longitude\": " + String(lng,6) + "}";
    Serial.print("Send GPS");
    Serial.println(requestBody);
    // PUT the request
    int responseCode = httpClient.PUT(requestBody);
    httpClient.end();
    
    if (responseCode > 0) {
      return true;
    }
    
    Serial.print("Error on LocationUploader request: ");
    Serial.println(responseCode);
    return false;
  }
};

#endif
