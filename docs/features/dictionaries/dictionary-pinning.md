# Dictionary Pinning

Dictionaries are versioned. Within the app we download them using a remote configurable map that will provide us with the version for each dictionary variant. The process of updating these dictionary versions is what we call dictionary pinning.

Dictionary pinning consist of two parts, remote and local pinning.

## Remote dictionary pinning

We need to update the latest versions in our appconfig repository. These are the versions we will use at runtime to download the actual dictionaries and use them for the user language/region. For example [ANDROID-5964: Dictionary pinning](https://github.bamtech.co/Mobile/dmgz-android-appconfig/pull/1572).

1. Branch off of `prod-internal` from our [app config repo](https://github.bamtech.co/Mobile/dmgz-android-appconfig)
2. Update the versions in [`src/pinnedDictionaryVersions.json`](https://github.bamtech.co/Mobile/dmgz-android-appconfig/blob/prod-internal/src/pinnedDictionaryVersions.json) to match the version number in the Pin dictionaries to Prod ticket. > **_NOTE:_** You should update/verify all dictionaries, not only those in red. (At this time of writing, we are not using the dictionaries: commerce, off-device, promo, seo. You can skip those.)
3. Run [`./scripts/generate-output/script.main.kts`](https://github.bamtech.co/Mobile/dmgz-android-appconfig/blob/prod-internal/scripts/generate-output/script.main.kts) locally.
4. Run [`./scripts/compare-configs/script.main.kts`](https://github.bamtech.co/Mobile/dmgz-android-appconfig/blob/prod-internal/scripts/compare-config/script.main.kts) locally
5. If the compare-config script reports a change try to identify if the change is actually a breaking one. Typically, you can ask about this in the slack thread about the dictionary pinning or check with your Team Lead/TPM. See the [README](https://github.bamtech.co/Mobile/dmgz-android-appconfig/blob/prod-internal/scripts/compare-configs/README.md) on the compare-configs script for more details
6. Put up a PR to merge all the changes into `prod-internal`. If there are potentially breaking changes, build will fail and merge will be blocked. Then, after confirming it's not a breaking change (as described in step 5) you can add the label `breaking-dictionary-change` to the PR so build will pass and unblock the merge.
7. Once merged into `prod-internal` put up a PR to merge `prod-internal` into `prod`
8. Once the new dictionary versions are deployed to prod, send a [message](https://bamtechmedia.slack.com/archives/C02873S1EFR/p1646672189510459) to `#platform_deployments` to announce the pinning deployment.

## Local dictionary pinning

We need to update the latest versions in our Dmgz codebase. These are the versions we use to access dictionaries in our codebase in an easy way (later explained in [Using Dictionaries](using-dictionaries.md)) For example: [ANDROID-5964: Update pinned dictionaries](https://github.bamtech.co/Android/Dmgz/pull/13516)

1. In the [Android Dmgz project](https://github.bamtech.co/Android/Dmgz) update the [dictionary_bundle_config.json](https://github.bamtech.co/Android/Dmgz/blob/development/dictionary_bundle_config.json) to match the newly pinned versions.
2. Update the dictionaries by running `make updateDictionaries` in the root of the project
3. Final step is to make the PR for all the changes. If there is a release branch and the RC is not ready yet, point the PR to the release branch, otherwise to the development branch
