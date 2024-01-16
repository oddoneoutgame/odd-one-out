# Lifecycle Callbacks in UI Architecture elements

Lifecycle callbacks are a key concept in the UI Architecture, their main goal being that the right things happen at the right time and to ensure that resources are not being used when they shouldn't be.

The lifetime of architectural elements is covered in the depth [here](lifetimes.md).

## Lifecycle events in UI Architecture elements

Different elements in the UI Architecture may be able to receive different lifecycle requests, or they expose method to register for receiving lifecycle events. In the interest of keeping classes small and focused, the latter is often the preferred option. Below is an overview of the different lifecycle events of all the elements covered in the lifetimes documentation.

### ViewModel

Although they don't know about an `androidx.lifecycle` ViewModels do also have a lifecycle. Typically this is one with a single lifecycle callback, which is `onCleared`. The only other way in which ViewModels are sort of aware of lifecycles is by knowing if its state stream has active subscribers, that typically means that the lifecycle of the matching Fragment is started.

### Fragment

A `Fragment` instance does not have one, but two lifecycles. Traditionally you would differentiate between these with `onCreate` vs `onCreateView` and `onDestroy` vs. `onDestroyView` but with the introduction of the `androidx.lifecycle` they have been split out into the `Fragment.lifecycle` and `Fragment.viewLifecycleOwner.lifecycle`. Both of these allow registering a `LifecycleObserver` and we typically only use the latter in this project. See [lifetimes](lifetimes.md#view-of-the-fragment) for more details.

## ProcessLifecycleOwner

The applications makes quite a lot of use of the [ProcessLifecycleOwner](https://developer.android.com/reference/android/arch/lifecycle/ProcessLifecycleOwner) that is part ot the `androidx.lifecycle` libraries. Check the documentation on that class for more details.

A feature module can define a `LifecycleObserver` and bind that into a Set to ensure that it gets added to the `ProcessLifecycleOwner`'s `Lifecycle`. This allows loose coupling since Dagger will take care of the integration, and for example, if the feature is only included on debug builds, then feature's code just won't be included in the release builds.

## `onStart` and configuration changes

onStart is often used to trigger a refresh or other actions that may or may not result in a network request. It is important to consider that, when an app is ran on a free-form window like a multi-window tablet or a Chromebook the `Fragment` and its view will be re-created, every time that the window size slightly changes. Every time it is re-created it goes through `onPause`, `onStop`, `onDestroy`, `onCreate`, `onStart` and `onResume` in that order. Therefore, triggering a network request every time the fragment's `onStart` is called, could result in a ton of network requests.

Network requests should therefore never be triggered directly from one of these methods. Some alternative options are:

- Invoking the ViewModel from this method and implement some sort of debouncing mechanism in the ViewModel
- Triggering the request from a ViewModel while it has active subscribers.

Below is an example of the second option. The state stream defined here will load data once per minute while it has active subscribers. Due to the `replay(1).refCount(3, SECONDS)` the stream will remain active for 3 seconds after the last subscriber unsubscribes. On configuration changes it will get a subscriber again before the stream is disposed, meaning that no new network request is triggered.

```kotlin
class TestViewModel : AutoDisposeViewModel() {

    val stateOnceAndStream: Flowable<State> =
        Flowable.interval(1, TimeUnit.MINUTES)
            .switchMapSingle { loadData() }
            .replay(1)
            .refCount(3, TimeUnit.SECONDS)

    private fun loadData(): Single<State> {
        TODO("Not yet implemented")
    }

    data class State(val value: String)
}
```
