# Project Akela RFC

Just like in the Jungle Book, [Akela] is here to help you make important decisions.

![](images/akela.jpg)

## Why?

At this point we have a lot of `if (buildInfo.project == DISNEY)` type of checks, and although most of them are within a feature's configuration file, it is not enforced.

This can become very tricky with New Hulu coming up these kinds of checks outside of config defaults should be considered an anti-pattern.

Additionally the way that we currently provide configuration defaults are quite varying across the board, it would be nice to make that more of a recognizable pattern and standardize what kind of inputs result in a specific configuration value to be used.

## What?

This RFC proposes introducing a new API that simplifies the decision process of configuration defaults and eventually makes it impossible to make decisions based on the "current app" or "current device" without that value being overridable through the remote config.

The general idea is to introduce a mechanism that allows you to provide values if certain conditions are true, and ultimately come up with a default value if none of them are true. The actual evaluation of whether the condition is true is considered an implementation detail of `Akela`.

An example usage of this API could be as follows:

```kotlin
class AtmosConfig(private val akela: Akela) {
    fun isAtmosEnabled(): Boolean {
        return akela.seekAdviceOn<Boolean>("playbackCapabilities", "atmosEnabled")
            .defaultWhen(isRoProductDeviceOneOf(setOf("deviceA", "deviceB"))) { true }
            .defaultWhen(isTv and isAmazon) { true }
            .defaultWhen(isRoProductDevice("darcy") and isBuildTimeAtLeast(1579314970000L)) { true }
            .defaultWhen(isRoProductDevice("foster") and isBuildTimeAtLeast(1579312304000L)) { true }
            .getOrDefault(false)
    }
}

```

The `defaultWhen` method takes two arguments, the first is an expression and the second one is a value provider.

At runtime, when the method is called it would evaluate expressions in the order that they were added and when one is evaluated to `true` the method will return that value.

### Per Project/Market/Platform defaults

The approach above does still allow something very similar to the current `if (DISNEY) .. else ...` issue logic like you can see below.

```kotlin
val groupWatchEnabled: Boolean
    get() = akela.seekAdviceOn<Boolean>("groupWatch", "enabled")
        .defaultWhen(isDisney) { true }
        .getOrDefault(false)
```

However, the major difference is that (eventually) all decisions that are based on the "targeted app" can be overridden in config for another app.

Additionally, for cases where we are sure that different values need to be used for each of the different target apps we can define a convenience method that would require a lambda to be specified for each partner.

## How?

### Public API

The proposed public API would consist of an API to build [expressions](#evaluation-of-expressions) and an API that builds "Advice". An example of the latter one, that supports the usages mentioned above, could be something like the interface below.

```kotlin
interface Akela {

    fun <T> seekAdviceOn(featureGroup: String, topic: String): AdviceBuilder<T>

    interface AdviceBuilder<T> {

        fun defaultWhen(expression: AkelaExpression, value: AdviceProvider<T>): AdviceBuilder<T>

        fun getOrDefault(defaultProvider: AdviceProvider<T>): T

        fun getOrDefault(defaultValue: T): T
    }

    fun interface AdviceProvider<T> {
        fun get(): T
    }
}
```

### Evaluation of expressions

For the merging of remote config overrides we already build a set of tags that allow targeting specific device, this API design is using the same principle on that to be able to unify the way that we do remote override and local defaults.

Using `operator`and `infix` functions in Kotlin we can write the expressions used above using the following APIs.

```kotlin
fun interface AkelaExpression {
    fun evaluate(tags: Set<String>): Boolean
}

infix fun AkelaExpression.or(other: AkelaExpression) = AkelaExpression { this@or.evaluate(it) || other.evaluate(it) }

infix fun AkelaExpression.and(other: AkelaExpression) = AkelaExpression { this@and.evaluate(it) && other.evaluate(it) }

operator fun AkelaExpression.not() = AkelaExpression { !this@not.evaluate(it) }

data class TagExpression(val value: String) : AkelaExpression {
    override fun evaluate(tags: Set<String>): Boolean = tags.contains(value)
}

val isGoogle = TagExpression(value = "MARKET_GOOGLE")
val isAmazon = TagExpression(value = "MARKET_AMAZON")

val isDisney = TagExpression(value = "PROJECT_DISNEY")
val isHulu = TagExpression(value = "PROJECT_HULU")
val isStar = TagExpression(value = "PROJECT_STAR")

val isPartner = TagExpression(value = "PARTNER_DEVICE")
fun isPartner(name: String) = TagExpression("PARTNER_$name")

fun isPurchaseCountry(code: String) = TagExpression("PURCHASE_COUNTRY_$code")
```

The implementation of the `Akela` interface will be the one that knows about the current session/device tags and invoke the `AkelaExpression.evaluate(Set<String>): Boolean` method to determine if a default value is applicable.

## Impact

If we're going forward with this, the `AppConfigMap` interface and a bunch of fields on `BuildConfig` and `DeviceInfo`would be deprecated so replacing all of those invocations will be quite a lot of work. On the other hand this new API should be easily usable in new features/code.
