import 'package:flutter/material.dart';
import 'package:jfu_movecare_wearos/views/LoginScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Flutter Wear App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.compact,
          useMaterial3: true,
        ),
        home: LoginScreen(),
        debugShowCheckedModeBanner: false,
      );
}
