# Miscellaneous

Page collecting different secondary matters related to our dictionaries implementation.

## Lint checks

To help migrating from the [legacy implementation](legacy-dictionaries.md) to this current implementation there are a few new lint checks for:

- XML usage of non “ts” prefixed string resources
- getString usage. There are a few cases were getString should be used, for these cases we can add a SuppressWarning annotation in the method/class.

These lint checks can be found in [here](https://github.bamtech.co/Android/Dmgz/tree/dab468f55ae77714caad3a88a52b92cc6a96e769/lint-checks/src/main/kotlin/com/bamtechmedia/dominguez/lint/dictionaries)

Besides lint checks we also have a few Discouraged annotations to make sure developers use direct access as much as possible within the Dictionaries class instead of the Dictionary [getString](https://github.bamtech.co/Android/Dmgz/blob/dab468f55ae77714caad3a88a52b92cc6a96e769/features/dictionariesApi/src/main/java/com/bamtechmedia/dominguez/dictionaries/Dictionaries.kt#L18) or Dictionaries [getString](https://github.bamtech.co/Android/Dmgz/blob/dab468f55ae77714caad3a88a52b92cc6a96e769/features/dictionariesApi/src/main/java/com/bamtechmedia/dominguez/dictionaries/Dictionaries.kt#L49) methods.

## Other important dictionary matters

### Restrict Onboarding Language - ROL

Currently, our app handles two different languages at runtime:

- User language. This is the language we will use in the most cases of our app. It is the "regular" or "common" language.
- Restricted onboarding language. For some countries, due to legal aspects or translation limitations, we cannot use the User Languages when stating important or legal matters. That's where the ROL language comes in hand. For example: If your device is set to German, but you are in China, we do not have translations for our Chinese legal text in the German language to display

The ROL language is used for all onboarding screens and legal text before the user is logged in. When a user is logged in, all screens except the following use the profile's chosen language:

- Paywall
    - Annual Upgrade
    - Premier Access
- Legal center

In order to enforce ROL languages we have the `@RestrictedLanguage` qualifier. We will use this qualifier whenever injecting `Dictionaries`.
The two different languages to use while downloading dictionaries are being observed, as previously mentioned, by the DictionaryRequestProvider.

#### How does the languages preferences work in insight?

1. We send up the language preferences the user has selected on their device to the globalization API via `"preferredLanguages"`.
2. The globalization API will map the locale values (`"preferredLanguages"` sent) on their end. [Here is an example mapping](https://jira.disneystreaming.com/browse/PUSREQ-259) where they perform for Hong Kong / `zh-HK`
3. The globalization API will respond with a `"uiLanguage"` value. This is the onboarding / legal text ROL language. This `"uiLanguage"` value is based on:
    - The values and order of `"preferredLanguages"` sent
    - The user's location (which is based on the IP address)
4. At this point, what it was explained for [DictionaryRequestProvider](dictionaries-implementation.md#dictionaryrequestprovider) would come in.

All of this can be confusing, so here are a few examples:

Considering the user is in Hong Kong (HK) and the ROL Rules for Hong Kong are:

- Subscriber Agreement Languages - zh-HK & en-GB
- Fallback - English (en-GB)

???+ info "Example 1"
    - User has their device languages in this order: Simplified Chinese, English (UK), German
    - Onboarding language will be in Simplified Chinese since we send up `zh` to the globalization API, and they map that `zh` value to `zh-HK`

???+ info "Example 2"
    - User has their device languages in this order: German, Simplified Chinese, English (UK)
    - We do not have our Chinese legal text translated in German (their preferred device language)
    - Onboarding language will be in Simplified Chinese since we send up `zh` to the globalization API, and they map that `zh` value to `zh-HK`

???+ info "Example 3"
    - User has their device languages in this order: German, English (UK), Simplified Chinese
    - We do not have our Chinese legal text translated in German (their preferred device language)
    - Onboarding language will be in English (UK) since that has higher priority than Simplified Chinese

#### Tips

- Exact ROL configurations from services can be found here:
    - [Disney+](https://github.bamtech.co/userservices/service-resources/blob/master/resources/instances/global/disney/language-preferences/language-preferences.json) Disney+ has environment specific overrides you can find in the parent folder
    - [Star+](https://github.bamtech.co/userservices/service-resources/blob/master/resources/instances/global/star/language-preferences/language-preferences.json)
- [Globalization API responses by version](https://github.bamtech.co/userservices/service-resources/tree/master/resources/instances/global/disney/globalization)
- [Original ticket (which includes huge table of ROL rules)](https://jira.disneystreaming.com/browse/DMGZAND-5830)
- [Extra globalization docs](https://github.bamtech.co/pages/fed-solutions/documentation/globalization/globalization-settings.html#globalization-settings)
- You may need to use Jarvis to toggle on `Localization` -> `Globalization API version 1.x.x` if you are not seeing the values you expect
- When you need to select a specific CJK language, it can be difficult to know which one is which. [This google sheets mapping can help](https://docs.google.com/spreadsheets/d/1BhMznnAoW1ABZM-t3gDbKgE27Q9KEQ2IXoA3hyZ4t0o/edit?usp=sharing)
