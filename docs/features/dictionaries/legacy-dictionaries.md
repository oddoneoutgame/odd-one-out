# Legacy Dictionaries Implementation

This page is about the legacy dictionaries implementation (prior to [New Dictionaries API RFC](../../administrative/rfc/2022_07_28_new_type_safe_dictionaries_api.md))

Since we are in the course of a dictionaries implementation migration (towards the previously mentioned RFC) we still have in our codebase the following old legacy dictionaries implementation. All of these are either currently Deprecated or on the way to become.

!!!note "Important"
    If you are currently migrating form this legacy implementation to the new one, please check our [Migration Guide](dictionaries_migration_guide.md)

## StringDictionary

Although our new implementation relies on the [StringDictionary](https://github.bamtech.co/Android/Dmgz/blob/dab468f55ae77714caad3a88a52b92cc6a96e769/core-utils/src/main/java/com/bamtechmedia/dominguez/config/StringDictionary.kt) interface, it is meant to be deleted once we are fully migrated. This interface was in the legacy implementation the way to inject dictionaries in any place of our codebase and retrieve dictionary values.

It provides a protocol to access dictionary values through either a string resource reference or string literal keys. It has also an optional alternative in case we don't know if the keys are present for every variant.

## NameSpacedDictionary

The [NameSpacedDictionary](https://github.bamtech.co/Android/Dmgz/blob/dab468f55ae77714caad3a88a52b92cc6a96e769/features/dictionaries/src/main/java/com/bamtechmedia/dominguez/dictionaries/NameSpacedDictionary.kt) class is the concrete implementation of StringDictionary to represent all dictionaries. It would resolve StringRes and string literal keys into dictionary values. In our current implementation [AllDictionaries](https://github.bamtech.co/Android/Dmgz/blob/dab468f55ae77714caad3a88a52b92cc6a96e769/features/dictionaries/src/main/java/com/bamtechmedia/dominguez/dictionaries/AllDictionaries.kt) would be the equivalent class and once migration is over, this will be deleted in favor of it.

This class has the ability to split namespaced dictionary keys such as `ns_application_btn_play` into a dictionary resource key and the actual key and retrieve it from the dictionaries.

## KeyValueDictionary

The [KeyValueDictionary](https://github.bamtech.co/Android/Dmgz/blob/dab468f55ae77714caad3a88a52b92cc6a96e769/features/dictionaries/src/main/java/com/bamtechmedia/dominguez/dictionaries/KeyValueDictionary.kt) class is also still used in our new implementation, but it will get replaced by a new Dictionary class in the future when the migration is over. It is a concrete implementation of StringDictionary as well but representing a single dictionary being able to resolve dictionary keys from it.

## DictionaryResourceKeysGenerator

The [DictionaryResourceKeysGenerator](https://github.bamtech.co/Android/Dmgz/blob/dab468f55ae77714caad3a88a52b92cc6a96e769/tools/src/main/java/com/bamtechmedia/dominguez/core/dictionary/DictionaryResourceKeysGenerator.kt) is a script formerly used to generate namespaced string resources for the legacy dictionaries implementation. It is fully deprecated and shouldn't be used.
