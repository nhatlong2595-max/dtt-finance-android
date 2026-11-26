# DTT Finance – Android source

Flutter Android application for personal finance management.

## Included
- Five-tab app shell: overview, transactions, accounts, reports and settings.
- Local SQLite storage, account balances and transaction workflows.
- Basic reports and calculation tests.
- GitHub Actions workflow for Android release APK.

## Build
The workflow runs `flutter pub get`, `flutter analyze`, `flutter test` and `flutter build apk --release`. The APK is uploaded as the `dtt-finance-android-apk` artifact.

## Engineering status
This is an active development build, not a production-complete finance product. Complete accounting postings, debt schedules, secure cloud sync, biometric integration, encrypted backup, recurring transactions, full budget/goal interfaces and comprehensive financial-health scoring remain engineering gates.

Money values use integer VND. Verify build and tests through GitHub Actions before installing the APK.
