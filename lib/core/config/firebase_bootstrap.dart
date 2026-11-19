import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../firebase_options.dart';

final firebaseBootstrapProvider =
    NotifierProvider<FirebaseBootstrapController, AsyncValue<void>>(
      FirebaseBootstrapController.new,
    );

class FirebaseBootstrapController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.loading();

  Future<void> initialize() async {
    state = const AsyncValue.loading();
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}
