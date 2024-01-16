# State Streams

State streams are a foundational concept in this codebase. You'll see them everywhere and therefore it is good to have a common understanding of them.

The primary goal of a state stream is to model a observable state that can change overtime.

The section below defines the contract of a State Stream as we intend to use it in the application. *intend* is an important word in that sentence because, at the time of writing this, most state streams in the project adhere to parts of this contract, but not necessarily all of it.

## Contract of a State Stream

All state streams:

- have a single current value at any point in time.
- emit the current value to a new subscriber directly when it subscribes
- only emit new values if something actually changed
- don't emit exceptions through on error

### BehaviorProcessor as a State Stream

A BehaviorProcessor by itself can almost be considered a state stream if it is created with a default value. The only part of the contract that it doesn't implement is uniqueness, but a `distinctUntilChanged()` fixes that.

Also there is no guarantee that it always has a value unless you create it with `createDefault` method.

> In case you're unfamiliar with them, `Processor` in RxJava is the `Flowable`-equivalent of a `Subject` in `Observable`. So a `BehaviorProcessor` is just a `BehaviorSubject` with additional functionality like backpressure that is available on a `Flowable`.

```kotlin
val processor = BehaviorProcessor.createDefault(1)

val stateOnceAndStream: Flowable<Int> = processor.distinctUntilChanged()
```

There are a lot of cases where this might work, but it doesn't really fully adhere to a reactive paradigm where state is often the result of other state and/or actions. Especially when multiple things that affect the change may happen in parallel it becomes really hard to manage a correct state and avoid concurrent modification issues.

> When we move to Kotlin Flow a [MutableStateFlow](https://kotlin.github.io/kotlinx.coroutines/kotlinx-coroutines-core/kotlinx.coroutines.flow/-mutable-state-flow/index.html) can be considered the equivalent of `BehaviorProcesser`. The major advantages there being that it supports nullable types and actually already implements the `distinctUntilChanged` internally.

### Loading State Stream

The loading of data can have multiple states. To be able to model the state of a screen effectively you'll quite often need to first model the state of an action as a state stream.

Effectively these kind of state stream are a `Single<T>` which gets converted to a `Flowable<State<T>>` that will emit a loading state when it starts loading data converts any exception emitted by that `Single<T>` into an error state.

A typical RxJava example of this could be as follows

```kotlin
fun loadDataStream(): Flowable<State> =
    repository.dataOnce()
        .map { State(data = it) }
        .toFlowable()
        .startWith(State(loading = true))
        .onErrorReturn { State(error = it) }
```

In some cases a loading state stream could also contain an internal retry which would result in it first emitting a loading state. For example if the load fails twice and it has an automatic retry every 2 seconds it would result in a stream emitting the sequence `Loading -> Failed -> Loading -> Failed -> Loading -> Loaded`

## Event-Driven State Streams

### Reactive/Composite State Streams

This is one of the most common types of state streams in the app used to model the state of a screen. They composite state stream is one that either combine or reduce state from other state streams. Those other state streams can be [BehaviorProcessors](#behaviorprocessor-as-a-state-stream), [Loading State Streams](#loading-state-stream) or [Event-Driven State Streams](#event-driven-state-streams).

A very basic example of such a state stream is one for the active account id. Since there is no guarantee that there is an active account, RxJava does not accept `null` values and a state stream needs to always have a value (per contract above), this type of state is often modeled through Guava's `Optional`

```kotlin
class ActiveProfileViewModel(sessionStateRepository: SessionStateRepository) {
  val accountIdOnceAndStream: Flowable<Optional<String>> =
    sessionStateRepository.stateOnceAndStream
      .map { Optional.fromNullable(it.account?.id) }
      .startWith(Optional.absent())
      .distinctUntilChanged()
      .replay(1)
      .refCount()
}
```

The stream here is using `replay(1).refCount()` to ensure that new subscribers always get the most recently emitted state if it is still being used. See our docs on [replay(1).refCount()](../resources/rx_java.md#replay1refcount) for more details.

Let's go one step further and say we want to have a state stream of the watchlist of the current profile.

The SessionStateRepository emits on every change in the session, so for example also when a profile name is changed. This change does affect the watchlist of the activeProfile so it makes sense to reduce the state stream from the entire session to just the profileId, put a `distinctUntilChanged()` on that to ensure that the watchlist is only reloaded if the active profile actually changed.

```kotlin
class ActiveProfileViewModel(
  sessionStateRepository: SessionStateRepository,
  private val watchlistDataSource: WatchlistDataSource
) {
  val accountIdOnceAndStream: Flowable<Result<Watchlist?>> =
    sessionStateRepository.stateOnceAndStream
      .map { Result.success(it.account?.activeProfileId) }
      .distinctUntilChanged()
      .switchMap { loadWatchlist(it.getOrNull) }
      .startWith(State.Loading(profileId = null))
      .distinctUntilChanged()
      .replay(1)
      .refCount()

  private fun loadWatchlist(profileId: String?): Flowable<State> {
    if (profileId == null) return Flowable.just(State.NoActiveProfile)
    return Single.just(State.Loading(profileId))
      .concatWith(watchlistDataSource.watchlistOnce(profileId).onErrorReturn { State.Failed(profileId, it) })

  }
  sealed interface State {
    val profileId: String? get() = null

    object NoActiveProfile : State
    data class Loading(override val profileId: String?) : State
    data class Watchlist(override val profileId: String, val items: List<Item>) : State
    data class Failed(override val profileId: String, val cause: Throwable) : State
  }
}
```

#### Action Driven State Stream

Action driven state streams can be used either by itself or serve as input to another state stream. The idea here is very much similar to MVI where actions get converted into a state. When one action gets emitted that typically results in first a `Loading`/`Processing` state to be emitted, followed by either `Loaded`/`Done` or `Failed`

```kotlin
val actionProcessor = PublishProcessor.create<SomeAction>()

val stateOnceAndStream: Flowable<State> =
  actionProcessor.switchMap { handleAction(it) }
    .startWith(State.Idle)
    .replay(1)
    .refCount()

fun handleAction(action: LoadAction): Flowable<State> {
  return Single.just(State.Loading(action.id))
    .concatWith(
      repository.loadDataOnce(action.id)
        .map { State.Loaded(it) }
        .onErrorReturn { State.Failed(it) }
    )
}

data class LoadAction(val id: String)

sealed interface State {
  object Idle : State
  data class Loading(val id: String) : State
  data class Loaded(val data: Data) : State
  data class Failed(val cause: Throwable) : State
}
```
