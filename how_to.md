# How To

The Glimpse implementation is built on top of the PageTracker logic implemented in the `mainApp` feature module. This logic determines what screens are deemed "active" to the user at any given time. The implementation uses this API internally, to determine when pageView/containerView tracking should occur.

## Hawkeye

> A master marksman, known for his extremely keen eyesight and accuracy

Hawkeye is the name of the internal framework within the codebase used to track pageView, containerView, and engagement events via Glimpse.

Tracking for a specific screen occurs through the use of the [`Hawkeye`](https://github.bamtech.co/Android/Dmgz/blob/development/features/analyticsGlimpseApi/src/main/java/com/bamtechmedia/dominguez/analytics/glimpse/hawkeye/Hawkeye.kt) interface. This can be injected directly in an Activity, Fragment, or passed into a wrapper class for analytics (i.e. CollectionAnalytics, MovieDetailAnalytics, etc).

The Activity/Fragment being tracked must then also implement both the `Hawkeye.Target` interface as well as the PageTracker's [`TrackedPage`](https://github.bamtech.co/Android/Dmgz/blob/development/features/mainAppApi/src/main/java/com/bamtechmedia/dominguez/main/pagetracker/TrackedPage.kt) interface. The `Hawkeye.Target` interface is meant to be explicit in order to prevent erroneously injecting a `Hawkeye` instance into certain fragments which should not be tracked (i.e. Tier2DialogFragment). Behind the scenes the [`Hawkeye.Factory`](https://github.bamtech.co/Android/Dmgz/blob/development/features/analyticsGlimpse/src/main/java/com/bamtechmedia/dominguez/analytics/glimpse/hawkeye/HawkeyeFactory.kt) will create a backing ViewModel (`HawkeyeViewModel`). The ViewModel will subscribe to the PageTracker state to determine when the page is considered "active" and only then will start sending Glimpse events.

```kotlin
class DetailFragment() : Fragment(), Hawkeye.Target, TrackedPage {

@Inject
lateinit var hawkeye: Hawkeye

override val glimpseMigrationId: GlimpseMigrationId = GlimpseMigrationId.DETAIL_FRAGMENT

...

}
```

For Fragments which do not use Hilt yet, a convenience function has been added.

```kotlin
class DetailFragment() : Fragment(), Hawkeye.Target, TrackedPage {

private val hawkeye by Hawkeye()

override val glimpseMigrationId: GlimpseMigrationId = GlimpseMigrationId.DETAIL_FRAGMENT

...

}
```

## Tracking a PageView Event

PageView tracking may occur when `markPage` is called on the `Hawkeye` interface. This method will set some page info for a screen and queue up a PageView event to be triggered when the screen reaches a state where it considered the active page (as determined by the `HawkeyeViewModel`).

If the screen is already active, then the PageView event will be triggered at the time of calling `markPage`. **It is important to emphasize that there should never be a need to override lifecycle methods to invoke `markPage`, as the framework internally handles when a page becomes active (i.e. overriding onStart/onResume to call markPage).** In most cases, it will be common to call `markPage` from the `init` constructor of the ViewModel.

Example:

```kotlin
init {
	hawkeye.markPage(HawkeyePage(...))
}
```

Commonly this would be abstracted into an "Analytics" class which contains all the analytics logic

```kotlin
// in DetailViewModel
init {
	detailAnalytics.markPage()
}
```

```kotlin
class DetailAnalytics @Inject constructor(
	hawkeye: Hawkeye
) {

	fun markPage() {
		hawkeye.markPage(HawkeyePage(...))
	}

}
```

The method `markPage` accepts a [`HawkeyePage`](https://github.bamtech.co/Android/Dmgz/blob/development/features/analyticsGlimpseApi/src/main/java/com/bamtechmedia/dominguez/analytics/glimpse/hawkeye/models/HawkeyePage.kt) which holds additional info needed in order to track the PageView.

## Tracking a ContainerView Event

ContainerView tracking can be performed by calling `hawkeye.markContainers` and passing a list of [`HawkeyeContainer`](https://github.bamtech.co/Android/Dmgz/blob/development/features/analyticsGlimpseApi/src/main/java/com/bamtechmedia/dominguez/analytics/glimpse/hawkeye/models/HawkeyeContainer.kt).

Example:

```kotlin
hawkeye.markContainers(
 	listOf(
    	HawkeyeContainer(
        	containerLookupId = CONTAINER_ID
        	containerType = GlimpseContainerType.CTA_BUTTON,
        	containerKey = "onboarding_cta",
        	elements = listOf(
        		HawkeyeElement.StaticElement(
        			containerLookupId = CONTAINER_ID,
        			elementLookupId = ELEMENT_LOOKUP_ID,
        			elementId = elementId,
        			elementType = ElementType.TYPE_BUTTON,
        			elementIdType = ElementIdType.BUTTON,
        			elementIndex = 0,
        			contentType = "other",
            		programType = "other"
				)
			)
		)
)
```

ContainerView tracking will only occur after a Page is set using `markPage`. **If `markContainers` is called before `markPage` any ContainerViews passed will be queued up and fired once a `markPage` is invoked (assuming the page is also "active" at that time).**

In some cases ContainerView tracking is much more complex (Collection and Detail pages). For a detailed breakdown of how tracking is performed on these pages see the [visible containers approach](https://github.bamtech.co/Android/Dmgz/blob/development/docs/GLIMPSE_VISIBLE_CONTAINERS_APPROACH.md). NOT YET UPDATED.

### Purpose of containerLookupId

The `containerLookupId` is used to store the necessary info about a container and any elements. When an input or interaction event occurs this ID is also passed along in order to retrieve the necessary container and element info. This ID should be unique and is created and provided by the feature. **It is important to note that this IS NOT the same thing as the containerViewId.** The `containerViewId` logic (that existed in the v2 implementation) is no longer exposed to the features and is internal to the `HawkeyeViewModel`.

## Tracking Interaction/Input Events

Simply call the corresponding method on the `Hawkeye` interface, passing the necessary info about the element to be tracked.

```kotlin
hawkeye.fireInteraction(
	containerLookupId = CONTAINER_ID,
	elementId = "done",
	interactionType = InteractionType.SELECT
)
```

```kotlin
hawkeye.fireInput(
	containerLookupId = CONTAINER_ID,
	elementId = "search_input",
	inputValue = "test",
	inputType = InputType.INPUT_FORM
)
```

### StaticElement, DynamicElement, and CollectionElement

These exist in an effort to clean up the calling sites where Glimpse tracking occurs.

- **StaticElement**
    - Used when the elementId does not change. For example, a "Done" or "Save" button on the edit profile screen.
- **DynamicElement**
    - Typically used for Elements which have Input events associated with them. These elements usually have elementIds which change. For example, a search field within search or the auto play toggle on edit profile.
- **CollectionElement**
    - Represents an Element tied to a Polaris collection. Additional properties are required when tracking these elements.

DynamicElement

If the element has a dynamic elementId (i.e. `auto_play_on` vs `auto_play_off`). You will need to set and pass an [`ElementLookupId`](https://github.bamtech.co/Android/Dmgz/blob/development/features/analyticsGlimpseApi/src/main/java/com/bamtechmedia/dominguez/analytics/glimpse/hawkeye/ElementLookupId.kt) as well.

```kotlin
hawkeye.fireInput(
	containerLookupId = CONTAINER_ID,
	elementLookupId = AUTO_PLAY
	elementId = "auto_play_on",
	inputValue = "on",
	inputType = InputType.TOGGLE
)

companion {
  private const val AUTO_PLAY = ElementLookupId("auto_play_toggle")
}
```

Internally, the framework will use the `containerLookupId` and `elementLookupId` to pull out the necessary info for the event. These IDs should match the IDs that were passed when the `HawkeyeContainer` was created.
