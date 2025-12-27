// models/user_model.dart
class User {
  final int id;
  final String email;
  final String? photo;
  final String firstName;
  final String? middleName;
  final String lastName;
  final String state;
  final String district;
  final String taluka;
  final String village;
  final String address;
  final String? landmark;
  final String pincode;
  final String contact;
  final String? altContact;

  User({
    required this.id,
    required this.email,
    this.photo,
    required this.firstName,
    this.middleName,
    required this.lastName,
    required this.state,
    required this.district,
    required this.taluka,
    required this.village,
    required this.address,
    this.landmark,
    required this.pincode,
    required this.contact,
    this.altContact,
  });

  String get fullName {
    final parts = [firstName];
    if (middleName != null && middleName!.isNotEmpty) parts.add(middleName!);
    parts.add(lastName);
    return parts.join(' ');
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int? ?? 0,
      email: json['user'] as String? ?? '',
      photo: json['photo'] as String?,
      firstName: json['first_name'] as String? ?? '',
      middleName: json['middle_name'] as String?,
      lastName: json['last_name'] as String? ?? '',
      state: json['state'] as String? ?? '',
      district: json['district'] as String? ?? '',
      taluka: json['taluka'] as String? ?? '',
      village: json['village'] as String? ?? '',
      address: json['address'] as String? ?? '',
      landmark: json['landmark'] as String?,
      pincode: json['pincode'] as String? ?? '',
      contact: json['contact'] as String? ?? '',
      altContact: json['alt_contact'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': email,
      'photo': photo,
      'first_name': firstName,
      'middle_name': middleName,
      'last_name': lastName,
      'state': state,
      'district': district,
      'taluka': taluka,
      'village': village,
      'address': address,
      'landmark': landmark,
      'pincode': pincode,
      'contact': contact,
      'alt_contact': altContact,
    };
  }
}