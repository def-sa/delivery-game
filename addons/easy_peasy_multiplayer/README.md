# Easy Peasy Multiplayer
### Multiplayer in Godot has never been easier
This plugin provides all of the backend tools you need to quickly start making a networked game in Godot! This plugin handles setting up MultiplayerPeers, lobby creation, network switching, and of course, connecting to servers. You will only need to: 
- Create a way to interface with the plugin (Or you can use a prebuilt UI that I have already created as a starting point [Here](https://github.com/Skeats/easy-peasy-multiplayer/tree/main/prefabs/ui/network_ui))
- Add Godot's [MultiplayerSpawners](https://docs.godotengine.org/en/stable/classes/class_multiplayerspawner.html) and [MultiplayerSynchronizers](https://docs.godotengine.org/en/stable/classes/class_multiplayersynchronizer.html#class-multiplayersynchronizer) (I will not cover that as it is a default Godot feature, however I have linked the documentation to each node.)

This plugin also allows you to switch easily between Enet/traditional IP networking, as well as Steam networking powered by GodotSteam and SteamMultiplayerPeer (both are required dependencies).

## Required Dependencies
These are all required for this plugin to work.
- [GodotSteam](https://godotengine.org/asset-library/asset/2445)
- [SteamMultiplayerPeer](https://godotengine.org/asset-library/asset/2258)

## Planned Features
- Dedicated servers
- Host Migration
- More GodotSteam stuff (There is SO much to that plugin)
- Steam User Authorization
- Allowing the game to be run without steam in the case of cross-platform/non Steam builds

## Installation
### Option 1 (easiest):
- Download the plugin through the Godot Asset Library [Here]().
- Go to `Project > Project Settings > Plugins` and enable `Easy Peasy Multiplayer`
### Option 2:
- Go to the [releases page](https://github.com/Skeats/easy-peasy-multiplayer/releases) and download the latest release.
- Extract the zip file.
- Take the `addons` folder and move it into your Godot project directory
  - Alternatively, if you already have addons installed, you can just move the folder named `easy_peasy_multiplayer` into your addons folder.
- Go to `Project > Project Settings > Plugins` and enable `Easy Peasy Multiplayer`

## Getting Started
For help getting started with this plugin, go to the wiki page [Here](https://github.com/Skeats/easy-peasy-multiplayer/wiki/Getting-Started).

## Additional Resources
- [High Level Multiplayer | Godot](https://docs.godotengine.org/en/stable/tutorials/networking/high_level_multiplayer.html)
- [Getting Started | GodotSteam](https://godotsteam.com/getting_started/introduction/)
- [Remote Procedure Calls/RPCs | Godot](https://docs.godotengine.org/en/stable/tutorials/networking/high_level_multiplayer.html#remote-procedure-calls)
