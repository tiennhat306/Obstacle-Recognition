import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vision_aid/domain/bloc/blocs.dart';
import 'package:vision_aid/presentation/screens/login/login_screen.dart';
import 'firebase_options.dart';

Future<void> _firebaseMessagingBackground( RemoteMessage message ) async {

  await Firebase.initializeApp();

}

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackground);
  runApp(MyApp());
}
 

 
class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.dark ));

    return MultiBlocProvider(
      providers: [ 
        BlocProvider(create: (context) => AuthBloc()),
        BlocProvider(create: (context) => GeneralBloc()),
        BlocProvider(create: (context) => UserBloc()),
        BlocProvider(create: (context) => MylocationmapBloc()),
        BlocProvider(create: (context) => DeviceBloc()),
        BlocProvider(create: (context) => MapdeliveryBloc()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Vision Aid',
        home: LoginScreen(),
      ),
    );
  }
}