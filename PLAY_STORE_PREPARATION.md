# Arktech Student Scientific Calculator — Play Store Preparation

## Release identity
Use one permanent Android application ID before the first Play Store release. A recommended example is:

`com.arktechsolutions.studentscientificcalculator`

Do not change the application ID after publishing.

## Signing
Create a dedicated upload keystore and keep an offline backup. In Codemagic, upload it under:

**Team settings → codemagic.yaml settings → Code signing identities → Android keystores**

Use this reference name:

`arktech_upload_keystore`

Never commit the keystore, passwords, `key.properties`, or Google Play service-account JSON to GitHub.

## Google Play service account
Create a Google Play service-account JSON key, grant it access to the app, and store the complete JSON content as the secret Codemagic variable:

`GOOGLE_PLAY_SERVICE_ACCOUNT_CREDENTIALS`

Place it in the variable group:

`google_play_credentials`

The provided `android-play-internal` workflow publishes to the **internal** track.

## Important first-release rule
The first Play Store AAB should be uploaded manually in Play Console. After that initial release exists, the automated Codemagic publishing workflow can publish later builds.

## Store listing assets to prepare
- App name: **Arktech Student Scientific Calculator**
- Short description (80 characters max)
- Full description
- 512 × 512 high-resolution app icon
- Feature graphic
- Phone screenshots
- Tablet screenshots if tablet support is advertised
- Support email
- Privacy-policy URL
- App category: Education
- Content rating questionnaire
- Target audience / age declaration
- Data safety form

## Suggested positioning
A scientific calculator and student study toolkit combining:
- scientific calculation
- statistics
- equations
- matrices and vectors
- function tables and graphing
- formula library
- calculation history
- optional on-device camera OCR / solver

Avoid claiming that the app is officially approved for WAEC, JAMB, NECO or any examination unless you have written approval from the relevant body.

## Privacy / data-safety review
Before submission, verify the final build. Current architecture stores user preferences and history locally. Camera images are selected/captured for OCR. Confirm the final plugins and behavior when completing Google Play's Data safety form.

## Release checklist
1. Confirm permanent application ID.
2. Confirm version name and build number.
3. Run `flutter analyze`.
4. Run `flutter test`.
5. Build signed AAB.
6. Test APK on a physical Android device.
7. Verify Camera Solver permissions/behavior.
8. Verify light/dark mode and accessibility scaling.
9. Verify privacy policy and developer contact.
10. Manually upload the first AAB.
11. Use Codemagic `android-play-internal` for later internal releases.
12. Promote tested builds to closed/open testing or production when ready.
