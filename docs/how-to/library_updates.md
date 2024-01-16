# Libraries

## Version Catalog

Which version of libraries is defined in our [version catalog](https://github.bamtech.co/Android/Dmgz/tree/development/buildLogic/libs.versions.toml). This catalog is not directly consumed by the project, but it is published to Maven with the rest of the [buildLogic](https://github.bamtech.co/Android/Dmgz/tree/development/buildLogic/README.md#publishing-to-maven) and the main project consumes that published artifact.

## When do libraries get updated?

The Platform team pro-actively attempts to keep the following tools/libraries that are essential to all of the app up-to-date to the latest stable version:

- Gradle
- Android Gradle Plugin
- Kotlin
- androidx

If you need something from a newer version of a library we have a [Library Updates Epic](https://jira.disneystreaming.com/browse/ANDROID-16) with tickets for updates. You can create a ticket in that epic and either do the update yourself or ask the platform team if they can prioritize it.

## Version enforcement

Automatic version bumping and resolution can create a risk for false positives on unit tests like in the example below.

> For example, `androidx.fragment:fragment-ktx:1.2.3` depends on `androidx.core:core-ktx:1.2.0` and `androidx.activity:activity-ktx:1.2.3` depends on `androidx.core:core-ktx:1.1.0`. If a module requests both `fragment-ktx` and `activity-ktx` there would be no problem because Gradle automatically pulls in the highest requested version of `core-ktx`, however if the module `feature-a` only requests `activity-ktx`, it will pull in `core-ktx:1.1.0`. If module `feature-b` pulls in `fragment-ktx` and thus `core-ktx:1.2.0`, and the application module pulls in `feature-a` and `feature-b` that would result in the runtime version being `1.2.0`. So the code that's compiled and tested against 1.1.0 ends up running on 1.2.0. If there is a bug in 1.2.0 that was not present in 1.1.0 the unit test would miss that and you get a runtime failure.

Considering the example above it is safer to ensure that the same library versions are used across the project. Additionally by making sure that all modules use the same version you don't end up with multiple different versions that need to be downloaded and indexed by Android Studio, thus improving build performance and IDE experience.

[resolutionStrategy.failOnVersionConflict()](https://docs.gradle.org/current/dsl/org.gradle.api.artifacts.ResolutionStrategy.html#org.gradle.api.artifacts.ResolutionStrategy:failOnVersionConflict()) functionality helps us here. When that's enabled the scenario above would result in the following Gradle error.

```text
> Could not resolve all dependencies for configuration ':app:debugRuntimeClasspath'.
   > Conflict(s) found for the following module(s):
       - androidx.core:core-ktx between versions 1.2.0 and 1.1.0
     Run with:
         --scan or
         :app:dependencyInsight --configuration debugRuntimeClasspath --dependency androidx.core:core-ktx
     to get more insight on how to solve the conflict.
```

The way to resolve this error is by explicitly declaring which version to use in the version catalog.

The project has been set up to always enforce versions of libraries to by defined in the version catalog.

- If a transitive dependency pulls in a lower version it will automatically bump that up to the version defined
- If a transitive dependency pulls in a higher version the build will fail and the solution is to bump the version that's defined in the version catalog.

## How to update libraries

The updating of libraries consists of a couple of steps. The easiest way to go about it is to follow the following steps

1. Make sure you have a ticket for it.
2. Locally enable [buildLogic](https://github.bamtech.co/Android/Dmgz/blob/development/buildLogic/README.md#using-included-build)
3. Bump the version of the library in [libs.versions.toml](https://github.bamtech.co/Android/Dmgz/tree/development/buildLogic/libs.versions.toml).
4. Make any changes needed for the library update
5. Open a Pull Request and add the label `publish build logic`. This will trigger a Github Actions run to publish a version of the buildLogic
6. Check the output of the Github Action for the version (it is being printed as part of the Gradle logs)
7. Update the value for `dominguez.buildLogicVersion` [gradle.properties](https://github.bamtech.co/Android/Dmgz/tree/development/gradle.properties)
8. Locally disable [buildLogic](https://github.bamtech.co/Android/Dmgz/blob/development/buildLogic/README.md#using-included-build).
9. Run `./gradlew documentDependencies` to update the docs on which dependencies are used.
10. Push all changes to the repository

### What if there is a merge conflict?

Since `buildLogic` versions include the commit you'll need to publish a new version after resolving a merge conflict (every push on a PR that includes the `publish build logic` label will publish a new version) and then update [gradle.properties](https://github.bamtech.co/Android/Dmgz/tree/development/gradle.properties) with the new version.
