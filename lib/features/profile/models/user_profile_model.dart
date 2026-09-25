import 'package:flutter/foundation.dart';

@immutable
class UserProfile {
  const UserProfile({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.address,
    required this.memberSince,
    required this.orderCount,
  });

  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String address;
  final DateTime memberSince;
  final int orderCount;

  String get fullName => '$firstName $lastName';

  String get initials => '${firstName[0]}${lastName[0]}'.toUpperCase();
}
