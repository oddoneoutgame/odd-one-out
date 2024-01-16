# Accessibility

High level overview of our accessibility setup with some important resources to assist in accessibility tasks

## Accessibility on emulators

Fortunately we can test accessibility on emulators

1. Create an emulator with the Google Play app on it (emulators that are at least API version 29 will have the Google Play app)
2. In the Google Play app, search for **talkback**
3. Download the **Android Accessibility Suite**

## Turning TTS on and off

Add the following adb alias commands to your bash profile to easily turn TTS on and off:

```bash
alias adbEnableTalkback='adb shell settings put secure enabled_accessibility_services com.google.android.marvin.talkback/com.google.android.marvin.talkback.TalkBackService'
alias adbDisableTalkback='adb shell settings put secure enabled_accessibility_services com.android.talkback/com.google.android.marvin.talkback.TalkBackService'
```

- Now you can run `adbEnableTalkback` to turn TTS on, and `adbDisableTalkback` to turn it off

!!! warning

    - If you run `adbEnableTalkback`, make sure to reload the entire app (or at least the screen you're on). This is because some accessibility functionality is initialized on screen startup

## [Content Description](https://developer.android.com/reference/android/view/View#setContentDescription(java.lang.CharSequence))

- It is common to set `android:contentDescription="@null"` when you are confident we should not be adding extra text to
- Do not set these for `TextView`s. [See here](https://developer.android.com/guide/topics/ui/accessibility/apps)
- This is common on `ImageView`s (like a background image, for example)
- When setting the content description in `.xml`, more often than not you will want to reference a string with our `a11y` prefix. All the resource ids are prefixed to make sure that they are unique, so the keys generated from the accessibility dictionary will have the `a11y_` prefix
  - **Example:** `android:contentDescription="@string/a11y_image_app_logo"`
- When setting the content description programmatically, check our `AccessibilityExt.kt` for helpful extension functions
  - **Example:** `binding.skipButton?.a11yKey = R.string.a11y_profilesetup_skip`
  - TODO: Delete this? - looks like we can replace all `contentDescription="@null"` with `android:importantForAccessibility="no"`
    - > If your UI includes graphical elements that are used for decorative effect only, set their descriptions to "@null". If your app's minSdkVersion is 16 or higher, you can instead set these graphical elements' android:importantForAccessibility attributes to "no".
    - [Source of quote](https://developer.android.com/guide/topics/ui/accessibility/apps)

## [Important For Accessibility](https://developer.android.com/reference/android/view/View#attr_android:importantForAccessibility)

- Mark something _not_ important for accessibility if you're confident it is not needed. This is common for a view that's
just a divider line, or maybe a `TextView` that should not be read out loud to the user
  - **Example:** `android:importantForAccessibility="no"`

## [Announce For Accessibility](https://developer.android.com/reference/android/view/View#announceForAccessibility(java.lang.CharSequence))

- Method used to request that the accessibility service announce the given text. This is commonly utilized when we need
something to be announced when a user first lands on a screen, or after the user performs an action

## FocusInterceptLayout

On some devices, accessibility services (like Talkback) consume `KeyEvents`. This intercepts our custom focusing logic.
It was [confirmed here](https://github.bamtech.co/Android/Dmgz/pull/8858#discussion_r850339) that it happens on a TV
emulator with at least API version 29. We fixed it with the following solution:

- Custom views will implement `FocusInterceptLayout`. Use these custom views as the root container in `xml`
- Create a helper class to implement the custom focusing logic for accessibility
- Set the `view.focusSearchInterceptor` to the implementation of `FocusSearchInterceptor`. This can be done inside of `onViewCreated`,
and is commonly done inside of a `if (requireContext().accessibilityNavigationEnabled())` check
- Clean it up inside of `onDestroyView()` by setting the interceptor to `null`
  - **Example:**
    - Custom view - `FocusSearchInterceptConstraintLayout.kt`
    - Helper class - `SearchAccessibilityHelper.kt`
    - Set them together - See `onViewCreated(...)` inside of `SearchTvFragment.kt`:

```kotlin
        override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        ...
        if (requireContext().accessibilityNavigationEnabled()) {
            searchAccessibilityHelper.initAccessibilityFocusSearchIntercept(searchRootView, binding)
        }
        ...
```

- Clean up - See `onDestroyView()` inside of `SearchTvFragment.kt`:

```kotlin
        override fun onDestroyView() {
        ...
        if (requireContext().accessibilityNavigationEnabled()) {
            searchRootView.focusSearchInterceptor = null
        }
        ...
```
