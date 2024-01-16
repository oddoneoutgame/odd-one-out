# Run Build Benchmarks on CI

## Why?

- Build benchmarks are an important tool to keep build times as low as possible. When doing a change that could impact build times, we want to know what the impact is.
- Benchmarks are problematic to run locally. They take up your local machine's resources for several hours, making it impossible to do other development work while the benchmark is running. By moving the benchmarks to CI, developers are free to continue with other work.
- We hope this will lower the barrier to run build benchmarks. This should improve the rate at which we're able to upgrade libraries/dependencies.

## What?

Add a [GitHub action](https://docs.github.com/en/actions/using-workflows/about-workflows) workflow for that runs the [existing build benchmark](../../tools/benchmark/build_performance_benchmark.md) scenarios When adding the `benchmark` label on a PR.

## How?

- Request GH actions runners for the Android repository.
- Add a workflow that runs the benchmark on labeling.
- Output the result of the benchmark as a PR comment.
- Add documentation on how to run the benchmarks on CI.

## Impact

This change should not impact the app or any existing proces. The option of running local benchmarks will still exist.
