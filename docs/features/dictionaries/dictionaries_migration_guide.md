# Type-safe Dictionaries API Migration Guide

We have implemented a [new way of using dictionaries](../../administrative/rfc/2022_07_28_new_type_safe_dictionaries_api.md) in our app and the goal of this guide is to help you go through the migration to it.

## Kotlin

### Use Dictionaries instead of StringDictionary

First make sure that the feature module you're migrating includes the dependency dictionariesApi, as this is necessary to be able to use Dictionaries.

```groovy
implementation project(':features:dictionariesApi')
```

Second you need to replace any [StringDictionary](https://github.bamtech.co/Android/Dmgz/blob/0993e74c702236e4174eba2a5ea77efaeb79bbd5/core-utils/src/main/java/com/bamtechmedia/dominguez/config/StringDictionary.kt) occurrence with [Dictionaries](https://github.bamtech.co/Android/Dmgz/blob/0993e74c702236e4174eba2a5ea77efaeb79bbd5/features/dictionariesApi/src/main/java/com/bamtechmedia/dominguez/dictionaries/Dictionaries.kt).

???+ info "Example"
    **Before**

    ```kotlin
    import com.bamtechmedia.dominguez.config.StringDictionary
    
    class SomeClassUsingDictionaries @Inject constructor(
        private val dictionary: StringDictionary,
        // Other parameters
    )
    ```
    
    **After**
    
    ```kotlin
    import com.bamtechmedia.dominguez.dictionaries.Dictionaries
    
    class SomeClassUsingDictionaries @Inject constructor(
        private val dictionaries: Dictionaries,
        // Other parameters
    )
    ```

If the `StringDictionary` property is annotated with @RestrictedLanguage, you will need to keep it when migrating to `Dictionaries`.

Then, each dictionary usage in this class needs to be updated, the approach depends on whether the key is passed in as a [String resource](#StringRes access) or a [String literal](#String literal access)

### StringRes access

For the StringRes access type it is necessary for you to check what is the actual key. For this you can navigate into the string resource and check for the dictionary and the real key in the following way:

```xml
<string name="network_error_header">ns_application_network_error_header</string>
```

| dictionary  | actual key           |
|-------------|----------------------|
| application | network_error_header |

As you can see the actual key is everything that comes after the dictionary.

???+ info "Then you can proceed to migrate the key in the following way"
    **Before**

    ```kotlin
    localizedTitle = dictionary.string(R.string.network_error_header)
    ```
    
    **After**
    
    ```kotlin
    localizedTitle = dictionaries.application.network_error_header
    ```
    
    **Before**
    
    ```kotlin
    localizedTitle = dictionary.optionalString(R.string.connection_error_header)
    ```
    
    **After**
    
    ```kotlin
    localizedTitle =
        dictionaries.application.connection_error_header ?: "Fallback for variants or languages were key is not present"
    ```

### String literal access

When having a string literal access, as well as with StringRes access, you need to analyze the string to get the dictionary and the actual key.

```kotlin
dictionary.string("ns_sdk-errors_unexpectederror")
```

| dictionary | actual key      |
|------------|-----------------|
| sdk-errors | unexpectederror |

???+ info "Then you can proceed to migrate the key in the following way"
    **Before**

    ```kotlin
    localized = dictionary.string("ns_sdk-errors_unexpectederror")
    ```
    
    **After**
    
    ```kotlin
    localized = dictionaries.sdkErrors.unexpectederror
    ```
    
    **Before**
    
    ```kotlin
    localized = dictionary.optionalString("ns_sdk-errors_unexpectederror")
    ```
    
    **After**
    
    ```kotlin
    localized = dictionaries.sdkErrors.unexpectederror ?: "Fallback for variants or languages were key is not present"
    ```

For the case of having dynamic keys (keys that are only known/formed at runtime) you will need to use the getString accessor.

???+ info "Example"
    **Before**

    ```kotlin
    val index = "1"
    
    val imageKey = dictionary.string("ns_identity_image_learn_more_${index}_logo")
    ```
    
    **After**
    
    ```kotlin
    val index = "1"
    
    val imageKey = dictionary.identity.getString("image_learn_more_${index}_logo")
    ```

!!! note "Warning"
    This last migration type should never be used for regular string literal access!! Only use it when having dynamically formed dictionary keys.

### withResourceKey access

Another way of currently accessing dictionary values is by getting the dictionary first and then using one of the previous methods but only with the actual key as a parameter.

???+ info "Example"
    **Before**

    ```kotlin
    val collectionNoContentAvailable = dictionary.withResourceKey("application").optionalString("collection_no_content_available")
       
    val collectionNoContentAvailableEmpty = dictionary.withResourceKey("application").optionalString(
        key = "collection_no_content_available_empty",
        replacements = mapOf("collection_title" to state.collection?.title)
    )
    ```
    
    **After**
    
    ```kotlin
    val collectionNoContentAvailable = dictionaries.application.collection_no_content_available
       
    val collectionNoContentAvailableEmpty = dictionaries.application.collection_no_content_available_empty(
        collection_title = state.collection?.title
    )
    ```

### Any of the previous ones with replacements

Replacements are passed as parameters of the extension functions now. There's no more need to create a map of replacement keys and values. You will only need to pass the values.  

!!! note "Important"  
    Sometimes you will see that replacement parameters are nullable. That means that some variants and/or languages might not contain those placeholders. If you find yourself in this situation go to [cypher](https://cypher.disneystreaming.com/) and make sure to cover all the different values of that key in the code (with correct replacements)

???+ info "Example"
    **Before**

    ```kotlin
    val replacements = mapOf("minLength" to passwordRules.minLength, "charTypes" to passwordRules.charTypes)
    
    passwordInputLayout?.passwordMeterText = dictionary.string(R.string.password_reqs_enhanced, replacements)
    ```
    
    **After**
    
    ```kotlin
    passwordInputLayout?.passwordMeterText = dictionaries.application.password_reqs_enhanced(
        minLength = passwordRules.minLength, charTypes = passwordRules.charTypes
    )
    ```

!!! Warning
    All new dictionary extension properties and functions might return a nullable String value whenever a key is not present in all platforms, partners and/or languages. **Make sure you double check the return type when migrating to prevent missing texts**

### Core utils dependency removal

Lastly, when you finish migrating all the kt files from a module it is important for you to check if you can remove the core-utils dependency from it. For this you can check for usages of any core-utils class within that module by, in AS, using the Find in Files feature (cmd + shift + F) to search for `com.bamtechmedia.dominguez.core.utils.`. If there's no ocurrence you can remove the core-utils dependency by deleting the following line from the build.gradle file: `implementation project(':core-utils')`

## XML

Migration for xml usages is pretty straight forward. You need to access the old key to see what dictionary to use and then type the key selecting from the autocompletion the "ts" prefixed key. If you don't find the "ts" equivalent key most likely that key contains replacements, so it cannot be used in xmls. Use the kotlin access instead through the correct binding.

???+ info "Example"
    **Before**

    ```xml
    <TextView
        android:id="@+id/welcomeDescriptionSub1"
        android:text="@string/welcome_sign_up_web" />
    ```
    
    In this case:
    
    ```xml
    <string name="welcome_sign_up_web">ns_application_welcome_sign_up_web</string>
    ```
    
    **After**
    
    ```xml
    <TextView 
        android:id="@+id/welcomeDescriptionSub1"
        android:text="@string/ts_application_welcome_sign_up_web" />
    ```

!!! Warning
    Some new dictionary string resources might not be present in all platforms, partners and/or languages. **Make sure you double check this when migrating to prevent missing texts**.

## Testing

In case you need it, we have a TestDictionaries class which provides an implementation of Dictionaries for testing purposes. To see an example of how to use it you can check [the following PR](https://github.bamtech.co/Android/Dmgz/pull/13507).
