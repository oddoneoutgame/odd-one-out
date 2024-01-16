# Macro Benchmarks and Baseline Profiles

## Why?

- Amazon reported significant app startup regression on our 2.7.2 builds. [ANDROID-3699](https://jira.disneystreaming.com/browse/ANDROID-3699)
- As long as we don't monitor startup time it is hard to say if we improve, regress or stay stable
- Google strongly recommends using baseline profiles for [Jetpack Compose](https://developer.android.com/jetpack/compose/performance#use-baseline)

## What?

### Macro Benchmark Projects

The [macro benchmark](https://developer.android.com/topic/performance/benchmarking/macrobenchmark-overview) setup that Google provides these days is pretty straightforward and easy to implement these days. We could use the suggested Github Actions and GCloud Monitoring to, for example, trigger these builds every time that a release tag is created.

Here is an example of the JSON output when you run the benchmark tests on Firebase Test Lab

```json
{
    "context": {
        "build": {
            "brand": "google",
            "device": "redfin",
            "fingerprint": "google/redfin/redfin:11/RQ3A.211001.001/7641976:user/release-keys",
            "model": "Pixel 5",
            "version": {
                "sdk": 30
            }
        },
        "cpuCoreCount": 8,
        "cpuLocked": false,
        "cpuMaxFreqHz": 2400000000,
        "memTotalBytes": 7819993088,
        "sustainedPerformanceModeEnabled": false
    },
    "benchmarks": [
        {
            "name": "startupNoCompilation",
            "params": {},
            "className": "com.bamtechmedia.dominguez.mobile.benchmark.MobileAppStartBenchmark",
            "totalRunTimeNs": 113970060937,
            "metrics": {
                "timeToInitialDisplayMs": {
                    "minimum": 411.319208,
                    "maximum": 611.881572,
                    "median": 445.6793675,
                    "runs": [
                        611.881572,
                        492.550674,
                        439.021138,
                        508.526561,
                        445.599055,
                        411.319208,
                        422.144782,
                        445.75968,
                        418.313948,
                        446.550201
                    ]
                }
            },
            "sampledMetrics": {},
            "warmupIterations": 0,
            "repeatIterations": 10,
            "thermalThrottleSleepSeconds": 0
        },
        {
            "name": "startupBaselineProfile",
            "params": {},
            "className": "com.bamtechmedia.dominguez.mobile.benchmark.MobileAppStartBenchmark",
            "totalRunTimeNs": 57526465731,
            "metrics": {
                "timeToInitialDisplayMs": {
                    "minimum": 385.875976,
                    "maximum": 451.5239,
                    "median": 410.36412900000005,
                    "runs": [
                        394.670716,
                        385.875976,
                        400.374727,
                        411.319155,
                        409.409103,
                        415.556708,
                        403.907905,
                        416.397333,
                        451.5239,
                        431.918845
                    ]
                }
            },
            "sampledMetrics": {},
            "warmupIterations": 0,
            "repeatIterations": 10,
            "thermalThrottleSleepSeconds": 0
        }
    ]
}
```

### Baseline profiles

A [Baseline Profile](https://developer.android.com/topic/performance/baselineprofiles) is a file that we would bundle in the application which Google Play can use to determine which classes should be pre-compiled on the device before the first application install. This could have a big impact in startup performance. With the setup of the macro benchmark projects it also because fairly straightforward to include these at least for mobileGoogle variants. TV and Amazon devices are a bit more tricky since you need a rooted device to be able to capture baseline profiles.

### Monitoring

According [to the docs](https://github.com/android/performance-samples/tree/main/MacrobenchmarkSample/ftl#google-cloud-monitoring) we can set up a monitoring to check the benchmarks over time. If we do kick these builds in the nightly and on kicking a release build that gives us a very basic monitoring option for application startup time.

## How?

There's still a few things that need to be flushed out but the branch [here](https://github.bamtech.co/Android/Dmgz/compare/rm/ANDROID-3632-baselines?expand=1) sets up the benchmark modules and GH Actions

If you have gcloud setup locally you can run the benchmarks using this command after running `./gradlew assembleMobileDisneyGoogleBenchmark` on that branch.

```shell
gcloud firebase test android run \
  --type instrumentation \
  --app /Users/rmokveld/Workspace/Dmgz/mobile/build/outputs/apk/mobileDisneyGoogle/benchmark/mobile-mobile-disney-google-benchmark.apk \
  --test /Users/rmokveld/Workspace/Dmgz/benchmarkMobile/build/outputs/apk/mobileDisneyGoogle/benchmark/benchmarkMobile-mobile-disney-google-benchmark.apk \
  --device model=redfin,version=30,locale=en,orientation=portrait \
  --directories-to-pull /sdcard/Download \
  --results-bucket gs://macro-benchmark-results \
  --environment-variables additionalTestOutputDir=/sdcard/Download,no-isolated-storage=true \
  --timeout 20m \
  --test-targets "class com.bamtechmedia.dominguez.mobile.benchmark.MobileAppStartBenchmark"
```

An example run can be found [here](https://console.firebase.google.com/u/0/project/disney-plus-internal/testlab/histories/bh.1201ed5334945a0f/matrices/7586573359938013809)

## Impact

Ideally this would become a fixed part of our release process so then it would become one of the signoff steps in the release posts that TPM share in the project.

Since this is a new concept in the build system build performance should also be measured.
