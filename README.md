# gml-raptor - WORK IN PROGRESS - BUILDING UP THE REPO CURRENTLY!

![image](https://user-images.githubusercontent.com/19487451/167885369-a5ae0b14-9176-4429-babd-2a140ab5880a.png) <br>&nbsp;&nbsp;Studio 2.3+

`raptor` is a collection of objects, (struct)classes and utility functions that I use to write games.
This repository contains a ready-to-use project template in yyz format ready to be downloaded as release from (todo:create link)here.

---

**Please note**

There are many objects and scripts in this library and to get going with this platform, you should take the time to read the basic concepts that this platform follows in the (todo:create link)wiki.

---

I tried to isolate some of the classes and make smaller repositories of it, but I failed. They work too good together and, as an example, to isolate my savegame-system out into its own repository and removing all the dependencies would've required to sacrifice lots of its functionality. Same is true for the StateMachine or the Animation system. So, after thinking about it for some time, I decided to make it public "as-it-is". It's a set of working-together parts, that allows you to speed up your game development process.

If you have questions, feedback or just want to discuss specific parts of this platform, just open a new thread in the (todo:create link)discussions for this repository. I'll do my best to answer any questions as quick as possible!
Feel free to fork, advance, fix and do what you want with the code in this repository, but please respect the MIT License and credit.<br/>


## CONTRIBUTING
I am happy, if you want to support raptor to become even better, just launch a pull request, explain me your changes, and I make sure, you get credited as contributor.


## Other libraries
My main goal is to provide a ready-to-use project template. I am not a big friend of "oh, yes, this is the classes, but you need to download this from here and that other thing from there and make sure, you apply this and this and this setting and best do a npm xy to have this running..." what a mess!
I do not like that. You will always find a single-download-and-run release in the template.

That being said, it leads to this requirement/fact:<br/>
`raptor` contains some other libraries that are referenced from my classes, so they are packaged together with this project template.


### Credits
Credits for external libraries go to 

[@JujuAdams](https://github.com/JujuAdams) and the great community at [GameMakerKitchen Discord](https://discord.gg/8krYCqr) for the [SNAP]() Library and [Scribble](), which i packaged into this repository and the project template.
I do my best to keep the re-packaged libraries here always at the latest version of Juju's repo.

[@YellowAfterLife](https://github.com/YellowAfterlife) for the [Open Link in new Tab](https://yal.cc/gamemaker-opening-links-in-new-tab-on-html5/) Browser Game extension for GameMaker, which I modified a bit to fit into the platform. This extension is also packaged into the platform and ready-to-use.

### Contact me
Beside the communication channel here, you can reach me as @Haerion on the GameMakerKitchen discord mentioned above.


