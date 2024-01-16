
# FAQ/Troubleshooting

## Creating instrumented tests for different language/locale

It's important to be able to run instrumentation tests in several languages, amongst others to know whether translations will fit within the expected UI.
In order for that to work properly, a couple of steps need to be taken:

### Globalization

Before logging in and for the dictionaries call, the application follows the language passed via globalization, even if the phone ui is set to a different one.
So we need to stub it:

```kotlin
r2d2Config.givenRequestInvoked("/v1/public/graphql")
    .whenAggressiveMatch(ExpectedAggressiveMatch("query", "globalization"))
    .thenRespondWithFile(globalizationPath, replaceExisting = true)
```

### Login/Profile

After logging in, it follows the ui language set to the profile json, not depending entirely on globalization anymore, so a profile with the desired `appLanguage` should be present and selected in the login stub:

```kotlin
R2D2SetupLoginSuccess("v1/public/graphql/login_with_pt_profile.json")
```

### Emulator/Device

This is not a required change since we can change the device location via config with [StubAppConfigValue](https://github.bamtech.co/Android/Dmgz/blob/development/coreAndroidTest/platformAgnosticTestFixtures/src/main/java/com/bamtechmedia/dominguez/config/StubAppConfigValue.kt)

```kotlin
StubAppConfigValue("BR", "contentApi", arrayOf("X-GEO-OVERRIDE"))
```

And if needed/wanted you can change your emulator locale inside settings.
If running on firebase test lab, `locale` can be configured the same as `model` and api `version`, but tests with different languages would need a different emulator from the others.
Check [build.gradle](https://github.bamtech.co/Android/Dmgz/blob/development/mobile/build.gradle) `devices` section for example.

### Example

A good test that can be used for reference is [SearchKoreanKeyboardTest](https://github.bamtech.co/Android/Dmgz/blob/development/tv/src/androidTestGoogle/java/com/bamtechmedia/dominguez/search/SearchKoreanKeyboardTest.kt)

------------

#### TODO [ANDROID-5096](https://jira.disneystreaming.com/browse/ANDROID-5096)

------------
