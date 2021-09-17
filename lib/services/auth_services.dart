import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth;

  AuthService(this._auth);

  Stream<User ?> get authStateChanges => _auth.idTokenChanges();

  Future<String?> login(String email, String password) async {
    try{
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return "Logged In";
    } catch(e) {
    }
  }

  Future<String?> signUp(String email, String password) async {
    try{
      await _auth.createUserWithEmailAndPassword(email: email, password: password).then((value) async {
        User? user = FirebaseAuth.instance.currentUser;
/*
        await FirebaseFirestore.instance.collection("users").doc(user!.uid).set({
          'uid': user.uid,
          'email': email,
          'password': password,
        });
  */
      });
      return "Signed Up";
    } catch(e) {}
  }

  Future signOut() async{
    try{
      return await _auth.signOut();
    }catch(e){}
  }
}