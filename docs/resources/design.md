# Design

* This doc gives a high overview of how we handle Design in Dmgz
* [Quick Zeplin link to our colors, TypeRamps, background, etc.](https://app.zeplin.io/project/62d587fbdeab4c10a1b62a84/dashboard)

## Design Engineering

* We have a Design Engineering team - [here is their documentation](https://github.bamtech.co/pages/design-engineering/documentation/)
    * [Direct link to our Android Design Engineering](https://github.bamtech.co/pages/design-engineering/documentation/about/android-team.html#android-team)
* They work on a Design Library that we use in our code - [here is the link to their repository](https://github.bamtech.co/design-engineering/android-design-library)
* Have any questions? Ask the person on your workstream that is on the **Android Design Group**
    * **Team Bender** - Guilherme Branco
    * **Team Edna** - Louis Davin
    * **Team Mandalorian** - Jon Kennedy
    * **Team Russell** - Selcan Guner
    * You could also reach out our Android Design Engineering Team directly: Sandra Dupre or Fulya Yongaci

## Android Design Library

* The Android Design Library helps us maintain a Design System. It makes working with colors, fonts, etc. across multiple Brands (Disney+, Star+, Hulu) in a single code base easier and more consistent
* [Android Design Library Repo](https://github.bamtech.co/design-engineering/android-design-library)
* [Exampe PR](https://github.bamtech.co/Android/Dmgz/pull/12418/files#diff-44160f39f6f45c7b6c82031da8118cfd366267ec1d6bd7d283de39ed5117a895R21) on how to update the Design Library Version in the Dmgz codebase
* Below will guide you on how to use the Android Design Library correctly in Dmgz

### Colors

* Only use colors that are defined in the Android Design Library
    * [Zeplin link of our colors here](https://app.zeplin.io/project/62d587fbdeab4c10a1b62a84/screen/62e94de696842f16a9f64a55)
    * If there is a color in your zeplin design that is not already defined, **please reach out to someone on the Design Engineering team**. Do not add a new color
* When using colors, **always use attributes**, not a direct color. We have to do this because Dmgz builds the apps for multiple different brands

!!! success "Correct color usage with attributes"

    ```xml
    android:textcolor="?gray100"
    ...
    <solid android:color="?primary" />
    ```

#### Gradients

* Do _not_ mix colors and attributes!
* What we mean is this - if you find an attribute value for `startColor` and `centerColor` but not for `endColor`, _please do not add a new value for `endColor`_. Reach out to Sandra and she can add the new value and publish it via our library

### TypeRamp

* TypeRamp is how we style our text in app
    * [Zeplin link to our TypeRamps here](https://app.zeplin.io/project/62d587fbdeab4c10a1b62a84/screen/62d588217341af12c54aac92)
* Only use TypeRamp values that are defined in the Android Design Library. Please do not override the TypeRamp values. Do not add values for:
    * line spacing
    * text size
* If there is a TypeRamp in your zeplin design that is not already defined, **please reach out to someone on the Design Engineering team**. Do not add a TypeRamp

!!! success "Correct TypeRamp style usage"

    ```xml
    <TextView
    android:id="@+id/confirmPasswordTitle"
    style="@style/TypeRamp.Headline.H1"
    ...
    <style name="Disney.TextView.FilterItemFocused" parent="TypeRamp.Headline.H3.Heavy">
    ```

!!! fail "Example of overriding the textSize - do not do this!"

    ```xml
    style="@style/Disney.TextView.Metadata"
    android:textSize="7sp" // do not do this!
    ```

!!! warning "Never use any text size **under 10sp**"

    Never use any text size **under 10sp**. Google can remove our app if we use
    text below 10sp because it is not accessibly enough

## Design System

* We utilize a Design System, and the library that our Android Design Engineering works on helps us maintain it
* [Quick Zeplin link to our colors, TypeRamps, background, etc.](https://app.zeplin.io/project/62d587fbdeab4c10a1b62a84/dashboard)
