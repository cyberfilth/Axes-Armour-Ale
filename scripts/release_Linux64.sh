#!/bin/sh
echo "Compiling Axes, Armour & Ale..."
fpc Axes.pas -Mfpc -Schi -CX -Cg -Os3 -Xs -XX -vewnhibq -Filib/x86_64-linux -Fuscreens -Fudungeons -Fuplayer -Fuvision -Fuitems -Fuitems/weapons -Fuitems/armour -Fuitems/macguffins -Fuentities -Fuentities/fungus -Fuentities/hobs -Fuentities/animals -Fuentities/bugs -Fuentities/gnomes -Fu. -FUlib/x86_64-linux -FE. -oAxes
echo "Complete."
