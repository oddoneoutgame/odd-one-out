# :rocket:  Feature Complete

The [FC date](https://wiki.disneystreaming.com/display/DMGZ/Android+Release+Train) is the day we plan to finish the development of the features for the next release, create the release branch, and send a Feature Complete build to QA.

???+ abstract "FC Tasks"
    Engineers from the Release team have to:

    * Create a `release/X.X` branch

    * Bump `development` branch version

    TPMs have to :

    * Ensure the feature code is merged and tickets are resolved

    * Kick an FC build on the [#ds-android-builds](https://bamtechmedia.slack.com/archives/C01BPDQQ58F) using the release branch

    * Send an email to QA with the build and tickets resolved.

## Create a `release` branch

The release branch should be created on the same day as the FC Build. To create the `release` branch follow these steps:

1. Announce in [#ds-android-devs](https://bamtechmedia.slack.com/archives/CCS275WKV) that you are starting the process of creating a release branch and that all merging of PRs will be temporarily blocked. Ask everyone to verify if all PRs that need to go on this release have the correct `Milestone`.

    ???+ warning
        Each team is responsible for adding the `Milestone` to the PRs when **creating the PR**; this helps identify which PR was merged in which app version easily.

    ??? example "Message template"

        The Release Team will cut the `release X.X` branch. Please make sure your Prs have the correct `Milestone`. We will block merging on the `development` branch now and unblock it soon.

2. Block all merging of PRs in `Dmgz Setting` -> [`Branch`](https://github.bamtech.co/Android/Dmgz/settings/branches) -> `Edit development` -> `Tick "Restrict who can push to matching branches"` -> `Save changes` (all team leads should have the permission to do this).

3. Locally create the branch `release/X.X` on the same commit as the current `HEAD` of the `development` branch. Push the `release/X.X` branch to origin.

4. Go through all PRs that contain the `X.X Milestone` and change the base branch to the `release/X.X` branch. With [this filter](https://github.bamtech.co/Android/Dmgz/pulls?q=is%3Apr+is%3Aopen+base%3Adevelopment+milestone%3AX.X) you can see the PRs that needs to be pointing to the `release/X.X` branch.

    ??? warning
        For PRs that should go into the release branch but do not contain the Milestone set, it will be the responsibility of the PR owner to update the branch later on.

5. Unblock the merging of PRs into the `development` branch. (Undo step 2).

6. Announce in [#ds-android-devs](https://bamtechmedia.slack.com/archives/CCS275WKV) that merging is now unblocked and PRs with the Feature Milestone have the release branch as the new base branch.
  
    ??? example "Message template"
        All PRs containing `X.X Milestone` now target the `X.X release` branch. The merge on the `development` branch is unblocked. :thumbsup:

## Bump the `development` branch version

After creating the new release branch, we need to bump the app version on the development branch. Steps are:

1. First deploy a new app config file for the new app version. See [this PR](https://github.bamtech.co/Mobile/dmgz-android-appconfig/pull/1469) as an example. (Use the New Version label).

    ???+ warning
        The app config PR needs to be deployed before merging the bump version PR (the step below).

2. Update the `dominguez.version.majorMinor` property in the Dmgz root `gradle.properties` file with `Y.X+1` and create a PR to the development branch. See [this PR](https://github.bamtech.co/Android/Dmgz/pull/13091) as an example.
