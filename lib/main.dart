import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'models/record_provider.dart';
import 'screens/welcome_page.dart';
import 'screens/auth_screen.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RecordProvider()..loadRecords()),
        Provider<AuthService>(create: (_) => AuthService()),
      ],
      child: MaterialApp(
        title: 'Diabetes Tracker',
        theme: ThemeData(
          primaryColor: Colors.purple,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
          scaffoldBackgroundColor: Colors.white,
          textTheme: TextTheme(
            titleLarge: TextStyle(color: Colors.purple, fontSize: 22, fontWeight: FontWeight.bold),
            bodyMedium: TextStyle(color: Colors.pink, fontSize: 16),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink,
              foregroundColor: Colors.white,
              textStyle: TextStyle(fontSize: 18),
            ),
          ),
        ),
        home: Builder(
          builder: (context) {
            return StreamBuilder(
              stream: Provider.of<AuthService>(context, listen: false).authStateChanges,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasData) {
              return WelcomePage();
            }
            return AuthScreen();
          },
    );
          },
        ),
      ),
    );
  }
}
