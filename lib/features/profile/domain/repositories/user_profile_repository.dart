import 'dart:typed_data';

import 'package:bookhub2/features/profile/domain/entities/user_profile.dart';

abstract class UserProfileRepository {
  Future<UserProfile> getProfile(String uid);

  Future<void> updateProfile({
    required String uid,
    required String fullName,
    required String phone,
  });

  Future<String> uploadAvatar({
    required String uid,
    required Uint8List imageBytes,
    required String contentType,
  });

  Future<void> deleteAccount({required String uid, required String password});
}
