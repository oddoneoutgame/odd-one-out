# CTV Activation

CTV activation allows users to login to a TV device using a mobile device on the same network.

## Feature Info

- Mahmoud has given a great presentation on what this feature is and how it works. You can check out [the slides](https://docs.google.com/presentation/d/1LkRxarrZMhf_r0zj72vypVeh9AxIynFyE_VEOryqWC0/edit#slide=id.gd0b4d203b3_0_21) or a [recording](https://disneystreaming.zoom.us/rec/share/6PmxZOSnrECll8e-mEGIOj6lO2pXkiJoWYP6kL1pXOkSLHTwBvzOyiT8fN3ajF-k.4ZG9OWi4oypJRs5P?startTime=1649862141000).
- To communicate between mobile and TV, we use the [Companion library](https://github.bamtech.co/mobile-core/android-companion).
- We use the same app ID for both D+ and S+. This means users can do CTV activation across products: using a S+ mobile to authenticate a D+ TV and vice versa.
- There are two different implementations of the feature.

### V1

The V1 and initial implementation uses credentials stored in [Google Smart Lock](https://developers.google.com/identity/smartlock-passwords/android).

- [Sequence diagrams](https://github.bamtech.co/fed-solutions/documentation/tree/master/docs/identity/ctv-activation#v1-flow).

### V2

The V2 implementation works with any account logged in on the mobile device, regardless of whether Smart Lock is enabled or what password manager is used.

- [Sequence diagrams](https://github.bamtech.co/fed-solutions/documentation/tree/master/docs/identity/ctv-activation#v2-flow).
- [Technical doc](https://docs.google.com/document/d/1ZfjBBieCUnHVgf_nXkAR5NrDwVtNY-LfiUZ8YPLKA5M/edit)

### Availability

|       | Availability |
| ----------- | :-----------: |
| :icons-disney-logo: Disney+ | :white_check_mark: |
| :icons-star-logo: Star+ | :white_check_mark: |
| :fontawesome-solid-mobile: Mobile | :white_check_mark: |
| :fontawesome-solid-tv: TV | :white_check_mark: |
| :material-earth: Regions | :white_check_mark: All regions |

### How to test

#### V1

- Use a physical TV device and a physical mobile device that are on the same network.
- Google Password Manager needs to be enabled on your mobile device.
- Make sure you have credentials stored in Google Password Manager for the app you're testing. You can check this on [passwords.google.com](https://passwords.google.com/). If you don't have credentials stored, login to the app with Google. Make sure "Offer so save passwords" is enabled in the Google Password Manager settings.
- Make sure both devices point to the same environment in Jarvis
- Disable CTV activation V2. Replace <TARGET_PACKAGE> in the following ADB command with either `com.disney.disneyplus` or `com.disney.starplus` and run it. `adb shell am broadcast -n com.disney.disneyplus.jarvis/.AdbInteractionBroadcastReceiver -a com.disney.disneyplus.jarvis.SET_ACTIVE_CONFIG --es encodedJson WwogIHsKICAgICJuYW1lIjogIkNUViBBY3RpdmF0aW9uIHYyIiwKICAgICJ1bmlxdWVLZXkiOiAiY3R2X2FjdGl2YXRpb25fdjIiLAogICAgInRyYW5zZm9ybU1hcCI6IHsKICAgICAgImN0dkFjdGl2YXRpb24iOiB7CiAgICAgICAgInYyRW5hYmxlZCI6IGZhbHNlCiAgICAgIH0KICAgIH0KICB9Cl0K --es <TARGET_PACKAGE>`
- Be logged out on TV
- Be logged in on Mobile
- Start TV app
- Start Mobile app
- A dialog to login on TV should appear on mobile

#### V2

- Use a physical TV device and a physical mobile device that are on the same network.
- Make sure both devices point to the same environment in Jarvis
- Be logged out on TV
- Be logged in on Mobile
- Start TV app
- Start Mobile app
- A dialog to login on TV should appear on mobile

### Relevant classes

All relevant code is located in the `ctvActivation` [module](https://github.bamtech.co/Android/Dmgz/tree/development/features/ctvActivation).
