import 'package:bookhub2/features/auth/data/datasources/firebase_auth_data_source.dart';
import 'package:bookhub2/features/auth/data/errors/auth_error_mapper.dart';
import 'package:bookhub2/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('register creates an Auth account and its Firestore profile', () async {
    final firestore = FakeFirebaseFirestore();
    final auth = MockFirebaseAuth();
    final repository = AuthRepositoryImpl(
      FirebaseAuthDataSource(auth: auth, firestore: firestore),
    );

    final user = await repository.register(
      fullName: '  Book Reader  ',
      email: 'reader@example.com',
      password: 'secure-password',
    );

    final profile = await firestore.collection('users').doc(user.id).get();
    expect(user.email, 'reader@example.com');
    expect(profile.data(), containsPair('uid', user.id));
    expect(profile.data(), containsPair('fullName', 'Book Reader'));
    expect(profile.data(), containsPair('email', 'reader@example.com'));
    expect(profile.data(), contains('createdAt'));
    expect(profile.data(), contains('updatedAt'));
  });

  test('profile write failure keeps the signed-in account retryable', () async {
    final auth = MockFirebaseAuth();
    final firestore = FakeFirebaseFirestore(
      authObject: auth.authForFakeFirestore,
      securityRules: '''
        service cloud.firestore {
          match /databases/{database}/documents {
            match /users/{userId} {
              allow read, write: if false;
            }
          }
        }
      ''',
    );
    final repository = AuthRepositoryImpl(
      FirebaseAuthDataSource(auth: auth, firestore: firestore),
    );

    await expectLater(
      repository.register(
        fullName: 'Book Reader',
        email: 'reader@example.com',
        password: 'secure-password',
      ),
      throwsA(
        isA<AuthFailure>().having(
          (failure) => failure.profileSetupPending,
          'profileSetupPending',
          isTrue,
        ),
      ),
    );
    expect(auth.currentUser, isNotNull);
  });
}
