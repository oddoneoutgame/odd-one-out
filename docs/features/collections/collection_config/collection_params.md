# Collection Parameters

Parameters defined within the base of each root element (e.g. `home` in the example above) pertain configuration on the [Collection](../../overview/collection) level, and thus are read by [CollectionConfigResolver](https://github.bamtech.co/Android/Dmgz/blob/development/features/collections/src/main/java/com/bamtechmedia/dominguez/collections/config/CollectionConfigResolver.kt). These parameters effectively result in the configuration of the page/fragment in which the collection is rendered.

At this level, the most significant parameter is `displayType`, as it determines which of the [AbstractCollectionHiltFragment](../../presentation_model#abstractcollectionhiltfragment) implementations will be used to render the collection. This is seen in the [CollectionItemClickHandlerImpl](https://github.bamtech.co/Android/Dmgz/blob/development/features/collections/src/main/java/com/bamtechmedia/dominguez/collections/items/CollectionItemClickHandlerImpl.kt):

???+ info "Method resolveForConfig"
    ```kotlin
        private fun resolveForConfig(config: CollectionConfig, reference: ReferrableContent) {
            val identifier = provideSlug(reference)
            when (config.displayType) {
                "contentTypeLanding" -> landingRouter.startLandingPage(identifier)
                "tabbedLanding" -> landingRouter.startTabbedCollectionPage(identifier)
                "brandLanding" -> landingRouter.startBrandPage(identifier)
                "originalsLanding" -> landingRouter.startOriginalsPage(identifier)
                "teamLanding" -> landingRouter.startTeamPage(identifier)
                "superEventLanding" -> landingRouter.startSuperEventPage(identifier)
                "allSportsLanding" -> landingRouter.startAllSportsPage(identifier)
                else -> landingRouter.startEditorialPage(identifier)
            }
        }
    ```

Other items are:

- `titleAspectRatio` and `titleImageConfigRef`: which declare aspect ratio and [image config](../../images_config) reference of the title image of the page

- `backgroundAspectRatio` and `backgroundImageConfigRef`: which declare aspect ratio and [image config](../../images_config) reference for the background image of the page
