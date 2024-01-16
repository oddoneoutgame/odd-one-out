# TV Instrumentation Tests

## Setup

- Please create an emulator that is only used for TV instrumentation tests
- Do not install `Jarvis` on that emulator
- Do not hook up charles to that emulator
- Here is an example of recommended emulator specs that will successfully run all of our TV instrumentation tests listed below

| **Device** | **API** |         **Target**        | **CPU/ABI** |
|:----------:|:-------:|:-------------------------:|:-----------:|
| Android TV |    30   | Android 11.0 (Android TV) |     x86     |

!!! warning

    Using API 29 will not pass all tests

## CLI commands

- List of up to date, currently passing commands to run TV instrumentation tests

### Disney+

| Test class | Disney+ Command |
|-|-|
| `AccountHoldTest` | `./gradlew :tv:connectedTvDisneyGoogleDebugAndroidTest --continue --info -Pandroid.testInstrumentationRunnerArguments.class=com.bamtechmedia.dominguez.paywall.AccountHoldTest` |
| `AccountSettingsSubsTest` | `./gradlew :tv:connectedTvDisneyGoogleDebugAndroidTest --continue --info -Pandroid.testInstrumentationRunnerArguments.class=com.bamtechmedia.dominguez.account.AccountSettingsSubsTest` |
| `AgeVerificationFlowTest` | `./gradlew :tv:connectedTvDisneyGoogleDebugAndroidTest --continue --info -Pandroid.testInstrumentationRunnerArguments.class=com.bamtechmedia.dominguez.ageverify.AgeVerificationFlowTest` |
| `ChangeEmailTest` | `./gradlew :tv:connectedTvDisneyGoogleDebugAndroidTest --continue --info -Pandroid.testInstrumentationRunnerArguments.class=com.bamtechmedia.dominguez.account.email.ChangeEmailTest` |
| `DeepLinkAccountInfoTest` | `./gradlew :tv:connectedTvDisneyGoogleDebugAndroidTest --continue --info -Pandroid.testInstrumentationRunnerArguments.class=com.bamtechmedia.dominguez.deeplink.DeepLinkAccountInfoTest` |
| `DeepLinkBrandPageTest` | `./gradlew :tv:connectedTvDisneyGoogleDebugAndroidTest --continue --info -Pandroid.testInstrumentationRunnerArguments.class=com.bamtechmedia.dominguez.deeplink.DeepLinkBrandPageTest` |
| `DeepLinkEditorialTest` | `./gradlew :tv:connectedTvDisneyGoogleDebugAndroidTest --continue --info -Pandroid.testInstrumentationRunnerArguments.class=com.bamtechmedia.dominguez.deeplink.DeepLinkEditorialTest` |
| `DeepLinkEditProfileTest` | `./gradlew :tv:connectedTvDisneyGoogleDebugAndroidTest --continue --info -Pandroid.testInstrumentationRunnerArguments.class=com.bamtechmedia.dominguez.deeplink.DeepLinkEditProfileTest` |
| `DeepLinkHomeTest` | `./gradlew :tv:connectedTvDisneyGoogleDebugAndroidTest --continue --info -Pandroid.testInstrumentationRunnerArguments.class=com.bamtechmedia.dominguez.deeplink.DeepLinkHomeTest` |
| `DeepLinkLegalTest` | `./gradlew :tv:connectedTvDisneyGoogleDebugAndroidTest --continue --info -Pandroid.testInstrumentationRunnerArguments.class=com.bamtechmedia.dominguez.deeplink.DeepLinkLegalTest` |
| `DeepLinkMoviesTest` | `./gradlew :tv:connectedTvDisneyGoogleDebugAndroidTest --continue --info -Pandroid.testInstrumentationRunnerArguments.class=com.bamtechmedia.dominguez.deeplink.DeepLinkMoviesTest` |
| `DeepLinkOriginalsTest` | `./gradlew :tv:connectedTvDisneyGoogleDebugAndroidTest --continue --info -Pandroid.testInstrumentationRunnerArguments.class=com.bamtechmedia.dominguez.deeplink.DeepLinkOriginalsTest` |
| `DeepLinkSearchTest` | `./gradlew :tv:connectedTvDisneyGoogleDebugAndroidTest --continue --info -Pandroid.testInstrumentationRunnerArguments.class=com.bamtechmedia.dominguez.deeplink.DeepLinkSearchTest` |
| `DeepLinkSeriesTest` | `./gradlew :tv:connectedTvDisneyGoogleDebugAndroidTest --continue --info -Pandroid.testInstrumentationRunnerArguments.class=com.bamtechmedia.dominguez.deeplink.DeepLinkSeriesTest` |
| `DeepLinkTier2DialogTest` | `./gradlew :tv:connectedTvDisneyGoogleDebugAndroidTest --continue --info -Pandroid.testInstrumentationRunnerArguments.class=com.bamtechmedia.dominguez.deeplink.DeepLinkTier2DialogTest` |
| `EditProfileTest` | `./gradlew :tv:connectedTvDisneyGoogleDebugAndroidTest --continue --info -Pandroid.testInstrumentationRunnerArguments.class=com.bamtechmedia.dominguez.profile.edit.EditProfileTest` |
| `LegalCenterAuthenticatedTest` | `./gradlew :tv:connectedTvDisneyGoogleDebugAndroidTest --continue --info -Pandroid.testInstrumentationRunnerArguments.class=com.bamtechmedia.dominguez.legal.LegalCenterAuthenticatedTest` |
| `LegalCenterOnboardingTest` | `./gradlew :tv:connectedTvDisneyGoogleDebugAndroidTest --continue --info -Pandroid.testInstrumentationRunnerArguments.class=com.bamtechmedia.dominguez.legal.LegalCenterOnboardingTest` |
| `LoginFlowTest` | `./gradlew :tv:connectedTvDisneyGoogleDebugAndroidTest --continue --info -Pandroid.testInstrumentationRunnerArguments.class=com.bamtechmedia.dominguez.login.LoginFlowTest` |
| `LoginFlowTest` (fireTV) | `./gradlew :tv:connectedTvDisneyAmazonDebugAndroidTest --continue --info -Pandroid.testInstrumentationRunnerArguments.class=com.bamtechmedia.dominguez.login.LoginFlowTest` |
| `LoginForgotPasswordFocusTest` | `./gradlew :tv:connectedTvDisneyGoogleDebugAndroidTest --continue --info -Pandroid.testInstrumentationRunnerArguments.class=com.bamtechmedia.dominguez.otp.LoginForgotPasswordFocusTest` |
| `LoginScreenFocusTest` | `./gradlew :tv:connectedTvDisneyGoogleDebugAndroidTest --continue --info -Pandroid.testInstrumentationRunnerArguments.class=com.bamtechmedia.dominguez.login.LoginScreenFocusTest` |
| `LogOutAllDevicesTest` | `./gradlew :tv:connectedTvDisneyGoogleDebugAndroidTest --continue --info -Pandroid.testInstrumentationRunnerArguments.class=com.bamtechmedia.dominguez.logoutall.LogOutAllDevicesTest` |
| `LogOutFlowTest` | `./gradlew :tv:connectedTvDisneyGoogleDebugAndroidTest --continue --info -Pandroid.testInstrumentationRunnerArguments.class=com.bamtechmedia.dominguez.login.LogOutFlowTest` |
| `MovieDetailsTest` | `./gradlew :tv:connectedTvDisneyGoogleDebugAndroidTest --continue --info -Pandroid.testInstrumentationRunnerArguments.class=com.bamtechmedia.dominguez.details.MovieDetailsTest` |
| `MovieDetailsTest` (fireTV) | `./gradlew :tv:connectedTvDisneyAmazonDebugAndroidTest --continue --info -Pandroid.testInstrumentationRunnerArguments.class=com.bamtechmedia.dominguez.details.MovieDetailsTest` |
| `PaywallFlowTest` | `./gradlew :tv:connectedTvDisneyGoogleDebugAndroidTest --continue --info -Pandroid.testInstrumentationRunnerArguments.class=com.bamtechmedia.dominguez.paywall.PaywallFlowTest` |
| `PaywallFlowTest` (fireTV)  | `./gradlew :tv:connectedTvDisneyAmazonDebugAndroidTest --continue --info -Pandroid.testInstrumentationRunnerArguments.class=com.bamtechmedia.dominguez.paywall.PaywallFlowTest` |
| `ProfilesFlowTest` | `./gradlew :tv:connectedTvDisneyGoogleDebugAndroidTest --continue --info -Pandroid.testInstrumentationRunnerArguments.class=com.bamtechmedia.dominguez.profiles.ProfilesFlowTest` |
| `PlaybackTest` | `./gradlew :tv:connectedTvDisneyGoogleDebugAndroidTest --continue --info -Pandroid.testInstrumentationRunnerArguments.class=com.bamtechmedia.dominguez.playback.PlaybackTest` |
| `PlaybackTest` (fireTV) | `./gradlew :tv:connectedTvDisneyAmazonDebugAndroidTest --continue --info -Pandroid.testInstrumentationRunnerArguments.class=com.bamtechmedia.dominguez.playback.PlaybackTest` |
| `PlaybackLanguagesTest` | `./gradlew :tv:connectedTvDisneyGoogleDebugAndroidTest --continue --info -Pandroid.testInstrumentationRunnerArguments.class=com.bamtechmedia.dominguez.playback.PlaybackLanguagesTest` |
| `PlaybackUpNextTest` | `./gradlew :tv:connectedTvDisneyGoogleDebugAndroidTest --continue --info -Pandroid.testInstrumentationRunnerArguments.class=com.bamtechmedia.dominguez.playback.PlaybackUpNextTest` |
| `SearchDefaultKeyboardTest` | `./gradlew :tv:connectedTvDisneyGoogleDebugAndroidTest --continue --info -Pandroid.testInstrumentationRunnerArguments.class=com.bamtechmedia.dominguez.search.SearchDefaultKeyboardTest` |
| `SearchJapaneseKeyboardTest` | `./gradlew :tv:connectedTvDisneyGoogleDebugAndroidTest --continue --info -Pandroid.testInstrumentationRunnerArguments.class=com.bamtechmedia.dominguez.search.SearchJapaneseKeyboardTest` |
| `SearchKoreanKeyboardTest` | `./gradlew :tv:connectedTvDisneyGoogleDebugAndroidTest --continue --info -Pandroid.testInstrumentationRunnerArguments.class=com.bamtechmedia.dominguez.search.SearchKoreanKeyboardTest` |
| `SearchScreenTest` | `./gradlew :tv:connectedTvDisneyGoogleDebugAndroidTest --continue --info -Pandroid.testInstrumentationRunnerArguments.class=com.bamtechmedia.dominguez.search.SearchScreenTest` |
| `SignupFlowTest` | `./gradlew :tv:connectedTvDisneyGoogleDebugAndroidTest --continue --info -Pandroid.testInstrumentationRunnerArguments.class=com.bamtechmedia.dominguez.signup.SignupFlowTest` |
| `SignupFlowTest` (fireTV) | `./gradlew :tv:connectedTvDisneyAmazonDebugAndroidTest --continue --info -Pandroid.testInstrumentationRunnerArguments.class=com.bamtechmedia.dominguez.signup.SignupFlowTest` |
| `SmokeTest` | `./gradlew :tv:connectedTvDisneyGoogleDebugAndroidTest --continue --info -Pandroid.testInstrumentationRunnerArguments.class=com.bamtechmedia.dominguez.smoke.SmokeTest` |
| `SmokeTest` (fireTV) | `./gradlew :tv:connectedTvDisneyAmazonDebugAndroidTest --continue --info -Pandroid.testInstrumentationRunnerArguments.class=com.bamtechmedia.dominguez.smoke.SmokeTest` |
| `WelchAddProfileTest` | `./gradlew :tv:connectedTvDisneyGoogleDebugAndroidTest --continue --info -Pandroid.testInstrumentationRunnerArguments.class=com.bamtechmedia.dominguez.onboarding.WelchAddProfileTest` |
| `WelchExistingProfileMigrationTest` | `./gradlew :tv:connectedTvDisneyGoogleDebugAndroidTest --continue --info -Pandroid.testInstrumentationRunnerArguments.class=com.bamtechmedia.dominguez.onboarding.WelchExistingProfileMigrationTest` |
| `WelchNewUserSignupTest` | `./gradlew :tv:connectedTvDisneyGoogleDebugAndroidTest --continue --info -Pandroid.testInstrumentationRunnerArguments.class=com.bamtechmedia.dominguez.onboarding.WelchNewUserSignupTest` |
| `WelcomeScreenFocusTest` | `./gradlew :tv:connectedTvDisneyGoogleDebugAndroidTest --continue --info -Pandroid.testInstrumentationRunnerArguments.class=com.bamtechmedia.dominguez.welcome.WelcomeScreenFocusTest` |
| `WelcomeScreenFocusTest` (fireTV) | `./gradlew :tv:connectedTvDisneyAmazonDebugAndroidTest --continue --info -Pandroid.testInstrumentationRunnerArguments.class=com.bamtechmedia.dominguez.welcome.WelcomeScreenFocusTest` |
| `WelcomeScreenTest` | `./gradlew :tv:connectedTvDisneyGoogleDebugAndroidTest --continue --info -Pandroid.testInstrumentationRunnerArguments.class=com.bamtechmedia.dominguez.welcome.WelcomeScreenTest` |
| `WelcomeScreenTest` (fireTV) | `./gradlew :tv:connectedTvDisneyAmazonDebugAndroidTest --continue --info -Pandroid.testInstrumentationRunnerArguments.class=com.bamtechmedia.dominguez.welcome.WelcomeScreenTest` |

### Star+

| Test class | Star+ Command |
|-|-|
| `AccountHoldTest` | |
| `AccountSettingsSubsTest` | |
| `EditProfileTest` | |
| `LegalCenterAuthenticatedTest` | |
| `LegalCenterOnboardingTest` | |
| `LoginFlowTest` | `./gradlew :tv:connectedTvStarGoogleDebugAndroidTest --continue --info -Pandroid.testInstrumentationRunnerArguments.class=com.bamtechmedia.dominguez.login.LoginFlowTest` |
| `LoginFlowTest` (fireTV) | `./gradlew :tv:connectedTvStarAmazonDebugAndroidTest --continue --info -Pandroid.testInstrumentationRunnerArguments.class=com.bamtechmedia.dominguez.login.LoginFlowTest` |
| `LoginForgotPasswordFocusTest` | |
| `LoginScreenFocusTest` | |
| `LogOutAllDevicesTest` | |
| `LogOutFlowTest` | |
| `PaywallFlowTest` | `./gradlew :tv:connectedTvStarGoogleDebugAndroidTest --continue --info -Pandroid.testInstrumentationRunnerArguments.class=com.bamtechmedia.dominguez.paywall.PaywallFlowTest`  |
| `PaywallFlowTest` (fireTV) | `./gradlew :tv:connectedTvStarAmazonDebugAndroidTest --continue --info -Pandroid.testInstrumentationRunnerArguments.class=com.bamtechmedia.dominguez.paywall.PaywallFlowTest`  |
| `WelcomeScreenFocusTest` | |
| `WelcomeScreenTest` | `./gradlew :tv:connectedTvStarGoogleDebugAndroidTest --continue --info -Pandroid.testInstrumentationRunnerArguments.class=com.bamtechmedia.dominguez.welcome.WelcomeScreenTest` |
| `WelcomeScreenTest` (fireTV) | `./gradlew :tv:connectedTvStarAmazonDebugAndroidTest --continue --info -Pandroid.testInstrumentationRunnerArguments.class=com.bamtechmedia.dominguez.welcome.WelcomeScreenTest` |
| `HomeBadgesTest` | `./gradlew :tv:connectedTvStarGoogleDebugAndroidTest --continue --info -Pandroid.testInstrumentationRunnerArguments.class=com.bamtechmedia.dominguez.badges.HomeBadgesTest` |
