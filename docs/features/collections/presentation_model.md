# Presentation model

## AbstractCollectionHiltFragment

AbstractCollectionHiltFragment was introduced to reduce duplicate logic, having the main enforced functions: `onCreateCollectionView()`, `onPreCollectionStateChanged` and `onCollectionStateChanged`. These functions may be in the end implemented by the Fragment or by a CollectionStateObserver.

AbstractCollectionHiltFragment is getting injected with CollectionViewModel, but it doesn't have the responsibility of observing Collections. This dependency is used for track and analytics purposes.

AbstractCollectionHiltFragment is strongly coupled to CollectionFragmentHelper.

***

## CollectionFragmentHelper

CollectionFragmentHelper ties together AbstractCollectionHiltFragment, the CollectionViewPresenter, CollectionView and OfflineViewModel. This can be used in combination with an implementation of AbstractCollectionHiltFragment to automatically set up the binding logic.

The Helper will observe the CollectionViewModel.State, bind it to CollectionViewPresenter and call `onPreCollectionStateChanged` which in turn will be implemented by a CollectionStateObserver or overridden by the Fragment.

This Helper shouldn’t be used by a feature directly, but instead just extend AbstractCollectionHiltFragment which will use this as intended.

***

## CollectionViewModel

CollectionViewModel will fetch the collection for a given `collectionIdentifier` from the repository when initialized. The Fragment is responsible for providing this Identifier with a property and CollectionView will be injected with it.

???+ example "Providing CollectionIdentifier with Hilt"
    ```kotlin
    class YourPageFragment : AbstractCollectionHiltFragment(), SlugProvider.Provider {

        val slug by parcelableArgument<CollectionIdentifier>(PARAM_SLUG)

        override fun provideSlug(slugProvider: SlugProvider) = slug
    }
    ```

CollectionViewModel calls `CollectionsRepository.getCollectionBySlug(slug)` and emits a new `CollectionViewModel.State`. As described above CollectionFragmentHelper will observe and bind it to CollectionViewPresenter (responsible for creating Groupie Items)
