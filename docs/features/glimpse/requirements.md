# Requirements

As the requirements for various Glimpse events are spread out amongst various DGI tickets, this is an effort to consolidate them in one place.

## Impression

An event that tracks what the user sees. Tracked as `pageView` and `containerView` events.

### PageView

The schema for a pageView event can be found [here](https://github.bamtech.co/pages/schema-registry/schema-registry/#tag/urn:dss:event:edge:glimpse:impression:pageView).

  - A pageView event fires when a screen immediately starts loading.
  - A pageView event fires when changing the orientation results in updates to the layout. If the layout does not change, then a new pageView should not fire.
  - A pageView event fires when a user returns to a screen they were previously on (i.e. back nav or returning to 'Home').
  - A pageView event fires when the app is foreground (from the background). At this point, any visible containerViews should also re-impress with the new pageViewId.
  - A pageView event fires only for the currently visible and topmost screen. If a screen contains an overlay. The overlay pageView and subsequent events should fire first. Once the overlay is dismissed then the bottom screen should fire its events.
  - A pageView is the first event that should fire when a new screen loads. containerViews, interactions, and input events should always come after the pageView. A pageView will have a timestamp property appended to it, this timestamp should always be earlier than any of the pages other events (containerView, interaction, etc).
  - A pageView event fires each time a video player screen loads, regardless of how a user landed on the video (i.e. clicking play button, deeplink, autoplay, etc.)
  - A pageView event will always be followed by at least 1 containerView
  - A pageView's pageViewId is randomly generated and must be unique forever.
  - A pageView's pageViewId needs to be reused in subsequent events (containerView, interaction, etc) within the same page instance
  - A pageView's pageViewId must be regenerated whenever a new pageView event occurs

### ContainerView

The schema for a containerView event can be found [here](https://github.bamtech.co/pages/schema-registry/schema-registry/#tag/urn:dss:event:edge:glimpse:impression:containerView).

  - A containerView event should fire when any part of an element (>= 1 pixel up to 100% present) is on the page (even if it's not clickable).
  - A containerView event should fire again when a user returns to a screen they were previously on (i.e. back nav or returning to 'Home').
  - A containerView should include an array `elements` which gives details on the current Elements being shown. This should include both Elements that are only peeking (1 pixel) as well as Elements that are 100% in view
  - A containerView event will only fire the first time the element comes into view on a page (peeking or fully visible).
  - A containerView event should fire for each containerView that is scrolled by even if the user scrolls very fast in a short amount of time (i.e. user swipes to bottom of page quickly, containerViews should fire for each item scrolled by, regardless of speed).
  - A containerView event should fire if the contents/elements of a container change. For example, on search as the user types into the search bar if the elements in the search results are changing, then a new containerView should fire each time it updates/changes.
  - A containerView event should fire when additional elements are loaded into a container. For example, if a user scrolls horizontally on a container and additional elements are loaded in async, a containerView should fire with the new array of elements.
  - A containerView should only fire once on a page, if the user scrolls up and down on a page, only track the first impression.
  - A containerView event should always fire after the initial pageView event for a given page. The containerView timestamp should come after the timestamp of the pageView event.
  - A containerView for a carousel item should only fire when that hero element is in the user's viewport and is considered a "new" element (the user has not previously seen it). If the user has already seen the same hero tile during a specific pageView instance, a new containerView should not fire (i.e. there should be no re-impressions, so each tile in the hero will only fire once for that pageView instance).
  - A containerView's containerViewId is randomly generated and must be unique forever.
  - A containerView's containerViewId needs to be reused in subsequent events (interaction, input, etc) within the same page instance.
  - A containerView's containerViewId must be regenerated if a page reloads or the user comes back to a page they were previously on.

## Engagement

An event that tracks an action implicitly taken by a user (ie a button click). Tracked as an `interaction` or `input` event

### Interaction

The schema for interaction events can be found [here](https://github.bamtech.co/pages/schema-registry/schema-registry/#tag/urn:dss:event:edge:glimpse:engagement:interaction).

  - An interaction event should fire whenever the user interacts with an `Element`, not Containers or Pages. For example, clicking, focusing, deeplinking or even hitting the back button.
  - An interaction event should always contain the containerViewId that corresponds to the containerView instance of the element that was interacted with.

### Input

The schema for input events can be found [here](https://github.bamtech.co/pages/schema-registry/schema-registry/#tag/urn:dss:event:edge:glimpse:engagement:input).

  - An input event should fire whenever the user types into the app (search, profile edits) or changes the state of a checkbox or toggle.
  - An input event should only be fired once the user stops typing for a certain amount of time (200ms).
  - An input event should always contain the containerViewId that corresponds to the containerView instance of the element that was interacted with.
