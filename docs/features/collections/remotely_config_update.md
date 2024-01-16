# Remotely Config Update

## How to update collection config remotely?

To update the collection / images config remotely, it requires a few steps. These steps should be done on the [dmgz-android-appconfig](https://github.bamtech.co/Mobile/dmgz-android-appconfig) repository.  

1. Create a PR to the `prod-internal` branch with the updated configs in the [dmgz-android-appconfig collections](https://github.bamtech.co/Mobile/dmgz-android-appconfig/tree/prod/outputs/android/collections) folder. It makes sense to use a name that matches the desired app version.

    ??? example "Example - Create the config file"
        For Disney+ 2.1 version, the `D.2.1.json` file has been created. The PR from this first step could be merged directly. That will deploy the provided `D.2.1.json` file, so once the deploy has been done, it could be referenced via [appconfigs.disney-plus.net/dmgz/prod-internal/android/collections/D.2.1.json](https://appconfigs.disney-plus.net/dmgz/prod-internal/android/collections/D.2.1.json).

2. Setup your build with Jarvis where it points to `collections.configVersion` to `D.2.1`.

    ??? hint "Enable app config environment to prod-internal"
        Enable `Config Staging - App Config Staging Environment (prod-internal)` and verify your changes.  

3. When the updated collections config is correct, create a PR that merges the changes from step 1 from `prod-internal` into `prod`.

    ??? example "Example - Deploy the config file to prod"
        That will deploy the `D.2.1.json` file to prod: [appconfigs.disney-plus.net/dmgz/prod/android/collections/D.2.1.json](https://appconfigs.disney-plus.net/dmgz/prod/android/collections/D.2.1.json).

4. Create a second PR to the `prod-internal` branch where it points the `collections.configVersion` config value to the filename used in step 1. In this example, it would point to `D.2.1`.

    ??? example "Example - Set config version on App config file."
        ```json
        {
        "collections": {
            "configVersion": "D.2.1"
        }
        }
        ```

5. Merge `prod-internal` again into `prod` with the changes from step 4.

    ???+ Important
        Once this PR has been merged, the production builds are referencing the updated collection config json.

???+ note "Images Config Update"
    In order to update the images config, it is basically the same process. The `collections.imagesConfigVersion` config field and [images](https://github.bamtech.co/Mobile/dmgz-android-appconfig/tree/prod/outputs/android/collections/images) folder should be used instead.

???+ warning "Updating an existent collection_config or image_config file"
    If there are existing `collection_config` or `image_config` files already deployed remotely for a specific version, updating this existing file will not affect users who have previously fetched this file. This is because when the app fetches that file version once, it stores it locally, and it will not fetch again the same file version, which causes the new changes to not appear for existing users.

    For this reason, if you need to add new configs to an existing `collection_config` or `image_config` files, you will need to create a new file (containing the existing config + the new config you want to add), and link the new version on the: `"configVersion": "D.X.X"`
    
    Some PR examples are: 

    * [Create new files with the old configs + new config needed](https://github.bamtech.co/Mobile/dmgz-android-appconfig/pull/1180)
    * [Update the configVersion on the app config file](https://github.bamtech.co/Mobile/dmgz-android-appconfig/pull/1180)

???+ warning "Check the Changelog"
    The `collections_config.json` and `images_config.json` files has been changed a lot in the past.

    Updating the collections config or image config for multiple versions at the same time might be a tricky operation. 
    
    Please keep the [changelog](../config_changelog) in mind and double check your changes on the different app versions that your change is pointing to.     
