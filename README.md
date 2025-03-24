upd:13-03-25
this version in the main branch is very outdated
there is a new version of the module manager, see the version in the branch latest
---------------------------------------------------------------
upd:25-06-24
I redid the Deactivate section algorithm, changed the code related to the removal of symbolic links, now removes links not from the list, but searches for and removes directly thrown links, as a result, the code has become more stable and the script does not destroy the system.
you should take the script of the latest version mod-man-9-r.sh
---------------------------------------------------------------

upd:Improved the code and added the `*` label in the peco output to mounted modules, now it has become much more convenient to visually distinguish a mounted module from an unmounted one. to do this, you should take the script mod_man-7.sh

upd2: I am fulfilling the AI's request The code was co-written with AI https://chat.mistral.ai/

The provided Bash script can work with modules created by the Bash repo2sb script available for viewing and downloading at the following address: https://github.com/totiks2012/repo2sb.git

This bash script is a module manager for Linux that allows you to activate and deactivate modules, as well as choose whether to load them permanently or only for 
the current session. To use the script, run it with bash or make it executable and run it with ./mod_man.sh. 
The script will prompt you to choose an action and guide you through the process of activating or deactivating a module.

The script performs the following actions:

Checks if the peco utility is installed.
Prompts the user to choose an action: Activate or Deactivate.
If the user chooses to activate a module, the script prompts them to select whether to load it permanently or only for the current session.
The script searches for available modules in the ~/modules directory and displays them in a list using peco.
The selected module is mounted in the /mnt directory.
The script creates a file with the module's specifications in the ~/.config directory.
The script creates symbolic links to all files and directories from the module in the 
file system and writes the paths of the symbolic links to the file with the module's specifications.
The script performs additional actions, such as compiling schemes and updating the desktop database.
If the user chose to load the module permanently, the script creates a permanent file, a script for autoloading, and a desktop file for the selected module.
If the user chooses to deactivate a module, the script searches for mounted modules in the ~/.config directory and displays them in a list using peco.
The script reads the file with the module's specifications and deletes the symbolic links.
The script unmounts the module's directory and deletes it.
The script updates the desktop database.
If the module was loaded permanently, the script deletes the permanent file, the script for autoloading, and the desktop file for the selected module.
Note: The script uses sudo to perform some actions, so make sure you have the necessary permissions. Also, the script uses symbolic links to link files and
 directories from the module to the file system, rather than creating virtual layers using aufs or another file system. The sb modules should be placed in the ~/modules directory.

This script is licensed under the GPL3 License. See the LICENSE file for details.
