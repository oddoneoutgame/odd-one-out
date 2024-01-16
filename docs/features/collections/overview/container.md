# Container

The presentation layer of a [set](../set) defining how it is displayed on client devices, a Container wraps the [set](../set) object with additional info that indicates how to render that object in the screen.

???+ example "Container response model"
    ```json
    {
        "set": {
            ...
        },
        "type": "HeroContainer",
        "style": "hero"
    }
    ```

???+ info "Type and Style"
    Containers mainly have a `type` (which can be a `grid`, a `hero`, a `full_bleed` or a `shelf`); and a `style`, which determines the differences in how to render a particular type. More information about the container `style` could be found in this [documentation](../../../containers/overview).

    Thus, while type defines the structural nature of the container (for instance, whether to present a grid or a linear collection or shelf, style merely defines a name that will be used to determine how to render that container in terms of cosmetics.
