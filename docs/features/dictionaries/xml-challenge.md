# XML Challenge

## The Problem

Some text in our app is set in our layout xmls. The only way to do this is through string resources, which represents a challenge for us because it doesn't allow us to use runtime downloaded dictionaries.

## Solution

To solve this problem the app hooks in to layout inflation using [LayoutInflater.Factory2](https://developer.android.com/reference/android/view/LayoutInflater.Factory2). This Factory gets a callback for every View that gets defined in a layout XML that gets inflated.

Take the layout below as an example.

```xml

<androidx.constraintlayout.widget.ConstraintLayout xmlns:android="http://schemas.android.com/apk/res/android"
                                                   xmlns:app="http://schemas.android.com/apk/res-auto"
                                                   android:layout_width="match_parent"
                                                   android:layout_height="match_parent"
                                                   android:paddingStart="70dp"
                                                   android:theme="@style/ThemeOverlay.Avatars">

    <androidx.constraintlayout.widget.Guideline
            android:id="@+id/guideline"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:orientation="vertical"
            app:layout_constraintGuide_percent="0.56"/>

    <TextView
            android:id="@+id/titleTextView"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"/>
</androidx.constraintlayout.widget.ConstraintLayout>

```

The method [onCreateView(String, Context, AttributeSet)](https://developer.android.com/reference/android/view/LayoutInflater.Factory.html#onCreateView\(java.lang.String,%20android.content.Context,%20android.util.AttributeSet\)) will be invoked three times. On each invocation the first argument will be the XML element name, so: `androidx.constraintlayout.widget.ConstraintLayout`, `androidx.constraintlayout.widget.Guideline` and `TextView` in that order.

The `LayoutInflater.Factory2` is designed in such a way that the system will create an instance of the `View` if it returns null. This allows libraries and apps to decide if they want to create another class then what was requested in Layout. As an example the appcompat library will create an `AppCompatTextView` when the XML element is `TextView`, this results in support for certain newer features of TextView being available on older platforms. Check [here](https://developer.android.com/reference/androidx/appcompat/app/AppCompatViewInflater#protected-methods_1) for a full list of views that are being created by appcompat instead of framework classes.

For dictionary strings the app does not want to replace this logic, but by using a delegation pattern it does allow us to:

- Adjust subclasses of `TextView` created by appcompat to set the dictionary value based on the string resource id.
- Create new instances for views that are not created by appcompat and set correct dictionary values for those.

The factory is applied to the activity layout inflater, and all Fragments will be using a clone of that.

Our custom LayoutInflater will delegate view creation and attribute resolution to Helper classes. For example, for TextView's referenced in layouts [TextViewLayoutInflaterHelper](https://github.bamtech.co/Android/Dmgz/blob/8d7706923c1d9c7e0c4343fb3e7d791783da9292/features/dictionaries/src/main/java/com/bamtechmedia/dominguez/dictionaries/layoutinflater/TextViewLayoutInflaterHelper.kt) will do the job.

This Helper classes will use [DictionaryLayoutInflaterHelper](https://github.bamtech.co/Android/Dmgz/blob/8d7706923c1d9c7e0c4343fb3e7d791783da9292/features/dictionaries/src/main/java/com/bamtechmedia/dominguez/dictionaries/layoutinflater/DictionaryLayoutInflaterHelper.kt) to resolve the dictionary keys present in the text attributes from the widgets and assign them correctly.

The string resources that we use in our xmls will resolve to a combination of dictionary + key so that the DictionaryLayoutInflaterHelper can split it and retrieve the dictionary value at runtime correctly.

All of this might be confusing or hard to understand. We will try to explain it also with an example:

Currently, in our fragment_kids_mode_selection.xml we have:

```xml

<com.bamtechmedia.dominguez.widget.button.StandardButton
        android:id="@+id/offButton"
        android:layout_width="0dp"
        android:layout_height="@dimen/btn_min_height"
        android:layout_marginTop="32dp"
        android:minWidth="85dp"
        android:focusable="true"
        app:buttonType="secondary"
        android:text="@string/ts_application_btn_add_profile_kids_profile_off"
        android:focusedByDefault="true"
        android:focusableInTouchMode="true"
        app:buttonBackground="@drawable/transparent_button_background"
        app:buttonTextColor="@color/color_basic_text"
        app:layout_constraintBottom_toTopOf="@+id/onButton"
        app:layout_constraintEnd_toEndOf="@id/twoThirdsGuideLine"
        app:layout_constraintStart_toStartOf="@id/oneThirdGuideLine"
        app:layout_constraintTop_toBottomOf="@+id/kidsModeDescription"
        app:layout_constraintVertical_bias="0.5"/>
```

And the string resource used in `android:text` is:

```xml
<string name="ts_application_btn_add_profile_kids_profile_off">ts_application_btn_add_profile_kids_profile_off</string>
```

Our custom LayoutInflater (ConfigStringsLayoutInflater) will delegate the creation of the StandardButton to the [StandardButtonLayoutInflaterHelper](https://github.bamtech.co/Android/Dmgz/blob/8d7706923c1d9c7e0c4343fb3e7d791783da9292/features/dictionaries/src/main/java/com/bamtechmedia/dominguez/dictionaries/layoutinflater/StandardButtonLayoutInflaterHelper.kt). This class will get the attribute `android:text` value (`ts_application_btn_add_profile_kids_profile_off` in this case) and pass it to the DictionaryLayoutInflaterHelper who will extract the dictionary and the key from the value and resolve it. For this example the dictionary would be `application`and the key would be `btn_add_profile_kids_profile_off`. And with this the dictionary key is resolved like the following:

```kotlin
dictionaries.getDictionary(dictionary).getString(key)
```

And StandardButtonLayoutInflaterHelper will assign the resulting value to the text attribute of the newly created view.
