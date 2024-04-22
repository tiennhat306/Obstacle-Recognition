#ifndef GPS_READER
#define GPS_READER

#include <TinyGPSPlus.h>
#include <SoftwareSerial.h> 
class GpsReader{
  private:
    TinyGPSPlus gps; 
    SoftwareSerial gpsSerial;
  public:
    GpsReader(int RX, int TX): gpsSerial(RX,TX){
      gpsSerial.begin(9600);  
    } 
    bool getLocation(double &_lat, double &_long){
      while (gpsSerial.available()>0) {
        gps.encode(gpsSerial.read());  
      }
      if(gps.location.isUpdated()){
          _lat = gps.location.lat();
          _long = gps.location.lng();
          return true;
      }
      return false;
    } 
};
#endif
