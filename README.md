Trains Game
==============================

Getting started:
------------------------------
**Case 1:** You have a binary of the game. Double-click it and run -> voila!

**Case 2:** You have a .love version of the game, you'll need to install the awesome Löve2D game engine. Get it at love2d.org (this game was developed for Löve2D Version 0.8.0). Then double click the .love file.

**Case 3:** You have the source of the game. Get the Löve2D engine and install it. Then open a console, type the path to the love engine (on unix, you might just need 'love', on windows you need the whole path to the Love.exe) and the path to the game folder after it (the one holding the main.lua file). See an example of this in the section **Command Line Options**!

First, try getting into the tutorials. Once through them, have a look at the Documentation.html file in this folder.

Then, the next step will be to get into the challenges. Once you've mastered them, you're ready to upload your AI and watch it fight others on the online servers!

Setting up your own server:
------------------------------
You can start your own dedicated server (see the section "Command Line Options" below). 
This server will automatically start running matches using random maps and the AIs located in your AI subfolder. You can watch these matches by starting the game again, without the server option. Start with **--host localhost** to connect to the server running on your PC.

Command Line Options:
------------------------------
Make sure to add these at the end, __after__ the folder or .love file. Otherwise the Löve engine won't know to run the game.
Example:  
**Linux:**
```bash
/path/to/love /path/to/game --server -p 4242
```
**Win:**
```dos
C:\Program/ Files\Love\Love.exe C:\Games\trAInsported --console --server -p 4242
```
- **-s** or **--server** or **--dedicated**: Start in dedicated server mode.
- **-h IP_OR_URL** or **--host IP_OR_URL** or **--ip IP_OR_URL**: IP address of server to connect to. You can also use an URL to connect if you have a server running on some web-machine. In both cases, make sure to open the ports on your server's router! [Client]
- **-p PORTNUMBER** or **--port PORTNUMBER**:  Port to use -> must be the same on client and server. (Default port is 5556. Make sure to port-forward that port if the game server is sitting behind a router.) [Client and Server]
- **-m TIME** or **--match_time TIME**: Time a match will take. [Server]
- **-c TIME** or **--cooldown TIME**: Time between two matches on Server. (TIME in seconds, minimum 10. - Note: if this is too low, watching clients won't be able to view the match results. 20 seconds is usually a good value.) [Server]
- **--mapsize NUMBER**: Maximum number of tiles the map can be in width and height. Default: 50.
- **--console** Needed on Windows if you want a console. On Unix-Systems, the standard console will be used for output. [Client and Server]
- **--render**: Forces game to rerender all images at startup. [Client]
- **--mysql USER,PASSWORD[,HOST[,PORT]]**: Will enable logging to a MySQL database if **--server** is activated. It will log into the MySQL server using **USER** and **PASSWORD**. Optionally, **HOST** and **PORT** can be given to connect to a remote server (default is localhost). You can use **--mysqlDB** to change the database to use. Otherwise, it will use the 'trAInsported' database. Note: You have to manually create the trAInsported Database beforehand, and make sure that USER has rights to create a table and edit a table on the database.[Server]
- **--mysqlDB DATABASE**: The game will connect to this database instead of the default one. The **USER** given by **--mysql** (see above) needs to have access to this database. [Server]
- **-d DIR** or **--directory DIR**: Needs LuaFileSystem installed! Gives the path to the folder which holds the various user folders, which in turn hold the users' AIs. The path must be absolute, relative paths should not work here!
- **--chart DIR**: If this DIR is given, the game will render a .svg chart of each round's results and store it in DIR.

Uninstalling:
------------------------------
The game creates a folder called **trAInsported** in your local home folder. Depending on how you uninstall, you might have to remove this manually. They'll usually be in these locations (taken from love2d.org):
- **Linux:** $XDG\_DATA\_HOME/love/ or ~/.local/share/love/
- **Mac:** /Users/user/Library/Application Support/LOVE/ 
- **Windows XP:** C:\Documents and Settings\user\Application Data\LOVE\ or %appdata%\LOVE\
- **Windows Vista and 7:** C:\Users\user\AppData\Roaming\LOVE or %appdata%\LOVE\

Translations:
------------------------------
Before you get started, please check if there is someone already working on the translation and has posted about it [on the forum](http://www.indiedb.com/games/trainsported/forum) or on [GitHub](https://github.com/Germanunkol/trainsported/issues). Feel free to collaborate with them if this is the case!
If you want to translate the Game into your own language, please do the following:
- Get the source code from github: https://github.com/Germanunkol/trainsported
- Copy the file English.lua in the Languages/ subfolder of the game. Rename it to the name of your Language.
- Edit the new file (for example: Deutsch.lua) to contain the correct translations of all the text strings in there.
- When you save the file and start the game, you should be able to load your new language by going into the settings menu.
- Copy the four Tutorial .lua Files from the Tutorial/ subfolder of the game into the Language/ folder. Add LANGUAGE_ to the beginning of all four file names, where LANGUAGE is the same as the name of your translation file in this folder. Example: Deutsch.lua Deutsch\_Tutorial1.lua Deutsch\_Tutorial2.lua etc.
- Send me the files! Either give them to me through gitHub, or send them to me some other way (file upload, or via email).
- Thanks!


[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/Germanunkol/trainsported/trend.png)](https://bitdeli.com/free "Bitdeli Badge")

