# Architecture

The general UI architecture attempts to follow many of the same concepts found within the [official Google docs](https://developer.android.com/topic/architecture).

The UI architecture is intended to be reactive and unidirectional, leveraging RxJava (migrating to Coroutines/Flow) in order to do so.

There are several main layers used within the architecture, each with their own responsibilities.

This documentation has been split up into four sections

- Project Architecture (TBD)
- [Screens](screens.md)
- [Layers within a screen](layers.md)
- [Lifetimes of elements within a screen](lifetimes.md)
- [Handling lifecycle events in a screen](lifecycle.md)

Since State Streams are such an integral part of the architecture there is a separate doc on that [here](state-streams.md).
