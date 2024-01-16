# Move Docs Site sources to Dmgz repo

## Why?

When the docs site was initially created, the choice was made to store the sources in a separate repository. IIRC, the reasons for this were mostly technical.

With the GH Actions runners, we can now deploy the docs from the main Dmgz repository. I've got a working example [here](https://github.bamtech.co/Android/Dmgz/pull/12034) and the deployed site [here](https://github.bamtech.co/pages/Android/Dmgz/).

Advantages:

- Changes to code and documentation can be done in a single PR instead of two PRs in two repos.
- Developers only have to checkout and manage a single repository.
- Migrating docs from the old `/docs` markdown files to the Docs site is easier, since the change is in a single repo.

Disadvantages:

- Jenkins and other CI processes will run on Docs PRs, even though they are not necessary when the PR does not contain code changes

## What?

- Move the contents of the Docs Site to the main Dmgz repo.

## How?

- Announce a code freeze to the `dmgz-docs` repository
- Move all the existing code to a folder in the `Dmgz` repository
- Update GH actions workflows so:
    - The site is deployed
    - The linter only lints the docs folder and does not run on non docs changes
- Deprecate/remove the `dmgz-docs` repository

## Impact

- Developers will now have to write docs in the main Dmgz repo.
- The URL of the doc site will change (`https://github.bamtech.co/pages/Android/dmgz-docs/` to `https://github.bamtech.co/pages/Android/Dmgz/`)
