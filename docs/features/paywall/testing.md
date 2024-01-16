# Testing Purchases

This page details how to go about testing purchases on our IAP platforms.

## Testing Google Purchases

In order to test Google purchases, the following criteria must be met:

### Google account setup

* Your Google account that you are logged in to on your test device needs to be set up as a licensed tester.
    * Only a few members of the team have permission to add licensed testers. This is because it's an admin level permission and Google limits the number of accounts to 400 licensed testers company wide (not just DSS, but TWDC).
    * Reach out to your team lead and supply them the desired Google account you would like to licensed as a tester.
        * Note: your `first.last@disneystreaming.com` is Gsuite enabled and is supported as a Google account.
* Next, you will need to be added as a "tester" for the desired app.
    * There are two groups of testers on the Play Console at the time of this writing: `Disney+ Internal` and `Star+ Internal`. The email will need to be added to one of these lists (or both).
    * While logged in to that Google account that was added, opt in as a tester for the following links:
        * Disney+:
            * [Alpha](https://play.google.com/apps/testing/com.disney.disneyplus)
            * [Internal](https://play.google.com/apps/internaltest/4701080507122322351)
        * Star+:
            * [Alpha](https://play.google.com/apps/testing/com.disney.starplus)
            * [Internal](https://play.google.com/apps/internaltest/4698798746879901472)

At this stage, you should be able to make a test purchase. From here, when entering the application, you should be presented with a test purchase dialog from Google.

### Store listing must be available

First and foremost, an app with the same package name must be uploaded to the Play Store. For most instances, this will have already been set up as Disney+ has been released since 2019, and Star+ store listings were created in March, 2021. If additional apps are to be spawned from the codebase (like Star+), the process is as follows:

* Create the Store listing.
* Follow the steps for the bare minimum of a release. This includes:
    * Filling out the Main Store Listing.
        * This includes app icon, screenshots, description. For Star+, we simply re-used Disney+ assets. Those are to be replaced at a later date with actual Star+ assets.
    * Release an APK to the Internal Test Track. **Be certain that this is not being released to production**.
    * Set up a list of testers.
* SKU's must be uploaded to the store listing.
    * First, the SKU's must be created by the Offer Management team.
    * Once SKU's are defined, upload them to the list of subscriptions.
    * If the app is not available, it is important to not set a low price. This is because Google showcases a range of pricing information on the Play Store. For example, if one sets the price to $1.99 for monthly, and $10.99 for yearly, Google will display `$1.99 - $10.99`. Therefore, it's a good idea to set a middle ground, such as $15.99 and $29.99.
* The new app must be set up as an accepted "partner" from Activation's perspective.
    * Reach out to someone on the Activation team to let them know a new store is being created. (`#activation` in slack).
    * The Activation will need to utilize utilize the OAuth Client ID that is associated with the Google Play Developer account. This is the same Client ID that is used by Disney+, Star+ and ESPN+.

## Testing Amazon Purchases

For Amazon, there are two ways to test purchases.

### Sandbox Testing

Sandbox testing within amazon is an _entirely local_ to your device method of testing. This does _not_ interact with Amazon in any way.

!!! warning
    **Sandbox testing is _only_ supported in the QA environment on Amazon.**

This is done via an Amazon-provided app called [Amazon App Tester](https://developer.amazon.com/docs/in-app-purchasing/iap-install-and-configure-app-tester.html). The app tester uses a file on the device called `amazon.sdktester.json`.

To help ensure that all dev and QA devices are up to date, we have an internal application called [Amazon IAP Helper](https://github.bamtech.co/arietschlin/Dmgz-Amazon-IAP-Helper) (found on [Appcenter here](https://appcenter.ms/orgs/BAMTECH-Media-Organization/apps/D-Amazon-IAP-Helper/distribute/releases)).
This application pulls down a file from a Firebase console with the necessary SKU's for all projects we support. See the README on the Amazon IAP Helper app for more details.

### Live App Testing (LAT)

* "Live App Testing" is a mechanism provided by Amazon that actually interacts with Amazon's services

* This completely ignores the `amazon.sdktester.json` file and instead pulls from Amazon
* This requires a "LAT" release to be done and one must be invited to the console
* Here are the links to deliver the newest LAT build to your Fire TV / Fire Tablet
    * [Disney+](https://www.amazon.com/gp/product/B07Y8VP89H)
    * [Star+](https://www.amazon.com/gp/product/B08ZGW554P)
* If you have access to the console, you can [reset LAT purchases here](https://developer.amazon.com/apps-and-games/console/app/amzn1.devportal.mobileapp.506ac6bea9a244c3a7f5b328713ce3b2/live-app-testing?)
    * Oftentimes QA members request this, or you might need it when testing LAT
    * It resets for both QA and PROD
    * Select `Reset In-app items`
        * `Reset Tester Entitlements` - This will reset premiere access
        * `Reset Tester Subscriptions` - This will reset a subscription to the app
* [More info on setting up LAT](https://wiki.disneystreaming.com/pages/viewpage.action?pageId=97663346)
* For more information on LAT and how to do releases, see the [LAT and Alpha releases docs](lat_and_alpha_releases.md).
