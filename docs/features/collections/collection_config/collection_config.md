# Collection Config

In order to be able to change the presentation of the collections on the fly, additional configuration sources are used to determine how an item is rendered on the screen, depending on a number of factors.

This is represented mainly by an external json file called `collections_config.json` and `collections_config_{partner}.json`. These two get merged to produce a final configuration for collections, the latter including only the specifics for that particular partner (note, thus, that when looking for defaults you might have to check both files).

Whenever a `collections.configVersion` is specified on the remote config at the [Configuration project](https://github.bamtech.co/Mobile/dmgz-android-appconfig), then that version will be retrieved and looked up to be merged with the bundled [collection_config.json] file mentioned above. See [CollectionConfigRepository](https://github.bamtech.co/Android/Dmgz/blob/development/features/config/src/main/java/com/bamtechmedia/dominguez/collections/config/CollectionConfigRepositoryImpl.kt).

???+ info "Basic structure"
    ```json
    {
        "home" : {
            "displayType": "seriesLanding",
            "titleAspectRatio": 1.78,
            "titleImageConfigRef": "default_landingTitle",
            "backgroundImageConfigRef": "default_landingBackground",
            "backgroundAspectRatio": {
            "land": 1.78,
            "port": 0.71,
            "sw420dp-port": 0.71,
            "sw600dp-land": 1.78,
            "sw600dp-port": 1.78,
            "sw720dp-land": 1.78,
            "sw720dp-port": 1.78,
            "television": 1.78
            },
            "sets" : {
            "default": {
                ...
            },
            "hero": {
                "hero": {
                    "tags" : ["tag1","tag2"],
                    "render": true,
                    "title": "none",
                    "aspectRatio": 1.2,
                    "tiles": 1,
                    "imageConfigRef": "home_hero",
                    "itemMargin": 10,
                    "topGridMargin": 5,
                    "bottomGridMargin": 5,
                    "breakpoints": {
                        ...
                    }
                }
            }
            }
        }
    }
    ```

This represents a series of configuration parameters that determine how to render each element within a collection. On this schema there are two types of config elements:
