Trains Game
==============================

Getting started:
------------------------------
Case 1: You have a binary of the game. Double-click it and run -> voila!

Case 2: You have a .love version of the game, you'll need to install the awesome Löve2D game engine. Get it at love2d.org (this game was developed for Löve2D Version 0.8.0).

First, try getting into the tutorials. Once through them, have a look at the Documentation.html file in this folder.

Then, the next step will be to get into the challenges. Once you've mastered them, you're ready to upload your AI and watch it fight others on the online servers!

Command Line Options:
------------------------------
Make sure to add these at the end, __after__ the folder or .love file. Otherwise love won't know to run the game.
- Dedicated Server: **-D** or **--server** or **--dedicated**
- Time between two matches on Server (in seconds): **-t TIME**
Note that you'll need to edit the IP address of the client to make sure your client will find the server and watch its matches.

Uninstalling:
------------------------------
The game creates a Folder in your local home folder. Depending on how you uninstall, you might have to remove this manually. They'll usually be in these locations (taken from love2d.org):
- Windows XP: C:\Documents and Settings\user\Application Data\LOVE\ or %appdata%\LOVE\
- Windows Vista and 7: C:\Users\user\AppData\Roaming\LOVE or %appdata%\LOVE\
- Linux: $XDG\_DATA\_HOME/love/ or ~/.local/share/love/
- Mac: /Users/user/Library/Application Support/LOVE/ 
