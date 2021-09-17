import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_liguey/screens/home.dart';
import 'package:flutter_liguey/screens/login.dart';
import 'package:flutter_liguey/services/auth_services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(
          create: (_) => AuthService(FirebaseAuth.instance),
        ),
        StreamProvider(
          create: (context) => context.read<AuthService>().authStateChanges, initialData:null,
        ),
      ],
      child: MaterialApp(
        title: "APP",
        home: AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    final user = context.watch<User>();

    if(user != null){
      return Home();
    }else {
      return Login();
    }
  }
}
