# Gradle build logic revamp

## Why?

### Trigger

We love Kotlin, it's a popular language and most folks working with Android would rather use Kotlin as opposed to Java or Groovy. It's fair to assume that the same sentiment extends to people working on build logic and scripts as well.

An initiative the tech council is working on is to start using Kotlin in build logic: [ANDROID-3589](https://jira.disneystreaming.com/browse/ANDROID-3589)

We currently have build logic scattered between couple of places and couple of languages:

- Build script in Groovy that mainly live in our `gradle` top level directory in the project
- Custom Gradle plugins and tasks that mainly live in `buildSrc` that is a mix of Groovy/Java

The main concern with starting to use Kotlin in those build scripts is the performance hit that comes from compiling Kotlin there, you can refer to: [Github issue](https://github.com/gradle/gradle/issues/15886) for comparison in performance

### Problem statement

While investigating the initiative, I came to the conclusion that we should re-adjust our definition of the problem to more accurately capture its essence.

- Gradle scripts are very powerful which can lead to misuse and complications to the build logic
- Depending on Gradle scripting leads to degrading performance:
  - The more scripts that has to be parsed and executed at runtime, the slower the build and the more demanding it becomes
  - Kotlin will only make this much worse
- Decoupling build logic from our project, just like we do with any feature module

## What?

The solution I am proposing has a very simple idea at its core.

> Move away from scripting as much as possible in our build logic.

High level overview of the solution:

- Move all of our build logic to custom Gradle plugins, tasks and extensions that can be written in Kotlin
- Centralize our build logic in an external project that can be consumed by other projects (mainly our app). This project will be consumed as a dependency rather than just being thrown on the compilation path like buildSrc.

### How does solve the problem?

#### Kotlin

- We can use Kotlin everywhere
- We can write our custom plugins, tasks and extensions as pure Kotlin classes in our new build logic project. Even better, we can write tests for them
- We can also write Kotlin in all of the Gradle scripts. In the build logic project and all other projects

#### Performance

**Build logic project**

- The performance of Kotlin DSL in this project might be a bit slower than Groovy's
- This will only impact people working on build logic and won't affect any developers working on the main app modules
- However, this project will be very lightweight, so the performance difference will be almost negligible
- If this ever becomes a problem, we can split up the build logic project to multiple sub-project
- Overall, this will a huge improvement for people working on build logic. Since they will be working with a much smaller project compared to the main app project

**Main app modules**

- Those modules would consume the build logic module as a binary dependency
- The consumption would be much faster than buildSrc
- The scripts of those project would be written in Kotlin but since those scripts would be very lightweight and simple it would be very performant. Since the huge chunks of complexity has been moved out of those scripts

## How?

In this section, I will try to provide a high level plan for how this can be executed; however, I won't be diving deep in implementation details unless it's needed.

### Phase 1: Setup build logic project

- Create module(s) for build logic project. This project can still live inside our Dmgz repo but will be a standalone project
- Publish this module to internal artifactory
- Consume this module as an included build. This would be consumed as artifact; however we can enable an option for it to be consumed directly from the project only to enable build logic maintainers to quickly test their work
- At this point, it might as well be empty, but the infra would be there

### Phase 2: Gathering requirements

- Investigate and list all of the Gradle functionalities we need. Those can include functionalities provided by our included Gradle scripts. This also includes things like Java lang config...etc
- This phase allows us to go in parallel mode
- First path is to start with migrating logic to an external module rather than buildSrc
- Second path is to start creating new setup with plugins and extensions to lay the foundation of Kotlin DSL usage in app modules

### Phase 2-A: Simple Gradle migration

- Just moving all of our common Gradle setup to the previously created external build module
- As little changes as possible, still in Groovy bs as convention plugins
- Heavily use this setup for testing performance impact of using included builds vs `buildSrc`
- Find gaps and problems with approach vs `buildSrc`

### Phase 2-B: Design new Gradle API

- Based on the input gathered in phase 2, we can design a high level API for our build logic
- Our API design needs to cover all the functionality we need as either a plugin or extension
- This design will be specific with guidelines for developers on how to configure their modules

### Phase 3: Removing `buildSrc`

- After phase 2-A is complete
- At this point we will be ready to remove `buildSrc` completely

### Phase 4: Implement the new Gradle API

- Here we implement a concrete API that was planned in phase 2-A
- This is when it's appropriate to implement this logic in Kotlin with proper testing
- This API becomes the main gate for developers to consume Gradle build logic
- This will be mainly a handful of Gradle convention plugins and custom extensions that allow developers to easily configure their modules

### Phase 5: Migrate app and feature modules to new Gradle API

- Migrate all app and feature modules to new Gradle API
- Migrate modules to use Kotlin DSL instead of Groovy

## Impact

The overall project is likely to touch every single module we have by the time it is completed.

- The incremental nature of the plan will allow us to evaluate and test our progress
- The nature of the plan allows us to continue to work and evolve our project naturally without the need for any freezes
- The nature of the plan leaves the project in a workable/better state at each phase which will allow us to spread the execution of the plan to different instants of time if needed. No need for this to happen immediately one after the other
