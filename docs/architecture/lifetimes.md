# Lifetimes of UI Architecture elements

A key factor in deciding where logic for a specific [Screen](screens.md) should be implemented, is an understanding of the lifetime of each of the classes in that screen. This document covers the lifetimes of different elements in a screen and how they are created, destroyed, or kept around, depending on the [state of the screen](screens.md#state-of-a-screen). It is strongly recommended to read the [documentation the the Screen concept](screens.md) before continuing here.

A concept that often gets confused with lifetimes is lifecycle callbacks. They key difference being that lifetime is about state, and lifecycle callbacks are events. Lifecycle callbacks are handled in separate documentation [here](lifecycle.md), while this document focuses more on the lifetime from the moment that an element is created, to the moment it is destroyed, and will be garbage collected.

## Elements

### ViewModel

A ViewModel of a screen is the element that has the longest lifetime in that screen. It is essentially the same as the lifetime of the screen itself and will get `onCleared()` invoked when the screen transitions to the [Destroyed state](screens.md#destroyed-state). It does not know whether the screen is considered [Active](screens.md#active-state) or [Inactive](screens.md#inactive-state) but can be informed of those if required.

The ViewModel stays around while a screen is in the [Inactive](screens.md#inactive-state) state. When something happened on the active screen, that something can result in the state stream of an inactive screen to already emit a new state. For example, the ViewModel of the edit profile screen will be inactive when the user opens the Avatar selection screen, but since the ViewModel of the edit profile screen observes a state with the profile that is being edited, if the user selects a new avatar, that will be reflected in the state stream and already have updated when the user navigates back to the edit profile screen.

There is one scenario where a ViewModel gets recreated for the same screen and that is when the application process died and the system attempts to restore back (because the user selected the app from recent apps screen). For cases like this, information that is important to restore should be stored in a `SavedStateHandle`.

### Fragment

The Fragment instance is the element that has the second longest lifetime of the screen. If no configuration changes happen its lifetime will actually be exactly the same as that of the `ViewModel`.

The only, and actually quite significant, difference is that the Fragment is configuration-aware, meaning that it will be destroyed and re-created every time something about the configuration changes. This destruction and recreation will always happen when the configuration changes, no matter if the fragment's screen is currently in the [Active](screens.md#active-state) or [InActive](screens.md#inactive-state) state.

Configuration changes are often just thought of as rotation, likely because it is the easiest one to trigger. Although rotation is a challenge to deal with properly, new devices have introduced much more frequent configuration changes. Especially free-form windows on Chromebooks may trigger many configuration changes in very short periods of time. Other more common examples of configuration changes these days are split-screen mode and foldable devices becoming more popular.

### View of the Fragment

The View of the Fragment has a shorter lifetime and only exists while the Fragment's screen is considered [Active](screens.md#active-state). As opposed to the Fragment which will exist while the screen is either [Active](screens.md#active-state) or [Inactive](screens.md#inactive-state).

### Presenter

Finally, the `Presenter` has pretty-much the same lifetime as the View of the Fragment. It gets created right after the Fragment's View is created and should be considered obsolete when the Fragment's View is destroyed. Meaning that a new `Presenter` is created every time that the screen transitions to the [Active](screens.md#active-state), and no references to the `Presenter` should be kept when the screen becomes [Inactive](screens.md#inactive-state) and the [View](#view-of-the-fragment) is destroyed.

### ViewScopedInstanceProperty

A ViewScopedInstanceProperty is a property that is created and destroyed following a fragments view lifecycle.

Using a ViewScopedInstanceProperty is the preffered way of scoping a presenter to a view and accesing that presenter for binding view model state.

```kotlin
private val presenter by viewScoped { presenterProvider.get() }
```

The viewScoped property also solves an issue that could occur when invoking a method on the presenter from within a Fragment.

!!! fail "Problematic"

```kotlin
@AndroidEntryPoint
class BirthdateFragment : Fragment(R.layout.fragment_birthdate), BackPressHandler {

    @Inject
    lateinit var lifecycleObserverProvider: Provider<BirthdateLifecycleObserver>

    @Inject
    lateinit var birthDateProvider: Provider<BirthdatePresenter>

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        viewLifecycleOwner.lifecycle.addObserver(lifecycleObserverProvider.get())
    }

    override fun onBackPress(): Boolean {
        birthDateProvider.get().onBackButtonPressed() // problematic code
        return true
    }
}
```

The above problematic code, would actually create a new instance of the presenter (because it is not scoped). This would cause the whole view setup to be done again, potentially resetting previously bound state. The viewScoped property ensures that this call is done on the already created instance (in this case, the presenter).

!!! success "Working"

```kotlin
@AndroidEntryPoint
class BirthdateFragment : Fragment(R.layout.fragment_birthdate), BackPressHandler {

    @Inject
    internal lateinit var presenterProvider: Provider<BasicPresenter>

    private val presenter by viewScoped { presenterProvider.get() }

    @Inject
    lateinit var viewModel: BirthdateViewModel

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        viewLifecycleOwner.subscribeWhileStarted(viewModel.stateOnceAndStream) { presenter.bindState(it) }
    }

    override fun onBackPress(): Boolean {
        presenter?.onBackButtonPressed()
        return true
    }
}
```

!!! warning

    Do not use the fragments onDestroy() callback to communicate with a ViewScopedInstanceProperty. The property is only alive between onViewCreated() and onDestroyView(). If you need to close resources or communicate with a ViewScopedInstance property you can pass in a onPreDestroy() to the viewScoped() convenience function or alternatively use the fragments onViewDestroy() callback. 

### Testing

A small side effect of this new property is that Fragment instantiation now requires the main thread, as upon instantiation a lifecycle observer is internally added to the fragments lifecycle.

This results in all tests instantiating a Fragment using `viewScoped` failing with the following exception:

```java
java.lang.NullPointerException
	at androidx.arch.core.executor.DefaultTaskExecutor.isMainThread(DefaultTaskExecutor.java:77)
	at androidx.arch.core.executor.ArchTaskExecutor.isMainThread(ArchTaskExecutor.java:116)
	at androidx.lifecycle.LifecycleRegistry.enforceMainThreadIfNeeded(LifecycleRegistry.java:322)
	at androidx.lifecycle.LifecycleRegistry.addObserver(LifecycleRegistry.java:178)
	at com.bamtechmedia.dominguez.core.framework.ViewScopedInstanceProperty.<init>(ViewScopedInstanceProperty.kt:39)
	at com.bamtechmedia.dominguez.core.framework.ViewScopedInstancePropertyKt.viewScoped(ViewScopedInstanceProperty.kt:77)
	at com.bamtechmedia.dominguez.core.framework.ViewScopedInstancePropertyKt.viewScoped$default(ViewScopedInstanceProperty.kt:74)
```

This can be circumvented by adding the following test rule to your tests:

```kotlin
@get:Rule
    val rule = InstantTaskExecutorRule()
```

This requires the module importing the dependency:

    `androidTestImplementation buildLibs.dagger.hilt.android.testing`

### Working with Lifecycle Observers

Although the above paradigm lets us avoid the creation of an extra `LifecycleObserver` to create the presenter and bind it to a state, often there are cases where the presenter needs to perform an action when a lifecycle event occurs. In those cases, we should not inject the `Presenter` directly into the `LifecycleObserver`, as this would mean producing a new instance and thus recreating the view again, as we bind the `ViewBinding` instance in the Presenter's creation.

Instead, an [Assisted Factory](https://dagger.dev/dev-guide/assisted-injection.html) should be created, that takes the presenter as a parameter in order to produce an instance of the `LifecycleObserver`. Then this factory can be injected in the `Fragment` and the `LifecycleObserver` gets the same `Presenter` instance.

!!! fail "Problematic"

```kotlin
class BasicLifecycleObserver @Inject constructor(
    private val presenter: BasicPresenter
) : DefaultLifecycleObserver {

    override fun onCreate(owner: LifecycleOwner) {
        presenter.doSomething()
    }
}

@AndroidEntryPoint
class BasicFragment : Fragment(R.layout.fragment_sample) {

    @Inject
    lateinit var viewModel: BasicViewModel

    @Inject
    internal lateinit var presenterProvider: Provider<BasicPresenter>

    @Inject
    lateinit var lifecycleObserver: BasicLifecycleObserver

    private val presenter by viewScoped { presenterProvider.get() }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        viewLifecycleOwner.subscribeWhileStarted(viewModel.stateOnceAndStream) { presenter.bindState(it) }
        viewLifecycleOwner.lifecycle.addObserver(lifecycleObserver)
    }
}
```

!!! success "Good"

```kotlin
class BasicLifecycleObserver @AssistedInject constructor(
    @Assisted private val presenter: BasicPresenter
) : DefaultLifecycleObserver {

    override fun onCreate(owner: LifecycleOwner) {
        presenter.doSomething()
    }
    
    @AssistedFactory
    interface Factory {
        fun create(presenter: BasicPresenter): BasicLifecycleObserver
    }
}

class BasicFragment : Fragment(R.layout.fragment_sample) {

    @Inject
    lateinit var viewModel: BasicViewModel

    @Inject
    internal lateinit var presenterProvider: Provider<BasicPresenter>

    @Inject
    lateinit var lifecycleObserverFactory: BasicLifecycleObserver.Factory

    private val presenter by viewScoped { presenterProvider.get() }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        viewLifecycleOwner.subscribeWhileStarted(viewModel.stateOnceAndStream) { presenter.bindState(it) }
        viewLifecycleOwner.lifecycle.addObserver(lifecycleObserverFactory.create(presenter))
    }
}
```

## Examples

Below is a table which shows a scenario which covers the lifetime of a few cases in the selection of profiles. The number between `<>` indicates how many instances of that class have been created. This example is not referencing the view of the Fragment because its lifetime is the same as that of the Presenter.

| Step 	| Action 	| User sees 	| Events	| Existing instances after this step	|
|-	|-	|-	|-	|-	|
| 1 	| Start Activity and<br>add ProfilePickerFragment 	| ProfilePicker	| MainActivity<1> is created<br>MainActivityViewModel<1> is created<br>ProfilePickerFragment<1> is created<br>ProfilePickerViewModel<1> is created<br>ProfilePickerPresenter<1> is created 	| MainActivity<1><br>MainActivityViewModel<1><br><br>ProfilePickerFragment<1><br>ProfilePickerViewModel<1><br>ProfilePickerPresenter<1>	|
| 2 	| Rotate Screen 	| Profile Picker	| ProfilePickerPresenter<1> is destroyed<br>ProfilePickerFragment<1> is destroyed<br>MainActivity<1> is destroyed<br>MainActivity<2> is created<br>ProfilePickerFragment<2> is created<br>ProfilePickerPresenter<2> is created 	| MainActivity<2><br>MainActivityViewModel<1><br><br>ProfilePickerFragment<2><br>ProfilePickerViewModel<1><br>ProfilePickerPresenter<2>	|
| 3 	| Select Edit Profiles 	| Edit Profiles	| ProfilePickerPresenter<2> is destroyed<br>EditProfilesFragment<1> is created<br>EditProfilesViewModel<1> is created<br>EditProfilesPresenter<1> is created 	| MainActivity<2><br>MainActivityViewModel<1><br><br>ProfilePickerFragment<2><br>ProfilePickerViewModel<1><br><br>EditProfilesFragment<1><br>EditProfilesViewModel<1><br>EditProfilesPresenter<1>	|
| 4 	| Change Foldable from <br>open to closed state 	| Edit Profiles	| EditProfilesPresenter<1> is destroyed<br>EditProfilesFragment<1> is destroyed<br>ProfilePickerFragment<2> is destroyed<br>MainActivity<2> is destroyed<br>MainActivity<3> is created<br>ProfilePickerFragment<3> is created<br>EditProfileFragment<2> is created<br>EditProfilePresenter<2> is created 	| MainActivity<3><br>MainActivityViewModel<1><br><br>ProfilePickerFragment<3><br>ProfilePickerViewModel<1><br><br>EditProfilesFragment<2><br>EditProfilesViewModel<1><br>EditProfilesPresenter<2>	|
| 5 	| Press back to return<br>ProfilePicker 	| Profile Picker	| EditProfilesPresenter<2> is destroyed<br>EditProfilesFragment<2> is destroyed<br>EditProfileViewModel<1> is destroyed<br>ProfilePickerPresenter<3> is created 	| MainActivity<3><br>MainActivityViewModel<1><br><br>ProfilePickerFragment<3><br>ProfilePickerViewModel<1><br>ProfilePickerPresenter<3>	|
| 6 	| Select a Profile 	| Discover	| ProfilePickerPresenter<3> is destroyed<br>ProfilePickerFragment<3> is destroyed<br>ProfilePickerViewModel<1> is destroyed<br>DiscoverFragment<1> is created<br>DiscoverViewModel<1> is created<br>DiscoverPresenter<1> is created 	| MainActivity<3><br>MainActivityViewModel<1><br><br>DiscoverFragment<1><br>DiscoverViewModel<1><br>DiscoverPresenter<1>	|
| 7 	| Close the app with<br>back button 	| App Closing	| DiscoverPresenter<1> is destroyed<br>DiscoverFragment<1> is destroyed<br>DiscoverViewModel<1> is destroyed<br>MainActivity<3> is destroyed<br>MainActivityViewModel<1> is destroyed 	| 	|
