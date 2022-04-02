#!/bin/sh
echo "Compiling Axes, Armour & Ale..."
'/usr/local/bin/fpc' Axes.lpr -Mfpc -Schi -CX -Os3 -Xs -XX -vewnhibq -Filib/x86_64-darwin -Fuscreens -Fudungeons -Fuplayer -Fuvision -Fuitems -Fuitems/weapons -Fuitems/armour -Fuitems/macguffins -Fuentities -Fuentities/fungus -Fuentities/hobs -Fuentities/animals -Fu. -FUlib/x86_64-darwin -FE. -oAxes
echo "Complete."
