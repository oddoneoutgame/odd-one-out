# Subscription SKU's

This document outlines the SKU's that are used for subscriptions within this project (for in app products, see [product sku list](product_sku_list.md)). This includes all applications supported (Disney+ and Star+)

## Disney+

* `com.disney.monthly.usdisneyplus2021.google`
* `com.disney.yearly.usdisneyplus2021.google`
    * **Term**: Yearly/monthly SKU's
    * **Regions**: US Only
    * **Platform**: _Google Only_
    * **Description**: These were created for Google only because of the way that Google wanted to do the price change. They told us to increase the price of the _existing_ SKU's (`com.disney.(yearly|monthly).disneyplus(7dft).google`) a month early. In order to ensure that the new Price was not exposed to _new_ users, we created these two SKU's.
    * **Prices** (US Based):
        * Original: $6.99/$69.99
        * 03/26/21: Increased to $7.99/$79.99
* `com.disney.monthly.disneyplus7dft.google`
* `com.disney.yearly.disneyplus7dft.google`
    * **Term**: Yearly/monthly SKU's, with Free Trial
    * **Regions**: All (some regions did _not_ get this, but not sure which)
    * **Platform**: Google/Amazon
    * **Description**: These were the first SKU's created for Disney+ (along with the non-`7dft`and included a free trial.
        * The price was increased on February 23rd for US only.
    * **Prices** (US Based):
        * Original: $6.99/$69.99
        * 02/23/21: Increased to $7.99/$79.99
* `com.disney.monthly.disneyplus.google`
* `com.disney.yearly.disneyplus.google`
    * **Term**: Yearly/monthly SKU's
    * **Regions**: All (some regions did _not_ get this, but not sure which)
    * **Platform**: Google/Amazon
    * **Description**: These were the first SKU's created for Disney+ and included a free trial.
        * The price was increased on February 23rd for US only.
    * **Prices** (US Based):
        * Original: $6.99 / $69.99
        * 02/23/21: Increased to $7.99/$79.99
* `com.disney.monthly.disneyplus2021.google`
* `com.disney.yearly.disneyplus2021.google`
    * **Term**: Yearly/monthly SKU's
    * **Regions**: Originally just Star/Welch countries. For Amazon, this was introduced to US on 03/26/21.
    * **Platform**: Google/Amazon
    * **Description**: These were the SKU's used with the intention of increasing the price to all users.
    * **Prices** (US Based):
        * Original: $6.99 / $69.99
        * 02/23/21: Increased to $7.99/$79.99
* `com.disney.monthly.dplusday21.google`
* `com.disney.monthly.dplusday21.amazon`
    * **Term**: Monthly SKU
    * **Regions**: All except APAC.
    * **Platform**: Google/Amazon
    * **Description**: These were SKU's used for the Disney+ Day offer in 2021. This was an offer that started at $1.99 for the first three months, then normal pricing afterwards. Some additional notes:
        * For Google, we are using the Introductory Pricing.
            * [How to set up introductory pricing](https://support.google.com/googleplay/android-developer/answer/140504?hl=en)
            * [Developer Documentation](https://developer.android.com/google/play/billing/subscriptions#intro)
        * For Amazon, we set the prices at the introductory offer ($1.99), then performed a price increase after three months
    * **Prices** (Us Based):
        * Original: $7.99
        * Introductory Price: $1.99
* `com.disney.monthly.dplusday22.google`
* `com.disney.monthly.dplusday22.amazon`
    * **Term**: Monthly SKU
    * **Regions**: All except APAC.
    * **Platform**: Google/Amazon
    * **Description**: These were SKUs used for the Disney+ Day offer in 2022. The setup was identical to 2021.
    * **Prices** (US Based):
        * Original: $7.99
        * Introductory Price: $1.99
* `com.disney.monthly.dpluswithads.google`
* `com.disney.monthly.dpluswithads.amazon`
    * **Term**: Monthly SKU
    * **Regions**: US.
    * **Platform**: Google/Amazon
    * **Description**: The Monthly SKUs for Disney+ with ads.
    * **Prices** (US Based):
        * Original: $7.99

## Star+

* `com.star.monthly.starplus.google`
* `com.star.yearly.starplus.google`
    * **Term**: Yearly/monthly SKU's
    * **Regions**: All Star+ based regions.
    * **Platform**: Google/Amazon
    * **Description**: These were the first SKU's created for Star+ and included a free trial.
        * The price was increased on February 23rd for US only.
    * **Prices**:
        * As of the time of this writing, pricing has not been finalized.

## Pricing

Note: The above pricing information is US based at the moment. In the resources below is a link to a wiki page with every single region and their expected price. The prices are defined by the Offer Management team (or at least passed to us from them via a JIRA ticket). In general, both Amazon and Google will do an automatic conversion for you when you enter the base price.
However, that rarely (if ever) matches the expected price from Offer Management. As a result, it is required to update each region individually on the Amazon Appstore and Google Play Store.

## Resources

* [Current Pricing and Platform Support](https://wiki.disneystreaming.com/display/BUSOPS/Current+Pricing+and+Platform+Support)
* [Product Overview & Requirements](https://wiki.disneystreaming.com/pages/viewpage.action?pageId=26289276) - A list of every region we support and their expected requirements (login only vs signup).
* [Amazon's Countries and territories](https://www.amazon.com/gp/help/customer/display.html?nodeId=GG6HESXQN45DZQ8N)
    * Whereas Google supports individual countries, Amazon IAP support is divvy'd up by regions, called "marketplaces". This link shows the list of supported countries by marketplace.
* Price change docs
    * [February 23rd Price Change Wiki](https://wiki.disneystreaming.com/display/BUSOPS/Feb+23+Price+Increase)
