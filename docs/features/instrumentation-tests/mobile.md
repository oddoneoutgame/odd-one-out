# Mobile Instrumentation Tests

## Setup

- Please create an emulator that is only used for mobile instrumentation tests
- Do not install `Jarvis` on that emulator
- Do not hook up charles to that emulator
- Here is an example of recommended emulator specs that will successfully run all of our mobile instrumentation tests listed below

| **Device** | **API** |         **Target**         | **CPU/ABI** |
|:----------:|:-------:|:--------------------------:|:-----------:|
|   Pixel 4  |    30   | Android 11.0 (Google Play) |    x86_64   |

## CLI commands

- List of up to date, currently passing commands to run mobile instrumentation tests

### Disney+

| **Test class** | **Command** |
|-|-|
| `AccountHoldTest` | `./gradlew :mobile:connectedMobileDisneyGoogleDebugAndroidTest --continue --info -Pandroid.testInstrumentationRunnerArguments.class=com.bamtechmedia.dominguez.paywall.AccountHoldTest` |
| `AccountSettingsStackedSubsTest` | `./gradlew :mobile:connectedMobileDisneyGoogleDebugAndroidTest --continue --info -Pandroid.testInstrumentationRunnerArguments.class=com.bamtechmedia.dominguez.account.AccountSettingsStackedSubsTest` |
| `AccountSettingsSubsTest` | `./gradlew :mobile:connectedMobileDisneyGoogleDebugAndroidTest --continue --info -Pandroid.testInstrumentationRunnerArguments.class=com.bamtechmedia.dominguez.account.AccountSettingsSubsTest` |
| `AgeVerificationFlowTest` | `./gradlew :mobile:connectedMobileDisneyGoogleDebugAndroidTest --continue --info -Pandroid.testInstrumentationRunnerArguments.class=com.bamtechmedia.dominguez.ageverify.AgeVerificationFlowTest`|
| `AgeVerificationKoreanFlowTest` | `./gradlew :mobile:connectedMobileDisneyGoogleDebugAndroidTest --continue --info -Pandroid.testInstrumentationRunnerArguments.class=com.bamtechmedia.dominguez.ageverify.AgeVerificationKoreanFlowTest` |
| `ChangeEmailTest` | `./gradlew :mobile:connectedMobileDisneyGoogleDebugAndroidTest --continue --info -Pandroid.testInstrumentationRunnerArguments.class=com.bamtechmedia.dominguez.account.email.ChangeEmailTest` |
| `ChangePasswordFlowTest` | `./gradlew :mobile:connectedMobileDisneyGoogleDebugAndroidTest --continue --info -Pandroid.testInstrumentationRunnerArguments.class=com.bamtechmedia.dominguez.account.password.ChangePasswordFlowTest` |
| `DeepLinkAccountInfoTest` | `./gradlew :mobile:connectedMobileDisneyGoogleDebugAndroidTest --continue --info -Pandroid.testInstrumentationRunnerArguments.class=com.bamtechmedia.dominguez.deeplink.DeepLinkAccountInfoTest` |
| `DeepLinkBrandPageTest` | `./gradlew :mobile:connectedMobileDisneyGoogleDebugAndroidTest --continue --info -Pandroid.testInstrumentationRunnerArguments.class=com.bamtechmedia.dominguez.deeplink.DeepLinkBrandPageTest` |
| `DeepLinkDataUsageTest` | `./gradlew :mobile:connectedMobileDisneyGoogleDebugAndroidTest --continue --info -Pandroid.testInstrumentationRunnerArguments.class=com.bamtechmedia.dominguez.deeplink.DeepLinkDataUsageTest` |
| `DeepLinkDownloadsTest` | `./gradlew :mobile:connectedMobileDisneyGoogleDebugAndroidTest --continue --info -Pandroid.testInstrumentationRunnerArguments.class=com.bamtechmedia.dominguez.deeplink.DeepLinkDownloadsTest` |
| `DeepLinkEditorialTest` | `./gradlew :mobile:connectedMobileDisneyGoogleDebugAndroidTest --continue --info -Pandroid.testInstrumentationRunnerArguments.class=com.bamtechmedia.dominguez.deeplink.DeepLinkEditorialTest` |
| `DeepLinkEditProfileTest` | `./gradlew :mobile:connectedMobileDisneyGoogleDebugAndroidTest --continue --info -Pandroid.testInstrumentationRunnerArguments.class=com.bamtechmedia.dominguez.deeplink.DeepLinkEditProfileTest` |
| `DeepLinkHomeTest` | `./gradlew :mobile:connectedMobileDisneyGoogleDebugAndroidTest --continue --info -Pandroid.testInstrumentationRunnerArguments.class=com.bamtechmedia.dominguez.deeplink.DeepLinkHomeTest` |
| `DeepLinkLegalTest` | `./gradlew :mobile:connectedMobileDisneyGoogleDebugAndroidTest --continue --info -Pandroid.testInstrumentationRunnerArguments.class=com.bamtechmedia.dominguez.deeplink.DeepLinkLegalTest` |
| `DeepLinkMoviesTest` | `./gradlew :mobile:connectedMobileDisneyGoogleDebugAndroidTest --continue --info -Pandroid.testInstrumentationRunnerArguments.class=com.bamtechmedia.dominguez.deeplink.DeepLinkMoviesTest` |
| `DeepLinkOriginalsTest` | `./gradlew :mobile:connectedMobileDisneyGoogleDebugAndroidTest --continue --info -Pandroid.testInstrumentationRunnerArguments.class=com.bamtechmedia.dominguez.deeplink.DeepLinkOriginalsTest` |
| `DeepLinkSearchTest` | `./gradlew :mobile:connectedMobileDisneyGoogleDebugAndroidTest --continue --info -Pandroid.testInstrumentationRunnerArguments.class=com.bamtechmedia.dominguez.deeplink.DeepLinkSearchTest` |
| `DeepLinkSeriesTest` | `./gradlew :mobile:connectedMobileDisneyGoogleDebugAndroidTest --continue --info -Pandroid.testInstrumentationRunnerArguments.class=com.bamtechmedia.dominguez.deeplink.DeepLinkSeriesTest` |
| `DeepLinkTier2DialogTest` | `./gradlew :mobile:connectedMobileDisneyGoogleDebugAndroidTest --continue --info -Pandroid.testInstrumentationRunnerArguments.class=com.bamtechmedia.dominguez.deeplink.DeepLinkTier2DialogTest` |
| `LegalCenterAuthenticatedTest` | `./gradlew :mobile:connectedMobileDisneyGoogleDebugAndroidTest --continue --info -Pandroid.testInstrumentationRunnerArguments.class=com.bamtechmedia.dominguez.legal.LegalCenterAuthenticatedTest` |
| `LegalCenterOnboardingTest` | `./gradlew :mobile:connectedMobileDisneyGoogleDebugAndroidTest --continue --info -Pandroid.testInstrumentationRunnerArguments.class=com.bamtechmedia.dominguez.legal.LegalCenterOnboardingTest` |
| `LoginFlowTest` | `./gradlew :mobile:connectedMobileDisneyGoogleDebugAndroidTest --continue --info -Pandroid.testInstrumentationRunnerArguments.class=com.bamtechmedia.dominguez.login.LoginFlowTest` |
| `LoginFlowTest` (fireTablet) | `./gradlew :mobile:connectedMobileDisneyAmazonDebugAndroidTest --continue --info -Pandroid.testInstrumentationRunnerArguments.class=com.bamtechmedia.dominguez.login.LoginFlowTest` |
| `LoginForgotPasswordTest` | ` ./gradlew :mobile:connectedMobileDisneyGoogleDebugAndroidTest --continue --info -Pandroid.testInstrumentationRunnerArguments.class=com.bamtechmedia.dominguez.otp.LoginForgotPasswordTest` |
| `LogOutAllDevicesTest` | `./gradlew :mobile:connectedMobileDisneyGoogleDebugAndroidTest --continue --info -Pandroid.testInstrumentationRunnerArguments.class=com.bamtechmedia.dominguez.logoutall.LogOutAllDevicesTest` |
| `LogOutFlowTest` | `./gradlew :mobile:connectedMobileDisneyGoogleDebugAndroidTest --continue --info -Pandroid.testInstrumentationRunnerArguments.class=com.bamtechmedia.dominguez.login.LogOutFlowTest` |
| `MovieDetailsTest` | `./gradlew :mobile:connectedMobileDisneyGoogleDebugAndroidTest --continue --info -Pandroid.testInstrumentationRunnerArguments.class=com.bamtechmedia.dominguez.details.MovieDetailsTest` |
| `MovieDetailsTest` (fireTablet) | `./gradlew :mobile:connectedMobileDisneyAmazonDebugAndroidTest --continue --info -Pandroid.testInstrumentationRunnerArguments.class=com.bamtechmedia.dominguez.details.MovieDetailsTest` |
| `OtpLoginFlowTest` | `./gradlew :mobile:connectedMobileDisneyGoogleDebugAndroidTest --continue --info -Pandroid.testInstrumentationRunnerArguments.class=com.bamtechmedia.dominguez.login.OtpLoginFlowTest` |
| `PaywallFlowTest` | `./gradlew :mobile:connectedMobileDisneyGoogleDebugAndroidTest --continue --info -Pandroid.testInstrumentationRunnerArguments.class=com.bamtechmedia.dominguez.paywall.PaywallFlowTest` |
| `PaywallFlowTest` (fireTablet) | `./gradlew :mobile:connectedMobileDisneyAmazonDebugAndroidTest --continue --info -Pandroid.testInstrumentationRunnerArguments.class=com.bamtechmedia.dominguez.paywall.PaywallFlowTest` |
| `ProfilesFlowTest` | `./gradlew :mobile:connectedMobileDisneyGoogleDebugAndroidTest --continue --info -Pandroid.testInstrumentationRunnerArguments.class=com.bamtechmedia.dominguez.profiles.ProfilesFlowTest` |
| `PlaybackLanguagesTest` | `./gradlew :mobile:connectedMobileDisneyGoogleDebugAndroidTest --continue --info -Pandroid.testInstrumentationRunnerArguments.class=com.bamtechmedia.dominguez.playback.PlaybackLanguagesTest` |
| `PlaybackTest` | `./gradlew :mobile:connectedMobileDisneyGoogleDebugAndroidTest --continue --info -Pandroid.testInstrumentationRunnerArguments.class=com.bamtechmedia.dominguez.playback.PlaybackTest` |
| `PlaybackUpNextTest` | `./gradlew :mobile:connectedMobileDisneyGoogleDebugAndroidTest --continue --info -Pandroid.testInstrumentationRunnerArguments.class=com.bamtechmedia.dominguez.playback.PlaybackUpNextTest` |
| `SearchScreenTest` | `./gradlew :mobile:connectedMobileDisneyGoogleDebugAndroidTest --continue --info -Pandroid.testInstrumentationRunnerArguments.class=com.bamtechmedia.dominguez.search.SearchScreenTest` |
| `SignupFlowTest` | `./gradlew :mobile:connectedMobileDisneyGoogleDebugAndroidTest --continue --info -Pandroid.testInstrumentationRunnerArguments.class=com.bamtechmedia.dominguez.signup.SignupFlowTest` |
| `SignupFlowTest` (fireTablet) | `./gradlew :mobile:connectedMobileDisneyAmazonDebugAndroidTest --continue --info -Pandroid.testInstrumentationRunnerArguments.class=com.bamtechmedia.dominguez.signup.SignupFlowTest` |
| `SmokeTest` | `./gradlew :mobile:connectedMobileDisneyGoogleDebugAndroidTest --continue --info -Pandroid.testInstrumentationRunnerArguments.class=com.bamtechmedia.dominguez.smoke.SmokeTest` |
| `SmokeTest` (fireTablet) | `./gradlew :mobile:connectedMobileDisneyAmazonDebugAndroidTest --continue --info -Pandroid.testInstrumentationRunnerArguments.class=com.bamtechmedia.dominguez.smoke.SmokeTest` |
| `VerifyAccountFlowTest` | `./gradlew :mobile:connectedMobileDisneyGoogleDebugAndroidTest --continue --info -Pandroid.testInstrumentationRunnerArguments.class=com.bamtechmedia.dominguez.account.verify.VerifyAccountFlowTest` |
| `WelcomeScreenTest` | `./gradlew :mobile:connectedMobileDisneyGoogleDebugAndroidTest --continue --info -Pandroid.testInstrumentationRunnerArguments.class=com.bamtechmedia.dominguez.welcome.WelcomeScreenTest` |
| `WelcomeScreenTest` (fireTablet) | `./gradlew :mobile:connectedMobileDisneyAmazonDebugAndroidTest --continue --info -Pandroid.testInstrumentationRunnerArguments.class=com.bamtechmedia.dominguez.welcome.WelcomeScreenTest` |
| `WelchAddProfileTest` | `./gradlew :mobile:connectedMobileDisneyGoogleDebugAndroidTest --continue --info -Pandroid.testInstrumentationRunnerArguments.class=com.bamtechmedia.dominguez.onboarding.WelchAddProfileTest` |
| `WelchExistingProfileMigrationTest` | `./gradlew :mobile:connectedMobileDisneyGoogleDebugAndroidTest --continue --info -Pandroid.testInstrumentationRunnerArguments.class=com.bamtechmedia.dominguez.onboarding.WelchExistingProfileMigrationTest` |
| `WelchNewUserSignupTest` | `./gradlew :mobile:connectedMobileDisneyGoogleDebugAndroidTest --continue --info -Pandroid.testInstrumentationRunnerArguments.class=com.bamtechmedia.dominguez.onboarding.WelchNewUserSignupTest` |
| `DynamicTests` | `./gradlew :mobile:connectedMobileDisneyGoogleDebugAndroidTest --continue --info -Pandroid.testInstrumentationRunnerArguments.class=com.bamtechmedia.dominguez.dynamic.DynamicTests` |

### Star+

| Test class | Star+ Command |
|-|-|
| `AccountHoldTest` |  |
| `AccountSettingsStackedSubsTest` |  |
| `AccountSettingsSubsTest` |  |
| `ChangeEmailTest` |  |
| `DeepLinkDetailTest` |  |
| `HomeBadgesTest` | `./gradlew :mobile:connectedMobileStarGoogleDebugAndroidTest --continue --info -Pandroid.testInstrumentationRunnerArguments.class=com.bamtechmedia.dominguez.badges.HomeBadgesTest` |
| `LegalCenterAuthenticatedTest` | |
| `LegalCenterOnboardingTest` |  |
| `LoginFlowTest` | `./gradlew :mobile:connectedMobileStarGoogleDebugAndroidTest --continue --info -Pandroid.testInstrumentationRunnerArguments.class=com.bamtechmedia.dominguez.login.LoginFlowTest` |
| `LoginFlowTest` (fireTablet) | `./gradlew :mobile:connectedMobileStarAmazonDebugAndroidTest --continue --info -Pandroid.testInstrumentationRunnerArguments.class=com.bamtechmedia.dominguez.login.LoginFlowTest` |
| `LoginForgotPasswordTest` |  |
| `LogOutAllDevicesTest` |  |
| `LogOutFlowTest` |  |
| `PaywallFlowTest` | `./gradlew :mobile:connectedMobileStarGoogleDebugAndroidTest --continue --info -Pandroid.testInstrumentationRunnerArguments.class=com.bamtechmedia.dominguez.paywall.PaywallFlowTest` |
| `ProfilesFlowTest` |  |
| `WelcomeScreenTest` | `./gradlew :mobile:connectedMobileStarGoogleDebugAndroidTest --continue --info -Pandroid.testInstrumentationRunnerArguments.class=com.bamtechmedia.dominguez.welcome.WelcomeScreenTest` |
| `WelcomeScreenTest` (fireTablet) | `./gradlew :mobile:connectedStarAmazonDebugAndroidTest --continue --info -Pandroid.testInstrumentationRunnerArguments.class=com.bamtechmedia.dominguez.welcome.WelcomeScreenTest` |
