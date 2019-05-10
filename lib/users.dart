import 'package:firebase_database/firebase_database.dart';

class Users {
  String key;
  String username;
  String phone;
  String email;
  String userId;

  Users(this.username, this.phone, this.email, this.userId);

  Users.fromSnapshot(DataSnapshot snapshot) :
        key = snapshot.key,
        userId = snapshot.value["userId"],
        username = snapshot.value["username"],
        email = snapshot.value["email"],
        phone = snapshot.value["phone"];



  toJson() {
    return {
      "userId": userId,
      "username": username,
      "phone": phone,
      "email": email,
    };
  }
}