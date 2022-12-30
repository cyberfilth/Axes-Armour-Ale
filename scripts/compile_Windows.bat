if not exist "..\source\lib\i386-win32" (
    mkdir "..\source\lib\i386-win32"
)
cd ..\source
fpc Axes.pas -MObjFPC -Scghi -CX -Os3 -Xs -XX -l -vewnhibq -Filib\i386-win32 -Fientities -Fidungeons -Fudungeons -Fuentities -Fuitems -Fuplayer -Fuscreens -Fuvision -Fuentities\animals -Fuentities\bugs -Fuentities\fungus -Fuentities\gnomes -Fuentities\hobs -Fuitems\armour -Fuitems\macguffins -Fuitems\weapons -Fuentities\bogles -Fuentities\undead -Fuentities\goblinkin -Fuentities\troglodytes -Fuentities\npc -Fuitems\traps -Fu. -FUlib\i386-win32 -FE. -oAxes.exe
