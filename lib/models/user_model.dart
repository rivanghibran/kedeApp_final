class UserModel {
  final String uid;
  final String firstName;
  final String lastName;
  final String username;
  final String phone;
  final String address;

  UserModel({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.phone,
    required this.address,
  });

  Map<String, dynamic> toMap() {
    return {
      "firstName": firstName,
      "lastName": lastName,
      "username": username,
      "phone": phone,
      "address": address,
    };
  }

  factory UserModel.fromMap(String uid, Map<String, dynamic>? map) {
    map ??= {};
    return UserModel(
      uid: uid,
      firstName: map["firstName"] ?? "",
      lastName: map["lastName"] ?? "",
      username: map["username"] ?? "",
      phone: map["phone"] ?? "",
      address: map["address"] ?? "",
    );
  }
}
