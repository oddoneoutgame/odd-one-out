# TV Channels

**TV Channels** are each row displayed on the home screen of the TV. Each row contains the channel's programs shown in cards, and when clicked, it deep-links to the app to view the program. Disney+ and Star+ provide content to be displayed on TV Channels from the Android TV. It can help users discover the content through recommendations on the home screen and quickly access or continue watching programs.

<figure markdown>
![](gifs/tv_channels_disney.gif){ width="700" }
<figcaption>Disney+ Channels</figcaption>
</figure>

<figure markdown>
![](gifs/tv_channels_star.gif){ width="700" }
<figcaption>Star+ Channels</figcaption>
</figure>

## The Default channel

Apps can offer any number of channels for the user to add to the TV home screen. The user usually has to select and approve each channel before it appears on the home screen. Every app has the option of creating one  _default_  channel. The _default channel_ is special because it automatically appears on the home screen; the user does not have to enable it explicitly.

## The Watch Next channel

The _Watch Next_ channel is the second row that appears in the home screen, after the apps row. It has the label **Play Next**. The system creates and maintains this channel. Apps can add programs to the _Watch Next_ channel if it is programs that: the user marked as interesting, stopped watching in the middle, or that are related to the content the user is watching (like the next episode in a series or next season of a show).

When inserting content into the _Watch Next_ channel, we need to follow the [Google guidelines](https://developer.android.com/training/tv/discovery/guidelines-app-developers) to make sure it is eligible to be published. Some of the guidelines are:

- The user should have interacted with the content within your app.
- The user has "started" the program if they've watched more than 3% or 2 minutes, whichever timestamp is earlier.
- Do not add more than one episode for the same TV series. For example, do not add an unfinished episode and a new episode for the same TV show.
- Do not update all items in the **Play Next** row when any one item changes. _Only_ update the item which the user has interacted with since the last update.

## Manually add or remove programs

To manually add a program to the _Play Next_ row, or remove a program from any tv channel, select the desired program, click and hold it with your remote control. A pop-up will ask you if you'd like to add it to _Play Next_ or remove it.

Deleted programs from Watch Next are saved in the app (shared preference), so they are not displayed again.

## Disney+ and Star+ Channels

### Available Channels

Currently, the apps support three channels: `Recommended For You`, `Watchlist` (only Disney+ has it enabled), and `Watch Next`.
The _default channel_ is `Recommended For You` for both apps.

The channels and programs are deleted if the Kids mode is enabled or if the user logout.

### Programs Synchronisation

When a `WatchlistSet` or a `ContinueWatchingSet` is invalidated, synchronisation will happen to ensure the content on the tv channels is updated.
The _Watchlist_ channel gets its programs updated every time the user adds or removes content from the watchlist in the app.
The _Watch Next_ channel gets a program updated every time the user stops the playback at a certain point and leaves the content/app. This way, the latest progress for the program is displayed on the channel.
When the user switches between profiles, all channels get updated programs with relevant content for the active profile.

## Feature Info

### Availability

|       | Availability |
| ----------- | :-----------: |
| :icons-disney-logo: Disney+ | :white_check_mark: |
| :icons-star-logo: Star+ | :white_check_mark: |
| :fontawesome-solid-mobile: Mobile | :x: |
| :fontawesome-solid-tv: TV | :white_check_mark:  |
| :material-earth: Regions | :white_check_mark: All regions |

### How to test

A few toggles are available in Jarvis to help to test the App TV Channels. Under the category App Channels (TV), you can:

- Disable all App Channels
- Enable/Disable Recommendations Channel
- Enable/Disable Watchlist Channel
- Disable Play Next Channel

**Testing steps**

- Open D+/S+ Tv app
- Log in
- Choose profile
- Go to home screen of the TV; Tv Channels are each row displayed on the screen

### Relevant classes

- `DefaultChannelProvider.kt` - Responsible for creating the default channel.

- `WatchlistChannelProvider.kt` - Responsible for creating the watchlist channel.

- `BaseProgramCandidateProvider.kt` - Provides a list of `ProgramCandidate` after fetching the collections by `CollectionIdentifier`

- `ChannelWorkerManager.kt` - Responsible for scheduling proper workers to populate or remove items from app channels.

- `AppChannelsConfig.kt` - Remote config for the app channels feature.

- `ChannelsLog.kt` - Loggings regarding the channels feature.

## Official Documentation

- [Recommend content on the home screen](https://developer.android.com/training/tv/discovery/recommendations)
