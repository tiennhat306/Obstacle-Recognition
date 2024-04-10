//#include "Arduino.h"
// #include "SoftwareSerial.h"
#include "DFRobotDFPlayerMini.h"
#include "AudioPlayer.h"  
AudioPlayer audioPlayer(14,15); // RX, TX 

void setup()
{
  Serial.begin(115200);  
}

void loop()
{
  audioPlayer.playFromServer("1_1_2");
  delay(4000);
}

/* Code chay duoc
#include "DFRobotDFPlayerMini.h"
#include "AudioPlayer.h"   
SoftwareSerial mySerial(14,15);
DFRobotDFPlayerMini player; 

void setup()
{
  Serial.begin(115200);  
  mySerial.begin(9600);  
  player.begin(mySerial); 
  player.volume(30);  
  Serial.println("OK");    
}

void loop()
{
  String response = "2_1_3000";
  int firstSplit = response.indexOf('_');
  int secondSplit = response.indexOf('_', firstSplit + 1);

  int number = response.substring(0, firstSplit).toInt();
  int object = response.substring(firstSplit + 1, secondSplit).toInt();
  int length = response.substring(secondSplit + 1).toInt();
  Serial.println(number);
  Serial.println(object);
  Serial.println(length);

  player.playFolder(1, number);
  delay(2500);
  player.playFolder(2, object);
  delay(length); 
}


*/ 

