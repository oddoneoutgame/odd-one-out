# Project and Code Guidelines

The goal of this document is to outline some of the common rules and conventions we use as a team, within the Dmgz Android code base. This ensures we maintain consistent and high quality code within our project.

## Code Style

The code style and conventions used within the code base are based off of [Kotlin's official and recommended style](https://kotlinlang.org/docs/coding-conventions.html). There is a minor change to the style to prevent the use of wildcard imports, but the rest is untouched. Unless otherwise specified, the conventions outlined in the document above should be followed. See [Setting Up Android Studio](../../resources/android_studio/android_studio/#setting-up-android-studio) on how to import our project code style.

## File Naming

### Class files

Class names are written in [UpperCamelCase](http://en.wikipedia.org/wiki/CamelCase).

For classes that extend an Android component, the name of the class should end with the name of the component; for example: `SignInActivity`, `SignInFragment`, `ImageUploaderService`, `ChangePasswordDialog` (or `ChangePasswordDialogFragment`).

For classes that contain an acronym:

- If it is two letters, capitalize both (i.e. IOException).
- If it is three or more, use lowercase (i.e. IapProduct).

### Resources files

Resources file names are written in __lowercase_underscore__.

### Drawable files

Naming conventions for drawables (these are not exhaustive, but other types will follow the same convention).

| Asset Type   | Prefix            |		Example               |
|--------------| ------------------|-----------------------------|
| Button       | `button_`	         |  `button_send.xml`   |
| Divider      | `divider_`        | `divider_horizontal.xml` |
| Icon         | `ic_`	            | `ic_star.xml` |
| Selector     | `selector_`	     | `selector_search_bar.xml` |

### Layout files

Layout files should match the name of the Android components that they are intended for but moving the top level component name to the beginning. For example, if we are creating a layout for the `SignInActivity`, the name of the layout file should be `activity_sign_in.xml`.

| Component        | Class Name             | Layout Name                   |
| ---------------- | ---------------------- | ----------------------------- |
| Activity         | `UserProfileActivity`  | `activity_user_profile.xml`   |
| Fragment         | `SignUpFragment`       | `fragment_sign_up.xml`        |
| Dialog           | `ChangePasswordDialog` | `dialog_change_password.xml`  |
| Adapter item     | `PersonItem`           | `item_person.xml`             |

### Layout ID Naming

View IDs should:

- Be prefixed with the class/feature (login, movieDetail, download, etc)
- Suffixed with the name of the element type (TextView, RecyclerView, Button, etc)
- Optionally, within the `.xml` an additional identifer can be used to distinguish between each view. (i.e. header/footer or email/password, etc)
- If the element type is a ViewGroup (Linear, Constraint, Frame, etc), `Layout` should be used as the suffix

| Feature       | Identifier (within xml)| Element type  | Name
| --------------| ---------------------- | --------------| ----------------------- |
| Login         | Email                  | Button        | loginEmailButton        |
| Login         | Password               | Button        | loginPasswordButton     |
| Movie Detail  | Header                 | ViewGroup     | movieDetailHeaderLayout |
| Movie Detail  | Footer                 | ViewGroup     | movieDetailFooterLayout |

## Code Guidelines

### Fully qualify imports

!!! success "Do this"

```kotlin
import foo.Bar
```

!!! fail "Not this"

```kotlin
import foo.*
```

!!! tip "If you see some wildcard imports still occuring you may need to check your "Packages to use imports with '*'" setting in Android Studio. CMD + Shift + A and then search for "Packages to use imports with"."

### Android component method ordering

- If your class is extending an Android component such as an Activity or a Fragment, order the override methods so that they match the component's lifecycle.
- __This is particularly important for LifecycleObservers.__
- These should be the top-most functions in the class (after constructors and `init`).

!!! success "Do this"

```kotlin
class MainActivity : BaseActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
      ...
    }
    
    override fun onResume() {
      ...
    }
    
    override fun onPause() {
      ...
    }
    
    override fun onDestroy() {
      ...
    }
    
    private fun someMethod() {
      ...
    }
}

```

!!! fail "Not this"

```kotlin
class MainActivity : BaseActivity() {

	override fun onCreate(savedInstanceState: Bundle?) {
      ...
    }
    
    override fun onResume() {
      ...
    }
    
    private fun someMethod() {
      ...
    }
    
    override fun onDestroy() {
      ...
    }
    
    override fun onPause() {
      ...
    }
}

```

### Chains styling (RxJava, Flow, etc)

Chains of operators require line-wrapping. Every operator must go on a new line and the line should be broken before the `.`

!!! success "Do this"

```kotlin
override fun entitlementCheck(groupId: String): Completable =
    groupWatchApi.getContentId(groupId)
        .flatMapSingle { loadPlayable(it) }
        .filter { it is Movie }
        .flatMapCompletable { playable -> earlyAccessCheck.checkEntitlement(groupId, playable) }
```

!!! fail "Not this"

```kotlin
override fun entitlementCheck(groupId: String): Completable =
    groupWatchApi.getContentId(groupId).flatMapSingle { loadPlayable(it) }.filter { it is Movie }
        .flatMapCompletable { playable -> earlyAccessCheck.checkEntitlement(groupId, playable) }
```

### Kotlin's scoping functions (let, with, apply, run, also)

There is almost always an alternative to these functions that communicates intent better. Oftentimes, these result in less readable code and may make code reviews more difficult.

The Dmgz project primarily makes use of `let` and `also`.

#### Primary usages of let

- copying a `var` reference into local scope
- null checking a reference
- performing a `map` operation on a single value in a chain

#### Primary usage of also

- Can be used for builders to create a local scope and nice grouping

!!! success "Use named receiver"
    A named receiver (`animator` below) makes the code more clear
    ```kotlin
    val fadeOutAnimator = ObjectAnimator.ofFloat(...).also { animator ->
        animator.duration = DURATION10
        animator.startDelay = DURATION40
        animator.interpolator = CubicBezierInterpolator.EASE_IN
    }
    ```

#### Avoid usage of `apply` and `with`

`apply` or a `with` can be very difficult to understand without an IDE, especially with longer blocks of code

!!! success "Do this"

```kotlin
binding.titleAboutTextView.text = title
binding.titleAboutTextView.isGone = title.isEmpty()
binding.valueAboutTextView.text = value
binding.valueAboutTextView.isVisible = value.isNotEmpty()
```

!!! fail "Over this"

```kotlin
with (binding) {
    titleAboutTextView.text = title
    titleAboutTextView.isGone = title.isEmpty()
    valueAboutTextView.text = value
    valueAboutTextView.isVisible = value.isNotEmpty()
}
```

### When vs If

Prefer using `if` for binary conditions instead of `when`.

!!! success "Do this"

```kotlin
if (x == null) ... else ...
```

!!! fail "Not this"

```kotlin
when (x) {
    null -> // ...
    else -> // ...
}
```

If there are three or more options prefer `when`

!!! success "Do this"

```kotlin
when (state) {
    Loading -> router.startSplash()
    LoggedOut -> determineLoggedOutAccountState()
    LoggedIn -> determineLoggedInAccountState()
    NewUser -> loadProfilesAndRoute { handleNewUser() }
    else -> ExampleLog.e(e) { $state is not handled properly }
```

!!! fail "Not this"

```kotlin
if (state is Loading) {
    router.startSplash()
} else if (state is LoggedOut) {
    determineLoggedOutAccountState()
} else if (state is LoggedIn) {
	 determineLoggedInAccountState()
} else if (state is Newuser) {
    loadProfilesAndRoute { handleNewUser() }
} else {
    ExampleLog.e { $state is not handled properly }
}
```

### Use destructuring declarations to make code more readable

It is often common to have functions return tuples (Pair, Triple, etc) or sometimes `data` classes. Destructuring declarations should be used to improve readability and provide more context.

!!! success "Do this"

```kotlin
private fun showIntroOverlayWhenNeeded(devicesAvailableStream: Flowable<Boolean>): Completable =
    Flowables.combineLatest(devicesAvailableStream, overlayEnabledProcessor, allowedInThisSessionOnceAndStream())
        .map { (isCastAvailable, isCastOverlayEnabled, isCastAllowedForSession) -> 
            isCastAvailable && isCastOverlayEnabled && isCastAllowedForSession 
        }
        .firstOrError()
```

!!! fail "Not this"

```kotlin
private fun showIntroOverlayWhenNeeded(devicesAvailableStream: Flowable<Boolean>): Completable =
    Flowables.combineLatest(devicesAvailableStream, overlayEnabledProcessor, allowedInThisSessionOnceAndStream())
        .map { it.first && it.second && it.third }
        .firstOrError()
```

### Use Companion Object

The project primarily uses companion objects to organize static class members and static functions. This allows for accessing members of a class by class name only (we dont have to explictly create an instance of the class).

This is useful in many scenarios, but most commonly is used to create factories. A common pattern used throughout the project is their usage when creating a Fragment.

#### String constants, naming, values

Many elements of the Android SDK such as `SharedPreferences`, `Bundle`, or `Intent` use a key-value pair approach.

!!! success "Define these keys in the associated companion object and prefix them as indicated"

| Element            | Field Name Prefix |
| -----------------  | ----------------- |
| SharedPreferences  | `PREF_`             |
| Bundle             | `BUNDLE_`           |
| Fragment Arguments | `ARG_`              |
| Intent Extra       | `EXTRA_`            |
| Intent Action      | `ACTION_`           |

```kotlin
companion object {
    const val ARG_DETAIL = "detailArg"

    /**
     * Create a new instance of the [DetailFragment]
     */
    fun newInstance(arguments: DetailPageArguments) =
        DetailFragment().withArguments(DETAIL_ARG to arguments)
}
```

## Tests Style Rules

### Unit test naming

Test classes should match the name of the class the tests are targeting, followed by "Test". For example, if we create a test class that contains tests for the `LoginEmailFragment`, we should name it `LoginEmailFragmentTest`.

### Prefix any Mock objects with "mock"

```kotlin
private val mockLoginEmailAction: LoginEmailAction = mock()
private val mockAccountValidationRouter: AccountValidationRouter = mock()
private val mockGlobalIdRouter: GlobalIdRouter = mock()
private val mockErrorRouter: ErrorRouter = mock()
private val mockOtpRouter: OtpRouter = mock()

// followed by the object under test
private lateinit var loginEmailViewModel: LoginEmailViewModel
```

### Use Mockito's (mockito-kotlin) mock() instead of @Mock

!!! success "Do this"

```kotlin
private val mockRipcutImageLoader = mock<RipcutImageLoader>()
private val mockChannelDrawableProvider = mock<ChannelDrawableProvider>()
private val mockResources = mock<Resources>()
```

!!! fail "Not this"

```kotlin
@Mock
lateinit var mockRipcutImageLoader: RipcutImageLoader

@Mock
lateinit var mockChannelDrawableProvider: ChannelDrawableProvider

@Mock
lateinit var mockResources: Resources
```

### Use doReturn().whenever() syntax

!!! success "Do this"

```kotlin
doReturn(Observable.just(Success))
	.whenever(mockLoginEmailAction).login(expectedInput)
```

!!! fail "Not this"

```kotlin
whenever(mockLoginEmailAction.login(expectedInput))
	.thenReturn(Observable.just(Success))
```

### Use Arrange/Act/Assert

Format unit tests in the following manner:

```kotlin
@Test
fun `name of unit test`() {
    
    // Arrange
    doReturn(FooData()).whenever(someMock).someMethod()
    
    // Act
    val actual = objectUnderTest.methodToTest()
    
    // Assert
    assertThat(actual).isEqualTo(expected)
}
```
