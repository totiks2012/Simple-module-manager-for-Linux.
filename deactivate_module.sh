#!/bin/bash
#totiks+Grok 12_03_2025
# Путь к файлам
activated_modules_file="$HOME/.config/activated_modules.txt"
permanent_modules_file="$HOME/.config/permanent_modules.txt"
one_session_file="$HOME/.config/one_session.txt"
TMPFS_DIR="/mnt/mod_tmp"
FALLBACK_DIR="/tmp"
NUM_CORES="$(nproc)"
RAMSIZE_CONF="$HOME/.config/mod_man_conf/ramsize.conf"

# Функция для очистки битых символических ссылок
clean_broken_symlinks() {
    # Проверяем наличие fd или fdfind
    FD_CMD=""
    if command -v fd >/dev/null 2>&1; then
        FD_CMD="fd"
    elif command -v fdfind >/dev/null 2>&1; then
        FD_CMD="fdfind"
    fi
    notify-send "Используется команда $FD_CMD"
    if [ -n "$FD_CMD" ]; then
        # Используем найденную команду для поиска битых ссылок
        for dir in /usr /var /etc /home/live/.local; do
            if [ -d "$dir" ]; then
                "$FD_CMD" --hidden --type symlink --base-directory "$dir" . --print0 | while IFS= read -r -d '' link; do
                    [ ! -e "$link" ] && echo -n "$link\0"
                done
            fi
        done | xargs -0 -P "$NUM_CORES" -n 50 sudo rm -f
    else
        # Fallback на find, если ни fd, ни fdfind не установлены
        find /usr /var /etc /home/live/.local -type l -xtype l -print0 | xargs -0 -P "$NUM_CORES" -n 50 sudo rm -f
    fi
    wait
}
# Загрузка списков модулей
if [ -f "$activated_modules_file" ]; then
    mapfile -t activated_modules < "$activated_modules_file"
else
    activated_modules=()
fi

if [ -f "$permanent_modules_file" ]; then
    mapfile -t permanent_modules < "$permanent_modules_file"
else
    permanent_modules=()
fi

if [ -f "$one_session_file" ]; then
    mapfile -t one_session_modules < "$one_session_file"
else
    one_session_modules=()
fi

# Функция проверки места
check_space_and_set_target() {
    local source_file="$1"
    local module_name="$2"
    local module_size_kb=$(ls -l "$source_file" | awk '{print $5}')
    module_size_kb=$((module_size_kb / 1024))
    
    local tmpfs_available_kb=$(df -k "$TMPFS_DIR" | tail -1 | awk '{print $4}')
    local required_size_kb=$((module_size_kb * 2))
    
    if [ "$required_size_kb" -lt "$tmpfs_available_kb" ]; then
        echo "$TMPFS_DIR/$(basename "$module_name" .sb)"
    else
        echo "$FALLBACK_DIR/$(basename "$module_name" .sb)"
    fi
}

# Функция создания автозагрузочного скрипта
create_autostart_script() {
    local autostart_script="$HOME/.config/mod_man_conf/permanent_autostart.sh"
    echo "#!/bin/bash" > "$autostart_script"
    # Установка TMPFS_SIZE из RAMSIZE_CONF
    echo "RAMSIZE_CONF=\"$RAMSIZE_CONF\"" >> "$autostart_script"
    echo "if [ -f \"\$RAMSIZE_CONF\" ]; then" >> "$autostart_script"
    echo "    TMPFS_SIZE=\$(cat \"\$RAMSIZE_CONF\" | tr -d '[:space:]')" >> "$autostart_script"
    echo "else" >> "$autostart_script"
    echo "    TMPFS_SIZE=\"1024m\"" >> "$autostart_script"
    echo "fi" >> "$autostart_script"
    echo "if ! mountpoint -q \"$TMPFS_DIR\"; then" >> "$autostart_script"
    echo "    sudo mkdir -p \"$TMPFS_DIR\"" >> "$autostart_script"
    echo "    sudo mount -t tmpfs -o size=\$TMPFS_SIZE tmpfs \"$TMPFS_DIR\"" >> "$autostart_script"
    echo "fi" >> "$autostart_script"
    
    find "$HOME/.config/mod_man_conf" -type f -name "*-permanent.sh" | while read -r script; do
        module_name=$(basename "$script" | sed 's/-permanent.sh$//')
        echo "bash \"$script\"" >> "$autostart_script"
        echo "wait" >> "$autostart_script"
    done
    chmod +x "$autostart_script"
    
    local autostart_desktop="$HOME/.config/autostart/permanent_autostart.desktop"
    echo "[Desktop Entry]" > "$autostart_desktop"
    echo "Type=Application" >> "$autostart_desktop"
    echo "Name=Permanent Modules Autostart" >> "$autostart_desktop"
    echo "Exec=$autostart_script" >> "$autostart_desktop"
    echo "X-GNOME-Autostart-enabled=true" >> "$autostart_desktop"
    chmod +x "$autostart_desktop"
}

# Основная логика деактивации
module="$1"

if [ -z "$module" ]; then
    echo "Ошибка: укажите имя модуля" >&2
    exit 1
fi

# Исправляем путь, если передан полный путь
if [[ "$module" =~ ^/ ]]; then
    MODULE_NAME=$(basename "$module")
else
    MODULE_NAME="$module"
fi

TARGET_DIR=$(check_space_and_set_target "$HOME/modules/$MODULE_NAME" "$MODULE_NAME")
sudo rm -rf "$TARGET_DIR"
sudo rm -rf ~/.cache/menus/
sudo update-desktop-database

module_conf_dir="$HOME/.config/mod_man_conf/${MODULE_NAME%.*}-conf"
permanent_file="$module_conf_dir/${MODULE_NAME%.*}-permanent"
autostart_script="$module_conf_dir/${MODULE_NAME%.*}-permanent.sh"

# Удаляем файлы скриптов
[ -f "$permanent_file" ] && rm -f "$permanent_file"
[ -f "$autostart_script" ] && rm -f "$autostart_script"

# Удаляем модуль из всех списков
sed -i "/$MODULE_NAME/d" "$activated_modules_file"
sed -i "/$MODULE_NAME/d" "$permanent_modules_file"
sed -i "/$MODULE_NAME/d" "$one_session_file"

# Очистка массивов и перезапись файлов
activated_modules=("${activated_modules[@]/$MODULE_NAME}")
permanent_modules=("${permanent_modules[@]/$MODULE_NAME}")
one_session_modules=("${one_session_modules[@]/$MODULE_NAME}")

# Перезаписываем списки только с оставшимися модулями
printf "%s\n" "${activated_modules[@]}" | grep -v '^$' | sort -u > "$activated_modules_file"
printf "%s\n" "${permanent_modules[@]}" | grep -v '^$' | sort -u > "$permanent_modules_file"
printf "%s\n" "${one_session_modules[@]}" | grep -v '^$' | sort -u > "$one_session_file"

#find /usr /var /etc /home/live/.local -type l -xtype l -print0 | xargs -0 -P "$NUM_CORES" -n 50 sudo rm -f
clean_broken_symlinks
wait

# Пересоздаём автозагрузочный скрипт после удаления
create_autostart_script

echo "Модуль $MODULE_NAME деактивирован"
