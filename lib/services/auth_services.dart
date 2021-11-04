import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth;

  AuthService(this._auth);

  final databaseRef = FirebaseDatabase.instance.reference();
  final Future<FirebaseApp> _future = Firebase.initializeApp();

  Stream<User?> get authStateChanges => _auth.idTokenChanges();

  Future<String?> login(String email, String password) async {
    try{
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return "Logged In";
    } catch(e) {
    }
  }

  Future<String?> register(String email, String password, String name, String surname, String phone, double credit, DateTime date) async {
    try{
      await _auth.createUserWithEmailAndPassword(email: email, password: password).then((value) async {
        User? user = FirebaseAuth.instance.currentUser;
        String Uid = user!.uid;
        databaseRef.child("Users").child(Uid).set({"userCredit":credit, "userEmail":email,"userID":Uid,"userLat":1000,"userLng":1000,"userName":name +" "+ surname,"userPhone":phone}).whenComplete(() =>  _success());
      });
      return "Signed Up";
    } catch(e) {}
  }

  Future signOut() async{
    try{
      return await _auth.signOut();
    }catch(e){}
  }

  void _success() async {
  }

  Future<String?> send(
    String name, int end, String annonceLink, String annonceText, String annonceType,
    String date, String description, String email, String id, double lat, double lng, String phone, String r_mail,
    String r_phone, double rate, String sector) async {
    int time = new DateTime.now().millisecondsSinceEpoch;

    try{
      await databaseRef.child("Test").push().set({
        "name": name,
        "annonceEnd": end,
        "annonceLink": annonceLink,
        "annonceOrder": -time,
        "annonceText": annonceText,
        "annonceTime": time,
        "annonceType": annonceType,
        "day": date,
        "descMessage": description,
        "email": email,
        "id": id,
        "lat": lat,
        "lng": lng,
        "phone": phone,
        "r_mail": r_mail,
        "r_phone": r_phone,
        "rate": rate,
        "sector": sector,
      }).whenComplete(() =>  _success());
      return "Sent";
    } catch(e) {}
  }
}