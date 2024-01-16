# List of Important Classes

- [`AbstractCollectionHiltFragment`](https://github.bamtech.co/Android/Dmgz/blob/development/features/collections/src/main/java/com/bamtechmedia/dominguez/collections/AbstractCollectionHiltFragment.kt) - Base implementation for Collection pages. Some examples are:
    - [`BrandPageFragment`](https://github.bamtech.co/Android/Dmgz/blob/development/features/collections/src/main/java/com/bamtechmedia/dominguez/brand/BrandPageFragment.kt) (e.g. Star Wars or Marvel pages)
    - [`DiscoverFragment`](https://github.bamtech.co/Android/Dmgz/blob/development/features/collections/src/main/java/com/bamtechmedia/dominguez/discover/DiscoverFragment.kt) (Home page)
    - [`EditorialPageFragment`](https://github.bamtech.co/Android/Dmgz/blob/development/features/collections/src/main/java/com/bamtechmedia/dominguez/editorial/EditorialPageFragment.kt)
    - [`LandingPage`](https://github.bamtech.co/Android/Dmgz/blob/development/features/collections/src/main/java/com/bamtechmedia/dominguez/landing/LandingPageFragment.kt)
    - [`OriginalsPageFragment`](https://github.bamtech.co/Android/Dmgz/blob/development/features/collections/src/main/java/com/bamtechmedia/dominguez/originals/OriginalsPageFragment.kt)
    - [`SportsHomeFragment`](https://github.bamtech.co/Android/Dmgz/blob/development/features/collections/src/main/java/com/bamtechmedia/dominguez/sports/SportsHomeFragment.kt)

- [`CollectionViewModel`](https://github.bamtech.co/Android/Dmgz/blob/development/features/collectionsApi/src/main/java/com/bamtechmedia/dominguez/collections/CollectionViewModel.kt) - Performs the collection request (either by `slug` or `collectionGroupId`) and exposes the result as a `CollectionViewModel.State`

- [`CollectionViewPresenter`](https://github.bamtech.co/Android/Dmgz/blob/development/features/collectionsApi/src/main/java/com/bamtechmedia/dominguez/collections/CollectionViewPresenter.kt) - Data class that encapsulates the minimum required UI elements for a `Collection` page (`recyclerview`, `adapter`, `emptyview`, `progressbar`...)

- [`CollectionFragmentHelper`](https://github.bamtech.co/Android/Dmgz/blob/development/features/collections/src/main/java/com/bamtechmedia/dominguez/collections/CollectionFragmentHelper.kt) - Ties together the `CollectionFragment`, `CollectionViewModel` and `CollectionView`.

- [`ShelfItem`](https://github.bamtech.co/Android/Dmgz/blob/development/features/collections/src/main/java/com/bamtechmedia/dominguez/collections/items/ShelfItem.kt) - Base implementation for a Shelf Container, which holds a title TextView and the RecyclerView that will contain the `ShelfListItems`

- [`ShelfListItem`](https://github.bamtech.co/Android/Dmgz/blob/development/features/collections/src/main/java/com/bamtechmedia/dominguez/collections/items/ShelfListItem.kt) - Contains a base implementation for a single tile (corresponding with an Asset) within a container view.

- [`ImageConfigResolver`](https://github.bamtech.co/Android/Dmgz/blob/development/coreContentApi/src/main/java/com/bamtechmedia/dominguez/core/content/imageconfig/ImageConfigResolver.kt) & [`Impl`](https://github.bamtech.co/Android/Dmgz/blob/development/coreContent/src/main/java/com/bamtechmedia/dominguez/core/content/imageconfig/ImageConfigResolverImpl.kt) - Handles the parsing & merger of configuration sources for image presentation within collections.

- [`ContainerConfigResolver`](https://github.bamtech.co/Android/Dmgz/blob/development/features/collectionsApi/src/main/java/com/bamtechmedia/dominguez/collections/config/ContainerConfigResolver.kt) & [`Impl`](https://github.bamtech.co/Android/Dmgz/blob/development/features/collections/src/main/java/com/bamtechmedia/dominguez/collections/config/ContainerConfigResolverImpl.kt) - Handles the parsing & merger of configuration sources for presentation at the Container level.

- [`ContainerConfig`](https://github.bamtech.co/Android/Dmgz/blob/development/features/collectionsApi/src/main/java/com/bamtechmedia/dominguez/collections/config/ContainerConfig.kt) - Represents a given config after the resolution is performed by `ContainerConfigResolver`

- [`CollectionConfigResolver`](https://github.bamtech.co/Android/Dmgz/blob/development/features/collections/src/main/java/com/bamtechmedia/dominguez/collections/config/CollectionConfigResolver.kt) - Handles the parsing & merger of configuration sources for presentation at the Collection level.

- [`CollectionsAppConfigImpl`](https://github.bamtech.co/Android/Dmgz/blob/development/features/collections/src/main/java/com/bamtechmedia/dominguez/collections/config/CollectionsAppConfigImpl.kt) - Config class that contains the configurable values related collection setup in general.

- [`CollectionRequestConfigImpl`](https://github.bamtech.co/Android/Dmgz/blob/development/features/collections/src/main/java/com/bamtechmedia/dominguez/core/content/collections/CollectionRequestConfigImpl.kt) - Config class that contains the configurable values related to loading the collection.

- [`ContainerConfigParser`](https://github.bamtech.co/Android/Dmgz/blob/development/features/collections/src/main/java/com/bamtechmedia/dominguez/collections/config/ContainerConfigParser.kt) - Handles the parsing & merger of configuration sources for presentation at the container level.
