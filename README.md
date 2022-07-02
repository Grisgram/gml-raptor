<p align="center"><img src="https://user-images.githubusercontent.com/19487451/174816442-47348841-a956-4f23-970b-38fc7ad73864.png" style="display:block; margin:auto; width:438px"></p>

`raptor` is kind of a platform, a layer I put on top of the GameMaker Studio environment, a collection of objects, (struct)classes and utility functions that I use to write games.<br/>
This repository contains a ready-to-use project template in `.yyz` format ready to be downloaded as release from (todo:create link)here.

## Version list
You need [![gmlogo](https://user-images.githubusercontent.com/19487451/177008359-37a3cdb7-2068-4ac8-84ef-4c455c2194de.png)](https://gamemaker.io)&nbsp;&nbsp;Studio 2.3+ to use `raptor`.<br/>
These version of external links are packaged in the current `raptor` release:
| raptor Version | Scribble | SNAP | OutlineShader | AnimatedFlag |
|:-:|:-:|:-:|:-:|:-:|
|1.0|8.0.4|4.0.2|1.3|1.1|

## Main Features

|![gms](https://user-images.githubusercontent.com/19487451/174742864-ca80b221-8799-42f0-851d-474ebbbf06be.png) Coding & Data|![gms](https://user-images.githubusercontent.com/19487451/174742864-ca80b221-8799-42f0-851d-474ebbbf06be.png) Visuals & Objects|
|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------|
|![savegame](https://user-images.githubusercontent.com/19487451/174751651-b5630b17-0b12-40ab-be1c-d20c4e012779.png) **Savegames**<br/>Have your data saved and restored with optional encryption|![state](https://user-images.githubusercontent.com/19487451/174751048-0d3e2c9c-0974-437b-b5de-9a9d1ee068a2.png) **State Machines**<br/>Easy to use but powerful game object control|
|![race](https://user-images.githubusercontent.com/19487451/174751649-ee0bc6a8-a274-4f1e-872c-851b95861184.png) **RACE** (**RA**ndom **C**ontent **E**ngine)<br/>Loot, Random maps, Dice, all that can be random with json-based config|![animation](https://user-images.githubusercontent.com/19487451/174751647-d88c71c7-edea-4883-a180-e7edbdf1455d.png) **Animations**<br/>Runtime sprite animations with triggers and runtime tweaks|
|![tools](https://user-images.githubusercontent.com/19487451/174751654-34b7e843-9fba-4c3e-a5b4-21c7134a9666.png) **Tools**<br/>Utils and Helpers, like Object Pools,<br/> Effects, Struct & Array enhancements, Message Broadcasting|![ui](https://user-images.githubusercontent.com/19487451/174751656-75fddb70-8f39-4b55-a1f1-f4dfd042974f.png) **UI and Localization**<br/>Basic UI Controls objects incl. Text Input, json-localization, 100% [Scribble](https://github.com/JujuAdams/scribble)-based|

## How Releases are organized
When working with an entire platform like this one, there is more to do for the author (me), than simply publishing a .zip file and call it a release.<br/>
While the project template itself is useful and must be up-to-date when you start a *new Project*, the normal case is, that you are in the middle of development, when a new release is done here. But in this second case you have very likely adapted configuration scripts (in the _GAME_SETUP_ section of the project) and you do not want to have them overwritten when updating to the latest version.

To cover both of these scenarios, you will find several files and downloads for each release here:
* A `.zip` file, containing the project template (you should *always* update this locally in your templates folder to be ready for the next project!)
* A `*-full.yymps` local package file that contains *all files of the platform* in a single package. This includes the config files, so take care, when importing!
* A `*-update.yymps` local package file that contains all files of the platform *except the configuration files*. It should be safe to import this, as long as you didn't modify any of the platform source code itself.

**Please Note:** In rare cases it might be possible, that there is no `*-update.yymps` available for a release. This happens, when I (for whatever reason) had to update/change the basic configuration files also. I will leave a dedicated note in the Release Notes, if this is the case. You should copy the sources of your GameConfiguration out of the way before updating and have to merge manually then. But mostly such a case will only contain a new config switch or two. Nothing to worry about.

---

**Important! Please read**

There are many objects and scripts in this library and to get going with this platform, you should take the time to read the basic concepts that this platform follows in the [Wiki](https://github.com/Grisgram/gml-raptor/wiki).

---

I tried to isolate some of the classes and make smaller repositories of it, but I failed. They work too good together and, as an example, to isolate my savegame-system out into its own repository and removing all the dependencies would've required to sacrifice lots of its functionality. Same is true for the StateMachine or the Animation system. So, after thinking about it for some time, I decided to make it public "as-it-is". It's a set of working-together parts, that allows you to speed up your game development process.

If you have questions, feedback or just want to discuss specific parts of this platform, just open a new thread in the [discussions](https://github.com/Grisgram/gml-raptor/discussions) for this repository. I'll do my best to answer any questions as quick as possible!
Feel free to fork, advance, fix and do what you want with the code in this repository, but please respect the MIT License and credit.<br/>


### CONTRIBUTING
I am happy, if you want to support `raptor` to become even better, just launch a pull request, explain me your changes, and I make sure, you get credited as contributor.


## Other libraries
My main goal is to provide a ready-to-use project template. I am not a big friend of "oh, yes, this is the classes, but you need to download this from here and that other thing from there and make sure, you apply this and this and this setting and best do a npm xy to have this running..." what a mess!
I do not like that. You will always find a single-download-and-run release in the template.

That being said, it leads to this requirement/fact:<br/>
`raptor` contains some other libraries that are referenced from my classes, so they are packaged together with this project template.

Some of these 'other libraries' are my own and are by default also included in the package, because I find it more easy to remove one not required folder by a simple hit of the 'Delete' key instead of browsing the file system for all bread crumbs that need to be added. It just saves time.

By default, these libraries of mine are included:

* [Outline Shader Drawer](https://github.com/Grisgram/gml-outline-shader-drawer)
* [Animated Flag](https://github.com/Grisgram/gml-animated-flag)

## Credits
### Translation help and proof reading

Very special thanks to `Alex` [@pamims](https://github.com/pamims) for proof reading my version of the english language and correcting it to the _real_ version of the english language! Thank you very much for volunteering here!


### Credits for external libraries go to 

* [@JujuAdams](https://github.com/JujuAdams) and the great community at [GameMakerKitchen Discord](https://discord.gg/8krYCqr) for the [SNAP](https://github.com/JujuAdams/SNAP) Library and [Scribble](https://github.com/JujuAdams/scribble), which I packaged into this repository and the project template.
I do my best to keep the re-packaged libraries here always at the latest version of Juju's repo.
If you prefer to look up the most recent version (or any specific version) for yourself, you find SNAP and Scribble at the links a few lines above this one.


* [@YellowAfterLife](https://github.com/YellowAfterlife) for the [Open Link in new Tab](https://yal.cc/gamemaker-opening-links-in-new-tab-on-html5/) Browser Game extension for GameMaker, which I modified a bit to fit into the platform. This extension is also packaged into the platform and ready-to-use.

### Contact me
Beside the communication channel here, you can reach me as @Haerion on the [GameMakerKitchen Discord](https://discord.gg/8krYCqr).


