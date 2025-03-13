upd:13-03-25
------------
en
------------
The script has been heavily reworked. Now it is a full-fledged GUI tool, on tcl/tk, which covers all aspects from creating modules from apt or a directory to connecting them. Below is a description and instructions for the updated project.


Readmy-last
"Module Manager" is a tool with a graphical interface (GUI) in Tcl/Tk for managing portable modules in Linux. It allows you to create, activate, deactivate and remove modules - compressed SquashFS images that are mounted, copied to tmpfs and connected via symlinks. A project for comprehensive work with isolated applications, combining all functions in one convenient interface.
Modules for connecting from the APT package or directories, used in Russian/English, dark/light themes and tmpfs configuration for optimizing RAM.
Main features
Graphical interface: Control via Tk.
**
Creating modules: From APT or directories.
Symlinks and tmpfs: Easy to connect and fast.
Fuzzy Finder: Fuzzy package search.
Customization: Themes, languages, font (Ctrl+= / Ctrl+-).
All in one: Single tool.
Comparison with other technologies
What is better about AUFS and OverlayFS?
Modernity: AUFS is outdated, enabled from the kernel, nested in the configuration. The module manager uses SquashFS.
Management: OverlayFS is difficult to control layers, the module manager uses symlinks and tmpfs.
Isolation: Autonomous modules without interference.
Performance: tmpfs degrades performance.
Simple: Everything is controlled from the GUI.
How it works: Modules are mounted as SquashFS in /mnt/<module_name>, copied to tmpfs (e.g. /tmp/<module_name>), and then symlinked to system directories (e.g. /usr/bin). This is tight control and speed.
Compared to AppImage
Similarities: Portable applications.
Differences: AppImage is a single file, the module manager is SquashFS with tmpfs and GUI management. Creation from APT/directories instead of assembly.

Advantages
Convenience: Intuitive interface.
Flexibility: Creation and activation from GUI.
Speed: Uses tmpfs.
Simplicity: Symlinks instead of layers.
All in one: Single tool.
obtained
Dependencies: Requires Tcl/Tk, mksquashfs, etc.
Complexity: Setup for beginners.
Linux-specific: Depends on SquashFS/tmpfs.
Dependency
Tcl/Tk: For the GUI.
sudo apt install tcl tk
sqashfs-tools: For SquashFS.
sudo apt install squshfs-tools
wget: For downloading .deb.
sudo apt install wget
dpkg: For unpacking .deb.
sudo apt install dpkg
bash: For scripts.
fd-find (optional): For searching.
Installation: download the archive mod_man-sprites_G-18_themes+lang.tar and unpack it to a directory of your choice

Usage
Launch
Launch via a single script:
./LAUNCH.sh
Prepares the system (creates directories, caches packages, removes broken links).
Opens the GUI.
Working in the graphical interface
All actions are performed through the interface:
Create a module: From APT or a directory.
Activate: Permanently or per session.
Deactivate: Disable a module.
Delete: Modules or resources.
Settings: Theme, language, tmpfs.
Internal scripts (due to the GUI):
owapt2sb.sh: Creates a module based on APT.
active_module.sh: Mounts the module in tmpfs and connects it with symlinks.
deactivate_module.sh: Disables the module, removes the symlink.
2fst.tcl: Fuzzy search for selecting a package.
Project structure
LAUNCH.sh: Launch the program.
m_m_s-g-18-lang+themes.tcl: Main graphical interface.
owapt2sb.sh: Create modules.
active_module.sh: Activation.
deactivate_module.sh: Deactivation.
2fst.tcl: Fuzzy finder.
Examples
Launch:
beat

./LAUNCH.sh
In the graphical interface, select "Create module", then through the fuzzy finder "firefox" → select firefox in the output list, press enter, firefox.sb is created.
Activate the module using the Activate button → it is connected via tmpfs and symlinks.

upd:13-03-25
-----------
rus
-----------
Скрипт был сильно переделан. Теперь это полноценый GUI инструмент, на tcl/tk  который охватывает все аспекты от создания модулей из apt или каталога,до их подключения. Ниже описание и инструкции обновленого проекта.

Readmy-latest
--
"Module Manager" — это инструмент с графическим интерфейсом (GUI) на Tcl/Tk для управления портативными модулями в Linux. Он позволяет создавать, активировать, деактивировать и удалять модули — сжатые SquashFS-образы, которые монтируются, копируются в tmpfs и подключаются через симлинки. Проект упрощает работу с изолированными приложениями, объединяя все функции в одном удобном интерфейсе.
Модули создаются из пакетов APT или каталогов, поддерживаются русский/английский языки, тёмная/светлая темы и настройка tmpfs для оптимизации RAM.
Основные особенности
---
Графический интерфейс: Управление через Tk.
--
Создание модулей: Из APT или каталогов.
--
Симлинки и tmpfs: Простое подключение и высокая скорость.
--
Fuzzy Finder: Нечёткий поиск пакетов.
--
Кастомизация: Темы, языки, шрифт (Ctrl+= / Ctrl+-).
--
Всё в одном: Единый инструмент.
--
Сравнение с другими технологиями
Чем лучше AUFS и OverlayFS?
Современность: AUFS устарел, исключён из ядра, сложен в настройке. Module Manager использует SquashFS.
--
Управление: OverlayFS сложен для контроля слоёв, Module Manager использует симлинки и tmpfs.
--
Изоляция: Автономные модули без конфликтов.
--
Производительность: tmpfs ускоряет работу.
--
Простота: Всё управляется из GUI.
--
Как это работает: Модули монтируются как SquashFS в /mnt/<module_name>, копируются в tmpfs (например, /tmp/<module_name>), а затем подключаются симлинками в системные директории (например, /usr/bin). Это упрощает управление и повышает скорость.
Сравнение с AppImage
--
Сходства: Портативные приложения.
--
Отличия: AppImage — единый файл, Module Manager — SquashFS с tmpfs и GUI-управлением. Создание из APT/каталогов вместо сборки.
--
Преимущества
--
Удобство: Интуитивный интерфейс.
--
Гибкость: Создание и активация из GUI.
--
Скорость: Использование tmpfs.
--
Простота: Симлинки вместо слоёв.
--
Всё в одном: Единый инструмент.
--
Недостатки
Зависимости: Требуются Tcl/Tk, mksquashfs и др.
--
Сложность: Настройка для новичков.
--
Linux-специфичность: Зависит от SquashFS/tmpfs.
--
Зависимости
Tcl/Tk: Для GUI.
sudo apt install tcl tk
squashfs-tools: Для SquashFS.
sudo apt install squashfs-tools
wget: Для скачивания .deb.
sudo apt install wget
dpkg: Для распаковки .deb.
sudo apt install dpkg
bash: Для скриптов.
fd-find (опционально): Для поиска.
--
Установка : Скачайте архив mod_man-sprites_G-18_themes+lang.tar распакуйте в удобный вам каталог 
--
Использование
Запуск
Запустите через единый скрипт:
./LAUNCH.sh
Подготавливает систему (создаёт каталоги, кэширует пакеты, удаляет битые ссылки).
Открывает GUI.
Работа в GUI
Все действия выполняются через интерфейс:
Создать модуль: Из APT или каталога.
Активировать: Постоянно или на сессию.
Деактивировать: Отключение модуля.
Удалить: Модули или ресурсы.
Настройки: Тема, язык, tmpfs.
Внутренние скрипты (запускаются из GUI):
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
Запуск:
bash

./LAUNCH.sh
В GUI выберите "Создать модуль", затем "firefox" через fuzzy finder → выбираем в ссписке вывода  firefox жмем ввод создаётся firefox.sb.
Активируйте модуль через кнопку Активировать → он подключится через tmpfs и симлинки.

--------------------------------------------------------------
12-13_03_2025 totiks

This script is licensed under the GPL3 License. See the LICENSE file for details.
