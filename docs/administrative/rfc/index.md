# RFC (Request for Comments)

An RFC is a document describing a change in our codebase.

## Why?

- Provide a way for developers to get feedback on ideas and suggestions before implementation.
- Ensure that cross-team changes can be discussed and reviewed by all interested parties.
- Provide a historical overview of changes within the codebase.

## When?

RFCs should be submitted when making significant changes in the code base that impact multiple teams. For example:

- Migrating from RxJava to Coroutines.
- Changing the view architecture from MVVM to MVP.

We do not want to slow down regular development on the app. Most changes to our codebase do not require one, such as:

- Changes impacting only a single feature team.
- Changes that do not take a lot of time to implement. In these cases, you can simply submit a PR with the change and request a review from @android-fed.

Although not required, RFCs for single team changes are still welcome and a nice way to get input and feedback from the rest of the engineers.

## How?

RFCs are submitted as PRs to this repo (`dmgz-docs`) so the proposal can be discussed using threaded comments. This allows for concurrent discussions on different points.

- Copy and rename the [docs/administrative/rfc/template](https://github.bamtech.co/Android/dmgz-docs/blob/main/docs/administrative/rfc/rfc_template.md) into the [docs/administrative/rfc](https://github.bamtech.co/Android/dmgz-docs/tree/main/docs/administrative/rfc) folder.
- Complete the template. Feel free to modify the template to fit your proposal.
- Add your proposal to the navigation under RFCs in [mkdocs.yml](https://github.bamtech.co/Android/dmgz-docs/blob/main/mkdocs.yml).
- Submit a PR.
- Request a review from @android-fed.
- Get at least two approvals.
- Merge and start implementation.

For inspiration, take a look at the existing RFCs in the [rfc](https://github.bamtech.co/Android/dmgz-docs/tree/main/docs/administrative/rfc) folder.

If you are:

- Unsure if an RFC needs to be written
- Would like some help with writing one
- Would like to discuss your proposal before submitting an RFC

Please contact the tech-council! You can reach the council on Slack in #ds-android-tech-council or by joining one of the office hours.
