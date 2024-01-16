# Using dictionaries

In our codebase we can access dictionaries either via Kotlin or Xml (through our layouts).

## Kotlin

You can use dictionaries in our codebase by injecting [Dictionaries](https://github.bamtech.co/Android/Dmgz/blob/bb2603a7131c808b1303ca0973b0153b614bd2a3/features/dictionariesApi/src/main/java/com/bamtechmedia/dominguez/dictionaries/Dictionaries.kt) in your class (either via constructor or property) and access directly the dictionary and the key by using property or function extensions. If the value of the key requires placeholder replacements, you will need to pass them as parameters. For example:

Suppose you want to use the `btn_play` key from the application dictionary. Which value looks as the following:

`btn_play = "Play"`

Then your code to access it will look like this:

```kotlin
@Inject
lateinit var dictionaries: Dictionaries

dictionaries.application.btn_play
```

In the case of using a key whose value contains replacements, let's say, `password_reqs_enhanced` also from the application dictionary:

`password_reqs_enhanced = "Use a minimum of ${minLength} characters (case sensitive) with characters from ${charTypes} of the following: letters, numbers, special characters."`

Then your code will look like this:

```kotlin
@Inject
lateinit var dictionaries: Dictionaries

fun someFunction(passwordRules: PasswordRules) {

    dictionaries.application.password_reqs_enhanced(
        minLength = passwordRules.minLength, charTypes = passwordRules.charTypes
    )
}
```

!!!note "Important"
    If your usage is within the onboarding flow, you will need to annotate the Dictionary injection with @RestrictedLanguage. For more info please check [Restricted Onboarding Language](dictionaries-implementation-extras.md#restrict-onboarding-language---rol)

### Dynamic dictionary keys

Dynamic dictionary keys are keys where we don't know their full value at compile time, only at run time. These are keys based on some form of (server-side) state. A good example are dictionary keys with a Paywall Hash suffix. The Paywall hash is returned by the server based on the User's entitlement and location and needs to be appended to the key. For example:

`welcome_monthly_tagline_9cfb5d89da74ee3147a62af3c0b09c50 = "No extra costs, no commitments. T&Cs apply."`

The last "9cfb5d89da74ee3147a62af3c0b09c50" part will be only know at runtime, so we need to form the key dynamically.

For this type of keys (and only for these) we can access dictionaries using `getString` in the following way:

```kotlin
@Inject
lateinit var dictionaries: Dictionaries

dictionaries.application.getString("welcome_monthly_tagline_9cfb5d89da74ee3147a62af3c0b09c50")
```

And if it has replacements, for example:

`annual_value_prop_168c0486da803ce5a87b5990ba76c9a0 = "(12 months at ${PRICE_PROP_1}/mo. Save over 15%)"`

We would use it like the following:

```kotlin
@Inject
lateinit var dictionaries: Dictionaries

fun someFunction(price: String) {
    dictionaries.application.getString(
        "welcome_monthly_tagline_9cfb5d89da74ee3147a62af3c0b09c50",
        mapOf("PRICE_PROP_1" to price)
    )
}
```

### Dynamic dictionaries

There are a tiny amount of cases where we actually don't know not only the dictionary key but also the dictionary itself. For these cases, we have two ways of accessing dictionaries.

When we have the dictionary resource key and the actual key separately:

```kotlin
@Inject
lateinit var dictionaries: Dictionaries

private val dictionary: String = "application"

private val key: String = "btn_play"

fun someFunction() {
    dictionaries.getDictionary(dictionary).getString(key)
}
```

When we have the dictionary resource key and the actual key all together:

```kotlin
@Inject
lateinit var dictionaries: Dictionaries

private val dictionaryKey: String = "ns_application_btn_play"

private val dictionaryKeyAlternative: String = "ts_application_btn_play"

fun someFunction() {
    dictionaries.getString(dictionaryKey)

    dictionaries.getString(dictionaryKeyAlternative)
}
```

!!! note "Important"  
    The previous two usages shown ([Dynamic dictionary keys](#dynamic-dictionary-keys) and [Dynamic dictionaries](#dynamic-dictionaries)) are only meant to be used in very special occasions. Make sure you need to use them and there's no other way to migrate to the first examples shown at the beginning of the section.

## XML

Dictionary access through our xml layouts is pretty straight forward. You just have to type the key (with `ts` as prefix) into the xml attribute (android:text for example) and the value will get resolved. Some examples are:

For android:text:

```xml

<com.bamtechmedia.dominguez.widget.button.StandardButton
        android:id="@+id/offButton"
        android:layout_width="0dp"
        android:layout_height="@dimen/btn_min_height"
        app:buttonType="secondary"
        android:text="@string/ts_application_btn_add_profile_kids_profile_off"/>
```

For android:contentDescription:

```xml

<androidx.appcompat.widget.AppCompatImageView
        android:id="@+id/up_next_back_btn"
        android:layout_width="@dimen/up_next_close_icon_size"
        android:layout_height="@dimen/up_next_close_icon_size"
        android:contentDescription="@string/ts_accessibility_btn_back"
        android:src="@drawable/ic_circle_back_black_resizable"/>
```

!!! note "Important"  
    Currently we support the following widgets and their text related attributes: TextView, AppCompatTextView, EditText, EmptyStateView, SearchView, ImageView, StandardButton. This should cover the majority of our cases. The remaining custom views we have with custom attributes currently not supported will be migrated soon. For now, use Kotlin access for them

## Extra important notes

* Keep in mind that assigning values through kotlin or xml means dictionary access and resolution. For the best performance, assign values either through Kotlin OR XML, not both.
* If you need to wait for dictionaries to be loaded in your code, [DictionariesState.Provider](https://github.bamtech.co/Android/Dmgz/blob/f46fc7393c978a005a1b1478ce0385e8f2237a6a/features/dictionariesApi/src/main/java/com/bamtechmedia/dominguez/dictionaries/DictionariesState.kt#L112) has functions allowing us to wait for dictionaries to be loaded.

### Testing

If you are working with unit test, and you need a Dictionaries fake implementation you can use [TestDictionaries](https://github.bamtech.co/Android/Dmgz/blob/1c977727744402590af497e0a472fa1f39e93871/features/dictionariesApi/src/main/java/com/bamtechmedia/dominguez/dictionaries/TestDictionaries.kt)
