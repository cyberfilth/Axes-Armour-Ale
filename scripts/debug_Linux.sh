#!/bin/sh
echo "Compiling Axes, Armour & Ale - DEBUG VERSION"
mkdir -p ../source/lib/x86_64-linux
cd ../source
fpc Axes.pas -Mfpc -Scaghi -Cg -CirotR -O1 -gw2 -godwarfsets -gl -gh -Xg -gt -l -vewnhibq -Filib/x86_64-linux -Fientities -Fudungeons -Fuentities -Fuitems -Fuplayer -Fuscreens -Fuvision -Fuentities/animals -Fuentities/fungus -Fuentities/gnomes -Fuentities/hobs -Fuitems/armour -Fuitems/macguffins -Fuitems/weapons -Fuitems/traps -Fuentities/bugs -Fuentities/bogles -Fuentities/undead -Fuentities/goblinkin -Fuentities/troglodytes -Fu. -FUlib/x86_64-linux -FE. -oAxes
echo "cleaning up files...."
delp -r ./
echo "updating tags file..."
ctags -R --languages=Pascal
echo "Complete."