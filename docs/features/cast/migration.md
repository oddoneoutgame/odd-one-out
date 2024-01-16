# Critical points for Chromecast v2 Intregratio

## Motivation

The current (as of Jan 2022) implementation of Chromecast within the D+ project is based on a [library](https://github.bamtech.co/Android/BamnetCast) whose development was started by Bamtech in 2016, and the disadvantages of such an old codebase are starting to show. Additionally, this codebase was being managed by a single person, and we would like to move away from that.

Some of the problems we have identified are:

* As a consequence of this library being a number of years old, some decisions were made based on older, less capable versions of the underlying cast framework provided by Google. The result is a codebase that feels too overcomplicated for what is really needed.
* Some decisions made on the design of the SDK are now deemed obsolete or incorrect in regards to the architectural choice of the current D+ app.
* A number of downsides arise from having the SDK live in a separate deployment (the Bamnet Cast library), the biggest of which is having to rely on versioning in order to push updates or fixes, which then needs to be synchronized with a D+ deployment in order to promote to production.
* The development of Chromecast features, particularly UI wise, has been constrained by the components that Google would provide out of the box, meaning that historically certain cosmetic or motion requirements by product were not able to be satisfied
* We'd like to transfer the knowledge and ownership over the feature over the D+ team, rather than a one man effort as it was up until now.

## Version selection

First step is introducing a config item flag to toggle between the new and old version of the solution.

This config item will have the new `cast` remote config namespace, but it wont be the main source of truth employed by the app to decide whether to use v1 or v2 solutions. Rather, this value is read when the config is retrieved and stored in the app's SharedPreferences.

The reason for this is that the V1 Chromecast solution initializes itself at launch, and so we need to be able to provide a readable value upon app launch that does not cause the startup to stall, in order to decide which implementation will be enabled for each client.

Because retrieving the remote config implies executing a network request, we have resorted to having a default value on all clients, that is stored in the `SharedPreferences`. This value is read on app launch and is kept stable during an app execution on the [Cast2EnabledValueHolder](https://github.bamtech.co/Android/Dmgz/blob/development/features/cast/src/main/java/com/bamtechmedia/dominguez/cast/Cast2EnabledValueHolder.kt) which is a Singleton instance. The value is then updated on each remote config retrieval, and it only becomes effective on the subsequent hard launch of the app, when the new value in the preferences is read again by `Cast2EnabledValueHolder`.

Although reading from the preferences (which is a disk I/O) is also an expensive operation, we have settled for it as the lesser evil compared to waiting for the remote config network request to complete.

In order to be able to test locally and on QA, we need a way to enforce this config locally, so we will add this as a transformation switch in Jarvis. The same principle remains: enabling it on Jarvis still requires 2 subsequent hard launches of the app in order to apply the change.

Due to this caveat and in order to aide in testing for this phase, an additional item in the Debug About section of the app has been added, which will always reflect the value on `Cast2EnabledValueHolder`:

![Debug about](images/debugabout.png)

## Configuration

We have prepared V2 to support remote configuration at initialization point, which means we make sure we delay the instantiation of `CastOptionsProvider` until the config is retrieved. This allows to make the basic parameters for cast configuration that were previously static to be declared in the `Cast2Config` class. These are at the time of writing this, the receiverId, message namespace and the expandedActivity name.

Because we planned the Amazon flavor not to include the `cast` lib, though, we had to split the config into a basic interface, [Cast2ApiConfig](https://github.bamtech.co/Android/Dmgz/blob/development/features/castApi/src/main/java/com/bamtechmedia/dominguez/cast/Cast2ApiConfig.kt), which is declared as Optional and will have no implementation on Amazon, and the full fledged `Cast2Config` class which includes all other implementation specific config parameters.

This `Cast2ApiConfig` being declared within the DI graph as an Optional also allow us to use it in V1 to enable/disable certain components depending on whether V1 is the chosen approach or not.

## CastOptionsProvider

Each solution has its own CastOptionsProvider. We wrapped both solutions' options provider and decide at runtime on each app launch which one will be picked up. This Wrapper will be declared as a replacement for those on the libs, on the google mobile version of the app through:

    <meta-data
    android:name="com.google.android.gms.cast.framework.OPTIONS_PROVIDER_CLASS_NAME"
    tools:replace="android:value"
    android:value="CastOptionsProviderWrapper" />

## Expanded Activity

The two implementations have different mechanisms to implement the ExpandedControls. While the old library uses a separate Activity, the new approach is based on a combined MiniController+Expanded view. However the Cast SDK requires to specify an activity name for the Notification action to work properly.

We must then declare an activity alias in the Mobile app in order to declare that one as a ExpandedControlsActivity. We are safe by declaring this with the older version of the library.

Both Activity declarations can coexist in the same Manifest, and only one will be used in runtime, so none of these changes should impact the current implementation.

## MediaRouteButton

The [MediaRouteButton](https://github.bamtech.co/Android/Dmgz/tree/development/features/castApi/src/main/java/com/bamtechmedia/dominguez/cast/button/MediaRouteButton.kt) from V2 is declared in all layouts. This view depends on a Presenter for inflation, and this presenter is added through a lifecycle observer, in a similar fashion as our suggested architecture proposes for fragments and activities.

This presenter will then inject a [ProxyMediaRouteButtonLifecycleObserver](https://github.bamtech.co/Android/Dmgz/tree/development/features/cast/src/main/java/com/bamtechmedia/dominguez/cast/button/ProxyMediaRouteButtonLifecycleObserver.kt) which decides based on the configuration whether to inflate the [MediaRouteButton](https://github.bamtech.co/Android/Dmgz/tree/development/features/chromecastApi/src/main/java/com/bamtechmedia/dominguez/chromecast/MediaRouteButton.kt) from v1 or the [MediaRouteButtonLifecycleObserver](https://github.bamtech.co/Android/Dmgz/tree/development/features/cast/src/main/java/com/bamtechmedia/dominguez/cast/button/MediaRouteButtonLifecycleObserver.kt), which then binds the ViewModel and Presenter, thus inflating the V2 MediaRouteButton layout.

Since this observer is declared as optional, and will only be

## CastController/MiniController

Because the ExpandedControls/MiniController approaches are fundamentally different in V1 vs. V2, adding them as a single wrapping view would yield to a more complex solution than having two views declared that in runtime will decide whether to inflate themselves or not.

In the case of V2's [CastControllerPresenter](https://github.bamtech.co/Android/Dmgz/blob/development/features/cast/src/main/java/com/bamtechmedia/dominguez/cast/castcontroller/CastControllerPresenter.kt) when preparing the v2 solution for remote config we had to stall the inflation of CastController/MiniController to ensure we don't eagerly trigger cast initialization before config was retrieved. This is done in [CastControllerLifecycleObserver](https://github.bamtech.co/Android/Dmgz/blob/development/features/cast/src/main/java/com/bamtechmedia/dominguez/cast/castcontroller/CastControllerLifecycleObserver.kt), which, similar to how its done for [MediaRouteButton], it lazily initializes the [CastControllerPresenter] only if V2 is enabled.

For V1, though, because the original view is simply a fragment contained in the BamnetCast library, we have added a [MiniControllerWrapper](https://github.bamtech.co/Android/Dmgz/blob/development/features/castApi/src/main/java/com/bamtechmedia/dominguez/cast/castcontroller/MiniControllerWrapper.kt) with a presenter that decides whether to inflate such fragment or not depending on the config.

So in `fragment_global_nav.xml` we see both `MiniControllerWrapper` and `CastController` are declared, each with different layout constraints. Only one of them will actually be inflated in runtime.

## Cast Play requester

The public interface to request a playback is pretty similar on both approaches, so [CastConnectionWrapper](https://github.bamtech.co/Android/Dmgz/blob/development/mobile/src/main/java/com/bamtechmedia/dominguez/cast/CastConnectionWrapper.kt) just exposes the two required functions with all needed params and relays the call to V1 or V2 according to the config.

## CastInitiator / VideoPlayerConnector

We follow two different approaches to automatically initiate the playback of the item currently being played locally when initiating a cast session from the player.

On V1, a lifecycleObserver is added that waits for a cast connection to happen and then retrieves all required information from the injected player instance and the corresponding viewModel. We can now just inject the `Cast2ApiConfig` object and only observe the connection event if V2 is not enabled.

On V2, the [MobilePlaybackActivity](https://github.bamtech.co/Android/Dmgz/tree/development/features/playback/src/main/java/com/bamtechmedia/dominguez/playback/mobile/MobilePlaybackActivity.kt) explicitly opts-in to this feature by subscribing to [VideoPlayerConnector](https://github.bamtech.co/Android/Dmgz/blob/development/features/castApi/src/main/java/com/bamtechmedia/dominguez/cast/requester/VideoPlayerConnector.kt)'s `startWhenConnected` method. The [Player] interface includes other callbacks to react upon loading, end and error states.

Similarly to how it's done on V1, this implementation only does any work if V2 is enabled.

## Other changes done in V1 `chromecast` module

[CastInitialization](https://github.bamtech.co/Android/Dmgz/tree/development/features/chromecast/src/main/java/com/bamtechmedia/dominguez/chromecast/CastInitialization.kt) has been changed from an explicit interface/implementation injected in the main app to a ProcessLifecycleObserver that triggers initialization upon app startup. The role of this class was to make sure that ChromecastBridge was initialized as soon as the app was launched. This has been changed as well:

All injections of ChromecastBridge have been replaced with [ChromecastBridgeProvider](https://github.bamtech.co/Android/Dmgz/tree/development/features/chromecast/src/main/java/com/bamtechmedia/dominguez/chromecast/ChromecastBridgeProvider.kt), which has a nullable method returning the actual ChromecastBridge, initialized lazily only if V2 is not enabled and returning null otherwise. This is done to prevent V1 from eagerly initializing V2.

Because of this lazy initialization, we miss the time window for the first device discovery when the app is launched. That means the app would miss such discovery and not show the MediaRoute button on the first launch, only after coming back to the underlying activity. Thus, we have to trigger discovery manually, in the same way we do for V2. This is done in [CastDeviceDiscovery](https://github.bamtech.co/Android/Dmgz/blob/development/features/cast/src/main/java/com/bamtechmedia/dominguez/cast/CastDeviceDiscovery.kt), which is triggered in the aforementioned `CastInitialization` object.

When V2 is enabled, ChromecastBridgeProvider will return a null ChromecastBridge and no initialization for V1 is done.

## Improvements of V2 over V1

* Subtitle and Audio tracks are now being handled through Custom Messaging and thus are now more stable. Using the direct method, i.e. the mediaTracks on the remoteMediaClient, produced erratic behavior when saving language settings on the user's profile.

* Subtitle Styling is added to the solution. Closed Caption's styling data is taken from the Accessibility settings and sent over to Chromecast on each connection to the SDK.

* Animations are added to toggle between the MiniController and the ExpandedControls.

* Most of the configuration parameters for the SDK are remote configurable.

* Exception handling is introduced in the solution, through incoming message processing from the Receiver. Messages are interpreted as errors and mapped into local Exception models.

* IMAX version switching now properly works by allowing the request for the same contentID to be sent over to the Receiver if the IMAX preference has changed.

* MiniController & ExpandedControls now properly survive rotation on Tablet devices (would yield an unstable state on V1)

* GW Reactions are also appended to the UI after joining a preexisting GW session; the space would be blank on V1.

* Both Dashboard and debug panels are now toggleable from Jarvis.

* Requests with the same contentId are now only blocked if the playbackState is not IDLE. This allows the solution to survive playback errors by reattempting to cast the same content that errored.
