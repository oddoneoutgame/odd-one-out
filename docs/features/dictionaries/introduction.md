# Dictionaries

This page is in charge of explaining how we handle dictionaries in the Dmgz codebase.

## Introduction

Currently, in our codebase, we use runtime downloaded dictionaries to retrieve the texts we show. These dictionaries are maps holding dictionary keys and the corresponding values. You can check [Cypher](https://cypher.disneystreaming.com/dictionary/list) to see the latest dictionaries and their structure.

These dictionaries are created individually for every language, platform (so far mobile and tv) and app (so far disney, star and hulu) we support. They are also versioned. We can think of them as something like the following:

```kotlin
typealias DictionaryKey = String
typealias DictionaryValue = String

class Dictionary(resourceKey: String, map: Map<DictionaryKey, DictionaryValue>)

val dictionaries = listOf(
    Dictionary("application", mapOf("btn_play" to "Play")),
    Dictionary("accessibility", mapOf("main_button_a11y" to "Main button pressed")),
    // etc...
)
```

In order to make it easier to read, the dictionaries documentation is divided into different pages per topic.

## Quick access

- [Implementation](dictionaries-implementation.md)
- [Dictionary Pinning](dictionary-pinning.md)
- [Using dictionaries](using-dictionaries.md)
- [Legacy implementation](legacy-dictionaries.md)
- [Migration guide](dictionaries_migration_guide.md)
- [XML Challenge](xml-challenge.md)
- [Implementation extras](dictionaries-implementation-extras.md)
