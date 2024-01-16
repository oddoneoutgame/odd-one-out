# Jarvis Transforms Management

## Why?

### Today's situation

In the current situation there are two different flavors for Jarvis.

- `dev` flavor
    - Used internally by developers on QA team
    - does not require a passcode
    - loads the config from [https://appconfigs.disney-plus.net/dmgz/qa/transformations/all.json](https://appconfigs.disney-plus.net/dmgz/qa/transformations/all.json)
- `partner` flavor
    - fetches [https://appconfigs.disney-plus.net/dmgz/qa/jarvis/PasscodeMap.json](https://appconfigs.disney-plus.net/dmgz/qa/jarvis/PasscodeMap.json) on first start
    - requests the user to input a passcode
    - then fetches the transforms from the filename that matches that passcode

## Why does this need to change?

On the one hand we want it to be easy to add jarvis toggles for development purposes, on the other hand we may sometimes be working on new features which are partners are legally not allowed to know about, or maybe in some cases some partners are allowed to know about it but not all.

The current approach isn't very secure since all passcodes are exposed in the plaintext endpoint that's accessible without authentication. When someone from Amazon sees that the Jarvis app loads [https://appconfigs.disney-plus.net/dmgz/qa/jarvis/PasscodeMap.json](https://appconfigs.disney-plus.net/dmgz/qa/jarvis/PasscodeMap.json) which contains the JSON below, and when they enter the password `DS+AZ*partner` that we provided to them which then loads [https://appconfigs.disney-plus.net/dmgz/qa/transformations/amazon.json](https://appconfigs.disney-plus.net/dmgz/qa/transformations/amazon.json), you don't need to be a genius to try and load [https://appconfigs.disney-plus.net/dmgz/qa/transformations/all.json](https://appconfigs.disney-plus.net/dmgz/qa/transformations/all.json).

```json
{
  "dssDEVpass*" : "all",
  "DisneyPartner!" : "partner",
  "qe,Access" : "qe",
  "D+G*partner" : "google",
  "DS+S*partner" : "sony",
  "DS+AZ*partner" : "amazon",
  "DS+SHCAY*partner" : "sharp",
  "DS+T*partner" : "hisense",
  "DS+MT*partner" : "mediatek"
}
```

Additionally it is quite cumbersome to manage partner configs at this point since we copy-paste transforms over from one partner to the other when needed.

## What?

This RFC proposes to introduce a script that helps with the management and security of Jarvis transforms.

## How?

Similar to the changes that were recently done to the prod configs to prevent us to have to edit many files for dictionary pins, we can apply the same for Jarvis transforms. See the original PR [here](https://github.bamtech.co/Mobile/dmgz-android-appconfig/pull/1171) for more detail on that.

That way, instead of managing many partner files we could have a central list of transforms and for each transform make it possible to define what partners it should be available for.

We can increase the security by, instead of writing the output to a file that has a plain name (like `amazon.json`) the file name could be something like a `sha256` hash of the passcode. In the "partner source config" we'd define partner names and their matching passcodes and the script that generates outputs writes the output for each partner.

The Jarvis app can also apply the same hash function to the passcode that the partner entered when constructing the url to load. If the passcode is wrong the file will not exist and the CDN will respond with a 403 response.

An example of the source file could be as follows. Note that we could also decide to create multiple source files and group transforms per feature/workstream but we can start with a single one.

```json
{
  "variants": [
    {"name": "internal", "passcode": "t34gbf%"},
    {"name": "amazon", "passcode": "dab35"}
  ],
  "transformGroups":[
    {
      "name": "Playback",
      "transforms": [
        {
          "name": "Enable Atmos",
          "variants": ["all"],
          "path": "playbackCapabilities.atmos",
          "value": "true"
        },
        {
          "name": "Enable Dolby Vision",
          "variants": ["internal"],
          "path": "playbackCapabilities.hdrTypes",
          "value": ["dolbyVision"]
        },
        {
          "name": "Enable HDR10",
          "variants": ["amazon"],
          "path": "playbackCapabilities.hdrTypes",
          "value": ["HDR10"]
        }
      ]
    }
  ] 
}
```

The script would produce two different files in `outputs/transformations`. One for dev builds (we'd hardcode the password in those builds) and one for Amazon. The dev variant would have the Dolby Vision and the Dolby Atmos toggle, while the one for Amazon would have the Atmos and HDR10 toggle.

## Impact

- This would impact all engineers on the team since everyone adds jarvis transforms. With likely a bit of extra impact on Team Bender for the partner stuff.

## Additional notes

- To avoid bloating the UI we could also include a the application packageName in the hash. That way we could specify that a transform is only relevant for D+, S+ and/or Hulu.
- Since the urls of transforms now become hash values it would be nice to have a bookmarkable "index" page which links to all the generated files, including the name of the variant to make it easy to find, for example, the transform file that is served for Amazon.
- Maybe it would be nice to not have to specify `"variants": ["internal"]` if a transform is only intended for internal use and make that the default if no variants array is specified.
- Considering that this is a breaking change we should try to start off in a backward compatible manner and ensure that partners are notified of the upcoming change before we make it breaking.
- We could likely use the [deep link functionality of transforms](https://github.bamtech.co/Mobile/dmgz-android-appconfig/blob/5eeae90f2ff188f9478f990c5743cd3a47d95a4c/outputs/transformations/all.json#L670-L677) to direct the user to a new place to download the updated Jarvis app
