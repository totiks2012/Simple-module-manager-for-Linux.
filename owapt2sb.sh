#!/bin/bash
#set -x
#totiks+Grok 12_03_2025
sudo apt-get clean

# Путь к кэшированному файлу в текущем каталоге
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
CACHE_FILE="$SCRIPT_DIR/package_list.txt"

# Проверка существования кэшированного файла
if [ ! -f "$CACHE_FILE" ]; then
    echo "Кэшированный список пакетов не найден. Создаём новый..."
    sudo apt-cache pkgnames | sort > "$CACHE_FILE"
fi

# Выбор пакета из кэшированного файла через 2fst.tcl
package_name="$(cat "$CACHE_FILE" | ./2fst.tcl)"
if [ "$package_name" = "" ]; then
    echo "Выход из скрипта."
    exit 0
fi

# Отметка начала создания модуля
echo "START_CREATION: $package_name"

cd ~/portapps
rm -rf ./"$package_name"
app_dir=~/portapps/"$package_name"
mkdir -p "$app_dir"

url_file=$(mktemp)
sudo apt-get install --download-only --print-uris "$package_name" | grep -o 'https\?://\S*\.deb' > "$url_file"
wget -P "$app_dir" -i "$url_file"
rm "$url_file"

for deb in "$app_dir"/*.deb; do
    dpkg-deb -x "$deb" "$app_dir"
done
rm "$app_dir"/*.deb

cd "$app_dir/usr/share/"
rm -rf ./fonts ./locale ./doc ./man

cd "$HOME/portapps/"
mksquashfs ./"$package_name" ./"$package_name".sb -comp gzip -b 256K -Xcompression-level 9

echo "Портативное приложение $package_name создано в $app_dir"
