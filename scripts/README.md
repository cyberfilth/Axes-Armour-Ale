# Scripts

Scripts used to develop / compile **Axes, Armour & Ale**
The Free Pascal textmode IDE is used to develop this game. Place the *fp.cfg* & *fp.ini* files in the source folder if you want to edit the source code.

  * *compile_Linux.sh* - BASH script to compile the release version for Linux 
  * *compile_Windows.bat* - Batch file to compile the release version for Windows
  * *tidyUp.sh* - BASH script to call DELP (FP tool to clean up files after compilation) and update tags file
  * *findInFiles.sh* - BASH script to grep for a string in .pas files
  * *fp.cfg* - Free Pascal IDE config file, sets the different build modes
  * *fp.ini* - Free Pascal IDE user settings, includes custom theme and some tools
  * *formatCode.sh* drop this in the source directory, along with *ptop.cfg* and you can beautify your code from FP IDE tools menu