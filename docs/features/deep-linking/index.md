# Deep Linking in Dominguez

[Doc to reference supported deep links (URLs tab)](https://docs.google.com/spreadsheets/d/1yVn_HJvxBdbCeMQZl1-r1DsMb1nADy5HETYlCXF-6r8/edit#gid=1378740772)

## How to add support for a deep link

### Deep link which requires auth

#### Step 1 - Handle the deep link

The first step for handling deep links is getting it from the Intent. This happens in MainActivity and can either come
from the intent in onCreate (only when saved instance state is not null) or when onNewIntent is called.
MainActivity will populate [DeepLinkViewModel](https://github.bamtech.co/Android/Dmgz/blob/development/features/deeplink/src/main/java/com/bamtechmedia/dominguez/deeplink/DeepLinkViewModel.kt)
which will parse the deep link into and OkHttpUrl. If the app is already active and logged in this will emit it through
a subject to the right place. See [Handle deep link while created](#handle-deep-link-while-created).

#### Step 2 - Ensure the right main tab is selected

Step two is to decide what the top level tab will be for the deep link. This influences both the selected tab at the
bottom, and if the deep linked screen has back navigation to what page it should go back. To determine this you need to
make sure that the right menu id is returned in [GlobalNavDeepLinkMapper](https://github.bamtech.co/Android/Dmgz/blob/development/features/globalNavApi/src/main/java/com/bamtechmedia/dominguez/globalnav/GlobalNavDeepLinkMapper.kt) for your deep link.

#### Step 3 - Final handling of the deep link

At this point a [TabFragment](https://github.bamtech.co/Android/Dmgz/blob/development/features/globalNav/src/main/java/com/bamtechmedia/dominguez/globalnav/tab/TabFragment.kt) is the
lowest level at which a deep link can be handled. It gives the opportunity to start a single screen over the root screen
but then consumes the deeplink so any information that is still required in that other screen should be passed to it in
a bundle format.

##### Nothing extra needed

If the root fragment is where you need to be, you need to inject DeepLinkViewModel, verify that the link points to where
you are now and then mark it complete. by calling `deepLinkViewModel.clearDeepLink()`.

##### Right fragment, extra parsing needed

Example for this case is search. If step 2 is done correctly you are now at the search fragment, but a search deep link
can also contain a query parameter `q=marvel`. In this case you can read that from the deep link and then mark it
handled.

##### Deep link into a deeper level fragment/activity

Note, this currently only works for fragments that have their binding module included in the
[TabFragmentBindingModule.FragmentModule](https://github.bamtech.co/Android/Dmgz/blob/development/features/globalNav/src/main/java/com/bamtechmedia/dominguez/globalnav/tab/TabFragmentBindingModule.java).

If you need to deep link into another fragment than the root, you can implement a [DeepLinkHandler](https://github.bamtech.co/Android/Dmgz/blob/development/features/deeplinkApi/src/main/java/com/bamtechmedia/dominguez/deeplink/DeepLinkHandler.kt)
for that feature which should implement and use dagger multi-binding to integrate.
The DeepLinkHandler can implement `createDeepLinkedFragment(HttpUrl)` and `createDeepLinkedActivity(HttpUrl)` to handle
the creation of the next screen.

At this point this `DeepLinkHandler` should completely handle the deep link. and if you would need to go into an even
deeper level, that fragment should be stared from the child fragment, which should be indicated using arguments in the
created fragment.

#### Handle deep link while created

Once started, the [MobileGlobalNavViewModel](https://github.bamtech.co/Android/Dmgz/blob/development/mobile/src/main/java/com/bamtechmedia/dominguez/globalnav/MobileGlobalNavViewModel.kt)
will observe any new deep links coming in through [onNewIntent]. This will then replace the current `TabFragment` with a
new one that get's created with the correct deep link handling. This satisfies the requirement that deep links should
clear the current back stack.

## Why the multi-bindings approach

The multi binds approach is used here to be able to delegate the deep link handling to specific features and not have
one deep link god-class which knows about all fragments that allow to be deep linked into.

### Deep link which does not require auth

- TBD

## Deep links in logcat

- There is a new initiative to display the deep link URL in the logcat for screens accessible through deep link.
- This is done in order to help create better testing notes for PRs and Jira tickets.
- Don't hesitate to add such a log on the screen you're working on when you implement a new deep link.
- For now, content detail and collection screens are supported. Opening such a screen will trigger a debug logcat message looking like:

```sh
[…] D/Deeplink: adb shell am start -a android.intent.action.VIEW -d https://www.starplus.com/movies/kingsman-the-secret-service/KU1ZHosjEuhK/related
```

Enable these messages on your build with the following command:

```sh
adb shell setprop log.tag.DmgzDeeplink DEBUG
```

- For more information, see [CollectionDeeplinkLogger](https://github.bamtech.co/Android/Dmgz/blob/development/features/collections/src/main/java/com/bamtechmedia/dominguez/collections/CollectionDeeplinkLogger.kt), [DetailDeeplinkLogger](https://github.bamtech.co/Android/Dmgz/blob/development/features/contentDetail/src/main/java/com/bamtechmedia/dominguez/detail/deeplink/DetailDeeplinkLogger.kt) and [DeeplinkLog](https://github.bamtech.co/Android/Dmgz/blob/development/features/loggingApi/src/main/java/com/bamtechmedia/dominguez/logging/DeeplinkLog.kt).

## App/Asset Links

When opening a deeplink to one of the applications, it is important that the mapping has been set up to identify the application as the owner of a specific link. This was introduced in Android 6.0 Marshmallow and is known as App Links. To find out more, please read [the Asset Link documentation](../app-linking/index.md).

## Quick Reference

- Quick reference to a list of valid deep links in case someone needs to grab one
- TODO - Put these into a markdown table with values Mobile? TV? Star+? etc.
    - Reminder until then:
        - Certain content is not available in all regions
        - Downloads is not available on TV
        - Star is not available in all countries

### Home Tabs

```sh
adb shell am start -a android.intent.action.VIEW -d https://www.disneyplus.com/home
adb shell am start -a android.intent.action.VIEW -d https://www.disneyplus.com/search
adb shell am start -a android.intent.action.VIEW -d https://www.disneyplus.com/downloads
adb shell am start -a android.intent.action.VIEW -d https://www.disneyplus.com/account
```

### Search

```sh
adb shell am start -a android.intent.action.VIEW -d https://www.disneyplus.com/movies
adb shell am start -a android.intent.action.VIEW -d https://www.disneyplus.com/originals
adb shell am start -a android.intent.action.VIEW -d https://www.disneyplus.com/series
adb shell am start -a android.intent.action.VIEW -d https://www.disneyplus.com/character/hawkeye
adb shell am start -a android.intent.action.VIEW -d https://www.disneyplus.com/editorial/female-leads
adb shell am start -a android.intent.action.VIEW -d https://www.disneyplus.com/franchise/marvel-the-infinity-saga
```

### Legal

```sh
adb shell am start -a android.intent.action.VIEW -d https://www.disneyplus.com/legal
adb shell am start -a android.intent.action.VIEW -d https://www.disneyplus.com/legal/privacy-policy
adb shell am start -a android.intent.action.VIEW -d https://www.disneyplus.com/legal/terms-of-use
adb shell am start -a android.intent.action.VIEW -d https://www.disneyplus.com/legal/eu-privacy-rights
```

### Series Detail Pages

```sh
adb shell am start -a android.intent.action.VIEW -d https://www.disneyplus.com/series/the-book-of-boba-fett/57TL7zLNu2wf/episodes\?addToWatchlist
adb shell am start -a android.intent.action.VIEW -d https://www.disneyplus.com/series/the-book-of-boba-fett/57TL7zLNu2wf/episodes\?download\=true
adb shell am start -a android.intent.action.VIEW -d https://www.disneyplus.com/series/the-book-of-boba-fett/57TL7zLNu2wf/extras
adb shell am start -a android.intent.action.VIEW -d https://www.disneyplus.com/series/agents-of-shield/2UT4VQrwpVgi/episodes
adb shell am start -a android.intent.action.VIEW -d https://www.disneyplus.com/series/agents-of-shield/2UT4VQrwpVgi/details
adb shell am start -a android.intent.action.VIEW -d https://www.disneyplus.com/series/agents-of-shield/2UT4VQrwpVgi/related
adb shell am start -a android.intent.action.VIEW -d https://www.disneyplus.com/series/agents-of-shield/2UT4VQrwpVgi/season/4
```

### Movie Detail Pages

```sh
adb shell am start -a android.intent.action.VIEW -d https://www.disneyplus.com/movies/star-wars-the-empire-strikes-back-episode-v/iqtDTZAewwYl\?addToWatchlist
adb shell am start -a android.intent.action.VIEW -d https://www.disneyplus.com/movies/star-wars-the-empire-strikes-back-episode-v/iqtDTZAewwYl\?download\=true
adb shell am start -a android.intent.action.VIEW -d https://www.disneyplus.com/movies/star-wars-the-empire-strikes-back-episode-v/iqtDTZAewwYl/related
adb shell am start -a android.intent.action.VIEW -d https://www.disneyplus.com/movies/star-wars-the-empire-strikes-back-episode-v/iqtDTZAewwYl/extras
```

### Playback

```sh
adb shell am start -a android.intent.action.VIEW -d https://www.disneyplus.com/video/3de87281-eae4-4e5a-924b-f1888e4c4814
adb shell am start -a android.intent.action.VIEW -d https://www.disneyplus.com/video/90ff6e09-afd3-4d46-a2cb-80e3767e67ea
```

### Brands

```sh
adb shell am start -a android.intent.action.VIEW -d https://www.disneyplus.com/brand/pixar
adb shell am start -a android.intent.action.VIEW -d https://www.disneyplus.com/brand/disney
adb shell am start -a android.intent.action.VIEW -d https://www.disneyplus.com/brand/marvel
adb shell am start -a android.intent.action.VIEW -d https://www.disneyplus.com/brand/star-wars
adb shell am start -a android.intent.action.VIEW -d https://www.disneyplus.com/brand/national-geographic
adb shell am start -a android.intent.action.VIEW -d https://www.disneyplus.com/brand/star
```

### Profiles

```sh
adb shell am start -a android.intent.action.VIEW -d https://www.disneyplus.com/account/edit-profiles
adb shell am start -a android.intent.action.VIEW -d https://www.disneyplus.com/account/add-profile
```

### Account / App Settings

```sh
adb shell am start -a android.intent.action.VIEW -d https://www.disneyplus.com/account/app-settings/download-quality
adb shell am start -a android.intent.action.VIEW -d https://www.disneyplus.com/account/app-settings/cellular-data-usage
adb shell am start -a android.intent.action.VIEW -d https://www.disneyplus.com/account/change-password
adb shell am start -a android.intent.action.VIEW -d https://www.disneyplus.com/account/change-email
```
