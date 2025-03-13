#!/bin/bash
#set -x
# Путь к файлу со списком активированных модулей
activated_modules_file="$HOME/.config/activated_modules.txt"

# Проверяем, существует ли файл, и загружаем список активированных модулей
if [ -f "$activated_modules_file" ]; then
    mapfile -t activated_modules < "$activated_modules_file"
fi

while true; do
    # Проверки
    command -v peco >/dev/null || { echo "Требуется утилита peco"; exit 1; }

    # Выбор действия
    ACTION=$(echo -e "Активировать\nДеактивировать" | peco --prompt "Выберите действие:")
    if [ -z "$ACTION" ]; then
        echo "Выход из скрипта."
        break
    fi

    case "$ACTION" in
        "Активировать")
        clear
            # Выбор способа загрузки модуля
            load_option=$(echo -e "Загружать модуль на постоянной основе\nТолько на одну сессию" | peco --prompt "Выберите способ загрузки модуля:")
            if [ -z "$load_option" ]; then
                echo "Выход из скрипта."
                continue
            fi

            # Получаем список доступных модулей и помечаем активированные модули звездочкой (*)
            available_modules="$(find ~/modules -maxdepth 1 -type f | sed 's|.*/||')"
            marked_modules="$(for module in $available_modules; do
                                if [[ " ${activated_modules[@]} " =~ " ${module} " ]]; then
                                    echo "* $module"
                                else
                                    echo "$module"
                                fi
                             done)"

            # Выбор модуля
            selected_module="$(echo "$marked_modules" | peco)"

            if [ -z "$selected_module" ]; then
                echo "Выход из скрипта."
                continue
            fi

            # Удаляем звездочку (*) из названия выбранного модуля, если она присутствует
            selected_module="${selected_module#* }"

            # Путь к файлу спецификации модуля
            #spec_file="$HOME/.config/special_file_${selected_module}.txt"

            # Ищем и удаляем битые символические ссылки в системе
            echo "Поиск и удаление битых ссылок: ЖДИТЕ"
            sudo find /usr /var /etc -xtype l ! \( -path /proc -prune -o -path /sys -prune -o -path /dev -prune \) ! -exec test -e {} \; -print0 | sudo xargs -0 -I {} -P 4 sudo rm -f {}
            echo "БИТЫЕ ССЫЛКИ УДАЛЕНЫ!"

            # Монтируем выбранный модуль в /mnt
            SOURCE_DIR="$HOME/modules/$selected_module"
            TARGET_DIR="/mnt/$(basename "$selected_module" .sb)"

            # Создаем каталог в /mnt с именем выбранного модуля
            sudo mkdir -p "$TARGET_DIR"

            # Монтируем выбранный модуль в /mnt
            sudo mount -t squashfs -o loop "$SOURCE_DIR" "$TARGET_DIR"


            # Создаём сиволические ссылки на все файлы и каталоги из модуля в файловую систему
          
            sudo cp -rsPn "$TARGET_DIR"/* /
           

            # Продолжаем с остальными действиями, такими как компиляция схем и т.д.
            sudo glib-compile-schemas /usr/share/glib-2.0/schemas/
            sudo ldconfig
            sudo rm -rf ~/.cache/menus/
            sudo update-desktop-database
            xfce4-panel -r
            echo "Модуль АКТИВИРОВАН!"
            sleep 3

            # Создаем permanent-файл, скрипт для автозагрузки и desktop-файл для выбранного модуля
            if [ "$load_option" == "Загружать модуль на постоянной основе" ]; then
                # Создаем permanent-файл
                permanent_file="$HOME/.config/${selected_module%.*}-permanent"
                echo "$TARGET_DIR" > "$permanent_file"

                # Создаем скрипт для автозагрузки
                autostart_script="$HOME/.local/bin/${selected_module%.*}-permanent.sh"
                echo "#!/bin/bash" > "$autostart_script"
                echo "sudo mount -t squashfs -o loop \"$SOURCE_DIR\" \"$TARGET_DIR\"" >> "$autostart_script"
                chmod +x "$autostart_script"

                # Создаем desktop-файл для автозагрузки
                autostart_desktop="$HOME/.config/autostart/${selected_module%.*}-permanent.desktop"
                echo "[Desktop Entry]" > "$autostart_desktop"
                echo "Type=Application" >> "$autostart_desktop"
                echo "Name=${selected_module%.*}-permanent" >> "$autostart_desktop"
                echo "Exec=$autostart_script" >> "$autostart_desktop"
                echo "X-GNOME-Autostart-enabled=true" >> "$autostart_desktop"
            fi

            # Если модуль активирован только на одну сессию, добавляем его в one_session.txt
            if [ "$load_option" == "Только на одну сессию" ]; then
                echo "${selected_module}" >> "$HOME/.config/one_session.txt"
                    # Создаем скрипт для автоматического удаления модулей, активированных только на одну сессию
one_session_script="$HOME/.config/one_session_script.sh"
echo "#!/bin/bash" > "$one_session_script"
echo "one_session_file=\$HOME/.config/one_session.txt" >> "$one_session_script"
echo "activated_modules_file=\$HOME/.config/activated_modules.txt" >> "$one_session_script"
echo "" >> "$one_session_script"
echo "mapfile -t one_session_modules < \"\$one_session_file\"" >> "$one_session_script"
echo "mapfile -t activated_modules < \"\$activated_modules_file\"" >> "$one_session_script"
echo "" >> "$one_session_script"
echo "for module in \${one_session_modules[@]}; do" >> "$one_session_script"
echo "    if [[ \" \${activated_modules[@]} \" =~ \" \$module \" ]]; then" >> "$one_session_script"
echo "        activated_modules=(\"\${activated_modules[@]/\$module}\")" >> "$one_session_script"
echo "        sed -i \"/\$module/d\" \"\$activated_modules_file\"" >> "$one_session_script"
echo "    fi" >> "$one_session_script"
echo "done" >> "$one_session_script"
echo "" >> "$one_session_script"
echo "echo \"\${activated_modules[@]}\" > \"\$activated_modules_file\"" >> "$one_session_script"
echo "rm -f \"\$one_session_file\"" >> "$one_session_script"
chmod +x "$one_session_script"

# Создаем desktop-файл для автозагрузки скрипта
one_session_desktop="$HOME/.config/autostart/one_session_script.desktop"
echo "[Desktop Entry]" > "$one_session_desktop"
echo "Type=Application" >> "$one_session_desktop"
echo "Name=One Session Script" >> "$one_session_desktop"
echo "Exec=$one_session_script" >> "$one_session_desktop"
echo "X-GNOME-Autostart-enabled=true" >> "$one_session_desktop"
            fi

            # Добавляем выбранный модуль в список активированных модулей
            activated_modules+=("$selected_module")
            echo "${selected_module}" >> "$activated_modules_file"
            ;;

        "Деактивировать")
        clear
         start_time=$(date +%s) # Записываем время начала в секундах
    # Получаем список доступных модулей и помечаем активированные модули звездочкой (*)
    available_modules="$(find ~/modules -maxdepth 1 -type f | sed 's|.*/||')"
    marked_modules="$(for module in $available_modules; do
                        if [[ " ${activated_modules[@]} " =~ " ${module} " ]]; then
                            echo "* $module"
                        else
                            echo "$module"
                        fi
                     done)"

    # Выбор модуля
    selected_module="$(echo "$marked_modules" | peco)"

    if [ -z "$selected_module" ]; then
        echo "Выход из скрипта."
        continue
    fi

    # Удаляем звездочку (*) из названия выбранного модуля, если она присутствует
    selected_module="${selected_module#* }"

    TARGET_DIR="/mnt/$(basename "$selected_module" .sb)"

    # Отмонтируем каталог
    sudo umount "$TARGET_DIR"
    sudo rm -rf "$TARGET_DIR"
    sudo rm -rf ~/.cache/menus/
    sudo update-desktop-database
    clear
    echo "Запущен процесс деактивации,ждите..."

    # Удаляем permanent-файл
    permanent_file="$HOME/.config/${selected_module%.*}-permanent"
    if [ -f "$permanent_file" ]; then
        rm -f "$permanent_file"
    fi

    # Удаляем скрипт для автозагрузки
    autostart_script="$HOME/.local/usr/bin/${selected_module%.*}-permanent.sh"
    if [ -f "$autostart_script" ]; then
        rm -f "$autostart_script"
    fi

    # Удаляем desktop-файл для автозагрузки
    autostart_desktop="$HOME/.config/autostart/${selected_module%.*}-permanent.desktop"
    if [ -f "$autostart_desktop" ]; then
        rm -f "$autostart_desktop"
    fi

    # Удаляем выбранный модуль из списка активированных модулей
    activated_modules=("${activated_modules[@]/$selected_module}")
    sed -i "/$selected_module/d" "$activated_modules_file"

    # Рекурсивно проходим по каталогу /usr и удаляем битые символические ссылки

    sudo find /usr /var /etc -xtype l ! \( -path /proc -prune -o -path /sys -prune -o -path /dev -prune \) ! -exec test -e {} \; -print0 | sudo xargs -0 -I {} -P 4 sudo rm -f {}
    end_time=$(date +%s) # Записываем время окончания в секундах
    elapsed_time=$((end_time - start_time)) # Вычисляем разницу
    echo "Модуль ДЕАКТИВИРОВАН-за: $elapsed_time секунд!"
    echo "Чтоб продолжить жмём ВВОД"
    read nex
    
   
    ;;

    esac

    echo "Готово"

done


