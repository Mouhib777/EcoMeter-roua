import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:roua_benamor/screens/splashScreen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
    return Scaffold(body: Center(child: Text("Unexpected error.")));
  };
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: splashScreen(),
    );
  }
}
