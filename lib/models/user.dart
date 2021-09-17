
class UserModel {
  final String userId;
  final String displayName;
  final String email;

  UserModel({required this.email,this.displayName='',required this.userId});

  Map<String,dynamic> toMap(){
    return {
      'user_id' : userId,
      'display_name':displayName,
      'email':email,
    };
  }

  factory UserModel.fromJson(Map<String,dynamic> json){
     return UserModel(
        userId: json['user_id'],
        displayName: json['display_name'],
        email: json['email'],
    );
  }
}