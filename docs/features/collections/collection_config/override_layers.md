# Different Layers to Override Values

In the `collections_config.json` and `collections_config_PARTNER.json` files, you can basically define those values in 4 different layers with the following combination `contentClass:container`.

!!! summary "We have the following combinations"
    1. `[contentClass]:[containerStyle]` - contains the configurations for a specific collection and a specific container style.
    2. `default:[containerStyle]` - contains the configurations for the default collection and a specific container style.
    3. `[contentClass]:default` - contains the configurations for a specific collection and the default container style.
    4. `default:default` - contains the configurations for the default collection and default container.

!!! warning "Order Matters"
    The [ContainerConfigParser](https://github.bamtech.co/Android/Dmgz/blob/development/features/collections/src/main/java/com/bamtechmedia/dominguez/collections/config/ContainerConfigParser.kt) implementation handles the parsing of the different layers.

    It will first look a specific value in the the `[contentClass]:[containerStyle]` layer, then `default:[containerStyle]`, then `[contentClass]:default` and in the `default:default` layer as last option.   

???+ example "Examples"

    * If you'd like to change the number of `tiles` for the `poster` container style on the `home` contentClass, you'll need to put `tiles: X` into the `home.sets.poster` layer. 
    * If you'd like to change the number of `tiles` for all the container styles on the `editorial` contentClass, you'll need to put `tiles: X` into the `editorial.sets.default` layer. 
    * If you'd like to change the `itemViewType` for the `episode` container style on all collection, you'll need to put `itemViewType: X` into the `default.sets.episode` layer. 
    * If you'd like to change the `tags` for all container styles on all collection, you'll need to put `tags: X` into the `default.sets.default` layer. 
