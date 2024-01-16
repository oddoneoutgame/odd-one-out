# :boom:  Release Candidate

The [RC date](https://wiki.disneystreaming.com/display/DMGZ/Android+Release+Train) is the day we create a release candidate build. Between FC and RC dates, PRs with bug fixes that have low risk can be merged into the release branch. Once the RC build is created, only blocker fixes should be merged in the release branch (after syncing with TPMs about having a new RC build to include the blocker fix).

???+ abstract "RC Tasks"
    Engineers from the Release team have to:

    * Update release app config files with default values and WeaponX experiments and deploy the config

    TPMs have to :

    * Kick an RC build on the [#ds-android-builds](https://bamtechmedia.slack.com/archives/C01BPDQQ58F) using the release branch

    * Send an email to QA with the build and tickets resolved.

    * [Upload](https://github.bamtech.co/pages/Android/dmgz-docs/features/paywall/lat_and_alpha_releases/) RC build to Google Alpha & Amazon LAT (for both Star+ & Disney+)

## Release Config Deployment

Before distributing release candidate builds, we must always ensure that the configuration we want to release has also been deployed via the [app-config project](https://github.bamtech.co/Mobile/dmgz-android-appconfig). Please do:

1. Ensure the latest dictionary pin is done on the release app config file.

2. Apply remote configs as default for version X. (Sentry configs, target overrides and experiments)
    1. Get the remote config of the previous version
    2. If any of the config flags becomes the default value within the new version, it should be enabled in the codebase and remove from the config for version X.
    3. If any of the config flags is not definitive, it should be transferred in the version X config.
    4. Apply WeaponX experiments for version X copying over from the previous version.
    5. Deploy the config
