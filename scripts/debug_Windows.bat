if not exist "..\source\lib\i386-win32" (
    mkdir "..\source\lib\i386-win32"
)
cd ..\source
fpc Axes.pas  -Mfpc -Scaghi -CirotR -O1 -gw2 -godwarfsets -gl -gh -Xg -gt -l -vewnhibq -Filib\i386-win32 -Fientities -Fudungeons -Fuentities -Fuitems -Fuplayer -Fuscreens -Fuvision -Fuentities\animals -Fuentities\fungus -Fuentities\gnomes -Fuentities\hobs -Fuitems\armour -Fuitems\macguffins -Fuitems\weapons -Fuitems\traps -Fuentities\bugs -Fuentities\bogles -Fuentities\undead -Fuentities\goblinkin -Fuentities\troglodytes -Fu. -FUlib\i386-win32 -FE. -oAxes.exe
