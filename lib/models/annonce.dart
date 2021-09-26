import 'package:firebase_database/firebase_database.dart';

class AnnonceModel {
  double annonceEnd;
  String annonceLink;
  double annonceOrder;
  String annonceText;
  double annonceTime;
  String annonceType;
  String day;
  String descMessage;
  String email;
  String id;
  double lat;
  double lng;
  String name;
  String phone;
  String r_mail;
  String r_phone;
  double rate;
  String sector;

  AnnonceModel(this.name,this.email,this.annonceEnd,this.annonceLink,this.annonceOrder,this.annonceText,this.annonceTime,this.annonceType,this.day,this.descMessage,this.id,this.lat,this.lng,this.phone,this.r_mail,this.r_phone,this.rate,this.sector);

  AnnonceModel.fromSnapshot(DataSnapshot snapshot):
        id= snapshot.value["id"],
        name = snapshot.value["name"],
        email= snapshot.value["email"],
        phone= snapshot.value["phone"],
        annonceType= snapshot.value["annonceType"],
        annonceTime= snapshot.value["annonceTime"],
        annonceText= snapshot.value["annonceText"],
        annonceOrder= snapshot.value["annonceOrder"],
        annonceLink= snapshot.value["annonceLink"],
        annonceEnd= snapshot.value["annonceEnd"],
        descMessage= snapshot.value["descMessage"],
        day= snapshot.value["day"],
        lat= snapshot.value["lat"],
        lng= snapshot.value["lng"],
        r_phone= snapshot.value["r_phone"],
        r_mail= snapshot.value["r_mail"],
        rate= snapshot.value["rate"],
        sector= snapshot.value["sector"];

  toJson() {
    return {
      "name": name,
      "annonceEnd": annonceEnd,
      "annonceLink": annonceLink,
      "annonceOrder": annonceOrder,
      "annonceText": annonceText,
      "annonceTime": annonceTime,
      "annonceType": annonceType,
      "day": day,
      "descMessage": descMessage,
      "email": email,
      "id": id,
      "lat": lat,
      "lng": lng,
      "phone": phone,
      "r_mail": r_mail,
      "r_phone": r_phone,
      "rate": rate,
      "sector": sector,
    };
  }
}