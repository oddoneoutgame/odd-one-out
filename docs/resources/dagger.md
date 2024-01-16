# Dagger Hilt

The Dominguez project uses [Dagger Hilt](https://dagger.dev/hilt) for dependency injection. Some older versions the project still uses [dagger-android](https://dagger.dev/dev-guide/android.html).

## Hilt

## Best Practises

As a baseline for Dagger usage the project assumes the best practises from the [Keeping the Daggers Sharp](https://developer.squareup.com/blog/keeping-the-daggers-sharp/) Blog Post of Square. Below is a high-level overview of the best practices. Check out the blog post for more detail, reasoning and examples.

- Favor constructor injection over field injection.
- Favor constructor injection over `@Provides` methods in Dagger modules.
- `@Provides` methods must always be static.
- `@Binds` methods must always be abstract.
- Dagger Modules must always be `abstract`
- `@Binds` methods must never have a scope annotation.
- Prefer a combination of a constructor injected implementation with a `@Binds` method to bind it to an interface over a `@Provides` method that has the interface as the return type and creates the implementation in the method body.

Additionally there are a few other best-practices that relate more to Hilt.

### No Business Logic

Dagger and Hilt are a tool to tie things together. Dagger Modules should therefore contain the bare minimal business logic. All they should do is

- Instruct the dagger compiler what implementation to use when a certain interface is requested
- Define a static factory method for creating instances of classes that can not be constructor injected because:
    - The class is not declared in our codebase
    - The class requires some special mechanism to be conditionally created (like an `androidx.lifecycle.ViewModel`).

### Small Hilt Modules

For Hilt modules, just like regular code, the principle of single responsibility applies. This does not mean that every Hilt Module should always be limited to a single `@Provides` or `@Binds` method, but for testing purposes it is helpful sometimes.

Let's take remote config loading as an example.

Let's assume there is an interface `AppConfigRepository` and an implementation `AppConfigRepositoryImpl`. The app config module also defines a `AppConfigLifecycleObserver` which is registered as a process lifecycle observer using `@Binds @IntoSet @ProcessLifecycleObserver` which ensures that the config is refreshed every time the user foregrounds the app.

A Hilt module for this could look like this.

```java
@Module
@InstallIn(SingletonComponent.class)
public abstract class Config_AppModule {
    @Binds
    abstract AppConfigRepository appConfigRepository(AppConfigRepositoryImpl repository);
    
    @Binds
    @IntoSet
    @ProcessLifecycleObserver
    abstract LifecycleObserver lifecycleObserver(AppConfigLifecycleObserver observer);
}
```

For an instrumented test you might want to replace the real `AppConfigRepositoryImpl` with a test instance, but keep the behavior of the lifecycle observer in place. In that case it is better to define two Hilt modules, one `AppConfig_AppModule` which sets up bindings that are not expected to be replaced in tests, and another `AppConfigRepository_AppModule` which would only define the binding of the `AppConfigRepository` and the Hilt test would just install that module.

### Naming

For the naming of Dagger modules a fixed suffix' are used to indicate the [component](https://dagger.dev/hilt/components) that the module installs in.

- A module that has `@InstallIn(SingletonComponent.class)` must have a name ending with `_AppModule`
- A module that has `@InstallIn(ActivityComponent.class)` must have a name ending with `_ActivityModule`
- A module that has `@InstallIn(FragmentComponent.class)` must have a name ending with `_FragmentModule`
- A module that has `@InstallIn(ViewComponent.class)` must have a name ending with `_ViewModule`

### HiltViewModel

In this project we do not use `@HiltViewModel` because it is not possible to inject those in the places where we want to inject them and their usage guide breaks with some of the foundational principles of dependency injection.

For example, the code below is a common pattern in this codebase.

```kotlin
@HiltViewModel
class SomeViewModel @Inject constructor() : ViewModel()

class SomePresenter @Inject constructor(viewModel: SomeViewModel)
```

This will fail compilation with the following error

```text
Injection of an @HiltViewModel class is prohibited since it does not create a ViewModel instance correctly.
Access the ViewModel via the Android APIs (e.g. ViewModelProvider) instead.
Injected ViewModel: SomeViewModel
```

This is because Hilt doesn't know what `ViewModelStoreOwner` to obtain the ViewModel from.

Instead, to be able to inject a `HiltViewModel` into a Presenter you would need to do something like this

```kotlin
class SomePresenter @Inject constructor(viewModel: Fragment) {
    val viewModel by fragment.viewModels<SomeViewModel>()
}
```

This breaks dependency injection principles because the consumer becomes responsible for determining where a dependency comes from.

Instead we stick to dependency principles by letting the provider define where the ViewModel comes from by declaring a `@Provides` method for each ViewModel.

### `@FragmentViewModel` and `@ActivityViewModel`

To respond to the frustration of not having `@HiltViewModel` and in order to reduce the amount of boilerplate code resulting from wiring up all bits of our designated architecture, two annotations have been introduced, to mark a `ViewModel` either as `Fragment` scoped (`@FragmentViewModel`) or `Activity` scoped (`@ActivityViewModel`).

These two work by creating a standalone module that declares a binding for the ViewModel in question. For example, for a `BasicViewModel` in `com.disney.disneyplus.sample.list`, doing:

```kotlin
@FragmentViewModel
class BasicViewModel(
    private val repository: BasicRepository,
) : AutoDisposeViewModel() {

}
```

Will produce the following `BasicFragment_FragmentModule.java` in `build/generate/source/kapt/[debug/release]/com/disney/disneyplus/sample/list`:

```kotlin
@Module
@InstallIn(FragmentComponent.class)
abstract class BasicViewModel_FragmentModule {
  @Provides
  static BasicViewModel provideBasicViewModel(Fragment fragment,
      @NotNull BasicRepository repository) {
    return ViewModelUtils.getViewModel(
        fragment,
         com.disney.disneyplus.sample.list.BasicViewModel.class,
         () -> new com.disney.disneyplus.sample.list.BasicViewModel(repository)
        );
  }
}
```

Relieving the developer of that work.

#### The `parentClass` parameter

In certain occasions one might want their `ViewModel` to be bound in the dagger graph as a parent class or interface. This happens, for instance, if an interface for the `ViewModel` is declared in an `api` module and the class consuming the `ViewModel` does not know about its implementation. For instance:

```kotlin
@FragmentViewModel(parentClass = BaseViewModel::class)
class BasicViewModel(
    private val repository: BasicRepository,
) : AutoDisposeViewModel(), BaseViewModel {

}
```

Obviously, the class defined as `parentClass` has to be an actual ancestor of the `ViewModel`, otherwise the generator will throw an exception.

#### Bundle Arguments

If the ViewModel is marked as `@FragmentViewModel` or `@ActivityViewModel`, the arguments for its creation or intent can be also automatically injected in its constructor, by marking those parameters with the annotation `@BundleArgument` and providing the key name to that argument.

For instance, for a `Fragment` with a `String` argument like this:

```kotlin
 companion object {

        const val KEY_CHARACTER_ID = "character_id"

        /**
         * Creates an instance of [DetailFragment]
         */
        fun newInstance(characterId: String): DetailFragment {
            return DetailFragment().apply {
                arguments = Bundle().apply {
                    putString(KEY_CHARACTER_ID, characterId)
                }
            }
        }
    }

```

the matching argument injection will look like:

```kotlin
@FragmentViewModel
class DetailViewModel(
    @BundleArgument(name = KEY_CHARACTER_ID) private val id: String?,
    private val repository: BasicRepository
) : AutoDisposeViewModel() {

}
```

Note that this annotation does not allow for default values, and that nullable types can still be nullable so they should always be declared as so in the constructor parameters, unless it's 100% certain they will never be null.

`@BundleArguments` are only available in `ViewModels` that are autoinjected. If there's a need to inject an argument into any other class, it is always possible to declare it explicitly in any Dagger module.

#### `@ViewModelConstructor` annotation

In the rare occasions in which a ViewModel would have more than one constructor, one and only one of them should be marked with the `@ViewModelConstructor` annotation to indicate the code generator which one it should be using to produce instances of the ViewModel.

#### Injecting `SavedStateHandle`

The same way that `@HiltViewModel` does, automatic injection of the `SavedStateHandle` is also provided with both `@FragmentViewModel` and `@ActivityViewModel`. Just adding a parameter of type `SavedStateHandle` is enough for the generator to infer the `SavedStateHandle` extraction.

However, using a `SavedStateHandle` implies a fundamental shift in the way the ViewModels are perceived. As stated in the [HiltViewModel](#hiltviewmodel) section, our ViewModels are injected in places beyond the view lifecycle, and a `SavedStateHandle` is only available for retrieval after the view creation.

Because Dagger will perform the injection on a Fragment in the `onAttach` event, which happens earlier than the `onCreate` (where the saved state handle is first available), injecting the `ViewModel` directly in the Fragment like so:

!!! fail "Crashes if using `SavedStateHandle`"

```kotlin
@AndroidEntryPoint
class BasicFragment : Fragment(R.layout.fragment_sample) {

    @Inject
    lateinit var viewModel: BasicViewModel

    @Inject
    internal lateinit var presenterProvider: Provider<BasicPresenter>
    
    private val presenter by viewScoped { presenterProvider.get() }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        viewLifecycleOwner.subscribeWhileStarted(viewModel.stateOnceAndStream) { presenter.bindState(it) }
    }
}
```

Would result in a crash as Dagger tries to create an instance of the `BasicViewModel`, for which it needs a `SavedStateHandle` that is not yet available.

For this reason, we have made the `SavedStateHandle` injection opt-in, like so:

```kotlin
@FragmentViewModel(optInSavedSateViewModel = true)
class BasicViewModel(
    private val repository: BasicRepository,
    private val savedStateHandle: SavedStateHandle,
) : AutoDisposeViewModel() {

}
```

In opt-in scenarios, then, the `ViewModel` needs to be injected using `Lazy`. Although technically `Provider` will also work, it is not the semantically correct wrapper.

!!! success "Works when using `SavedStateHandle`"

```kotlin
@AndroidEntryPoint
class BasicFragment : Fragment(R.layout.fragment_sample) {

    @Inject
    lateinit var viewModel: dagger.Lazy<BasicViewModel>

    @Inject
    internal lateinit var presenterProvider: Provider<BasicPresenter>

    private val presenter by viewScoped { presenterProvider.get() }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        viewLifecycleOwner.subscribeWhileStarted(viewModel.get().stateOnceAndStream) { presenter.bindState(it) }
    }
}
```

Note that for these opt-in scenarios the developer is responsible for handling when the `ViewModel` is created. This means if the `ViewModel` is injected in other classes, the developer must make sure its creation only happens after the View is available (by marking it `Lazy` and not accessing it prior to onCreate), and in the UI thread. In these cases, though, the recommendation is to limit the `ViewModel` usage to the `Fragment`/`Activity` and `Presenter`.
