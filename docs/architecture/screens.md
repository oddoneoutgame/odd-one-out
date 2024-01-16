# Screens

In the [layers](layers.md), [lifecycles](lifecycle.md) and [lifetimes](lifetimes.md) documentation there are references to the concept `Screen`. This document serves to explain what is meant by that, some of the behavior of screens and what states a screen can have.

A `Screen` is not represented by any single class in the codebase but it is more conceptual, and described from a user's perspective.

A Screen may need data to load, it displays UI and it can respond to events from the user, system or other parts of the app. In most cases, there is only a single screen active at a time. Screens are usually either started on top of other screens (meaning the user can go back which in Android terminology is often called a back stack) or they replace another (potentially stack of) screens.

## Stacking Screens

Stacking screens means that the previous screen will not be destroyed and become `Inactive` when a new screen is started and becomes `Active`, and the user will be able to go back to that previous screen from the new screen.

Examples of screens started on top of other screens are:

- Opening a BrandLanding screen from the Home screen.
- Opening MovieDetail screen from Home screen.
- Opening the LoginPassword screen after the user has entered their email in the LoginEmail screen.

In all of these cases the user can go back to the previous screen, which will typically be in the same state as it was when the user navigated away from it. When one the three navigational events above happen, the "from screen" will transition to the [inactive state](#inactive-state) while the "to screen" gets the [active](#active-state) state. When the user does navigate back, the screen that was opened on top of the other screen transitions to the [destroyed state](#destroyed-state), and the screen that was inactive will transition back to active.

## Replacing Screens

Replacing screens means that the currently active screen, or stack of screens, get completely replaced by the new screen. The old screens will all transition to the [destroyed state](#destroyed-state).

Examples of screens replacing other screens are:

- Starting the ProfilePicker screen after a successful login will replace the Welcome, LoginEmail and LoginPassword screen.
- Starting the Welcome screen after the Splash screen animation is complete and content is loaded will replace the Splash screen.
- Starting the ProfilePicker screen after the user deleted the active profile will replace the entire back stack to ensure that the user can not go back to a home screen of the delete profile.

In all of these cases, there is nowhere to go back after navigating, which means that the user pressing on the new screen should not result in the user going back to the previous screen.

For both of these types of navigation there are methods defined in the [FragmentViewNavigation](https://github.bamtech.co/Android/Dmgz/blob/development/core-ui-framework/src/main/java/com/bamtechmedia/dominguez/core/navigation/FragmentViewNavigation.kt) class. Where `startFragment` will (with the default parameters) start a screen on top of the current screen, and `startFragmentAsBackStackRoot` will replace the current screen with a new screen. Note that if no screen has been started yet you should always use `startFragmentAsBackStackRoot`.

## State of a screen

The conceptual screen can have three conceptual states. Each of them are described below.

### Active State

A screen being active means that its UI is currently visible to the user. From this state a screen can transition into all other states, using either [stacking](#stacking-screens) or [replacing](#replacing-screens) navigation events.

### Inactive State

A screen being inactive means that one or more other screens have been stacked on top of this screen. The user can still get back to this screen, but it is currently not visible to the user. From this state a screen can transition into being `Active` if the user navigates back to this screen, or it can be `Destroyed` if the entire stack of screens gets replaced by a new screen. When this state is reached the [View](lifetimes.md#view-of-the-fragment) and the [Presenter](lifetimes.md#presenter) that show the UI of this state will be destroyed and all references to it from longer living elements should be removed.

### Destroyed State

A screen will get destroyed when the user either backs out of it after a [stacking](#stacking-screens) operation, or if it is being [replaced](#replacing-screens). This is a final state of the screen, meaning that no other states can be transitioned to once this state is reached. Also, all elements of the screen should be ready for garbage collection once this state is reached. From an implementation point-of-view, the transition to the destroyed state corresponds the the [ViewModel.onCleared()](lifetimes.md#viewmodel) being invoked.

## Multiple Active Screens

In some cases there might be multiple active screens. An example of this is the detail screen on tablets. The product requirement there is that the detail screen should be displayed as a smaller window, on top of the screen that was navigated from. So when opening a detail screen from the home screen, the home screen should still be displayed behind the detail page. This means that both the home and the detail screen are in the [Active state](#active-state).

## Background the application

It can be argued that pressing the home button, sending the app to the background, would result in an [inactive state](#inactive-state). However, according to the definition above, `View` of a Fragment exists while the screen is [active](#active-state), and is destroyed when the screen becomes inactive. Since the Fragment framework does not destroy the View of the Fragment, and just transitions the state of the fragment and its view to `STOPPED`, that would conflict with the rules mentioned above.

Since the screen is, at this point, still technically the active screen in the app, it is therefore still considered active, although certain elements in the screen should tie their updating/refresh logic to the `STARTED` state of the `Fragment` to ensure that the app does not use unnecessary resources in the background.

## Determining and reacting to changes

In some cases you may want to determine the current screen state, react to changes of the current screen state, or determine what the currently active screen is. There are a couple of places in the codebase which do this already, but work to centralise that still has to be done.

An example of a feature that implements some logic to determine the currently active screen is in the [BottomNavigationTintListener](https://github.bamtech.co/Android/Dmgz/blob/development/features/mainApp/src/main/java/com/bamtechmedia/dominguez/main/BottomNavigationTintListener.kt). That class compares the Fragment's which are currently started, and based on that comparison determines which Fragment's bottom navigation tint should be applied. For more details on this see the docs [here](https://github.bamtech.co/Android/Dmgz/blob/development/docs/HOW_TO_TINT_NAVIGATION_BAR.md).
