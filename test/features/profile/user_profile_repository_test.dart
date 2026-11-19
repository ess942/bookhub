import 'package:bookhub2/features/profile/data/repositories/user_profile_repository_impl.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockFirebaseAuth extends Mock implements FirebaseAuth {}

class _MockFirebaseUser extends Mock implements User {}

class _MockFirebaseStorage extends Mock implements FirebaseStorage {}

class _FakeAuthCredential extends Fake implements AuthCredential {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeAuthCredential());
  });

  test('reads and updates the Firestore user profile schema', () async {
    final firestore = FakeFirebaseFirestore();
    final repository = UserProfileRepositoryImpl(
      firestore: firestore,
      auth: _MockFirebaseAuth(),
      storage: _MockFirebaseStorage(),
    );
    await firestore.collection('users').doc('customer-1').set({
      'uid': 'customer-1',
      'fullName': 'Sam Reader',
      'email': 'sam@example.com',
      'phone': '123456789',
      'photoUrl': 'https://example.com/avatar.jpg',
    });

    final profile = await repository.getProfile('customer-1');
    expect(profile.fullName, 'Sam Reader');
    expect(profile.phone, '123456789');
    expect(profile.photoUrl, 'https://example.com/avatar.jpg');

    await repository.updateProfile(
      uid: 'customer-1',
      fullName: 'Sam Updated',
      phone: '987654321',
    );
    final updated = await repository.getProfile('customer-1');
    expect(updated.fullName, 'Sam Updated');
    expect(updated.phone, '987654321');
    expect(updated.email, 'sam@example.com');
  });

  test('does not delete user data when re-authentication fails', () async {
    final firestore = FakeFirebaseFirestore();
    final auth = _MockFirebaseAuth();
    final user = _MockFirebaseUser();
    when(() => auth.currentUser).thenReturn(user);
    when(() => user.uid).thenReturn('customer-1');
    when(() => user.email).thenReturn('sam@example.com');
    when(
      () => user.reauthenticateWithCredential(any()),
    ).thenThrow(FirebaseAuthException(code: 'wrong-password'));
    await firestore.collection('users').doc('customer-1').set({
      'fullName': 'Sam Reader',
    });

    final repository = UserProfileRepositoryImpl(
      firestore: firestore,
      auth: auth,
      storage: _MockFirebaseStorage(),
    );
    await expectLater(
      repository.deleteAccount(uid: 'customer-1', password: 'bad-password'),
      throwsA(
        isA<ProfileFailure>().having(
          (failure) => failure.message,
          'friendly error',
          contains('incorrect'),
        ),
      ),
    );

    expect(
      (await firestore.collection('users').doc('customer-1').get()).exists,
      isTrue,
    );
    verify(() => user.reauthenticateWithCredential(any())).called(1);
  });
}
