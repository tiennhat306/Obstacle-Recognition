#include "SPIFFS.h"

class FileOperation
{
public:
  static void listDir(const char * dirname, uint8_t levels){
    Serial.printf("Listing directory: %s\r\n", dirname);

    File root = SPIFFS.open(dirname);
    if(!root){
        Serial.println("- failed to open directory");
        return;
    }
    if(!root.isDirectory()){
        Serial.println(" - not a directory");
        return;
    }

    File file = root.openNextFile();
    while(file){
      if(file.isDirectory()){
          Serial.print("  DIR : ");
          Serial.println(file.name());
          if(levels){
              listDir(file.path(), levels - 1);
          }
      } else {
          Serial.print("  FILE: ");
          Serial.print(file.name());
          Serial.print("\tSIZE: ");
          Serial.println(file.size());
      }
      file = root.openNextFile();
    }
  }

  static void readFileToSerial(const char * path){
    Serial.printf("Reading file: %s\r\n", path);

    File file = SPIFFS.open(path);
    if(!file || file.isDirectory()){
        Serial.println("- failed to open file for reading");
        return;
    }

    Serial.println("- read from file:");
    while(file.available()){
        Serial.write(file.read());
    }
    file.close();
  }

  static String readFile(const char *path) {
    // Đọc nội dung từ tệp và trả về dưới dạng String
    File file = SPIFFS.open(path, "r");
    if (!file) {
        Serial.printf("Failed to open file \"%s\" for reading", path);
        return "";
    }

    String content = file.readString();
    file.close();
    return content;
  }

  static void writeFile(const char * path, const char * message){
      Serial.printf("Writing file: %s\r\n", path);
  
      File file = SPIFFS.open(path, FILE_WRITE);
      if(!file){
          Serial.println("- failed to open file for writing");
          return;
      }
      if(file.print(message)){
          Serial.println("- file written");
      } else {
          Serial.println("- write failed");
      }
      file.close();
  }

  void deleteFile(const char * path){
    Serial.printf("Deleting file: %s\r\n", path);
    if(SPIFFS.remove(path)){
        Serial.println("- file deleted");
    } else {
        Serial.println("- delete failed");
    }
  }
};
