upd:13-03-25
------------
en
------------
The script has been heavily reworked. Now it is a full-fledged GUI tool, on tcl/tk, which covers all aspects from creating modules from apt or a directory to connecting them. Below is a description and instructions for the updated project.


# Script Update

The script has been heavily reworked. Now it is a full-fledged GUI tool on Tcl/Tk, which covers all aspects from creating modules from APT or a directory to connecting them. Below is a description and instructions for the updated project.

## Readme-last

### "Module Manager"

"Module Manager" is a tool with a graphical interface (GUI) in Tcl/Tk for managing portable modules in Linux. It allows you to create, activate, deactivate, and remove modules — compressed SquashFS images that are mounted, copied to tmpfs, and connected via symlinks. A project for comprehensive work with isolated applications, combining all functions in one convenient interface.

- **Modules**: Created from APT packages or directories.
- **Localization**: Supports Russian/English.
- **Themes**: Dark/light themes.
- **Optimization**: tmpfs configuration for optimizing RAM.

### Main Features

- **Graphical Interface**: Controlled via Tk.
- **Creating Modules**: From APT or directories.
- **Symlinks and tmpfs**: Easy connection and high speed.
- **Fuzzy Finder**: Fuzzy package search.
- **Customization**: Themes, languages, font adjustments (Ctrl+= / Ctrl+-).
- **All in One**: Single tool for all tasks.

### Comparison with Other Technologies

#### What’s Better About AUFS and OverlayFS?

- **Modernity**: AUFS is outdated, enabled from the kernel, nested in configuration. Module Manager uses SquashFS.
- **Management**: OverlayFS is difficult for layer control; Module Manager uses symlinks and tmpfs.
- **Isolation**: Autonomous modules without interference.
- **Performance**: tmpfs can degrade performance.
- **Simplicity**: Everything is controlled via GUI.

#### How It Works

Modules are mounted as SquashFS in `/mnt/<module_name>`, copied to tmpfs (e.g., `/tmp/<module_name>`), and then symlinked to system directories (e.g., `/usr/bin`). This ensures tight control and speed.

#### Compared to AppImage

- **Similarities**: Both support portable applications.
- **Differences**: AppImage is a single file, while Module Manager uses SquashFS with tmpfs and GUI management. Creation from APT/directories instead of assembly.

### Advantages

- **Convenience**: Intuitive interface.
- **Flexibility**: Creation and activation via GUI.
- **Speed**: Utilizes tmpfs.
- **Simplicity**: Symlinks instead of layers.
- **All in One**: Single tool for all operations.

### Disadvantages

- **Dependencies**: Requires Tcl/Tk, mksquashfs, etc.
- **Complexity**: Setup can be tricky for beginners.
- **Linux-Specific**: Relies on SquashFS/tmpfs.

## Dependencies

- **Tcl/Tk**: For the GUI.
  ```bash
  sudo apt install tcl tk

squashfs-tools: For SquashFS.
bash

sudo apt install squashfs-tools

wget: For downloading .deb files.
bash

sudo apt install wget

dpkg: For unpacking .deb files.
bash

sudo apt install dpkg

bash: For scripts.

fd-find (optional): For searching.

Installation
Download the archive mod_man-sprites_G-18_themes+lang.tar and unpack it to a directory of your choice.
Usage
Launch
Launch via a single script:
bash

./LAUNCH.sh

This script will:
Prepare the system (create directories, cache packages, remove broken links).

Open the GUI.

Working in the Graphical Interface
All actions are performed through the interface:
Create a Module: From APT or a directory.

Activate: Permanently or per session.

Deactivate: Disable a module.

Delete: Remove modules or resources.

Settings: Theme, language, tmpfs configuration.

Internal Scripts (Used by the GUI)
owapt2sb.sh: Creates a module based on APT.

active_module.sh: Mounts the module in tmpfs and connects it with symlinks.

deactivate_module.sh: Disables the module and removes the symlink.

2fst.tcl: Fuzzy search for selecting a package.

Project Structure
LAUNCH.sh: Launches the program.

m_m_s-g-18-lang+themes.tcl: Main graphical interface.

owapt2sb.sh: Creates modules.

active_module.sh: Handles activation.

deactivate_module.sh: Handles deactivation.

2fst.tcl: Fuzzy finder implementation.

Examples
Launch
bash

./LAUNCH.sh

In the graphical interface, select "Create module", then use the fuzzy finder to search for "firefox" → select firefox from the list, press Enter, and firefox.sb will be created. Activate the module using the "Activate" button → it will be connected via tmpfs and symlinks.



upd:13-03-25
-----------
rus
-----------
Скрипт был сильно переделан. Теперь это полноценый GUI инструмент, на tcl/tk  который охватывает все аспекты от создания модулей из apt или каталога,до их подключения. Ниже описание и инструкции обновленого проекта.

# Readme-latest

## "Module Manager"

"Module Manager" — это инструмент с графическим интерфейсом (GUI) на Tcl/Tk для управления портативными модулями в Linux. Он позволяет создавать, активировать, деактивировать и удалять модули — сжатые SquashFS-образы, которые монтируются, копируются в tmpfs и подключаются через симлинки. Проект упрощает работу с изолированными приложениями, объединяя все функции в одном удобном интерфейсе.

Модули создаются из пакетов APT или каталогов, поддерживаются русский/английский языки, тёмная/светлая темы и настройка tmpfs для оптимизации RAM.

### Основные особенности

- **Графический интерфейс**: Управление через Tk.
- **Создание модулей**: Из APT или каталогов.
- **Симлинки и tmpfs**: Простое подключение и высокая скорость.
- **Fuzzy Finder**: Нечёткий поиск пакетов.
- **Кастомизация**: Темы, языки, шрифт (Ctrl+= / Ctrl+-).
- **Всё в одном**: Единый инструмент.

### Сравнение с другими технологиями

#### Чем лучше AUFS и OverlayFS?

- **Современность**: AUFS устарел, исключён из ядра, сложен в настройке. Module Manager использует SquashFS.
- **Управление**: OverlayFS сложен для контроля слоёв, Module Manager использует симлинки и tmpfs.
- **Изоляция**: Автономные модули без конфликтов.
- **Производительность**: tmpfs ускоряет работу.
- **Простота**: Всё управляется из GUI.

#### Как это работает

Модули монтируются как SquashFS в `/mnt/<module_name>`, копируются в tmpfs (например, `/tmp/<module_name>`), а затем подключаются симлинками в системные директории (например, `/usr/bin`). Это упрощает управление и повышает скорость.

#### Сравнение с AppImage

- **Сходства**: Портативные приложения.
- **Отличия**: AppImage — единый файл, Module Manager — SquashFS с tmpfs и GUI-управлением. Создание из APT/каталогов вместо сборки.

### Преимущества

- **Удобство**: Интуитивный интерфейс.
- **Гибкость**: Создание и активация из GUI.
- **Скорость**: Использование tmpfs.
- **Простота**: Симлинки вместо слоёв.
- **Всё в одном**: Единый инструмент.

### Недостатки

- **Зависимости**: Требуются Tcl/Tk, mksquashfs и др.
- **Сложность**: Настройка для новичков.
- **Linux-специфичность**: Зависит от SquashFS/tmpfs.

## Зависимости

- **Tcl/Tk**: Для GUI.
  ```bash
  sudo apt install tcl tk

squashfs-tools: Для SquashFS.
bash

sudo apt install squashfs-tools

wget: Для скачивания .deb.
bash

sudo apt install wget

dpkg: Для распаковки .deb.
bash

sudo apt install dpkg

bash: Для скриптов.

fd-find (опционально): Для поиска.

Установка
Скачайте архив mod_man-sprites_G-18_themes+lang.tar и распакуйте в удобный вам каталог.
Использование
Запуск
Запустите через единый скрипт:
bash

./LAUNCH.sh

Скрипт выполнит следующие действия:
Подготовит систему (создаёт каталоги, кэширует пакеты, удаляет битые ссылки).

Откроет GUI.

Работа в GUI
Все действия выполняются через интерфейс:
Создать модуль: Из APT или каталога.

Активировать: Постоянно или на сессию.

Деактивировать: Отключение модуля.

Удалить: Модули или ресурсы.

Настройки: Тема, язык, tmpfs.

Внутренние скрипты (запускаются из GUI)
owapt2sb.sh: Создаёт модуль из APT.

activate_module.sh: Монтирует модуль в tmpfs и подключает симлинками.

deactivate_module.sh: Отключает модуль, удаляя симлинки.

2fst.tcl: Нечёткий поиск для выбора пакетов.

Структура проекта
LAUNCH.sh: Запуск программы.

m_m_s-g-18-lang+themes.tcl: Основной GUI.

owapt2sb.sh: Создание модулей.

activate_module.sh: Активация.

deactivate_module.sh: Деактивация.

2fst.tcl: Fuzzy finder.

Примеры
Запуск
bash

./LAUNCH.sh

В GUI выберите "Создать модуль", затем "firefox" через fuzzy finder → выберите firefox в списке вывода, нажмите Enter, создаётся firefox.sb. Активируйте модуль через кнопку "Активировать" → он подключится через tmpfs и симлинки.


--------------------------------------------------------------
12-13_03_2025 totiks

This script is licensed under the GPL3 License. See the LICENSE file for details.
