import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/user_profile_repository_impl.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/user_profile_repository.dart';

final userProfileRepositoryProvider = Provider<UserProfileRepository>(
  (ref) => UserProfileRepositoryImpl(
    firestore: FirebaseFirestore.instance,
    storage: FirebaseStorage.instance,
    auth: FirebaseAuth.instance,
  ),
);

final userProfileProvider = FutureProvider.family<UserProfile, String>(
  (ref, uid) => ref.watch(userProfileRepositoryProvider).getProfile(uid),
);
