#!/usr/bin/wish
package require Tk
#totiks+Grok 12_03_2025
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
