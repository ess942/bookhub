# BookHub

## Try the UI without Firebase

Run the local demo with sample books and an in-memory cart:

```shell
flutter run -d chrome --dart-define=BOOKHUB_DEMO=true
```

Or serve it on the web:

```shell
flutter run -d web-server --web-port 7357 --dart-define=BOOKHUB_DEMO=true
```

The demo supports browsing, search, cart, simulated checkout, library, profile
editing, and local theme/notification preferences. Orders and profile changes
stay in the demo session; photo upload, account deletion, and Firebase features
are unavailable without a Firebase project.

## Connect Firebase

Run `flutterfire configure`, then start the normal app:

```shell
flutter run -d chrome
```
