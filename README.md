![Axes, Armour & Ale - logo](GITscreenshots/Logo.png)

![build-test](https://github.com/cyberfilth/Axes-Armour-Ale/workflows/build-test/badge.svg)     ![Free Pascal](GITscreenshots/fpc.svg)      ![Lazarus](GITscreenshots/lazarus.svg)

### A low-fantasy, roguelike game

Alpha version, most features aren't implemented yet. This game builds on the terminal version at https://github.com/cyberfilth/FLUX/ and includes the following basic features;

 - A randomly generated dungeon
 - Save / Load last game
 - Should run on GNU/Linux and Windows
 - Small, native binary with no external dependencies

![Dungeon screenshot](GITscreenshots/linux_screenshot1.png)


![Cave screenshot](GITscreenshots/windows_screenshot1.png)


### Controls
Your character is controlled using either the numberpad or Vi keys.
<pre>
  y  k  u      7  8  9
   \ | /        \ | /
  h-   -l      4- 5 -6
   / | \        / | \
  b  j  n      1  2  3
  vi-keys      numpad
</pre>
You can also move in cardinal directions using the arrow keys.
Pick up an item from the ground with either 'g' or ','
View inventory with 'i'
Drop an item with 'd'
Quaff / drink with 'q'
To exit a menu / quit the game press ESCAPE


### documentation
All code has been heavily commented so that you can generate documentation using PasDoc.

Online documentation can be found at https://cyberfilth.github.io/Axes-Armour-Ale/
