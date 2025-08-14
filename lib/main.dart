import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:new01/pages/splashscreen.dart';
import 'package:new01/pages/theme_provider.dart';
import 'package:new01/pages/ui/home_page.dart';
import 'package:provider/provider.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase

  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => LevelUnlockProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Speakease',
      debugShowCheckedModeBanner: false,
      home:  SplashScreen(), // Start with SplashScreen
    );
  }
}

class GetStorage {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late bool isLogin = false;
  late String username = 'null';

  Future<void> getStorage() async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc('user1').get();
      if (userDoc.exists) {
        isLogin = userDoc['isLogin'] ?? false;
        username = userDoc['username'] ?? 'null';
      }
    } catch (e) {
      print("Error fetching Firestore data: $e");
    }
  }
}

final GetStorage storeClass=GetStorage();
