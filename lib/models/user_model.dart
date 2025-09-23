class UserModel {
  final String uid; 
  final String name;
  final String email;
  final String? address;
  final String? gender;
  final String? phone;
  final String? photo; 
  final String role; // ['admin', 'owner', 'user']

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.address,
    this.gender,
    this.phone,
    this.photo,
    required this.role,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      address: map['address'] ?? '',
      gender: map['gender'] ?? '',
      phone: map['phone'] ?? '',
      photo: map['photo'] ?? '',
      role: map['role'] ?? 'user',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'address': address,
      'gender': gender,
      'phone': phone,
      'photo': photo,
      'role': role,
    };
  }
}