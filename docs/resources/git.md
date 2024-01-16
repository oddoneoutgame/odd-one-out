# Git

[Install Git here](https://git-scm.com/download/mac) and read about our Git setup below

## Branching

- Active feature development for Disney+ happens on the `development` branch.
- For every release of the app a release branch will be created. e.g. `release/1.2`
- Any patches for that major-minor combination will then happen on that branch. So `1.2.0`, `1.2.1` etc will all come from the release branch
- For Pull Request a branch naming convention is enforced where the branch name should have the format
    - `your_initials/ticket-category-ticket-number-optional-description`
    - **Example:** `tc/ANDROID-5434-optional-description`
    - The ticket categories are the names of the jira tickets. We have four currently:
        - **ANDROID** - Ticket on mobile
        - **ANDROIDTV** - Ticket on STB (Set Top Box), so Android TV / Fire TV
    - One of our `git hooks` ensures this naming convention is respected

## Commit messages

- All commit messages should be prefixed by the ticket name of the branch
- You do not need to add the ticket prefix yourself. This is automatically done by the [commit-msg](../config/git-hooks/commit-msg) git hook.
- **Example** - `ANDROID-1234: Add support for feature X` (but when committing, you can just write `Add support for feature x`).

## Git hooks

- To get early feedback on your code, we automatically install a few `git hooks` when you compile the `mobile` project
- A `git hook` is a script that executes before an event
- We run a few checks before allowing a `git commit` to go through
- One of the checks we run is a code analysis tool called Detekt. Detekt helps ensure that your code is neat and follows our format rules. A commit with formatting errors will fail. If you would like Detekt to autocorrect simple mistakes when committing then you can set `dominguez.detekt.autoCorrect` to true in the `gradle.properties` file.
- If for whatever reason you randomly need to bypass the git hooks, use the `-n` flag to do so
    - Avoid doing this if possible
    - **Example** - `git commit -n -m "Special commit that does not need the git hooks"`

- Sometimes the descriptions of why a `git hook` failed are not sufficient. Try running the commands separately to try and get a more descriptive error. Use these:
    - `./gradlew checkstyle`
    - `./gradlew detekt`

- Sometimes it is okay to bypass a warning by suppressing it. Here is an example of suppressing `TooManyFunctions` error:

    ```kotlin
    ...
    @Suppress("TooManyFunctions")
    class MovieDetailViewModel(
    ...
    ```

### Up to date checks

- Branch protection has been set up to make sure that the `developemt` branch will always succeed and your branch must always contain the latest changes from `development` to be able to merge
- If another PR merges before you that means you will first need to merge those changes back into your branch (and then CI will run again to verify everything still works) before you can merge into `development`

## Force push policy

- In some cases it is okay to force push one of your own branches

## Merge, Rebase or Squash

- When your PR is ready to merge (for now) it is up to the author to decide if you want to do a rebase, squash or merge-commit

## Merging Release into Development

- Every day one workstream team is tasked with performing the daily task of merging `release/X.X` into `development`
- This can be completed by anyone

!!! danger

    **Never merge `development` into a `release` branch**

!!! bug

    There is a bug in the branch protection system, if you create a PR to merge release/1.1.1 into development, clicking the update button wil merge all of the changes from development into release/1.1.1 which is really bad

!!! warning

    - Sometimes there is more than one release branch
    - If this is the case, make sure to also merge the oldest release branch into the newer release branches
    - For example, if we have branch `release/2.14` and `release/2.15`, `release/2.14` is older. If `release/2.14` has new commits that `release/2.15` does not have, we will want to merge `release/2.14` into `release/2.15` too

### How to perform daily merge

- In the step below where you create a new branch, use the corresponding release ticket number in your branch name. [Open this release parent ticket](https://jira.disneystreaming.com/browse/ANDROID-389), find the release version and use that ticket number
    - Example:
        - [Here is an example](https://github.bamtech.co/Android/Dmgz/pull/12914) of Jochem merging `release/2.13` into `development`
        - His branch name uses jira ticket number **ANDROID-4357** because **Release 2.13** is jira ticket **ANDROID-4357** [inside of our parent release ticket](https://jira.disneystreaming.com/browse/ANDROID-389)
- Do the following to merge `release` into `development`:

```text
git fetch --all
git checkout development
git reset --hard origin/development
git checkout -b xx/ANDROID-xxx-merge-release-change
git merge origin/release
```
