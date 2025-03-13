#!/bin/bash
#set -x
#totiks+Grok 12_03_2025
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
cd /home/live/.local/bin/mod_man-sprites_G
# Текущий каталог, где находится скрипт
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
CACHE_FILE="$SCRIPT_DIR/package_list.txt"
NOTIFY_TCL="$SCRIPT_DIR/notify.tcl"

# Создаем Tcl/Tk скрипт для уведомления
cat > "$NOTIFY_TCL" << 'EOF'
#!/usr/bin/wish
package require Tk

# Скрываем главное окно интерпретатора wish
wm withdraw .

toplevel .prep_win
wm title .prep_win "Подготовка программы"
wm geometry .prep_win "400x150"
wm protocol .prep_win WM_DELETE_WINDOW {}

frame .prep_win.content -padx 10 -pady 10
pack .prep_win.content -fill both -expand yes

label .prep_win.content.label -text "Идёт подготовка программы:\n1. Кэширование списка пакетов\n2. Удаление битых ссылок\nПожалуйста, подождите..."
pack .prep_win.content.label -pady 10

ttk::progressbar .prep_win.content.progress -mode indeterminate -length 250
pack .prep_win.content.progress -pady 10
.prep_win.content.progress start

update idletasks
after 2000 {destroy .prep_win; exit}
EOF

# Делаем Tcl/Tk скрипт исполняемым
chmod +x "$NOTIFY_TCL"

# Создание необходимых каталогов
mkdir -p /home/live/modules /home/live/portapps

# Запускаем уведомление в фоне с nohup и перенаправлением вывода
nohup "$NOTIFY_TCL" > /dev/null 2>&1 &

# Кэширование списка пакетов в текущем каталоге
echo "Кэширование списка пакетов в $CACHE_FILE..."
sudo apt-cache pkgnames | sort > "$CACHE_FILE"

# Очистка битых ссылок в фоне с перенаправлением вывода
(
    sleep 6
    NUM_CORES="$(nproc)"
    echo "Поиск и удаление битых ссылок: ЖДИТЕ"
    #find /usr /var /etc /home/live/.local -type l -xtype l -print0 | xargs -0 -P "$NUM_CORES" -n 50 sudo rm -f
    clean_broken_symlinks
    wait
    echo "БИТЫЕ ССЫЛКИ УДАЛЕНЫ!"
) > /dev/null 2>&1 &

# Запускаем основной менеджер модулей с nohup и перенаправлением вывода
echo "Запуск менеджера модулей..."
#nohup wish "$SCRIPT_DIR/m_m_s-g-16-d.tcl" > /dev/null 2>&1 &
nohup wish "$SCRIPT_DIR/m_m_s-g-18-lang+themes.tcl" > /dev/null 2>&1 &
# Завершаем скрипт, чтобы терминал закрылся
exit 0
