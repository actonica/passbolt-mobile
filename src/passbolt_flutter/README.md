# passbolt_flutter

### How to build the app
1. Install [Android Studio with Android SDK](https://developer.android.com/studio)
2. Install [Flutter SDK](https://flutter.dev/docs/get-started/install)
3. Run `flutter doctor` and apply Android SDK licenses
4. Run `path_to_project/src/passbolt_flutter/scripts/prebuild.sh` to generate inject and json_annotation files
5. Open `path_to_project/src/passbolt_flutter/` in Android Studio
6. Create new Run/Debug Configuration with parameters
    - Dart entrypoint - path_to_project/src/passbolt_flutter/lib/main_dev.dart
    - Build flavor - dev
7. Run created configuration
