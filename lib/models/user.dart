
class UserModel {
  UserModel.fromMap(Map<String, dynamic> map) {
    name = map['name']?.cast<String>();
    email = map['email']?.cast<String>();
    credit = map['credit']?.cast<double>();
  }

  UserModel();

  String? name;
  String? email;
  double? credit;

  @override
  String toString() {
    return 'UserModel{name: $name, email: $email, credit: $credit}';
  }
}