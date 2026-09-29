# NarcTrace Android preview

This APK packages the redesigned NarcTrace website by Etaernal, including light and dark themes, as a standalone Android application. The website assets are bundled; no laptop or development server is required. Online authentication still needs internet.

## Install and share

Upload `NarcTrace-1.0-preview.apk` to Google Drive, share its link, and download it on an Android phone (Android 7.0 or later). Open the downloaded APK and allow installation from that source if Android prompts you. This is a debug-signed preview for sideloading, not a Play Store release.

## Preview limits

Capture drafts are held in memory and are lost when the app closes. Export drafts and original images through the Android share sheet before closing. Automated drug classification, trusted KMS signatures, cloud capture storage, and Android Google sign-in are not configured in this preview. Email sign-in and the preview interface remain available. Results must not be treated as laboratory confirmation or certified evidence.

## Rebuild (PowerShell from website/)

```powershell
npm.cmd ci
npm.cmd run build
npx.cmd cap sync android
$env:JAVA_HOME='C:\Program Files\Android\Android Studio\jbr'
cd android
.\gradlew.bat assembleDebug --no-daemon
```

Use your own Android SDK path in ignored `android/local.properties`. Output: `website/android/app/build/outputs/apk/debug/app-debug.apk`. Keep the same signing key for future in-place updates.

## Verification

Website production build and all 3 unit tests passed. Gradle assembleDebug succeeded. APK v2 signature verified. Installed and launched successfully on the Android 16 emulator; no startup errors appeared in the checked AndroidRuntime/Capacitor error logs. Camera, location, OAuth, and share-sheet flows have not been tested on a physical phone.

