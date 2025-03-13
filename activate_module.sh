#!/bin/bash
#totiks+Grok 12_03_2025
#set -x
# Путь к файлам
permanent_modules_file="$HOME/.config/permanent_modules.txt"
one_session_file="$HOME/.config/one_session.txt"
activated_modules_file="$HOME/.config/activated_modules.txt"
session_flag="$HOME/.config/session_flag"
TMPFS_DIR="/mnt/mod_tmp"
FALLBACK_DIR="/tmp"
RAMSIZE_CONF="$HOME/.config/mod_man_conf/ramsize.conf"
NUM_CORES="$(nproc)"
LOG_FILE="$HOME/.config/mod_man_conf/activation.log"

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
# Логирование
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Создаём директории, если их нет
mkdir -p "$HOME/.config" "$HOME/.config/mod_man_conf" "$HOME/.config/autostart"
chmod 755 "$HOME/.config" "$HOME/.config/mod_man_conf" "$HOME/.config/autostart"
log "Проверены и созданы директории $HOME/.config, $HOME/.config/mod_man_conf и $HOME/.config/autostart"

# Проверка и управление сессией
if [ ! -f "$session_flag" ]; then
    > "$one_session_file"  # Очищаем one_session.txt при новой сессии
    touch "$session_flag"  # Создаем флаг сессии
    log "Новая сессия начата, очищен $one_session_file и создан $session_flag"
else
    log "Сессия уже активна, $session_flag существует"
fi

# Инициализация файлов, если их нет
if [ ! -f "$permanent_modules_file" ]; then
    touch "$permanent_modules_file"
    chmod 644 "$permanent_modules_file"
    log "Создан пустой $permanent_modules_file"
fi

if [ ! -f "$one_session_file" ]; then
    touch "$one_session_file"
    chmod 644 "$one_session_file"
    log "Создан пустой $one_session_file"
fi

if [ -s "$one_session_file" ]; then
    log "В $one_session_file уже есть записи: $(cat "$one_session_file")"
fi

if [ ! -f "$activated_modules_file" ]; then
    touch "$activated_modules_file"
    chmod 644 "$activated_modules_file"
    log "Создан пустой $activated_modules_file"
fi

# Загрузка списков модулей (для отладки)
if [ -f "$permanent_modules_file" ]; then
    mapfile -t permanent_modules < "$permanent_modules_file"
    log "Загружен $permanent_modules_file: ${permanent_modules[*]}"
else
    permanent_modules=()
fi

if [ -f "$one_session_file" ]; then
    mapfile -t one_session_modules < "$one_session_file"
    log "Загружен $one_session_file: ${one_session_modules[*]}"
else
    one_session_modules=()
fi

# Проверка размера tmpfs
if [ -f "$RAMSIZE_CONF" ]; then
    TMPFS_SIZE=$(cat "$RAMSIZE_CONF" | tr -d '[:space:]')
else
    TMPFS_SIZE="1024m"
    mkdir -p "$HOME/.config/mod_man_conf"
    echo "$TMPFS_SIZE" > "$RAMSIZE_CONF"
    log "Установлен размер tmpfs по умолчанию: $TMPFS_SIZE"
fi

# Монтирование tmpfs
if ! mountpoint -q "$TMPFS_DIR"; then
    sudo mkdir -p "$TMPFS_DIR"
    if sudo mount -t tmpfs -o size="$TMPFS_SIZE" tmpfs "$TMPFS_DIR"; then
        log "Tmpfs смонтирован в $TMPFS_DIR с размером $TMPFS_SIZE"
    else
        log "Ошибка монтирования tmpfs в $TMPFS_DIR"
        exit 1
    fi
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

# Функция создания скрипта очистки one_session.txt и его автозапуска
create_cleanup_script() {
    local cleanup_script="$HOME/.config/mod_man_conf/session_cleanup.sh"
    echo "#!/bin/bash" > "$cleanup_script"
    echo "LOG_FILE=\"$LOG_FILE\"" >> "$cleanup_script"
    echo "log() { echo \"\$(date '+%Y-%m-%d %H:%M:%S') - \$1\" >> \"\$LOG_FILE\"; }" >> "$cleanup_script"
    echo "ONE_SESSION_FILE=\"$one_session_file\"" >> "$cleanup_script"
    echo "SESSION_FLAG=\"$session_flag\"" >> "$cleanup_script"
    echo "if [ -f \"\$SESSION_FLAG\" ]; then" >> "$cleanup_script"
    echo "    > \"\$ONE_SESSION_FILE\"" >> "$cleanup_script"
    echo "    rm -f \"\$SESSION_FLAG\"" >> "$cleanup_script"
    echo "    log \"Сессия завершена, очищен \$ONE_SESSION_FILE и удалён \$SESSION_FLAG\"" >> "$cleanup_script"
    echo "fi" >> "$cleanup_script"
    
    chmod +x "$cleanup_script"
    if [ -f "$cleanup_script" ]; then
        log "Создан скрипт очистки $cleanup_script"
    else
        log "Ошибка: не удалось создать $cleanup_script"
        return 1
    fi
    
    # Создание .desktop файла для автозапуска очистки
    local autostart_dir="$HOME/.config/autostart"
    local cleanup_desktop="$autostart_dir/session_cleanup.desktop"
    
    {
        echo "[Desktop Entry]"
        echo "Type=Application"
        echo "Name=Session Cleanup"
        echo "Exec=$cleanup_script"
        echo "Hidden=false"
        echo "NoDisplay=false"
        echo "X-GNOME-Autostart-enabled=true"
        echo "X-GNOME-Autostart-Phase=Initialization"
    } > "$cleanup_desktop"
    
    if [ -f "$cleanup_desktop" ] && [ -s "$cleanup_desktop" ]; then
        chmod 644 "$cleanup_desktop"
        log "Создан $cleanup_desktop для очистки сессии"
    else
        log "Ошибка: не удалось создать или заполнить $cleanup_desktop"
        return 1
    fi
}

# Функция создания автозагрузочного скрипта
create_autostart_script() {
    local autostart_script="$HOME/.config/mod_man_conf/permanent_autostart.sh"
    echo "#!/bin/bash" > "$autostart_script"
    echo "LOG_FILE=\"$LOG_FILE\"" >> "$autostart_script"
    echo "log() { echo \"\$(date '+%Y-%m-%d %H:%M:%S') - \$1\" >> \"\$LOG_FILE\"; }" >> "$autostart_script"
    echo "NUM_CORES="$(nproc)"" >> "$autostart_script"
    echo "find /usr /var /etc /home/live/.local -type l -xtype l -print0 | xargs -0 -P "$NUM_CORES" -n 50 sudo rm -f" >> "$autostart_script"
    echo "wait" >> "$autostart_script"
    # Установка TMPFS_SIZE из RAMSIZE_CONF
    echo "RAMSIZE_CONF=\"$RAMSIZE_CONF\"" >> "$autostart_script"
    echo "if [ -f \"\$RAMSIZE_CONF\" ]; then" >> "$autostart_script"
    echo "    TMPFS_SIZE=\$(cat \"\$RAMSIZE_CONF\" | tr -d '[:space:]')" >> "$autostart_script"
    echo "else" >> "$autostart_script"
    echo "    TMPFS_SIZE=\"1024m\"" >> "$autostart_script"
    echo "fi" >> "$autostart_script"
    # Уведомление о начале с задержкой 3 секунды
    echo "sleep 12" >> "$autostart_script"
    echo "notify-send \"ModMan Sprites\" \"Начало автозагрузки permanent-модулей...\" -t 8000" >> "$autostart_script"
    echo "if ! mountpoint -q \"$TMPFS_DIR\"; then" >> "$autostart_script"
    echo "    sudo mkdir -p \"$TMPFS_DIR\"" >> "$autostart_script"
    echo "    if sudo mount -t tmpfs -o size=\$TMPFS_SIZE tmpfs \"$TMPFS_DIR\"; then" >> "$autostart_script"
    echo "        log \"Tmpfs смонтирован в $TMPFS_DIR при автозапуске\"" >> "$autostart_script"
    echo "    else" >> "$autostart_script"
    echo "        log \"Ошибка монтирования tmpfs при автозапуске\"" >> "$autostart_script"
    echo "    fi" >> "$autostart_script"
    echo "fi" >> "$autostart_script"
    
    while IFS= read -r mod; do
        if [ -n "$mod" ]; then
            autostart_mod_script="$HOME/.config/mod_man_conf/${mod%.*}-conf/${mod%.*}-permanent.sh"
            if [ -f "$autostart_mod_script" ]; then
                echo "bash \"$autostart_mod_script\"" >> "$autostart_script"
                echo "log \"Выполнен скрипт активации для $mod\"" >> "$autostart_script"
                echo "wait" >> "$autostart_script"
                echo "sleep 1" >> "$autostart_script"  # Добавляем вашу задержку
            fi
        fi
    done < "$permanent_modules_file"
    # Уведомление о завершении
    echo "notify-send \"ModMan Sprites\" \"Автозагрузка permanent-модулей завершена.\" -t 5000" >> "$autostart_script"
    
    chmod +x "$autostart_script"
    if [ -f "$autostart_script" ]; then
        log "Создан $autostart_script"
    else
        log "Ошибка: не удалось создать $autostart_script"
        return 1
    fi
    
    local autostart_dir="$HOME/.config/autostart"
    local autostart_desktop="$autostart_dir/permanent_autostart.desktop"
    
    if [ ! -d "$autostart_dir" ]; then
        mkdir -p "$autostart_dir"
        chmod 755 "$autostart_dir"
        log "Создана директория $autostart_dir"
    fi
    
    {
        echo "[Desktop Entry]"
        echo "Type=Application"
        echo "Name=Permanent Modules Autostart"
        echo "Exec=$autostart_script"
        echo "Hidden=false"
        echo "NoDisplay=false"
        echo "X-GNOME-Autostart-enabled=true"
    } > "$autostart_desktop"
    
    if [ -f "$autostart_desktop" ] && [ -s "$autostart_desktop" ]; then
        chmod 644 "$autostart_desktop"
        log "Создан $autostart_desktop"
    else
        log "Ошибка: не удалось создать или заполнить $autostart_desktop"
        return 1
    fi
    
    # Вызываем создание скрипта очистки после создания автозагрузки
    create_cleanup_script
}

# Основная логика активации
module="$1"
load_type="$2"

log "Запуск активации: module=$module, load_type=$load_type"

if [ -z "$module" ] || [ -z "$load_type" ]; then
    echo "Ошибка: укажите имя модуля и тип загрузки (permanent/session)" >&2
    log "Ошибка: отсутствует имя модуля или тип загрузки"
    exit 1
fi

# Исправляем путь: если передан полный путь, берём только имя файла
if [[ "$module" =~ ^/ ]]; then
    MODULE_NAME=$(basename "$module")
    SOURCE_DIR="$HOME/modules/$MODULE_NAME"
else
    MODULE_NAME="$module"
    SOURCE_DIR="$HOME/modules/$module"
fi

log "Исправленный путь: SOURCE_DIR=$SOURCE_DIR, MODULE_NAME=$MODULE_NAME"

if [ ! -f "$SOURCE_DIR" ]; then
    log "Ошибка: файл $SOURCE_DIR не существует"
    echo "Ошибка: файл $SOURCE_DIR не существует" >&2
    exit 1
fi

TARGET_DIR=$(check_space_and_set_target "$SOURCE_DIR" "$MODULE_NAME")

# Очищаем целевую директорию перед распаковкой
sudo rm -rf "$TARGET_DIR"
sudo mkdir -p "$TARGET_DIR"
log "Очищена и создана директория $TARGET_DIR"

if sudo unsquashfs -d "$TARGET_DIR" "$SOURCE_DIR"; then
    log "Модуль $MODULE_NAME распакован в $TARGET_DIR"
else
    log "Ошибка распаковки $MODULE_NAME в $TARGET_DIR"
    exit 1
fi
sudo cp -rsPn "$TARGET_DIR"/* /
sudo glib-compile-schemas /usr/share/glib-2.0/schemas/ 2>/dev/null
sudo ldconfig
sudo rm -rf ~/.cache/menus/
sudo update-desktop-database

#find /usr /var /etc /home/live/.local -type l -xtype l -print0 | xargs -0 -P "$NUM_CORES" -n 50 sudo rm -f
clean_broken_symlinks
wait
log "Активация $MODULE_NAME завершена (основные действия)"

module_conf_dir="$HOME/.config/mod_man_conf/${MODULE_NAME%.*}-conf"
mkdir -p "$module_conf_dir"

if [ "$load_type" == "permanent" ]; then
    permanent_file="$module_conf_dir/${MODULE_NAME%.*}-permanent"
    echo "#!/bin/bash" > "$permanent_file"
    echo "SOURCE_DIR=\"$SOURCE_DIR\"" >> "$permanent_file"
    echo "TARGET_DIR=\"$TARGET_DIR\"" >> "$permanent_file"
    echo "sudo rm -rf \"\$TARGET_DIR\"" >> "$permanent_file"
    echo "sudo mkdir -p \"\$TARGET_DIR\"" >> "$permanent_file"
    echo "sudo unsquashfs -d \"\$TARGET_DIR\" \"\$SOURCE_DIR\"" >> "$permanent_file"
    echo "sudo cp -rsPn \"\$TARGET_DIR\"/* /" >> "$permanent_file"
    chmod +x "$permanent_file"
    
    autostart_script="$module_conf_dir/${MODULE_NAME%.*}-permanent.sh"
    echo "#!/bin/bash" > "$autostart_script"
    echo "source \"$permanent_file\"" >> "$autostart_script"
    chmod +x "$autostart_script"
    log "Создан скрипт $autostart_script для $MODULE_NAME"
    
    # Добавляем модуль в permanent_modules.txt
    echo "$MODULE_NAME" >> "$permanent_modules_file"
    sort -u "$permanent_modules_file" -o "$permanent_modules_file"
    log "Добавлен $MODULE_NAME в $permanent_modules_file"
    create_autostart_script
elif [ "$load_type" == "session" ]; then
    # Добавляем модуль в one_session.txt
    echo "$MODULE_NAME" >> "$one_session_file"
    sort -u "$one_session_file" -o "$one_session_file"
    log "Добавлен $MODULE_NAME в $one_session_file"
fi

# Обновляем activated_modules.txt как сумму permanent_modules.txt и one_session.txt
cat "$permanent_modules_file" "$one_session_file" 2>/dev/null | sort -u > "$activated_modules_file"
log "Обновлён $activated_modules_file"

echo "Модуль $MODULE_NAME активирован ($load_type)"
