import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/demo/demo_preview_app.dart';
import 'core/app/appdart/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const demoMode = bool.fromEnvironment('BOOKHUB_DEMO');
  if (demoMode) {
    runApp(const DemoPreviewApp());
  } else {
    runApp(const ProviderScope(child: BookHubApp()));
  }
}
