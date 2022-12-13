#!/bin/sh
echo "Compiling Axes, Armour & Ale..."
mkdir -p ../source/lib/x86_64-linux
cd ../source
fpc Axes.pas -MObjFPC -Scghi -CX -Cg -Os3 -Xs -XX -l -vewnhibq -Filib/x86_64-linux -Fientities -Fidungeons -Fudungeons -Fuentities -Fuitems -Fuplayer -Fuscreens -Fuvision -Fuentities/animals -Fuentities/bugs -Fuentities/fungus -Fuentities/gnomes -Fuentities/hobs -Fuitems/armour -Fuitems/macguffins -Fuitems/weapons -Fuentities/bogles -Fuentities/undead -Fuentities/goblinkin -Fuentities/troglodytes -Fuitems/traps -Fu. -FUlib/x86_64-linux -FE. -oAxes
echo "Complete."