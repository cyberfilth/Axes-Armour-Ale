#!/bin/sh
echo "Compiling Axes, Armour & Ale..."
'/usr/bin/fpc' ascii_axe.lpr -Mfpc -Schi -CX -Cg -Os4 -Xs -XX -vewnhibq -Filib/x86_64-linux -Fuscreens -Fudungeons -Fuplayer -Fuvision -Fuentities -Fuitems -Fuitems/weapons -Fuitems/armour -Fuitems/macguffins -Fuentities/hobs -Fuentities/fungus -Fuentities/animals -Fu. -FUlib/x86_64-linux -FE. -oAxes
echo "Complete."

