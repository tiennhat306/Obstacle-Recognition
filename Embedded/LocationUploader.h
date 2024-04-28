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
    httpClient->begin(UPLOAD_ENDPOINT + DEVICE_KEY);
    httpClient->addHeader("Content-Type", "application/json");
    
    String requestBody = "{ \"latitude\": " + String(lat) + ", \"longitude\": " + String(lng) + "}";

    // PUT the request
    int responseCode = httpClient->PUT(requestBody);
    http.end();
    
    if (httpResponseCode > 0) {
      return true;
    }
    
    Serial.print("Error on LocationUploader request: ");
    Serial.println(httpResponseCode);
    return false;
  }
};

#endif
