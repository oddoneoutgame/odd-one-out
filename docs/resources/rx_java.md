# RxJava Operators By Example

This document contains a bunch of commonly used RxJava operators in this project with an explanation of what they do and, in some cases, what the Kotlin Flow equivalent would be

## `replay(1).refCount()`

This operator combination is often used to create a shared [state stream](../architecture/state-streams.md) that:

- subscribes to the upstream once when the first downstream subscriber subscribes.
- keeps the upstream subscription active until the last downstream subscriber disposes.
- replays the last emitted value to any new subscribers if there was a subscriber already.

### Kotlin Flow

In Kotlin Flow the closest equivalent of `replay(1).refCount()` would be the [stateIn](https://kotlinlang.org/api/kotlinx.coroutines/kotlinx-coroutines-core/kotlinx.coroutines.flow/state-in.html) operator when used with [SharingStarted.WhileSubscribed](https://kotlinlang.org/api/kotlinx.coroutines/kotlinx-coroutines-core/kotlinx.coroutines.flow/-sharing-started/-companion/-while-subscribed.html). The main differences are:

- `replay(1).refCount()` does not include `distinctUntilChanged()` behavior while `stateIn` does. If the upstream emits equivalent data twice `stateIn` will just swallow the second one and not emit it downstream while the RxJava variant would re-emit the same values.
- `stateIn` returns a `StateFlow` which is guaranteed to also have a value (where `null` is a possible value as well).
- `stateIn` also requires a coroutine scope that will guarantee the upstream subscription to be cancelled when that scope is cancelled while `replay(1).refCount()` could be more prone to memory leaks if the downstream does not dispose its subscription.

### Examples

Below are a bunch of small example pieces of code that demonstrate what using the `replay(1).refCount()` operator combination means for a stream.

All of these examples have this piece of code in common

```kotlin
val processor = PublishProcessor.create<Int>()
val flowable = processor.startWith(5)
```

Where each subscriber receives a `5` to start and then any values that are passed in using `processor.onNext(Int)`

The variations below are:

- [Returning observer without replay(1).refCount()](#returning-observer-without-replay1refcount)
- [Returning observer with replay(1).refCount()](#returning-observer-with-replay1refcount)
- [Returning observer with replay(1).refCount(1, SECONDS)](#returning-observer-with-replay1refcount1-seconds)
- [Multiple observers without replay(1).refCount()](#multiple-observers-without-replay1refcount)
- [Multiple observers with replay(1).refCount()](#multiple-observers-with-replay1refcount)

Returning observer scenarios are cases where one observer starts observing, then disposes and then a second observer starts observing. A common use case for this is a configuration change.

The Multiple observer scenarios are cases where there are two observers to the same stream instance. A common usecase for this is sharing state between multiple screens.

#### Returning observer **without** `replay(1).refCount()`

```kotlin
val processor = PublishProcessor.create<Int>()
val flowable = processor.startWith(5)

val disposable = flowable.subscribe { println("First observer received $it") }

// Output:
// First observer received 5

processor.onNext(7)

// Output:
// First observer received 7

disposable.dispose()
flowable.subscribe { println("Second observer received $it") }

// Output:
// Second observer received 5

processor.onNext(10)
// Output:
// Second observer received 10
```

#### Returning observer **with** `replay(1).refCount()`

With a returning observer there is actually no difference from the variant [without `replay(1).refCount()`](#returning-observer-without-replay1refcount) because the reference counter for number of subscribers is set to 0 and the replay cache cleared directly when the first subscriber disposes and thus the second subscriber causes a new upstream subscription which will get the value from `startWith`. As you'll see below the result here is different when you use pass in a [timeout](#returning-observer-with-replay1refcount1-seconds).

```kotlin
val processor = PublishProcessor.create<Int>()
val flowable = processor.startWith(5).replay(1).refCount()

val disposable = flowable.subscribe { println("First observer received $it") }

// Output:
// First observer received 5

processor.onNext(7)

// Output:
// First observer received 7

disposable.dispose()
flowable.subscribe { println("Second observer received $it") }

// Output:
// Second observer received 5

processor.onNext(10)
// Output:
// Second observer received 10
```

#### Returning observer **with** `replay(1).refCount(1, SECONDS)`

In this example the upstream subscription and replay-cache get kept around for a second after the moment that the stream has no more subscribers. Since it gets a new subscriber directly after that, that new subscriber gets the cached value and not the value passed to `startWith`.

```kotlin
val processor = PublishProcessor.create<Int>()
val flowable = processor.startWith(5).replay(1).refCount(1, TimeUnit.SECONDS)

val disposable = flowable.subscribe { println("First observer received $it") }

// Output:
// First observer received 5

processor.onNext(7)

// Output:
// First observer received 7

disposable.dispose()
flowable.subscribe { println("Second observer received $it") }

// Output:
// Second observer received 7

processor.onNext(10)

// Output:
// Second observer received 10
```

#### Multiple observers **without** `replay(1).refCount()`

```kotlin
val processor = PublishProcessor.create<Int>()
val flowable = processor.startWith(5)

flowable.subscribe { println("First observer received $it") }

// Output:
// First observer received 5

processor.onNext(7)

// Output:
// First observer received 7

flowable.subscribe { println("Second observer received $it") }

// Output
// Second observer received 5

processor.onNext(10)

// Output
// First observer received 10
// Second observer received 10
```

#### Multiple observers **with** `replay(1).refCount()`

```kotlin
val processor = PublishProcessor.create<Int>()
val flowable = processor.startWith(5).replay(1).refCount()

flowable.subscribe { println("First observer received $it") }

// Output:
// First observer received 5

processor.onNext(7)

// Output:
// First observer received 7

flowable.subscribe { println("Second observer received $it") }

// Output:
// Second observer received 7

processor.onNext(10)
// Output:
// First observer received 10
// Second observer received 10
```
