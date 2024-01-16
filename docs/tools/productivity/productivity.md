# Productivity Tools

## CLI commands

Contained in this document are some useful aliases that can make various tasks, such working with [Charles Proxy](../../charles_proxy/charles_proxy) or Android Emulators/Devices, using commandline.

A lot of these commands were written with ZSH in mind (the default shell for macOS as of Catalina), but they should mostly work for shell alternatives such as BASH, Fish, SH, etc.

We encourage you to review the commands contained in this document as they can help improve your workflow. For example, building the app from the CLI is faster due to not having to switch between build variants that forces AS to index/build everything.

### Installing Aliases

For your convenience, the following aliases, function, and commands have been added (and version controlled) in the [zsh-alias-disney.sh](./files/zsh-alias-disney.sh) file.

To install `zsh-alias-disney.sh` in Zsh, download the file to the same location as your `.zshrc` file (usually in your home or `~` directory) and edit your `.zshrc` to include the following:

```zsh
source ~/zsh-alias-disney.sh 
```

(Alternatively, feel free to download the file to the directory of your choosing and then just reference the path directly in the source command)

Once added, either restart your terminal or utilize the following command:

```zsh
source ~/.zshrc
```

### Aliases/Functions (zsh-alias-disney.sh)

| Alias/Function                                         | Description                                                                         |
| ------------------------------------------------------ | ----------------------------------------------------------------------------------- |
| gw                                                     | shortcut for `./gradlew`                                                            |
| adbText `example@sample.com`                           | Adds text to adb connected device                                                   |
| adbUrl                                                 | Launch URL via intent                                                               |
| adbEnableLayoutBounds/adbDisableLayoutBounds           | Enable/Disable Layout Bounds                                                        |
| adbEnableTalkback/adbDisableTalkback                   | Enable/Disable Talkback                                                             |
| openLocale                                             | opens language selector screen                                                      |
| **App Commands**                                       |                                                                                     |
| restartDisney, restartHulu, restartJarvis, restartStar | Restarts app(s)                                                                     |
| clearDisney, clearHulu, clearJarvis, clearStar         | Clears local data for specified app(s)                                              |
| **Jarvis Commands**                                    |                                                                                     |
| installJarvis                                          | Installs Jarvis onto device                                                         |
| disneyQA/starQA                                        | Set app environment to QA through CLI instead of Jarvis                             |
| disneyProd/starProd                                    | Set app environment to Prod through CLI instead of Jarvis                           |
| **Charles/Network Commands**                           |                                                                                     |
| android-proxy-enable/android-proxy-disable             | Enable or disable proxy settings on a device through ADB                            |
| iplocal                                                | obtain your computer's local IP address                                             |
| ipexternal                                             | obtain your external IP address (via [What's my IP](http://whatismyip.akamai.com/)) |
