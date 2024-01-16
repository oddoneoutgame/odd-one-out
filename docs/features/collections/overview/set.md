# Set

A Set is each of the lists within a Collection. They are held by a [Container](../container), and encapsulate a group of individual [Assets](../asset) (Series, Seasons, Videos...) or links to other collections (ContentAssets).
There are two types of Sets, [ContentSet](#contentset) and [ReferenceSet](#referenceset).

## ContentSet

Content sets return the list of assets directly within the `items` key.

??? example "ContentSet response model"
    ```json
    {
    "set": {
        "items": [],
        "meta": {
        "hits": 5,
        "offset": 0,
        "page_size": 15
        },
        "setId": "e5f44966-12f4-4047-92e8-a2edb09cf5c3",
        "text": {
        "title": {
            "full": {
            "set": {
                "default": {
                "content": "Brands",
                "language": "en-GB",
                "sourceEntity": "set"
                }
            }
            }
        }
        },
        "type": "CuratedSet"
    },
    "type": "GridContainer",
    "style": "brand"
    }

    ```

## ReferenceSet

Reference sets are returned as a skeleton for a [set](#set), they have a type of `SetRef` and contain a `refId` that can then be used to retrieve the actual list of assets. They, thus, eventually resolve into a [ContentSet](#contentset).

??? example "ReferenceSet response model"
    ```json
    {
    "set": {
        "refId": "4fab9f98-416e-4d79-b8e8-2752f9eac1a3",
        "refIdType": "setId",
        "refType": "CuratedSet",
        "type": "SetRef",
        "text": {
        "title": {
            "full": {
            "set": {
                "default": {
                "content": "Movies",
                "language": "en",
                "sourceEntity": "set"
                }
            }
            }
        }
        }
    },
    "type": "ShelfContainer",
    "style": "editorialPanelLarge",
    }
    ```

Understanding the way the ReferenceSets are resolved in the app is not immediate. It is done through the [CollectionViewModel](https://github.bamtech.co/Android/Dmgz/blob/development/features/collections/src/main/java/com/bamtechmedia/dominguez/collections/CollectionViewModelImpl.kt) which implements the interface [ShelfBindListener](https://github.bamtech.co/Android/Dmgz/blob/development/coreContentApi/src/main/java/com/bamtechmedia/dominguez/collections/items/ShelfBindListener.kt), which gets passed into the Container holding the RecyclerView that would contain the tiles. Upon binding, the actual request is performed, as seen in [CollectionViewModel](https://github.bamtech.co/Android/Dmgz/blob/development/features/collections/src/main/java/com/bamtechmedia/dominguez/collections/CollectionViewModelImpl.kt).

???+ info "onShelfItemBound"
    ```kotlin
    override fun onShelfItemBound(list: PagedList<Asset>) {
        if (list is ReferenceSet) {
            state.firstOrError()
                .map { it.collection?.containersBySetId?.get(list.setId) }
                .flatMap { contentSetRepository.contentSetOnce(it) }
                .onErrorReturn { list.toEmptyContentSet() }
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .autoDisposable(viewModelScope)
                .subscribe(this::onSetLoaded, { Timber.e(it) })
        }
    }
    ```
