#!/bin/bash
#set -x

while true; do
    # Checks
    command -v peco >/dev/null || { echo "Utility peco is required"; exit 1; }

    # Select action
    ACTION=$(echo -e "Activate\nDeactivate" | peco --prompt "Select an action:")
                    if [ -z "$ACTION" ]; then
                        echo "Exiting the script."
                        break
                    fi
    case "$ACTION" in

        "Activate")
            # Select load method
            load_option=$(echo -e "Load module permanently\nOnly for one session" | peco --prompt "Select a load method:")
                    if [ -z "$load_option" ]; then
                        echo "Exiting the script."
                        continue
                    fi
            case "$load_option" in
                "Load module permanently")
                    echo "Here the module will be loaded permanently"
 # Select module
selected_module="$(find ~/modules -maxdepth 1 -type f | sed 's|.*/||' | peco)"

if [ -z "$selected_module" ]; then
    echo "Exiting the script."
    continue
fi

# Path to the module specification file
spec_file="$HOME/.config/special_file_${selected_module}.txt"

# Search for and delete broken symbolic links in the system
echo "Searching for and deleting broken links: WAIT"
sudo find /usr /var /etc -depth -type l ! \( -path /proc -o -path /sys -o -path /dev \) -prune -o -type l ! -exec test -e {} \; -print -delete
echo "BROKEN LINKS DELETED!"

# Mount the selected module in /mnt
SOURCE_DIR="$HOME/modules/$selected_module"
TARGET_DIR="/mnt/$(basename "$selected_module" .sb)"

# Create a directory in /mnt with the name of the selected module
sudo mkdir -p "$TARGET_DIR"

# Mount the selected module in /mnt
sudo mount -t squashfs -o loop "$SOURCE_DIR" "$TARGET_DIR"

# Create a specification file with the module name
spec_file="$HOME/.config/special_file_${selected_module%.*}.txt"
touch "$spec_file"

# Copy all files and directories from the module to the file system
# and write the paths of symbolic links to the specification file
#sudo cp -rs --no-clobber "$TARGET_DIR"/* /
sudo cp -rsPn "$TARGET_DIR"/* /
find "$TARGET_DIR" -type f -exec echo {} \; | sed "s|$TARGET_DIR||" >> "$spec_file"

# Continue with other actions, such as compiling schemes, etc.
sudo glib-compile-schemas /usr/share/glib-2.0/schemas/
sudo ldconfig
sudo rm -rf ~/.cache/menus/
sudo update-desktop-database
#lxpanelctl restart

echo "MODULE ACTIVATED!"
sleep 1

# Create permanent-file, autostart script and desktop-file for the selected module
if [ "$load_option" == "Load module permanently" ]; then
    # Create permanent-file
    permanent_file="$HOME/.config/${selected_module%.*}-permanent"
    echo "$TARGET_DIR" > "$permanent_file"

    # Create autostart script
    autostart_script="$HOME/.local/bin/${selected_module%.*}-permanent.sh"
    echo "#!/bin/bash" > "$autostart_script"
    echo "sudo mount -t squashfs -o loop \"$SOURCE_DIR\" \"$TARGET_DIR\"" >> "$autostart_script"
    chmod +x "$autostart_script"

    # Create desktop-file for autostart
    autostart_desktop="$HOME/.config/autostart/${selected_module%.*}-permanent.desktop"
    echo "[Desktop Entry]" > "$autostart_desktop"
    echo "Type=Application" >> "$autostart_desktop"
    echo "Name=${selected_module%.*}-permanent" >> "$autostart_desktop"
    echo "Exec=$autostart_script" >> "$autostart_desktop"
    echo "X-GNOME-Autostart-enabled=true" >> "$autostart_desktop"
fi

                    
                    ;;
                "Only for one session")
                    # Select module
                    selected_module="$(find ~/modules -maxdepth 1 -type f | sed 's|.*/||' | peco)"

                    if [ -z "$selected_module" ]; then
                        echo "Exiting the script."
                        continue
                    fi

                    # Path to the module specification file
                    spec_file="$HOME/.config/special_file_${selected_module}.txt"

                    # Search for and delete broken symbolic links in the system
                    echo "Searching for and deleting broken links: WAIT"
                    sudo find /usr /var /etc -depth -type l ! \( -path /proc -o -path /sys -o -path /dev \) -prune -o -type l ! -exec test -e {} \; -print -delete
                    echo "BROKEN LINKS DELETED!"

                    # Mount the selected module in /mnt
                    SOURCE_DIR="$HOME/modules/$selected_module"
                    TARGET_DIR="/mnt/$(basename "$selected_module" .sb)"

                    # Create a directory in /mnt with the name of the selected module
                    sudo mkdir -p "$TARGET_DIR"

                    # Mount the selected module in /mnt
                    sudo mount -t squashfs -o loop "$SOURCE_DIR" "$TARGET_DIR"

                    # Create a specification file with the module name
                    spec_file="$HOME/.config/special_file_${selected_module%.*}.txt"
                    touch "$spec_file"

                    # Copy all files and directories from the module to the file system
                    # and write the paths of symbolic links to the specification file
                    #sudo cp -rs --no-clobber "$TARGET_DIR"/* /
                    sudo cp -rsPn "$TARGET_DIR"/* /
                    find "$TARGET_DIR" -type f -exec echo {} \; | sed "s|$TARGET_DIR||" >> "$spec_file"

                    # Continue with other actions, such as compiling schemes, etc.
                    sudo glib-compile-schemas /usr/share/glib-2.0/schemas/
                    sudo ldconfig
                    sudo rm -rf ~/.cache/menus/
                    sudo update-desktop-database
                   # lxpanelctl restart

                    echo "MODULE ACTIVATED!"
                    sleep 1
                    ;;
            esac
            ;;

        "Deactivate")
    # Select module for deactivation
    clear
    mounted_modules="$(find ~/.config -type f -name 'special_file_*' -exec basename {} .txt \;)"
    mounted_modules_formatted="$(echo "$mounted_modules" | sed 's/special_file_//; s/$/.sb/')"
    selected_module="$(echo "$mounted_modules_formatted" | peco)"

    if [ -z "$selected_module" ]; then
        echo "Exiting the script."
        continue
    fi

    TARGET_DIR="/mnt/$(basename "$selected_module" .sb)"

    # Read the specification file and delete symbolic links
    xargs -a "$HOME/.config/special_file_${selected_module%.*}.txt" sh -c 'for file do
      if [ -L "$file" ]; then
        sudo rm -f "$file"
      else
        echo "Skipping real file: $file"
      fi
    done'
    # Delete the specification file
    rm -f "$HOME/.config/special_file_${selected_module%.*}.txt"

    # Unmount the directory
    sudo umount "$TARGET_DIR"
    sudo rm -rf "$TARGET_DIR"
    sudo rm -rf ~/.cache/menus/
    sudo update-desktop-database
    #lxpanelctl restart
    echo "MODULE DEACTIVATED!"

    # Delete permanent-file
permanent_file="$HOME/.config/${selected_module%.*}-permanent"
if [ -f "$permanent_file" ]; then
    rm -f "$permanent_file"
fi

# Delete autostart script
autostart_script="$HOME/.local/usr/bin/${selected_module%.*}-permanent.sh"
if [ -f "$autostart_script" ]; then
    rm -f "$autostart_script"
fi

# Delete desktop-file for autostart
autostart_desktop="$HOME/.config/autostart/${selected_module%.*}-permanent.desktop"
if [ -f "$autostart_desktop" ]; then
    rm -f "$autostart_desktop"
fi

    sleep 1
    ;;

    esac

    echo "Done"
done
