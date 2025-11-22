Android signing: how to produce a signed AAB/APK

This project now reads signing properties from `android/gradle.properties`.

1) Create a local signing file (do NOT commit):

   - Copy the example:
     cp android/gradle.properties.example android/gradle.properties

   - Edit `android/gradle.properties` and fill in your real values:
     KEYSTORE_FILE=../keystore/app-release.jks
     KEYSTORE_PASSWORD=your_store_password_here
     KEY_ALIAS=your_key_alias_here
     KEY_PASSWORD=your_key_password_here

   - Make sure the keystore file exists at the path you provided.

2) Build a signed AAB locally:

```bash
# from repo root
flutter build appbundle --release
```

The Gradle signing config will pick up the values from `android/gradle.properties` and sign the AAB.

3) CI / Play Console

- On CI, set the same properties as environment variables or write a temporary `android/gradle.properties` before the build.
- If using Google Play App Signing, upload the correct key or enroll as needed.

Notes
- We intentionally removed hard-coded passwords from `build.gradle.kts`. Never commit your keystore passwords or the keystore itself to the repository.
- If you prefer a different `applicationId`, edit `android/app/build.gradle.kts` -> `defaultConfig.applicationId`.
