# Instrumentation Tests

## Description

A set of tools, patterns, and guidelines related to instrumentation tests were designed to help developers in their day-to-day work and ultimately deliver higher-quality builds to QA.

Having our Instrumentation Test Suite as part of the development workflow helps developers with some of the daily challenges they face. Two main points where these tests should play a significant role:

* **Fewer regressions:** In addition to Unit Tests, they provide quicker feedback about new regressions introduced in the project, including in other apps that share the same code.

* **Safety net for refactoring:** These tests allow developers to have a safety net to add new features and apply refactoring where needed with greater confidence that existing functionality will not be affected.

## Walkthrough

This file contains instructions on how to create and run instrumentation tests for Disney+ and Star+ on all supported Android platforms: Google Mobile, Google TV, Fire Stick TV (Amazon TV), Fire Hd Tablet (Mobile Amazon).
  
### Directory Architecture

The first important thing to know is how instrumentation tests process is architected.  
In this case, we have three main modules to work with:

* mobile: Folder which contains all mobile class tests

* tv: Folder which contains all TV class tests

* coreAndroidTest: Folder which contains screen, launcher and config classes.  
  
About the test flow, we are going to work with three main types of classes, which you will probably create or reuse:

* Launcher Classes: Responsible for bringing the app to the point where the test should start

* Screen Classes: Represent a specific screen

* Test Classes:  Responsible for setting up some configs and running the tests

* R2D2, Stubs and extension classes: Classes that will help with additional configurations

Don't worry. We are going to explain all these classes in details.  

![Project Structure](images/instrumented_tests_01.png)
  
### CoreAndroidTest Directory

This folder contains all Launcher, Screen and configuration classes that we are going to use in our tests. They are:

#### **Screen Classes:**

This class represents a real app screen (fragment/activity/layout) and it is responsible for all the assertions and interactions with this screen. For example, if you need to tap a button, move the cursor, change focus, navigate inside the screen or any other interaction with this layout's components, this type of class will take care of that.
To build a screen class, first you will need to define the root screen id on init block or constructor of the class. After that you can start to write the functions that will interact with the screen. Also, each function that you write will have to return the screen class itself or the destination screen class in case you are navigating to other screen.

```kotlin
@Suppress("MagicNumber", "TooManyFunctions")
class EditProfileScreen {

    init {
        withId(R.id.editProfileRootView).waitUntilIsDisplayed(10L)
    }

    /**
     * Checks if the keyboard is showing, and closed it.
     */
    fun closeKeyBoardIfShown(): EditProfileScreen {
        if (isKeyboardShown(true)) pressDpadBack()
        return this
    }

    /**
     * Asserts that the provided [profileName] is the currently entered input on the edit profile editText.
     */
    fun enterProfileName(profileName: String): EditProfileScreen {
        withId(R.id.editFieldEditText).waitUntilIsDisplayed().perform(
            replaceText(profileName),
            closeSoftKeyboard()
        )
        return this
    }

    /**
     * Asserts that the provided [profileName] is the currently entered input on the edit profile editText.
     */
    fun assertProfileNameInputEntered(profileName: String): EditProfileScreen {
        withId(R.id.editFieldEditText).waitForExpectedCopy(profileName)
        return this
    }
}
```

#### **Launcher Classes:**

This type of class is responsible for moving the app to the starting point of your test. For example, if you have to test the login flow, the LoginFlowLauncher class will be responsible for navigating to the login screen as quickly and simply as possible, so you can test the login flow.<br/>
To build this class you will need to pass the destination screen class to test as type parameter of "AndroidTestLauncher<>" which you will inherit on your launcher class.
You will have to override the `startingPoint` function that will reuse existing screen classes to navigate the application to the desired screen and then return this screen at the end.<br/>
You also can set up configurations with R2D2 to mock api calls performed in the middle of this process and start at a specific point in the app.<br/>
Your launcher may or may not start at the usual start of the app (usual start it is the user start, starting at welcome screen and following through login flow). For example, you can start on welcome flow passing through the login flow, or you can start already on home screen. It depends on your configuration and goals.<br/>
Example: you need to test the profile screen, so you will set up R2D2 configuration to mock an already logged in user and start at home screen (or at profile picker screen in case of TV tests), select the desired profile, click on edit and entering the edit profile class. Then you can do the tests you want.

```kotlin
class EditProfileLauncher : AndroidTestLauncher<EditProfileScreen>() {

    override val commonTestSetupTeardowns: Array<ITestSetupTearDown>
        get() = arrayOf(
            R2D2SetupLoginSuccess("v1/public/graphql/login_with_multiple_profiles.json"),
            R2D2SetupPaywall(AccountEntitlementContext.AccountActiveEntitlement())
        )

    override fun startingPoint(): EditProfileScreen =
        ProfilePickerScreen()
            .pressDpadDown() //Change focus to the edit profile button on who is watching
            .pressDPadEnterSelectingProfileAndLandOnSelectProfile() //Press enter on  button and land on SelectProfile.
            .pressDPadEnterSelectingProfileAndLandOnEditProfile() //Press enter on profile and land on EditProfileScreen
}
```

#### **R2D2 Framework:**

R2D2 is a network mocking framework that help us to simulate API calls and return the desired response needed on our tests.
You will read some tips on how to use it here. However, if you want to read and understand more about it (which is strongly recommended), you can find the full R2D2 documentation here: [R2D2 Framework](r2d2_framework.md)
You can use R2D2 in your launcher class to simulate an activated user, an user session and a lot of other configurations to make the application start at the desired point with the desired setup. For example:

```kotlin
override val commonTestSetupTeardowns: Array<ITestSetupTearDown>
        get() = arrayOf(
            R2D2SetupLoginSuccess("v1/public/graphql/login_with_multiple_profiles.json"),
            R2D2SetupPaywall(AccountEntitlementContext.AccountActiveEntitlement())
        )
```

R2D2 can be used to stub responses in the middle of tests. For example:

```kotlin
@Test
fun addNewProfileTest() {
    launcher.launchAndNavToStartingPoint()
        .selectEditProfilesButtonWithDpad()
        .selectAddProfileWithDpad()
        .tapSkipAvatarIconSelectionWithDpad()
        .enterProfileName(NEW_PROFILE_NAME)
        .r2d2 {
            givenRequestInvoked("/v1/public/graphql")
                .whenPartialVariablesMatch(mapOf("operationName" to "createProfile"))
                .thenRespondWithFile("profiles/create_profile_response.json")
        }
        .doneEditProfileWithDpad()
        .assertProfileWithNameExists(NEW_PROFILE_NAME)
}
```

For more information on what is possible with R2D2, please check the documentation.

#### **StubAppConfigValue Classes:**

These classes override any value in the config to return an override setup for the provided configuration. With them, you can override time zone, geographic locations, user configs, payment status, account configuration and lots of other parameters.
You will read some tips on how to use it here. However, if you want to read and understand more about it (which is strongly recommended), you can find the full Config documentation here: [Config Docs](https://github.bamtech.co/Android/Dmgz/blob/development/docs/CONFIG.md)
You can use the StubAppConfigValue mostly on Test classes, to set up the configurations for your tests. For example:

Stub to restrict UIDevice focus to the selected component:

```kotlin
StubAppConfigValue(true, "focus", arrayOf("useInputTextOnKeyListener"))
```

Stub to set up paywall status:

```kotlin
StubAppConfigValue(true, "session", arrayOf("requestPaywallInMeQuery"))
StubAppConfigValue(true, "session", arrayOf("requestPaywallInRegisterMutation"))
StubAppConfigValue(true, "session", arrayOf("requestPaywallInLoginMutation"))
```

Stub to set up the geography location:

```kotlin
StubAppConfigValue("US", "contentApi", arrayOf("X-GEO-OVERRIDE"))
```

Usage example:

```kotlin
@Test
fun firstTimeUser_isTakenToPaywallUponRegistration_debugDictEnabled_withoutPaywallHash() {
    launcher.launchAndNavToStartingPoint(
        StubAppConfigValue(
            true,
            "dictionaries",
            arrayOf("debugDictionaryEnabled")
        ),
        R2D2SetupPaywall(
            AccountEntitlementContext.AccountNeverEntitled(),
            if (testBuildInfo.isAmazon) "paywall/paywall_account_never_entitled_no_paywallhash_amazon.json" else
                "paywall/paywall_account_never_entitled_no_paywallhash.json"
        ),
        StubAuthFlow(AuthFlow.REGISTER),
        R2D2StubLegalSiteConfig(),
        StubAppConfigValue(true, "focus", arrayOf("useInputTextOnKeyListener")),
        R2D2StubRegisterFlow(),
        R2D2BaseUnauthStubbing(),
    )
        .tapSignupButton()
        .enterEmailOnTv("newuseremail@myemail.com")
        .tapContinueToGoToSignUpPasswordScreen()
        .enterPasswordOnTV("Test123!")
        .tapContinueButtonAndLandOnPaywallScreen()
        .assertPaywallScreenIsDisplayedDictKeysEnabled()
        .assertCorrectPricesOnMonthlyButtonDictKeysEnabled()
        .assertCorrectPricesOnYearlyButtonDictKeysEnabled()
        .assertCorrectPricesOnYearlyButtonDictKeysEnabled().run {
            if (testBuildInfo.isAmazon) {
                assertYearlySubCtaTextNotDisplayedDictKeysEnabled()
            } else {
                assertCorrectPricesOnYearlySubCtaTextDictKeysEnabled()
            }
        }
}
```

### Mobile & Tv Directory

This folder contains all mobile and tv Test classes for both Amazon and Google platforms.

#### **Test Classes:**

All classes are placed in their respective directories. `tv` module includes testing for both Google and Amazon STB devices. `mobile` module holds testing for both Google mobile devices and Amazon tablets.
To run tests for Google or Amazon just change the `BuildVariant`. All the settings are ready for that so don't worry about it.
To write test classes, it is recommended to follow the following architecture and patterns:
First, you will create a test class which will inherit from "AndroidTestBase". With that, your class will have access to the launcher property, that you will need to override passing an instance of a specific launcher class related to your new test class. Also, you have to add `@HiltAndroidTest` and `@RunWith(AndroidJUnit4::class)` annotations to the scope of your class.
After all the setup described above, you can write your first test function. It must start with the launcher function initialization to which you can pass all needed pre-configuration such as R2D2 mocking and Stubs. Then, with the screen class returned from the launcher function, you can start to write the actual test. Finally, the new test class will look like this:

```kotlin
@HiltAndroidTest
@RunWith(AndroidJUnit4::class)
class EditProfileTest : AndroidTestBase() {

    @BindValue
    @JvmField
    val preAuthenticatedTest: AutoLoginTestSetup =
        AutoLoginTestSetup(username = "vwmattr+03022021@gmail.com", password = "Test123!")

    override val launcher = EditProfileLauncher()

    @Test
    fun testFocusOnEditProfile() {
        launcher.launchAndNavToStartingPoint(
            StubAppConfigValue(true, "focus", arrayOf("useInputTextOnKeyListener"))
        )
            .closeKeyBoardIfShown()
            .pressDoubleDownIfNeeded()
            .assertPositionOnRecycleHasFocus(1)
            .pressDpadDown()
            .assertPositionOnRecycleHasFocus(2)
            .pressDpadDown()
            .assertPositionOnRecycleHasFocus(3)
            .pressDpadDown()
            .assertPositionOnRecycleHasFocus(4)
    }
}
```

### AutoLoginTestSetup

This class, in combination with com.bamtechmedia.dominguez.config.TestDevConfig_AppModule], provides a
mechanism to 'auto login' users from instrumentation tests.

The test module `com.bamtechmedia.dominguez.config.TestDevConfig_AppModule` declares a
`dagger.BindsOptionalOf` binding for this class. Tests that don't need to go through the login flow can
declare a `dagger.hilt.android.testing.BindValue` which binds an instance of `AutoLoginTestSetup`.

When the app starts, `com.bamtechmedia.dominguez.auth.autologin.DevConfigAutoLogin.credentialsMaybe` emits the
provided credentials and the user will be automatically logged into the app.

```kotlin
@HiltAndroidTest 
@RunWith(AndroidJUnit4::class)
class LogOutFlowTest : AndroidTestBase() {

    override val launcher = LogOutFlowLauncher()

    @BindValue
    @JvmField
    val preAuthenticatedTest: AutoLoginTestSetup = AutoLoginTestSetup()

    @Test
    fun logOutFlow() {
        launcher.launchAndNavToStartingPoint()
            .logOutUser()

        withId(R.id.welcomeButtonSignUp).waitUntilIsDisplayed()
    }
}
```

### EnvironmentOverrideTestSetup

This class allows developers to choose the Environment which tests should run against.

Now that we have tests for both apps, Disney+ and Star+, a specific override of
`com.bamtechmedia.dominguez.sdk.EnvironmentConfig` needs to be provided. The logic to determine which
environment and app the test is using is part of
`com.bamtechmedia.dominguez.di.TestSdk_AppModule.environmentConfigOverride` method.

The test module `com.bamtechmedia.dominguez.di.TestSdk_AppModule` declares a
`dagger.BindsOptionalOf` binding for this class. Given that, you can define the environment to be used
in your tests declaring an instance of `EnvironmentOverrideTestSetup` with the desired environment.

!!! info

    Note: When not declared, QA will be used as default environment.

```kotlin
class SmokeTest {

      @BindValue
      @JvmField
      val environmentConfigTestSetup: EnvironmentOverrideTestSetup = EnvironmentOverrideTestSetup("prod")

      @Test
      fun testMethod() { /* ...*/ }

  }
```

### AndroidTestFilter

#### **AndroidTestFilter:**

Used to determine for which `Project` any given test/test class should be executed.

#### **NightlyTestFilter:**

Filter used to determine if a test should be executed or not. This allows developers to tell CI and the Nightly build
which tests are supported, and therefore, should run for a specific `Project`.

To run a test on a single `Project`, e.g. `Project.STAR`, you need to add `AndroidTestFilter` to a test method or
Test class:

```kotlin
 @AndroidTestFilter(runTestFor = [Project.STAR])
 class WelcomeScreenTest : AndroidTestBase() { ... }
```

Test method:

```kotlin
 @Test
 @AndroidTestFilter(runTestFor = [Project.STAR])
 fun marketSetupSuccess_showsSignUpScreen() { ... }
```

### Conclusion

Wrap-up:

1. Write the test class which will use launcher classes to navigate to the starting point of your test.
2. Pass pre-configuration parameters for mocking and stubbing.
3. Use screen classes to test assertions and interact with the screen (fragment/activity) to be tested.
4. Set up Autologin, if required.
5. Define whether is a `Project.STAR` test and/or `Project.Disney` test, setting up the @AndroidTestFilter
