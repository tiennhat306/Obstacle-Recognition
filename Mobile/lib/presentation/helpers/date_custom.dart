import 'package:intl/intl.dart';

class DateCustom {

  static String getDate(){

    int time = DateTime.now().hour;

    if( time < 12 ) return 'Chào Buổi Sáng';
    else if ( time  > 12 && time < 18 ) return 'Chào Buổi Chiều';
    else if( time < 24 && time > 18 ) return 'Chào buổi tối';
    else return 'Xin Chào!';
  }


  static String getDateOrder( String date ){

    
    var newStr = date.substring(0,10) + ' ' + date.substring(11,23);
   
    DateTime dt = DateTime.parse(newStr);
    return DateFormat("EEE, d MMM  yyyy HH:mm:ss").format(dt); 
    
  }


}
