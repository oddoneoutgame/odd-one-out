# Bamnet IAP Library Updates

Every once in a while, we will need to make an update to the Bamnet IAP library in order to fix an issue within the Disney+ application. This document details how we can go about doing that.

## Libraries

* [Disney Streaming IAP](https://github.bamtech.co/mobile-core/android-bamnet-iap)
* [Base IAP](https://github.bamtech.co/mobile-core/android-iap-base)

## Process

* Pull down library: <https://github.bamtech.co/mobile-core/android-bamnet-iap>
* Make new branch
* Make necessary changes
* Update the `CHANGELOG.md` file with your changes
    * At the top of the changelog is a header called `master`. While we're working in the alpha stage, we place all updates there.
    * There are multiple sections:
        * `Breaking` - Place any breaking changes here. This includes anything such as new API's, changed parameters in existing API's, etc.
        * `Enhancements` - Any enhancements that were made in the update.
        * `Bug Fixes` - Any bug fixes that were implemented.
        * When the final build is cut, these will be added to a new header.
* Test local integration with D+
    * Ensure that the library is in the same folder as the Dmgz project.
    * Set `dominguez.includeIapBuild` to true in your local `~/.gradle/gradle.properties`.
        * Note that after syncing the Dmgz project, the IAP library will be included as a subproject. This allows you to make changes in the same Android Studio window as Dmgz.
    * Build the project as you would normally do.
    * Test your changes and make adjustments if necessary.
    * Now that you've tested locally and it all works, we need to push the changes to the IAP library and then the D+ app.
        * IAP Library
            * First, push up your changes.
            * Then, make a PR. Tag Team Mandalorian to help review and possibly reach out to Shaun Rowe to delegate to the mobile core team.
                * Each PR in the Bam IAP Repository will need to be approved by someone from the Mobile core team.
            * Once the PR is merged, CI will publish the changes so that they are available to the D+ application.
        * D+ App
            * Once the changes are deployed, commit your changes.
            * Build and run the app to ensure it is pulling from the new version properly.
            * Push your changes and create the PR.
