class UserProfile {
  const UserProfile({
    required this.uid,
    required this.fullName,
    required this.email,
    this.phone = '',
    this.photoUrl = '',
  });

  final String uid;
  final String fullName;
  final String email;
  final String phone;
  final String photoUrl;

  factory UserProfile.empty({
    required String uid,
    String email = '',
    String fullName = '',
  }) {
    return UserProfile(uid: uid, email: email, fullName: fullName);
  }

  factory UserProfile.fromMap(Map<String, dynamic> map, String uid) {
    return UserProfile(
      uid: uid,
      fullName: map['fullName'] as String? ?? '',
      email: map['email'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      photoUrl: map['photoUrl'] as String? ?? '',
    );
  }
}
