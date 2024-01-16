# Collection Architecture Refactor

## Why?

The current implementation of collections is based on the `CollectionViewModel` which extends the `ReactiveViewModel`. The usage of the `ReactiveViewModel` does not fit in the current UI Architecture approach anymore. This proposal is to create a new `CollectionViewModel` implementation that extends the `androidx.lifecycle.ViewModel` and provides a state stream.

The current setup works with huge master `AbstractCollectionHiltFragment` & `CollectionFragmentHelper` class that contains most of the UI logic. This is something that doesn't fit in the current UI Architecture anymore and should be moved to smaller presenter implementations with each its own responsibility.

Another problem of the current setup is related to the nested collection approach which is used for movie, series, sport, league & team collection pages. The UI for this collection page is based on the available screen width. So for mobile, there is a button filter on top of the page to select the desired sub collection, while for the tablet & STB a screen width tab bar is used to select a sub collection. It has been set up as 2 different fragments because it didn't completely work with the current UI architecture. The problem here is that the user might end up with the wrong fragment after resizing the app window on for example FreeFrom or Chromebook devices.

## What?

This proposal is based on the new UI Architecture that is described [here](https://github.bamtech.co/Android/Dmgz/blob/development/docs/UI-ARCHITECTURE.md).

### Feature flag

There will be a feature flag to enable the new architecture on fragment level. That allows us to work on the refactor in different teams (or even a pair of programmers).

**Sample code**

```kotlin
class CollectionArchitectureRefactorConfig() {
    
    private val enabledMap = mapOf(
        "brand" to true,
        "espn" to false,
        "home" to true,
    )
    
    fun isEnabled(featureName: String): Boolean = enabledMap.getOrDefault(featureName, false)
}
```

### CollectionViewModel

Implementation of `androidx.lifecycle.ViewModel` that is responsible for managing the data for the `CollectionPresenter`.

**Responsibilities**

* Observing state stream of `CollectionRepository` for the main collection and an additional state stream of `CollectionRepository` for the selected sub collection.
    * Subscribe to `CollectionContentInteractor.subCollectionIdentifierSubject` to get notified when the user selects a different `CollectionAsset` by clicking on either a tab in the tab layout or filter button to load a different sub collection.
    * Instances of the `CollectionRepository` should be obtained from the `RepositoryHolder`.  
* Combining the main collection and optional sub collection data and map it to `CollectionViewModel.State`.
* Handle errors with `ErrorMapper`?.

**Sample code**

```kotlin
/**
 * @property collection is the main [Collection].
 * @property subCollectionIdentifier is optional the [CollectionIdentifier] in case of a sub
 * collection is available.
 * @property subCollection is the optional [Collection] in case of a sub collection is available.
 * @property isOffline
 * @property isLoading
 * @property error
 */
data class State(
    val collection: Collection,
    val subCollection: Collection?,
    val isOffline: Boolean,
    val isLoading: Boolean,
    val error: Throwable?,
    val configuration: Configuration,
) {
    val subCollectionIdentifier: CollectionIdentifier?
        get() = subCollection?.collectionGroup?.collectionIdentifier
}


/**
 * Configurable options for displaying the collection.
 */
data class Configuration(
    val displayContentRestrictedItemWhenEmpty: Boolean // This could be based on a new AppConfig property instead of based on checking Fragment type. 
    // Add any other relevant configurations for displaying the collection.
)
```

### CollectionRepository

The main responsibility of the `CollectionRepository` is to provide the `Collection` where `ContentSets` and `LiveNow` data have been updated.

**Responsibilities**

* It provides a state stream that combines the data from `DehydratedCollectionRepository`, `ContentSetRepository` and `LiveNowStateProvider`.
    * Instances of the `DehydratedCollectionRepository` and `ContentSetRepository` should be obtained from the `RepositoryHolder`.
* It emits a state with the `Collection` object where the `ContentSet`s and `LiveNow` data have been updated.
    * Each `Collection` should be updated with `ContentSet` data by calling the `Collection.copyWithContentSets` method.
    * Each `ContentSet` in the `Collection` should be updated with `LiveNow` data by calling the `ContentSet.copyWithLiveNow` method.
* Implement logic that resolves required ContentSets before emitting the State with the updated collection.
    * The requirements for content sets are specified by `CollectionRequestConfig` as `resolveSetTypes` and `numSetsRequired`. See the `shouldResolveSet` and `ensureMinimumNumberOfSets` methods in the legacy `CollectionsRepositoryImpl` implementation.
* Implement `ContentSetAvailabilityHint` to hide ReferenceSets that most-likely have no content. This is to prevent the user from seeing placeholder for a split second. Note that the request to load the `ContentSet` should be made anyway to ensure there still is no content.
    * The filtering is currently done by the `CollectionItemsFactory` implementation.
    * The additional request to load content for the hidden ReferenceSet is being done by the `loadNoContentExpectedSets` method in the `CollectionViewModel` implementation.
* Implement logic to filter out `ContentSet`s when these are empty. This is currently done by the `CollectionItemsFactory` implementation.
* Observing collection / set invalidation streams of `CollectionInvalidator` class and obtain related repositories to request a refresh of data. Some examples:
    * After watching any content, the `ContinueWatchingSet` needs to be refreshed.
    * After adding / removing assets from the watchlist, the `WatchlistSet` needs to be refreshed.

### DehydratedCollectionRepository

The main responsibility of the `DehydratedCollectionRepository` is to provide the dehydrated `Collection` for given `collectionIdentifier`. Unsupported sets will be filtered out and style / type overrides will be applied to the collection.

**Responsibilities**

* Providing a state stream with the dehydrated `Collection` for given `collectionIdentifier`.
    * Inject `CollectionsRemoteDataSource` to load the actual content. This class is responsible for selecting the desired request (`collectionBySlug` or `collectionByGroupId`).
* Implement `ContainerStyleAllowList` to filters out unsupported containers before emitting `Collection` to the `CollectionRepository`.
* Implement `ContainerOverrides` to apply container style / type overrides before emitting `Collection` to the `CollectionRepository`.
* Implement `CollectionCache` to cache objects / requests.

**Sample code**

```kotlin
interface DehydratedCollectionRepository {

    val stateOnceAndStream: Flowable<State>

    fun refresh(): Completable
    
    data class State(
        val collection: Collection,
        val loading: Boolean = false,
        val error: Throwable? = null,
    )
}
```

### ContentSetRepository

The `ContentSetRepository` is used to load the initial ContentSet for given `setId` and handle `ContentSet` pagination requests. It will provide a state stream that emits a state with latest `ContentSet`, `loading` and `error`. The `setId` will be used as constructor parameter, so there will be `ContentSetRepository` instance per `setId`.

**Responsibilities**

* Responsible for loading `ContentSet` for initial load & pagination request when supported for set.
    * Inject `RemoteContentSetDataSource` to load the actual content. This class is responsible for selecting the desired request (`getSet` or `getCWSet`).
    * Previously the `Collection.isPagingSupported` was used to check if a pagination request is enabled for set. Since it's using the `Collection.contentClass` here and collection is not available here, this probably needs to be split up into collection and set level checks.

**Sample code**

```kotlin
interface ContentSetRepository {

    val stateOnceAndStream: Flowable<State>
    
    fun loadNextPage(): Completable
    
    fun refresh(): Completable
    
    data class State(
        val contentSet: ContentSet?,
        val loading: Boolean = false,
        val error: Throwable? = null,
    )
}
```

### RepositoryHolder

The `RepositoryHolder` is used to hold the `CollectionRepository`, `DehydratedCollectionRepository` and `ContentSetRepository` instances. It would be a scoped instance, the presenter/groupie items would be able to inject it, obtain the ContentSetRepository for the Set they are displaying, and call the methods like loadMore and refresh. This would decouple the Collections from Sets in the ViewModel/Domain layer already and you avoid the pass-through stuff where a CollectionRepository shares responsibility in loading more data of the Set.

**Responsibilities**

* The repositories mentioned above should be accessible via a scoped RepositoryHolder instance.
* The `ContentSetRepository` instance could be obtained to request next page of set from presenter/groupie item layer.

**Sample code**

```kotlin
interface RepositoryHolder {
    
    fun getOrCreateContentSetRepository(setId: String): ContentSetRepository
    
    fun getOrCreateCollectionRepository(collectionIdentifier: CollectionIdentifier): CollectionRepository
}
```

### FeatureXCollectionFragment

Implementation of `androidx.fragment.app.Fragment` that holds the reference to [FeatureXCollectionLifecycleObserver](#featurexcollectionlifecycleobserver).

**Responsibilities**

* Register `FeatureXCollectionLifecycleObserver` to fragments view lifecycle.
* Capture `KeyEvent`s by implementing `OnKeyDownHandler` and pass `KeyEvent` to `CollectionViewFocusHelper`.
* Keep as clean as possible.

**Sample code**

```kotlin
@AndroidEntryPoint
class SampleCollectionFragment : Fragment(R.layout.fragment_sample_collection) {

    @Inject
    lateinit var lifecycleObserver: Provider<SampleCollectionLifecycleObserver>

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        viewLifecycleOwner.lifecycle.addObserver(lifecycleObserver.get())
    }
}
```

### FeatureXCollectionLifecycleObserver

Implementation of `DefaultLifecycleObserver` that works as bridge between the `CollectionViewModel` and `FeeatureXPresenter` by passing state updates to the presenter.

**Responsibilities**

* Responsible for observing the CollectionViewModel state and passing state to the feature [FeatureXCollectionPresenter](#featurexcollectionpresenter).

**Sample code**

```kotlin
class SampleCollectionLifecycleObserver @Inject constructor(
    private val viewModel: CollectionViewModel,
    private val presenter: SampleCollectionPresenter,
    private val rxSchedulers: RxSchedulers,
) : DefaultLifecycleObserver {

    override fun onStart(owner: LifecycleOwner) {
        viewModel.stateOnceAndStream
            .observeOn(rxSchedulers.mainThread)
            .autoDisposable(owner.scope(Lifecycle.Event.ON_STOP))
            .subscribe(
                { state -> presenter.bind(state) },
                { Timber.e(it) }
            )
    }
}
```

### FeatureXCollectionPresenter

Presenter class to handle view logic for this feature specifically.

**Responsibilities**

* Create the `ViewBinding` reference for fragments layout.
* Create the `CollectionPresenter` instance with the required views and configurable options.
* Pass `CollectionViewModel.State` to a [CollectionPresenter](#collectionpresenter) to handle common presenter logic.
* Process `CollectionViewModel.State` and handle view logic specifically to this feature.

**Sample code**

```kotlin
class SampleCollectionPresenter @Inject constructor(
    private val fragment: Fragment,
    private val collectionPresenterFactory: CollectionPresenter.Factory,
) {

    private val binding = FragmentSampleCollectionBinding.bind(fragment.requireView())
    private val collectionPresenter = collectionPresenterFactory.create(
        fragment.viewLifecycleOwner,
        CollectionPresenter.View(binding.collectionRecyclerView),
        CollectionPresenter.Config(RecyclerViewSnapScrollHelper.SnapType.Center)
    )

    fun bind(state: CollectionViewModel.State) {
        collectionPresenter.bind(state)
        // Handle presenter logic specific to this feature here
    }
}
```

### CollectionPresenter

The `CollectionPresenter` is the presenter implementation that contains common presenter logic. The main responsibility is to map `CollectionViewModel.State` to Groupie items with [CollectionItemsFactory](#collectionitemsfactory) and bind these to the adapter for the collection `RecyclerView`.

To be more flexible in what needs to be handled in the `CollectionPresenter`, it's possible to provide specific `View`s via the `CollectionPresenter.View` data class and other configurable options via the `CollectionPresenter.Config` class.

**Responsibilities**

* Set up defaults for given views.
    * Set adapter to `collectionRecyclerView`.
    * Nullify `itemAnimator` to disable default `RecyclerView` animations that could lead to conflicting View animations.
    * Set `FocusTag`s like `FocusTag.RootCollectionRecyclerView`.
    * See `CollectionFragmentHelper` for the current setup.
* Bind groupie items to RecyclerViews adapter. This could be:
    * Any container groupie item provided by the [CollectionItemsFactory](#collectionitemsfactory).
    * Loading state while loading the collection data. This is currently handled as part of fragments layout, a new groupie item needs to be created.
    * Empty state in case there are no items to show. This is currently handled as part of fragments layout, a new groupie item needs to be created.
    * `ErrorItem` in case an error occurred, this should be provided by the `ErrorStateFactory`.
    * `ContentRestrictedItem` in case content is restricted and `Config.displayContentRestrictedItemWhenEmpty` is true. This should be disabled for home & watchlist.
* Announce a11y page name when collection title is available. See `A11yPageNameAnnouncer`.
* Handle fragment / content transition with `FragmentTransitionPresenter`.
* Handle focus for focus navigation based devices like STB.
    * Request initial focus after fragment / content transition is done. In most cases, this will be the most top left tile. In case of a tabbed collection, the first tab should be selected.
    * Restore last focused view with `LastFocusedViewHelper`.
* Integrate `RecyclerViewStateHandler` to save / restore RecyclerView state.
* Integrate `RecyclerViewSnapScrollHelper` to setup scroll behavior.

**Sample code**

```kotlin
/**
 * Implementation of [CollectionPresenter] that is responsible for handling common view logic on collection pages.
 */
class CollectionPresenterImpl @AssistedInject constructor(
    private val adapter: GroupAdapter<GroupieViewHolder>,
    private val collectionItemsFactory: CollectionItemsFactory,
    private val recyclerViewSnapScrollHelper: RecyclerViewSnapScrollHelper,
    @Assisted private val viewLifecycleOwner: LifecycleOwner,
    @Assisted private val view: CollectionPresenter.View,
) : CollectionPresenter {

    init {
        view.collectionRecyclerView.adapter = adapter
        view.collectionItemDecorations.forEach { decoration ->
            view.collectionRecyclerView.addItemDecoration(decoration) 
        }
        recyclerViewSnapScrollHelper.init(
            viewLifecycleOwner,
            view.collectionRecyclerView,
            view.collectionSnapType
        )
    }

    override fun bind(state: CollectionViewModel.State) {
        val items = collectionItemsFactory.createItems(state.collection)
        adapter.update(items)
    }
}
```

```kotlin
/**
 * Views references for [CollectionPresenter].
 * @property collectionRecyclerView is the main [RecyclerView] to show collection content, loading or empty state.
 * @property collectionSnapType [RecyclerViewSnapScrollHelper.SnapType] to define scroll behavior.
 * @property collectionItemDecorations is a List of [RecyclerView.ItemDecoration] that will be added to the [collectionRecyclerView].
 */
data class View(
    val collectionRecyclerView: RecyclerView,
    val collectionSnapType: RecyclerViewSnapScrollHelper.SnapType? = null,
    val collectionItemDecorations: List<RecyclerView.ItemDecoration>? = null,
)
```

### CollectionItemsFactory

The `CollectionItemsFactory` is responsible for mapping the `Container` / `Asset` objects from given `collection` or `subCollection` into groupie items. This will be exactly the same as what we have right now.

### TODOs and other subjects to take care of

* Use `Set` instead of `Container` to resolve ContentSet. It seems like `Container` is currently required because of the `mapVariables` method that takes the `style`. By passing `Set` and `style` individually, it might be simpler to resolve the ContentSet as we don't have to copy the `Container` instance with latest `Set` anymore.
* Find out how to implement analytics.
* Find out how to implement brand / heroInteractive VideoArt playback with this new approach. Check if `AssetTransitionHandler` & `AssetVideoArtHandler` could be re-used.
* Find out how to implement `OfflineViewModel` with the retry logic. Current `OfflineViewModel` still uses the deprecated `ReactiveViewModel` and may need to be re-implemented.
* All collection fragments use a `CollectionIdentifier` as input for the `CollectionRepository` to load a specific collection. It'd be nice to have something like a `CollectionArguments` data class that can be parsed into a arguments bundle to keep fragment creation the same for all instances.

### SampleCollectionFragment

To be able to make progress on the new CollectionViewModel implementation without touching the current setup, it would be helpful to create at least 2 different sample collection fragments that supports a basic & nested collection setup.

The idea is to start with the simple setup as `SampleCollectionFragment`. The Fragment implementation would live in a new feature module named `features:sampleCollection`. The `SampleCollectionFragment` should be accessible for debug builds only, which could be managed by adding the `features:sampleCollection` dependency as `debugImplementation` project. A `SampleCollectionDeeplinkHandler` with a custom deeplink schema could be used to open the fragment. The `features:sampleCollection` module would have dependencies on at least the `features:collectionsApi` to have access to the new `CollectionViewModel`, `CollectionPresenter` and so on.

The following adb deeplink command could be used to navigate to the SampleCollectionFragment.

```text
adb shell am start -W -a android.intent.action.VIEW -d https://starplus.com/app/sample-collection
adb shell am start -W -a android.intent.action.VIEW -d https://disneyplus.com/app/sample-collection
```

### Use cases

#### AbstractCollectionHiltFragment

The `AbstractCollectionHiltFragment` is an abstract Fragment implementation that is used by mainly all collection related fragments. It is still driven by the old app architecture which is based on the `ReactiveViewModel`. With this refactor, we're gonna switch over to new architecture based on a is driven by `androidx.lifecycle.ViewModel`.

Summing up the different subclasses of the `AbstractCollectionHiltFragment` with each its own specialities:

**AllSportsPageFragment**

* No specialities

**BrandFragment**

* taking background, logo, videoart (tv only) from collection to show as header.

**CollectionTabFilterFragment / CollectionTabbedFragment**

* Content API delivers a collection where the first container has `tabs` as style.
    * Selecting a tab will trigger a new collection request for `collectionIdentifier` that is provided by active tab.

**DiscoverFragment**

* No specialities

**EditorialFragment**

* taking background, logo, videoart (tv only) from collection to show as header.

**LandingPageFragment**

* Content API delivers one huge collection response. Each set in the response represents a tab filter.
    * Selecting a tab will filter the collection response and show active set as content.

**OriginalsPageFragment**

* taking logo from collection to show as header.

**SimpleCollectionFragment**

* No specialities

**SportsHomeFragment**

* No specialities

**SuperEventFragment**

* No specialities

**TeamPageFragment**

* No specialities

**WatchlistFragment**

* Using a `CollectionFilter.ContentIdsFilter` to filter out recently removed assets as local fallback. However, I'm not sure if this is still needed.

#### Other usages legacy CollectionViewModel

The `CollectionViewModel` is mostly used by the `AbstractCollectionHiltFragment`, but there is more use cases to migrate to the new `CollectionViewModel`, like the search screen and the choose avatar screen.

**Search**

* The `SearchViewModel` is more or less a copy of the legacy `CollectionViewModel` with some added functionality to handle search results and suggestions. The `SearchViewModel` is still using the deprecated `ReactiveViewModel` and needs to be migrated as well.
* We need to find out whether we can use the new `CollectionViewModel` or `CollectionRepository` as replacement.

**Choose avatar**

* The `AvatarCollectionFetcher` is implemented in the `ChooseAvatarViewModel` which uses the legacy `CollectionViewModel` under the hood.
* We need to find out whether we can use the new `CollectionViewModel` or `CollectionRepository` as replacement.

### Acceptance criteria

* Support different UI setups based on Androids resource qualifier. Right now, we have 2 different Fragment implementations for the tabbed collections. With the new setup, this should be the same fragment + ViewModel that could switch between UI after resizing the window.
* The loading, empty & content restricted state should be provided as Groupie items. This is the responsibility of the `CollectionPresenter`.
* More TBD.

### Out-of-scope

Despite the fact that it would be great to opportunity to include Kotlin Coroutines, this refactor will have that much impact already that it might be wise to leave Kotlin Coroutines out-of-scope.

## How?

1. Create `features:sampleCollection` module for debug builds only.
    1. Add `SampleCollectionFragment` with setup for development purposes. See [SampleCollectionFragment](#samplecollectionfragment) for responsibilities.
    2. Add dependency on `features:collectionsApi` for access to the new `CollectionViewModel`.
    3. Add dependency on `features:deeplinkApi` to create a custom `DeeplinkHandler` to open the `SampleCollectionFragment`.
    4. Add support for loading & error state.
2. Add `CollectionViewModel`  and relevant implementations to `feature:collections`/`feature:collectionsApi` modules.
    1. See [CollectionViewModel](#collectionviewmodel) for responsibilities.
    2. See [CollectionRepository](#collectionrepository) for responsibilities.
    3. See [DehydratedCollectionRepository](#dehydratedcollectionrepository) for responsibilities.
    4. See [ContentSetRepository](#contentsetrepository) for responsibilities.
    5. See [RepositoryHolder](#repositoryholder) for responsibilities.
    6. See [CollectionPresenter](#collectionpresenter) for responsibilities.
    7. Use `CollectionLog` to provide all relevant logging.
    8. Add unit test coverage for all implementations.
3. Create feature module for each of the collection pages. It might be possible to start working on this together with the previous step. It might be good to start with a nested & basic approach on the same to be able to gather feedback in an early stage.
    1. Add dependency on `features:collectionsApi` for access to the new `CollectionViewModel`.
    2. Create feature flag per collection page and keep disabled by default.
4. Create markdown file with documentation about the new setup.

### Tickets

In order to keep track of the progress of this refactor, the following tickets are created within the [Collection Refactor](https://jira.disneystreaming.com/browse/ANDROID-1620) epic.

* [ANDROID-4755](https://jira.disneystreaming.com/browse/ANDROID-4755) Collection Architecture Refactor - Base
    * [ANDROID-4781](https://jira.disneystreaming.com/browse/ANDROID-4781) Sample setup with deeplink for debug builds only
    * [ANDROID-4796](https://jira.disneystreaming.com/browse/ANDROID-4796) Initial setup with loading of collection and sets
    * [ANDROID-4797](https://jira.disneystreaming.com/browse/ANDROID-4797) Nested setup with loading of nested collection and sets
    * [ANDROID-4798](https://jira.disneystreaming.com/browse/ANDROID-4798) Set pagination logic
    * [ANDROID-4799](https://jira.disneystreaming.com/browse/ANDROID-4799) Refresh logic
    * [ANDROID-4800](https://jira.disneystreaming.com/browse/ANDROID-4800) Empty, Error and Content restricted logic
    * [ANDROID-4801](https://jira.disneystreaming.com/browse/ANDROID-4801) Focus logic
    * [ANDROID-4802](https://jira.disneystreaming.com/browse/ANDROID-4802) Finalize CollectionPresenter
    * [ANDROID-4803](https://jira.disneystreaming.com/browse/ANDROID-4803) Tests
* [ANDROID-4804](https://jira.disneystreaming.com/browse/ANDROID-4804) Collection Architecture Refactor - Feature flag
* Collection Architecture Refactor - Features
    * [ANDROID-4805](https://jira.disneystreaming.com/browse/ANDROID-4805) AllSportsPageFragment
    * [ANDROID-4806](https://jira.disneystreaming.com/browse/ANDROID-4806) BrandFragment
    * [ANDROID-4807](https://jira.disneystreaming.com/browse/ANDROID-4807) ChooseAvatarFragment
    * [ANDROID-4808](https://jira.disneystreaming.com/browse/ANDROID-4808) CollectionTabFilterFragment / CollectionTabbedFragment / SimpleCollectionFragment
    * [ANDROID-4809](https://jira.disneystreaming.com/browse/ANDROID-4809) DiscoverFragment
    * [ANDROID-4810](https://jira.disneystreaming.com/browse/ANDROID-4810) EditorialFragment
    * [ANDROID-4811](https://jira.disneystreaming.com/browse/ANDROID-4811) LandingPageFragment
    * [ANDROID-4812](https://jira.disneystreaming.com/browse/ANDROID-4812) OriginalsPageFragment
    * [ANDROID-4813](https://jira.disneystreaming.com/browse/ANDROID-4813) SearchFragment
    * [ANDROID-4814](https://jira.disneystreaming.com/browse/ANDROID-4814) SportsHomeFragment
    * [ANDROID-4815](https://jira.disneystreaming.com/browse/ANDROID-4815) SuperEventFragment
    * [ANDROID-4816](https://jira.disneystreaming.com/browse/ANDROID-4816) TeamPageFragment
    * [ANDROID-4817](https://jira.disneystreaming.com/browse/ANDROID-4817) WatchlistFragment

## Impact

The highest impact will be for the Content Discovery team because the collections fall under their responsibility. It will have some impact on the Platform team as well to get feedback on the new UI Architecture implementation and for support on implementing Glimpse properly.

This change will affect all the collection pages through the app. See [Use cases](#use-cases) for a complete list of affected collection pages with its own specialities.

There will be some impact when speaking of modularization. By extracting each collection page into its own feature module and having the common logic in the `features:collectionApi` module, it might have a positive effect on the gradle build times.
