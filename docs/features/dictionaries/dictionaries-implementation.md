# Dictionaries Implementation

## Introduction

This page will proceed to explain how our current dictionaries implementation works.

There's two important and distinct parts for our dictionaries implementation details:

- Downloading dictionaries at runtime to use them. This means, on startup of the app, we will retrieve the latest pinned dictionaries remotely and download them.
- Accessing the previously downloaded dictionaries from anywhere in our codebase to assign correct values in our UI.

After this two topics, this documentation focus on some extra important matters about our dictionaries implementation.

## Downloading dictionaries at runtime

In our app, on start up, we download dictionaries and leave them ready to be used. When they are downloaded, they are also cached. If the user has no internet connection but has cached dictionaries, these will be used. Contrary if the user has no internet connection and no cached dictionaries, an error will be shown.

Downloading dictionaries starts when the app triggers a [LoadConfigsAction](https://github.bamtech.co/Android/Dmgz/blob/531e15ef8b62170cebad95aa43e386ea1f7961f9/features/configApi/src/main/java/com/bamtechmedia/dominguez/config/LoadConfigsAction.kt). This action will, among others, load our dictionaries by calling the [DictionariesProvider](https://github.bamtech.co/Android/Dmgz/blob/531e15ef8b62170cebad95aa43e386ea1f7961f9/features/dictionaries/src/main/java/com/bamtechmedia/dominguez/dictionaries/data/v2/DictionariesProvider.kt) `intialize` method.

From there on the following classes will be used to retrieve dictionaries (in order):

### DictionaryLanguageMerger

This class is in charge of loading dictionaries while avoiding duplicated dictionary requests whenever the user has the same language for both UI and legal (for more info on this please visit [Restrict Onboarding Language (ROL)](dictionaries-implementation-extras.md#restrict-onboarding-language---rol)). All requests and their results will be kept in memory while the app is still alive. In order to do this it calls the [DictionaryLoader](#dictionaryloader)class and uses the [DictionaryRequestProvider](#dictionaryrequestprovider) class to retrieve the dictionary request to perform.

It also implements interfaces relevant for:

- waiting until dictionaries are loaded
- checking if they are loaded in a certain moment in time.
- preloading dictionaries for a certain language. This can be called before doing a language profile switch to ensure that the dictionaries for it have been loaded correctly.

### DictionaryRequestProvider

Class in charge of exposing a stream and emitting new dictionary requests to load. This happens by listening to the SessionStateRepository and LocalizationRepository and expose a new dictionary [Request](https://github.bamtech.co/Android/Dmgz/blob/531e15ef8b62170cebad95aa43e386ea1f7961f9/features/dictionaries/src/main/java/com/bamtechmedia/dominguez/dictionaries/data/v2/DictionaryRequestProvider.kt) whenever either the session state or the globalization config has changed. This stream will be observed by the DictionaryLanguageMerger to retrieve new dictionaries accordingly.

### DictionaryLoader

This is the class in charge of loading dictionaries according to a dictionary request. It will first load cached dictionaries and check if their versions are the same as the ones being requested. If that's the case, cached dictionaries will be returned, otherwise new dictionaries will be downloaded and returned. The dictionaries returned type is [KeyValueDictionary](https://github.bamtech.co/Android/Dmgz/blob/531e15ef8b62170cebad95aa43e386ea1f7961f9/features/dictionaries/src/main/java/com/bamtechmedia/dominguez/dictionaries/KeyValueDictionary.kt). In order to perform the loading, it uses the [DictionaryRepository](https://github.bamtech.co/Android/Dmgz/blob/531e15ef8b62170cebad95aa43e386ea1f7961f9/features/dictionaries/src/main/java/com/bamtechmedia/dominguez/dictionaries/data/v2/datasource/DictionaryRepository.kt)

## Accessing dictionaries in our codebase

In order to allow developers to access the downloaded dictionaries we have implemented a solution that allows type-safe easy access.

### Dictionaries gradle convention plugin

To begin with, we have a [dictionaries convention plugin](https://github.bamtech.co/Android/Dmgz/blob/f46fc7393c978a005a1b1478ce0385e8f2237a6a/buildLogic/src/main/kotlin/com.disneystreaming.dominguez.feature-api.dictionaries.gradle.kts) that is only included in the dictionariesApi feature api module. This plugin registers two important gradle tasks related to our dictionaries accessing implementation:

- GenerateDictionarySchemasTask
- GenerateDictionaryExtensionsTask

#### GenerateDictionarySchemasTask

This task is in charge of downloading the latest dictionaries and generate dictionary schemas out of them. A [dictionary schema](https://github.bamtech.co/Android/Dmgz/blob/development/buildLogic/src/main/kotlin/com/bamtechmedia/dominguez/dictionaries/model/DictionarySchema.kt) is a json file that holds all the relevant information from a certain dictionary and the respective keys. This schemas will be later used by our GenerateDictionaryExtensionsTask as an input. An example of a schema can be found [here](https://github.bamtech.co/Android/Dmgz/blob/531e15ef8b62170cebad95aa43e386ea1f7961f9/features/dictionariesApi/src/main/dictionaries/schemas/welch_dictionary_entries.json)

It will read the latest dictionary versions from our [dictionary_config_bundle.json](https://github.bamtech.co/Android/Dmgz/blob/531e15ef8b62170cebad95aa43e386ea1f7961f9/dictionary_bundle_config.json), download and parse them to finally save them into json files under [a directory](https://github.bamtech.co/Android/Dmgz/tree/531e15ef8b62170cebad95aa43e386ea1f7961f9/features/dictionariesApi/src/main/dictionaries/schemas) that won't be bundled in the app.

This task must be manually run by developers at the time of pinning the dictionaries (See [Dictionary Pinning](dictionary-pinning.md)). For that there's a convenience make command: `make updateDictionaries`

In case the developer forgets to commit the updated dictionary schemas when pinning dictionaries locally, there's currently a [github action](https://github.bamtech.co/Android/Dmgz/blob/531e15ef8b62170cebad95aa43e386ea1f7961f9/.github/workflows/dictionary-schemas-uptodate-checker.yml) running that checks it and fails the build if it is the case. This github action runs a [script](https://github.bamtech.co/Android/Dmgz/blob/531e15ef8b62170cebad95aa43e386ea1f7961f9/buildLogic/src/main/kotlin/com/bamtechmedia/dominguez/dictionaries/utils/DictionarySchemasUpToDateChecker.kt) that will use a sha-256 checksum to validate that the combination of dictionary versions (from the dictionary_bundle_config.json file) together with the schemas are correct.

#### GenerateDictionaryExtensionsTask

This task is in charge of generating extension properties and functions to allow us to access dictionaries and their values in an easier way. For this it takes as an input the dictionary schemas (which are the outcome of the GenerateDictionarySchemasTask) and uses [KotlinPoet](https://square.github.io/kotlinpoet/) and [Jackson](https://github.com/FasterXML/jackson-dataformat-xml).

This task will be automatically run whenever kotlin code gets compiled or resources are generated.

The outcome of this task are the dictionary extensions and string resources. These can be found under the `dictionariesApi/build/generated` folder when you build the app. The first ones under `kotlin` and the second ones under `res/dictionaries`.

???+ info "Examples of how this generated code looks like"
    ```xml
    <resources>
        <!--
        billing_creditcard_cardpin key is not present in all platforms, partners and/or languages. Current usages are for:

        Platforms: android, android-tv
        Partners:
        Disney -> Languages (cs, da, de, el, en, en-GB, es-419, es-ES, fi, fr-CA, fr-FR, hu, it, ja, ko, nl, no, pl, pt-PT, pt-BR, ro, sk, sv, tr, zh-Hans, zh-Hant, zh-HK)
        -->
        <string name="ts_accessibility_billing_creditcard_cardpin">ts_accessibility_billing_creditcard_cardpin</string>

        <string name="ts_accessibility_billing_creditcard_cvv">ts_accessibility_billing_creditcard_cvv</string>
    
        <string name="ts_accessibility_billing_creditcard_cvvhelptip">ts_accessibility_billing_creditcard_cvvhelptip
        </string>
    
    </resources>
    ```

    ```kotlin
    /**
     * additional_content_info key is nullable because it is not present in all platforms, partners
     * and/or languages. Current usages are for:
     *
     * Platforms: android
     * Partners:
     * Disney -> Languages (cs, da, de, el, en, en-GB, es-419, es-ES, fi, fr-CA, fr-FR, hu, it, ja, ko,
     * nl, no, pl, pt-PT, pt-BR, ro, sk, sv, tr, zh-Hans, zh-Hant, zh-HK)
     * Star -> Languages (en, es-419, pt-BR)
     * Hulu -> Languages (en)
     */
    public inline fun AccessibilityDictionary.additional_content_info(additional_content_title: String): String? =
        getString("additional_content_info", mapOf("additional_content_title" to additional_content_title))

    public inline val AccessibilityDictionary.addprofile_pageload: String
        get() = getString("addprofile_pageload")

    public inline fun AccessibilityDictionary.air_window_live(startTime: String, endTime: String): String = 
        getString("air_window_live", mapOf("startTime" to startTime, "endTime" to endTime))
    ```

It is worth noticing that, in the previous examples, some autogenerated properties/functions and string resources contain a javadoc/comment on top. This is to make clear whenever a certain key is not present in all variants and/or languages. You can also notice that, because of this reason, for the kotlin case the return type changes from `String` to `String?`

## Offline/Fallback dictionary string resources

Our dictionaries implementation is currently internet connection dependant. What we mean with this is that the user needs to have a proper internet connection after opening the app for the first time in order to be able to use them. If the user has no internet connection at this point then we will show an error message for it. And since dictionaries couldn't be downloaded we need to have the strings we will show in the error message bundled.This is an example of why we also have offline/fallback dictionary string resources.

To sum up, we will use this offline/fallback string resources **only** when app **needs** to use strings before dictionaries have been loaded.

To implement the generation and bundling of these string resources we have a few different parts in place:

### dictionary_offline_keys.json

We have a [dictionary_offline_keys.json](https://github.bamtech.co/Android/Dmgz/blob/3fdefe961a81ca0fd1b6b8faaf908223cf95820d/dictionary_offline_keys.json) file in the root of the project that contains all the offline/fallback dictionary keys that should be downloaded and bundled into the apps (mobile and tv).

### GenerateDictionaryFallbacksTask

The application gradle convention plugin registers this task which is in charge of downloading all dictionaries, retrieving the dictionary keys stated in the dictionary_offline_keys.json file and generate the correct string resources files inside our apps.

The files are name after each dictionary in the following way: `offline_[dictionary name]_dictionary_keys.xml` and the string resources using `fallback_` as a prefix.

You can see this fallback files, for example for the disney mobile app, [here](https://github.bamtech.co/Android/Dmgz/tree/3fdefe961a81ca0fd1b6b8faaf908223cf95820d/mobile/src/disney/res).

This task must be run manually. If you are pinning dictionaries, you can use the `make updateDictionaries` which runs also this task.

### FallbackDictionary

The [FallbackDictionary](https://github.bamtech.co/Android/Dmgz/blob/3fdefe961a81ca0fd1b6b8faaf908223cf95820d/features/dictionaries/src/main/java/com/bamtechmedia/dominguez/dictionaries/FallbackDictionary.kt) class takes care of mapping the requested dictionary string to the correct fallback key.

**If you add a new offline dictionary key, you must add the mapping here.**

### EarlyDictionaryAccessException

This exception allows us to track in Sentry whenever the app requests a dictionary key before dictionaries are downloaded and there's no offline/fallback string for it bundled in the app. You can [check in Sentry](https://disney.my.sentry.io/organizations/disney/issues/?query=is%3Aunresolved+EarlyDictionaryAccessException&referrer=issue-list&statsPeriod=14d) for `EarlyDictionaryAccessException` to see the latest early accesses.

## Custom LayoutInflater to resolve XML string resources

We have in our codebase a custom LayoutInflater to allow XML dictionaries usage. For more info please check the [XML Challenge](xml-challenge.md).
