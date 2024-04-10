// #include "SoftwareSerial.h"
// #include "DFRobotDFPlayerMini.h"

// class AudioPlayer
// {
//   private:
//     SoftwareSerial _softwareSerial;
//     DFRobotDFPlayerMini _DFPlayer;

//   public:
//     AudioPlayer(int rx, int tx) : _softwareSerial(rx, tx) {
//        _softwareSerial.begin(9600);
//     } 
//     void init(){
//       if (!_DFPlayer.begin(_softwareSerial)) return; 
//       // DFPlayer default settings
//       _DFPlayer.setTimeOut(500); //Set serial communictaion time out 500ms 
//       _DFPlayer.EQ(DFPLAYER_EQ_NORMAL); // Set different EQ
//       _DFPlayer.outputDevice(DFPLAYER_DEVICE_SD); // Set device we use SD as default 
//     }
//     void setVolume(int vol){
//       _DFPlayer.volume(vol);
//     }

//     void play(int index) {
//       _DFPlayer.play(index);
//     }

//     void pause() {
//       _DFPlayer.pause();
//     }
    
//     // Return the number of bytes available to read
//     int available() {
//       return _DFPlayer.available();
//     } 

    

//     String getState() {
//       int value = _DFPlayer.read();
//       switch (_DFPlayer.readType()) {
//         case TimeOut:
//           return "Time Out!";
//         case WrongStack:
//           return "Stack Wrong!";
//         case DFPlayerCardInserted:
//          return "Card Inserted!";
//         case DFPlayerCardRemoved:
//           return "Card Removed!";
//         case DFPlayerCardOnline:
//           return "Card Online!";
//         case DFPlayerPlayFinished:
//           return "Number: " + String(value) + " Play Finished!";
//         case DFPlayerError:
//           switch (value) {
//             case Busy:
//               return "Error Card not found";
//             case Sleeping:
//               return "Error: Sleeping";
//             case SerialWrongStack:
//               return"Error: Get Wrong Stack";
//             case CheckSumNotMatch:
//               return "Error: Check Sum Not Match";
//             case FileIndexOut:
//               return "Error: File Index Out of Bound";
//             case FileMismatch:
//               return "Error: Cannot Find File";
//             case Advertise:
//               return "Error: In Advertise";
//             default:
//               return "Error: Something went wrong!";
//           }
//           break;
//         default:
//           break;
//       }
//       return "";
//     }
// };
// #include "WString.h"
#include "SoftwareSerial.h"
#include "DFRobotDFPlayerMini.h"

class AudioPlayer
{
  private:
    SoftwareSerial _mySerial;
    DFRobotDFPlayerMini _player;
  public:
    AudioPlayer(int rx, int tx): _mySerial(rx,tx){
      _mySerial.begin(9600);  
      _player.begin(_mySerial); 
      _player.volume(30); 
    } 
    // void volume(int x){
    //   _player.volume(x);
    // }
    // void playFolder(int folder, int file){
    //   _player.playFolder(folder,file);
    // }
    void playFromServer(String response) {        //Number_Object_length
      int firstSplit = response.indexOf('_');
      int secondSplit = response.indexOf('_', firstSplit + 1);

      int number = response.substring(0, firstSplit).toInt();
      int object = response.substring(firstSplit + 1, secondSplit).toInt();
      int length = response.substring(secondSplit + 1).toInt();
      Serial.println("play number");
      _player.playFolder(1, number);
      delay(2500);
      Serial.println("play object");
      Serial.println(object);
      _player.playFolder(2, object);
      delay(length);
      Serial.println("end");
    }

};