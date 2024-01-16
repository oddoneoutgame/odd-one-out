#!/bin/sh

# IP Address
alias iplocal="ipconfig getifaddr en0"
alias ipexternal="curl -s http://whatismyip.akamai.com/"

# gradle
alias gw="./gradlew"

# android
alias adbEnableDev="adb shell settings put global development_settings_enabled 1"
alias adbText='adb shell input text '
alias adbUrl='adb shell am start -W -a android.intent.action.VIEW -d '
alias adbEnableLayoutBounds='adb shell setprop debug.layout true'
alias adbDisableLayoutBounds='adb shell setprop debug.layout false'
alias adbEnableTalkback='adb shell settings put secure enabled_accessibility_services 
com.google.android.marvin.talkback/com.google.android.marvin.talkback.TalkBackService'
alias adbDisableTalkback='adb shell settings put secure enabled_accessibility_services 
com.android.talkback/com.google.android.marvin.talkback.TalkBackService'

# Opens the system language selector.
alias openLocale='adb shell am start -a android.settings.LOCALE_SETTINGS'

alias android-proxy-disable="adb shell settings put global http_proxy :0"
function android-proxy-enable() {
  adb shell settings put global http_proxy $1:8888
}

# Method that allows us to clear app data, start and restart jarvis or disney+
alias restartDisney="dmgz-app-data restart disney"
alias restartHulu="dmgz-app-data restart hulu"
alias restartJarvis="dmgz-app-data restart jarvis"
alias restartStar="dmgz-app-data restart star"
alias clearDisney="dmgz-app-data clear disney"
alias clearHulu="dmgz-app-data clear hulu"
alias clearJarvis="dmgz-app-data clear jarvis"
alias clearStar="dmgz-app-data clear star"
function dmgz-app-data() {
  if [[ "$1" == '' ]]
  then
    echo "Missing instruction. Enter 'clear', 'start', or 'restart'."
  elif [[ "$2" == '' ]]
  then
    echo "Missing application. Enter 'disney', 'hulu', 'star', or 'jarvis'."
  elif [[ "$1" == "clear" ]]
  then
    if [[ "$2" == "disney" ]]
    then
      adb shell pm clear com.disney.disneyplus
      adb shell am start com.disney.disneyplus/com.bamtechmedia.dominguez.main.MainActivity
    elif [[ "$2" == "hulu" ]]
    then
      adb shell pm clear com.disney.nulu
      adb shell am start com.disney.nulu/com.bamtechmedia.dominguez.main.MainActivity
    elif [[ "$2" == "jarvis" ]]
    then
      adb shell pm clear com.disney.disneyplus.jarvis
      adb shell am start com.disney.disneyplus.jarvis/com.disney.disneyplus.jarvis.common.ui.JarvisMainActivity
    elif [[ "$2" == "star" ]]
    then
      adb shell pm clear com.disney.starplus
      adb shell am start com.disney.starplus/com.bamtechmedia.dominguez.main.MainActivity
    fi
  elif [[ "$1" == "restart" ]]
  then
    if [[ "$2" == "disney" ]]
    then
      adb shell am force-stop com.disney.disneyplus
      adb shell am start com.disney.disneyplus/com.bamtechmedia.dominguez.main.MainActivity
    elif [[ "$2" == "hulu" ]]
    then
      adb shell am force-stop com.disney.nulu
      adb shell am start com.disney.nulu/com.bamtechmedia.dominguez.main.MainActivity
    elif [[ "$2" == "jarvis" ]]
    then
      adb shell am force-stop com.disney.disneyplus.jarvis
      adb shell am start com.disney.disneyplus.jarvis/com.disney.disneyplus.jarvis.common.ui.JarvisMainActivity
    elif [[ "$2" == "star" ]]
    then
      adb shell am force-stop com.disney.starplus
      adb shell am start com.disney.starplus/com.bamtechmedia.dominguez.main.MainActivity
    fi
  elif [[ "$1" == "start" ]]
  then
    if [[ "$2" == "disney" ]]
    then
      adb shell am start com.disney.disneyplus/com.bamtechmedia.dominguez.main.MainActivity
    elif [[ "$2" == "jarvis" ]]
    then
      adb shell am start com.disney.disneyplus.jarvis/com.disney.disneyplus.jarvis.common.ui.JarvisMainActivity
    elif [[ "$2" == "star" ]]
    then
      adb shell am start com.disney.starplus/com.bamtechmedia.dominguez.main.MainActivity
    fi
  fi
}

# Jarvis
alias installJarvis="gw :apps:jarvis:installDevDebug"
alias disneyQA="adb shell am broadcast -n com.disney.disneyplus.jarvis/.AdbInteractionBroadcastReceiver -a com.disney.disneyplus.jarvis.SET_ENVIRONMENT --es environment DISNEY_QA --es targetPackage com.disney.disneyplus --ez clearData false"
alias disneyProd="adb shell am broadcast -n com.disney.disneyplus.jarvis/.AdbInteractionBroadcastReceiver -a com.disney.disneyplus.jarvis.SET_ENVIRONMENT --es environment DISNEY_PROD --es targetPackage com.disney.disneyplus --ez clearData false"
alias starQA="adb shell am broadcast -n com.disney.disneyplus.jarvis/.AdbInteractionBroadcastReceiver -a com.disney.disneyplus.jarvis.SET_ENVIRONMENT --es environment STAR_QA --es targetPackage com.disney.starplus --ez clearData false"
alias starProd="adb shell am broadcast -n com.disney.disneyplus.jarvis/.AdbInteractionBroadcastReceiver -a com.disney.disneyplus.jarvis.SET_ENVIRONMENT --es environment STAR_PROD --es targetPackage com.disney.starplus --ez clearData false"

function adbinput() {
  adb shell input text $1
}