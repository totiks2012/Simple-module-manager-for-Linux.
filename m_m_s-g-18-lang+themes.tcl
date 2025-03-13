#!/usr/bin/wish
#totiks+Grok 12_03_2025
package require Tk

wm title . "Менеджер модулей"
wm geometry . "800x600"
wm attributes . -zoomed 1

proc load_config {} {
    global config
    set config_file "config.conf"
    # Значения по умолчанию
    array set config {
        font_size 16
        entry_font_size 14
        theme "dark"
        language "ru"
        bg_color "#2D1A1A"
        fg_color "#90999C"
        entry_bg_color "#776B62"
        entry_fg_color "#380D08"
        border_color "#5C7282"
        checkbox_border_color "#3A4B5A"
        highlight_color "#512D2F"
        highlight_thickness 2
        highlight_bg_color "#4C3F3F"
    }
    # Цветовые схемы для тем
    array set dark_theme {
        bg_color "#2D1A1A"
        fg_color "#90999C"
        entry_bg_color "#776B62"
        entry_fg_color "#380D08"
        border_color "#5C7282"
        checkbox_border_color "#3A4B5A"
        highlight_color "#512D2F"
        highlight_bg_color "#4C3F3F"
    }
    array set light_theme {
        bg_color "#F0F0F0"
        fg_color "#333333"
        entry_bg_color "#FFFFFF"
        entry_fg_color "#000000"
        border_color "#A0A0A0"
        checkbox_border_color "#A0A0A0"
        highlight_color "#0000FF"
        highlight_bg_color "#D0D0D0"
    }
    # Загрузка конфигурации
    if {[file exists $config_file]} {
        set file [open $config_file r]
        while {[gets $file line] != -1} {
            if {[llength $line] >= 2} {
                set key [lindex $line 0]
                set value [lindex $line 1]
                set config($key) $value
            }
        }
        close $file
    } else {
        puts "Конфигурационный файл не найден. Используются значения по умолчанию."
    }
    # Применяем тему на основе загруженного значения
    if {$config(theme) eq "light"} {
        array set config [array get light_theme]
    } else {
        array set config [array get dark_theme]
    }
}

proc save_config {} {
    global config
    set config_file "config.conf"
    if {[catch {open $config_file w} file]} {
        tk_messageBox -message "Ошибка при сохранении конфигурации: $file" -type ok -icon error
        return
    }
    set params {font_size entry_font_size theme language bg_color fg_color entry_bg_color entry_fg_color border_color checkbox_border_color highlight_color highlight_thickness highlight_bg_color}
    foreach param $params {
        if {[info exists config($param)]} {
            puts $file "$param $config($param)"
        }
    }
    close $file
}

proc apply_theme {} {
    global config
    # Определяем цветовые схемы
    array set dark_theme {
        bg_color "#2D1A1A"
        fg_color "#90999C"
        entry_bg_color "#776B62"
        entry_fg_color "#380D08"
        border_color "#5C7282"
        checkbox_border_color "#3A4B5A"
        highlight_color "#512D2F"
        highlight_bg_color "#4C3F3F"
    }
    array set light_theme {
        bg_color "#F0F0F0"
        fg_color "#333333"
        entry_bg_color "#FFFFFF"
        entry_fg_color "#000000"
        border_color "#A0A0A0"
        checkbox_border_color "#A0A0A0"
        highlight_color "#0000FF"
        highlight_bg_color "#D0D0D0"
    }
    if {$config(theme) eq "light"} {
        array set config [array get light_theme]
    } else {
        array set config [array get dark_theme]
    }
    apply_styles
}

proc apply_language {} {
    global config
    # Словари для языков
    array set lang_ru {
        title "Менеджер модулей"
        ramsize "Размер RAM-tmpfs"
        create "Создать модуль"
        create_from_dir "Создать мод.из кат."
        left_title "Доступные модули"
        right_title "Активированные модули"
        activate "Активировать"
        delete "Удалить"
        deactivate "Деактивировать"
        delete_resources "Удалить ресурсы"
        theme_label "Светлая тема"
        lang_label "Язык: Русский"
    }
    array set lang_en {
        title "Module Manager"
        ramsize "RAM-tmpfs Size"
        create "Create Module"
        create_from_dir "Create from Dir"
        left_title "Available Modules"
        right_title "Activated Modules"
        activate "Activate"
        delete "Delete"
        deactivate "Deactivate"
        delete_resources "Delete Resources"
        theme_label "Light Theme"
        lang_label "Language: English"
    }
    # Применяем язык
    if {$config(language) eq "en"} {
        array set lang [array get lang_en]
    } else {
        array set lang [array get lang_ru]
    }
    # Обновляем текст элементов интерфейса
    wm title . $lang(title)
    .top_frame.ramsize configure -text $lang(ramsize)
    .top_frame.create configure -text $lang(create)
    .top_frame.create_from_dir configure -text $lang(create_from_dir)
    .middle_frame.left.title configure -text $lang(left_title)
    .middle_frame.right.title configure -text $lang(right_title)
    .bottom_frame.activate configure -text $lang(activate)
    .bottom_frame.delete configure -text $lang(delete)
    .bottom_frame.deactivate configure -text $lang(deactivate)
    .bottom_frame.delete_resources configure -text $lang(delete_resources)
    .top_frame.theme_label configure -text $lang(theme_label)
    .top_frame.lang_label configure -text $lang(lang_label)
}

proc increase_font_size {} {
    global config
    set max_font_size 48
    if {$config(font_size) < $max_font_size} {
        incr config(font_size) 2
        incr config(entry_font_size) 2
        apply_styles
        apply_language
        save_config
    }
}

proc decrease_font_size {} {
    global config
    set min_font_size 8
    if {$config(font_size) > $min_font_size} {
        incr config(font_size) -2
        incr config(entry_font_size) -2
        apply_styles
        apply_language
        save_config
    }
}

proc apply_styles {} {
    global config
    . configure -bg $config(bg_color)
    .top_frame configure -bg $config(bg_color)
    .middle_frame configure -bg $config(bg_color)
    .bottom_frame configure -bg $config(bg_color)
    .middle_frame.left configure -bg $config(bg_color) -highlightbackground $config(border_color)
    .middle_frame.right configure -bg $config(bg_color) -highlightbackground $config(border_color)
    .top_frame.ramsize configure -bg $config(bg_color) -fg $config(fg_color) -font [list Helvetica $config(font_size)] -highlightbackground $config(border_color)
    .top_frame.create configure -bg $config(bg_color) -fg $config(fg_color) -font [list Helvetica $config(font_size)] -highlightbackground $config(border_color)
    .top_frame.create_from_dir configure -bg $config(bg_color) -fg $config(fg_color) -font [list Helvetica $config(font_size)] -highlightbackground $config(border_color)
    .middle_frame.left.title configure -bg $config(bg_color) -fg $config(fg_color) -font [list Helvetica $config(font_size)]
    .middle_frame.left.modules configure -bg $config(bg_color) -fg $config(fg_color) -font [list Helvetica $config(font_size)] -highlightbackground $config(border_color)
    .middle_frame.left.scroll configure -bg $config(bg_color) -troughcolor $config(border_color)
    .middle_frame.right.title configure -bg $config(bg_color) -fg $config(fg_color) -font [list Helvetica $config(font_size)]
    .middle_frame.right.active configure -bg $config(bg_color) -fg $config(fg_color) -font [list Helvetica $config(font_size)] -highlightbackground $config(border_color)
    .middle_frame.right.scroll configure -bg $config(bg_color) -troughcolor $config(border_color)
    .middle_frame.left.query configure -bg $config(entry_bg_color) -fg $config(entry_fg_color) -font [list Helvetica $config(entry_font_size)] -highlightbackground $config(highlight_bg_color) -highlightcolor $config(highlight_color) -highlightthickness $config(highlight_thickness) -relief flat
    .middle_frame.right.query configure -bg $config(entry_bg_color) -fg $config(entry_fg_color) -font [list Helvetica $config(entry_font_size)] -highlightbackground $config(highlight_bg_color) -highlightcolor $config(highlight_color) -highlightthickness $config(highlight_thickness) -relief flat
    .bottom_frame.activate configure -bg $config(bg_color) -fg $config(fg_color) -font [list Helvetica $config(font_size)] -highlightbackground $config(border_color)
    .bottom_frame.delete configure -bg $config(bg_color) -fg $config(fg_color) -font [list Helvetica $config(font_size)] -highlightbackground $config(border_color)
    .bottom_frame.deactivate configure -bg $config(bg_color) -fg $config(fg_color) -font [list Helvetica $config(font_size)] -highlightbackground $config(border_color)
    .bottom_frame.delete_resources configure -bg $config(bg_color) -fg $config(fg_color) -font [list Helvetica $config(font_size)] -highlightbackground $config(border_color)
    .top_frame.theme_label configure -bg $config(bg_color) -fg $config(fg_color) -font [list Helvetica $config(font_size)]
    .top_frame.lang_label configure -bg $config(bg_color) -fg $config(fg_color) -font [list Helvetica $config(font_size)]
    # Стили для чекбоксов с затемненной рамкой
    .top_frame.theme_cb configure -bg $config(bg_color) -fg $config(fg_color) -font [list Helvetica $config(font_size)] -highlightbackground $config(checkbox_border_color) -selectcolor $config(entry_bg_color)
    .top_frame.lang_cb configure -bg $config(bg_color) -fg $config(fg_color) -font [list Helvetica $config(font_size)] -highlightbackground $config(checkbox_border_color) -selectcolor $config(entry_bg_color)
}

# Добавляем чекбоксы для темы и языка
frame .top_frame -padx 5 -pady 5
frame .middle_frame -padx 5 -pady 5
frame .bottom_frame -padx 5 -pady 5

pack .top_frame -side top -fill x
pack .middle_frame -fill both -expand yes
pack .bottom_frame -side bottom -fill x

# Кнопки и чекбоксы в верхней панели
button .top_frame.ramsize -text "Размер RAM-tmpfs" -command show_ramsize_window
button .top_frame.create -text "Создать модуль" -command create_module
button .top_frame.create_from_dir -text "Создать мод.из кат." -command create_module_from_dir

# Чекбоксы для темы и языка
label .top_frame.theme_label -text "Светлая тема"
checkbutton .top_frame.theme_cb -variable ::theme_check -command {
    global config
    if {$::theme_check} {
        set config(theme) "light"
    } else {
        set config(theme) "dark"
    }
    apply_theme
    apply_language
    save_config
}
label .top_frame.lang_label -text "Язык: Русский"
checkbutton .top_frame.lang_cb -variable ::lang_check -command {
    global config
    if {$::lang_check} {
        set config(language) "en"
    } else {
        set config(language) "ru"
    }
    apply_language
    save_config
}

pack .top_frame.ramsize .top_frame.create .top_frame.create_from_dir -side left -padx 5 -pady 5
pack .top_frame.theme_label .top_frame.theme_cb .top_frame.lang_label .top_frame.lang_cb -side left -padx 5 -pady 5

frame .middle_frame.left -relief sunken -borderwidth 1
frame .middle_frame.right -relief sunken -borderwidth 1

pack .middle_frame.left -side left -fill both -expand yes -padx 5
pack .middle_frame.right -side right -fill both -expand yes -padx 5

label .middle_frame.left.title -text "Доступные модули"
entry .middle_frame.left.query -textvariable ::left_query
listbox .middle_frame.left.modules -yscrollcommand ".middle_frame.left.scroll set"
scrollbar .middle_frame.left.scroll -command ".middle_frame.left.modules yview"

pack .middle_frame.left.title -side top -pady 2
pack .middle_frame.left.query -side top -fill x -pady 2
pack .middle_frame.left.scroll -side right -fill y
pack .middle_frame.left.modules -side left -fill both -expand yes

label .middle_frame.right.title -text "Активированные модули"
entry .middle_frame.right.query -textvariable ::right_query
listbox .middle_frame.right.active -yscrollcommand ".middle_frame.right.scroll set"
scrollbar .middle_frame.right.scroll -command ".middle_frame.right.active yview"

pack .middle_frame.right.title -side top -pady 2
pack .middle_frame.right.query -side top -fill x -pady 2
pack .middle_frame.right.scroll -side right -fill y
pack .middle_frame.right.active -side left -fill both -expand yes

button .bottom_frame.activate -text "Активировать" -command activate_module
button .bottom_frame.delete -text "Удалить" -command delete_module
button .bottom_frame.deactivate -text "Деактивировать" -command deactivate_module
button .bottom_frame.delete_resources -text "Удалить ресурсы" -command delete_resources

pack .bottom_frame.activate -side left -padx 5 -pady 5
pack .bottom_frame.delete -side left -padx 5 -pady 5
pack .bottom_frame.delete_resources -side left -padx 5 -pady 5
pack .bottom_frame.deactivate -side right -padx 5 -pady 5

proc show_ramsize_window {} {
    global config
    toplevel .ramsize_win
    wm title .ramsize_win "Выбор размера tmpfs"
    wm geometry .ramsize_win "350x200"
    wm transient .ramsize_win .
    
    frame .ramsize_win.content -padx 10 -pady 10 -bg $config(bg_color)
    pack .ramsize_win.content -fill both -expand yes
    
    set ::ramsize_selection ""
    
    label .ramsize_win.content.title -text "Выберите размер tmpfs:" -bg $config(bg_color) -fg $config(fg_color) -font [list Helvetica $config(font_size)]
    pack .ramsize_win.content.title -pady 5
    
    radiobutton .ramsize_win.content.rb75 -text "75% от общего RAM" -variable ::ramsize_selection -value "75" -command apply_ramsize -bg $config(bg_color) -fg $config(fg_color) -font [list Helvetica $config(font_size)] -highlightbackground $config(border_color)
    radiobutton .ramsize_win.content.rb50 -text "50% от общего RAM" -variable ::ramsize_selection -value "50" -command apply_ramsize -bg $config(bg_color) -fg $config(fg_color) -font [list Helvetica $config(font_size)] -highlightbackground $config(border_color)
    radiobutton .ramsize_win.content.rb25 -text "25% от общего RAM" -variable ::ramsize_selection -value "25" -command apply_ramsize -bg $config(bg_color) -fg $config(fg_color) -font [list Helvetica $config(font_size)] -highlightbackground $config(border_color)
    radiobutton .ramsize_win.content.rb10 -text "10% от общего RAM" -variable ::ramsize_selection -value "10" -command apply_ramsize -bg $config(bg_color) -fg $config(fg_color) -font [list Helvetica $config(font_size)] -highlightbackground $config(border_color)
    
    pack .ramsize_win.content.rb75 .ramsize_win.content.rb50 \
         .ramsize_win.content.rb25 .ramsize_win.content.rb10 \
         -anchor w -pady 5
    
    button .ramsize_win.content.close -text "Закрыть" -command {destroy .ramsize_win} -bg $config(bg_color) -fg $config(fg_color) -font [list Helvetica $config(font_size)] -highlightbackground $config(border_color)
    pack .ramsize_win.content.close -pady 10
}

proc apply_ramsize {} {
    if {$::ramsize_selection ne ""} {
        set size_file "$::env(HOME)/.config/mod_man_conf/ramsize.conf"
        file mkdir [file dirname $size_file]
        
        set total_mem [exec free -m | grep "Mem:" | awk {{print $2}}]
        set percentage $::ramsize_selection
        set size_mb [expr {int($total_mem * $percentage / 100)}]
        
        set fp [open $size_file w]
        puts $fp "${size_mb}m"
        close $fp
        
        tk_messageBox -message "Размер tmpfs установлен: $percentage% (${size_mb} МБ)\nСохранено в $size_file" \
                     -title "Успех" -type ok
    }
}

proc create_module_from_dir {} {
    global config
    toplevel .dir_win
    wm title .dir_win "Создание модуля из каталога"
    wm geometry .dir_win "500x600"
    wm transient .dir_win .
    grab set .dir_win
    
    frame .dir_win.content -padx 10 -pady 10 -bg $config(bg_color)
    pack .dir_win.content -fill both -expand yes
    
    button .dir_win.content.create -text "Создать модуль" -command create_module_from_selected_dir -bg $config(bg_color) -fg $config(fg_color) -font [list Helvetica $config(font_size)] -highlightbackground $config(border_color)
    pack .dir_win.content.create -side top -pady 5
    
    entry .dir_win.content.query -textvariable ::dir_query -bg $config(entry_bg_color) -fg $config(entry_fg_color) -font [list Helvetica $config(entry_font_size)] -highlightbackground $config(highlight_bg_color) -highlightcolor $config(highlight_color) -highlightthickness $config(highlight_thickness) -relief flat
    pack .dir_win.content.query -side top -fill x -pady 5
    
    listbox .dir_win.content.dir_list -yscrollcommand ".dir_win.content.scroll set" -bg $config(bg_color) -fg $config(fg_color) -font [list Helvetica $config(font_size)] -highlightbackground $config(border_color)
    scrollbar .dir_win.content.scroll -command ".dir_win.content.dir_list yview" -bg $config(bg_color) -troughcolor $config(border_color)
    pack .dir_win.content.scroll -side right -fill y
    pack .dir_win.content.dir_list -side left -fill both -expand yes
    
    # Загружаем список каталогов из ~/portapps
    set ::dir_list [glob -nocomplain -directory "$::env(HOME)/portapps" -type d *]
    set ::dir_list [lsort [lmap dir $::dir_list {file tail $dir}]]
    foreach dir $::dir_list {
        .dir_win.content.dir_list insert end $dir
    }
    
    bind .dir_win.content.query <KeyRelease> {update_dir_list}
    set ::dir_query ""
}

proc update_dir_list {} {
    .dir_win.content.dir_list delete 0 end
    set query $::dir_query
    if {$query eq ""} {
        foreach dir $::dir_list {
            .dir_win.content.dir_list insert end $dir
        }
    } else {
        foreach dir $::dir_list {
            if {[string match -nocase "*$query*" $dir]} {
                .dir_win.content.dir_list insert end $dir
            }
        }
    }
}

proc create_module_from_selected_dir {} {
    set selected [.dir_win.content.dir_list curselection]
    if {$selected ne ""} {
        set dir_name [.dir_win.content.dir_list get $selected]
        set portapps_dir "$::env(HOME)/portapps"
        set modules_dir "$::env(HOME)/modules"
        
        show_progress_window "Создание модуля из каталога $dir_name"
        set cmd "mksquashfs \"$portapps_dir/$dir_name\" \"$portapps_dir/$dir_name.sb\" -comp gzip -b 256K -Xcompression-level 9"
        set pipe [open "|sh -c {$cmd}" r+]
        fconfigure $pipe -blocking 0
        fileevent $pipe readable [list handle_mksquashfs_output $pipe $dir_name]
    } else {
        tk_messageBox -message "Пожалуйста, выберите каталог для создания модуля" -type ok -icon warning
    }
}

proc handle_mksquashfs_output {pipe dir_name} {
    if {[eof $pipe]} {
        catch {close $pipe} result
        after 0 [list process_mksquashfs_result $result $dir_name]
        return
    }
    if {[gets $pipe line] >= 0} {
        puts "mksquashfs: $line"
    }
}

proc process_mksquashfs_result {result dir_name} {
    hide_progress_window
    set portapps_dir "$::env(HOME)/portapps"
    set modules_dir "$::env(HOME)/modules"
    
    if {$result ne ""} {
        tk_messageBox -message "Ошибка при создании модуля:\n$result" -type ok -icon error
        return
    }
    
    if {[file exists "$portapps_dir/$dir_name.sb"]} {
        file mkdir $modules_dir
        file rename -force "$portapps_dir/$dir_name.sb" "$modules_dir/$dir_name.sb"
        tk_messageBox -message "Модуль '$dir_name.sb' успешно создан и перемещён в ~/modules" -type ok -icon info
        load_modules
        destroy .dir_win
        grab release .dir_win
    } else {
        tk_messageBox -message "Ошибка: модуль '$dir_name.sb' не был создан" -type ok -icon error
    }
}

proc load_modules {} {
    set ::all_modules [glob -nocomplain -directory "$::env(HOME)/modules" *]
    set ::all_modules [lsort [lmap mod $::all_modules {file tail $mod}]]
    
    set activated_file "$::env(HOME)/.config/activated_modules.txt"
    set one_session_file "$::env(HOME)/.config/one_session.txt"
    set permanent_file "$::env(HOME)/.config/permanent_modules.txt"
    set session_flag "$::env(HOME)/.config/session_flag"
    
    if {![file exists $session_flag]} {
        puts "Перезагрузка: очищаем модули 'на сессию'"
        if [file exists $one_session_file] {
            file delete $one_session_file
            puts "Очищен $one_session_file"
        }
        file mkdir [file dirname $session_flag]
        exec touch $session_flag
        puts "Создан $session_flag"
        
        if [file exists $permanent_file] {
            exec cp $permanent_file $activated_file
            puts "Скопирован $permanent_file в $activated_file"
        } else {
            set fp [open $activated_file w]
            close $fp
            puts "Создан пустой $activated_file"
        }
    }
    
    set ::activated_modules {}
    if [file exists $activated_file] {
        set fp [open $activated_file r]
        set content [read $fp]
        close $fp
        set lines [split $content "\n"]
        puts "Содержимое $activated_file: $lines"
        foreach line $lines {
            if {$line ne "" && $line ni $::activated_modules} {
                lappend ::activated_modules $line
            }
        }
    } else {
        puts "Файл $activated_file не найден"
    }
    set ::activated_modules [lsort $::activated_modules]
    puts "Активированные модули в памяти: $::activated_modules"
    
    update_lists
}

proc update_lists {} {
    .middle_frame.left.modules delete 0 end
    .middle_frame.right.active delete 0 end
    
    set sorted_available {}
    foreach module $::all_modules {
        if {$module ni $::activated_modules} {
            lappend sorted_available $module
        }
    }
    set sorted_available [lsort $sorted_available]
    foreach module $sorted_available {
        .middle_frame.left.modules insert end $module
    }
    
    foreach module $::activated_modules {
        if {$module ne ""} {
            .middle_frame.right.active insert end $module
        }
    }
    puts "Обновлены списки: Доступные - $sorted_available, Активированные - $::activated_modules"
    
    fuzzy_search .middle_frame.left.modules $::left_query
    fuzzy_search .middle_frame.right.active $::right_query
}

proc fuzzy_search {listbox query} {
    set items [$listbox get 0 end]
    $listbox delete 0 end
    
    if {$query eq ""} {
        set source [expr {$listbox eq ".middle_frame.left.modules" ? $::all_modules : $::activated_modules}]
        set sorted_source [lsort $source]
        foreach item $sorted_source {
            if {$listbox eq ".middle_frame.left.modules" && $item ni $::activated_modules} {
                $listbox insert end $item
            } elseif {$listbox eq ".middle_frame.right.active" && $item in $::activated_modules && $item ne ""} {
                $listbox insert end $item
            }
        }
    } else {
        set sorted_items [lsort $items]
        foreach item $sorted_items {
            if {[string match -nocase "*$query*" $item]} {
                $listbox insert end $item
            }
        }
    }
}

proc show_progress_window {title} {
    global config
    toplevel .progress_win
    wm title .progress_win $title
    wm geometry .progress_win "800x100"
    wm transient .progress_win .
    wm protocol .progress_win WM_DELETE_WINDOW {}
    grab set .progress_win
    
    frame .progress_win.content -padx 10 -pady 10 -bg $config(bg_color)
    pack .progress_win.content -fill both -expand yes
    
    label .progress_win.content.label -text "$title, пожалуйста, подождите..." -bg $config(bg_color) -fg $config(fg_color) -font [list Helvetica $config(font_size)]
    pack .progress_win.content.label -pady 5
    
    ttk::progressbar .progress_win.content.progress -mode indeterminate -length 250
    pack .progress_win.content.progress -pady 5
    .progress_win.content.progress start
    
    update idletasks
}

proc hide_progress_window {} {
    destroy .progress_win
    grab release .progress_win
}

proc create_module {} {
    set create_script "$::env(PWD)/owapt2sb.sh"
    
    if {![file exists $create_script]} {
        tk_messageBox -message "Скрипт создания модуля $create_script не найден" -type ok -icon error
        return
    }
    
    set tcl_script "$::env(PWD)/2fst.tcl"
    if {![file exists $tcl_script]} {
        tk_messageBox -message "Скрипт $tcl_script не найден. Он необходим для выбора пакета." -type ok -icon error
        return
    }
    
    set ::create_output ""
    set pipe [open |$create_script r+]
    fconfigure $pipe -blocking 0
    fileevent $pipe readable [list handle_creation_output $pipe]
}

proc handle_creation_output {pipe} {
    if {[eof $pipe]} {
        catch {close $pipe}
        after 0 [list process_creation_result $::create_output]
        return
    }
    
    if {[gets $pipe line] >= 0} {
        append ::create_output "$line\n"
        if {[regexp {START_CREATION: (\S+)} $line -> pkg_name]} {
            set ::package_name $pkg_name
            show_progress_window "Создание модуля"
        }
    }
}

proc process_creation_result {output} {
    hide_progress_window
    
    if {[string match "Выход из скрипта.*" $output]} {
        tk_messageBox -message "Создание модуля отменено пользователем" \
                     -title "Отмена" -type ok -icon info
    } elseif {[regexp {Портативное приложение (\S+) создано в} $output -> pkg_name]} {
        set module_file "$::env(HOME)/portapps/${pkg_name}.sb"
        if {[file exists $module_file]} {
            file mkdir "$::env(HOME)/modules"
            file rename -force $module_file "$::env(HOME)/modules/${pkg_name}.sb"
            tk_messageBox -message "Модуль ${pkg_name}.sb успешно создан и перемещён в ~/modules" \
                         -title "Успех" -type ok -icon info
            load_modules
        } else {
            tk_messageBox -message "Не удалось найти созданный модуль ${pkg_name}.sb\nВывод:\n$output" \
                         -title "Ошибка" -type ok -icon error
        }
    } else {
        tk_messageBox -message "Ошибка при создании модуля:\n$output" \
                     -title "Ошибка" -type ok -icon error
    }
    set ::create_output ""
}

proc show_activation_options {module} {
    global config
    toplevel .activation_win
    wm title .activation_win "Тип активации"
    wm geometry .activation_win "500x200"
    wm transient .activation_win .
    grab set .activation_win
    
    frame .activation_win.content -padx 10 -pady 10 -bg $config(bg_color)
    pack .activation_win.content -fill both -expand yes
    
    set ::activation_type ""
    
    label .activation_win.content.title -text "Выбор типа активации для $module:" -bg $config(bg_color) -fg $config(fg_color) -font [list Helvetica $config(font_size)]
    pack .activation_win.content.title -pady 10
    
    radiobutton .activation_win.content.permanent -text "Постоянный" -variable ::activation_type -value "permanent" -bg $config(bg_color) -fg $config(fg_color) -font [list Helvetica $config(font_size)] -highlightbackground $config(border_color)
    radiobutton .activation_win.content.session -text "На сессию" -variable ::activation_type -value "session" -bg $config(bg_color) -fg $config(fg_color) -font [list Helvetica $config(font_size)] -highlightbackground $config(border_color)
    
    pack .activation_win.content.permanent .activation_win.content.session -anchor w -pady 5
    
    frame .activation_win.buttons -bg $config(bg_color)
    pack .activation_win.buttons -pady 10
    
    button .activation_win.buttons.ok -text "ОК" -command [list activate_with_type $module] -bg $config(bg_color) -fg $config(fg_color) -font [list Helvetica $config(font_size)] -highlightbackground $config(border_color)
    button .activation_win.buttons.cancel -text "Отмена" -command {destroy .activation_win; grab release .activation_win} -bg $config(bg_color) -fg $config(fg_color) -font [list Helvetica $config(font_size)] -highlightbackground $config(border_color)
    pack .activation_win.buttons.ok .activation_win.buttons.cancel -side left -padx 10
}

proc activate_with_type {module} {
    global config
    if {$::activation_type eq ""} {
        tk_messageBox -message "Пожалуйста, выберите тип активации" -type ok -icon warning
        return
    }
    
    set activate_script "$::env(PWD)/activate_module.sh"
    
    if {![file exists $activate_script]} {
        tk_messageBox -message "Скрипт активации $activate_script не найден" -type ok -icon error
        destroy .activation_win
        grab release .activation_win
        return
    }
    
    destroy .activation_win
    grab release .activation_win
    update idletasks
    
    show_progress_window "Активация модуля"
    set ::activate_output ""
    set pipe [open "|$activate_script $module $::activation_type" r+]
    fconfigure $pipe -blocking 0
    fileevent $pipe readable [list handle_activation_output $pipe $module]
}

proc handle_activation_output {pipe module} {
    if {[eof $pipe]} {
        catch {close $pipe}
        after 0 [list process_activation_result $::activate_output $module]
        return
    }
    
    if {[gets $pipe line] >= 0} {
        append ::activate_output "$line\n"
    }
}

proc process_activation_result {output module} {
    hide_progress_window
    
    if {[string match "*Ошибка*" $output]} {
        tk_messageBox -message "Ошибка активации модуля:\n$output" -type ok -icon error
    } else {
        load_modules  ;# Перечитываем список после активации
        tk_messageBox -message "Модуль $module успешно активирован" -type ok -icon info
    }
    set ::activate_output ""
}

proc activate_module {} {
    set selected [.middle_frame.left.modules curselection]
    if {$selected ne ""} {
        set module [.middle_frame.left.modules get $selected]
        show_activation_options $module
    } else {
        tk_messageBox -message "Пожалуйста, выберите модуль для активации" -type ok -icon warning
    }
}

proc deactivate_module {} {
    set selected [.middle_frame.right.active curselection]
    if {$selected ne ""} {
        set module [.middle_frame.right.active get $selected]
        set deactivate_script "$::env(PWD)/deactivate_module.sh"
        
        if {![file exists $deactivate_script]} {
            tk_messageBox -message "Скрипт деактивации $deactivate_script не найден" -type ok -icon error
            return
        }
        
        show_progress_window "Деактивация модуля"
        set ::deactivate_output ""
        set pipe [open "|$deactivate_script $module" r+]
        fconfigure $pipe -blocking 0
        fileevent $pipe readable [list handle_deactivation_output $pipe $module]
    } else {
        tk_messageBox -message "Пожалуйста, выберите модуль для деактивации" -type ok -icon warning
    }
}

proc handle_deactivation_output {pipe module} {
    if {[eof $pipe]} {
        catch {close $pipe}
        after 0 [list process_deactivation_result $::deactivate_output $module]
        return
    }
    
    if {[gets $pipe line] >= 0} {
        append ::deactivate_output "$line\n"
    }
}

proc process_deactivation_result {output module} {
    hide_progress_window
    
    if {[string match "*Ошибка*" $output]} {
        tk_messageBox -message "Ошибка деактивации модуля:\n$output" -type ok -icon error
    } else {
        set idx [lsearch -exact $::activated_modules $module]
        if {$idx >= 0} {
            set ::activated_modules [lreplace $::activated_modules $idx $idx]
            set ::activated_modules [lsort $::activated_modules]
        }
        load_modules  ;# Перечитываем список после деактивации
        tk_messageBox -message "Модуль $module успешно деактивирован" -type ok -icon info
    }
    set ::deactivate_output ""
}

proc delete_module {} {
    set selected_left [.middle_frame.left.modules curselection]
    set selected_right [.middle_frame.right.active curselection]
    set module ""
    if {$selected_left ne ""} {
        set module [.middle_frame.left.modules get $selected_left]
    } elseif {$selected_right ne ""} {
        set module [.middle_frame.right.active get $selected_right]
    } else {
        tk_messageBox -message "Пожалуйста, выберите модуль для удаления" -type ok -icon warning
        return
    }
    set response [tk_messageBox -message "Вы уверены, что хотите удалить модуль '$module'?\nЭто действие нельзя отменить." \
                                -type yesno -icon question -title "Подтверждение удаления"]
    if {$response eq "no"} {
        return
    }
    set module_name [file rootname $module]
    set modules_dir "/home/live/modules"
    set portapps_dir "/home/live/portapps"
    set module_file_modules "$modules_dir/${module}"
    set module_file_portapps "$portapps_dir/${module}"
    set module_dir_portapps "$portapps_dir/${module_name}"
    
    set idx [lsearch -exact $::activated_modules $module]
    if {$idx >= 0} {
        set ::activated_modules [lreplace $::activated_modules $idx $idx]
        set ::activated_modules [lsort $::activated_modules]
        
        set permanent_file "$::env(HOME)/.config/permanent_modules.txt"
        set one_session_file "$::env(HOME)/.config/one_session.txt"
        set activated_file "$::env(HOME)/.config/activated_modules.txt"
        
        if [file exists $permanent_file] {
            set fp [open $permanent_file r]
            set content [read $fp]
            close $fp
            set lines [split $content "\n"]
            set new_lines {}
            foreach line $lines {
                if {$line ne "" && $line ne $module} {
                    lappend new_lines $line
                }
            }
            set fp [open $permanent_file w]
            puts $fp [join $new_lines "\n"]
            close $fp
        }
        
        if [file exists $one_session_file] {
            set fp [open $one_session_file r]
            set content [read $fp]
            close $fp
            set lines [split $content "\n"]
            set new_lines {}
            foreach line $lines {
                if {$line ne "" && $line ne $module} {
                    lappend new_lines $line
                }
            }
            set fp [open $one_session_file w]
            puts $fp [join $new_lines "\n"]
            close $fp
        }
        
        if [file exists $permanent_file] {
            if [file exists $one_session_file] {
                exec cat $permanent_file $one_session_file | sort -u > $activated_file
            } else {
                exec cat $permanent_file | sort -u > $activated_file
            }
        } elseif [file exists $one_session_file] {
            exec cat $one_session_file | sort -u > $activated_file
        } else {
            set fp [open $activated_file w]
            close $fp
        }
    }
    
    set deleted 0
    if {[file exists $module_file_modules]} {
        file delete -force $module_file_modules
        incr deleted
    }
    if {[file exists $module_file_portapps]} {
        file delete -force $module_file_portapps
        incr deleted
    }
    foreach dir [glob -nocomplain -directory $modules_dir "${module_name}*"] {
        if {[file exists $dir]} {
            file delete -force $dir
            incr deleted
        }
    }
    load_modules
    update_lists
    if {$deleted > 0} {
        tk_messageBox -message "Модуль '$module' успешно удален." -type ok -icon info
    } else {
        tk_messageBox -message "Файлы или каталоги модуля '$module' не найдены в /home/live/modules/ или /home/live/portapps/." -type ok -icon warning
    }
}

proc delete_resources {} {
    set selected_left [.middle_frame.left.modules curselection]
    set selected_right [.middle_frame.right.active curselection]
    set module ""
    if {$selected_left ne ""} {
        set module [.middle_frame.left.modules get $selected_left]
    } elseif {$selected_right ne ""} {
        set module [.middle_frame.right.active get $selected_right]
    } else {
        tk_messageBox -message "Пожалуйста, выберите модуль для удаления ресурсов" -type ok -icon warning
        return
    }
    set module_name [file rootname $module]
    set portapps_dir "/home/live/portapps"
    set module_dir_portapps "$portapps_dir/${module_name}"
    set response [tk_messageBox -message "Вы уверены, что хотите удалить ресурсы модуля '$module_name' из /home/live/portapps/?\nЭто действие нельзя отменить." \
                                -type yesno -icon question -title "Подтверждение удаления ресурсов"]
    if {$response eq "no"} {
        return
    }
    if {[file exists $module_dir_portapps] && [file isdirectory $module_dir_portapps]} {
        file delete -force $module_dir_portapps
        tk_messageBox -message "Ресурсы модуля '$module_name' успешно удалены из /home/live/portapps/." -type ok -icon info
    } else {
        tk_messageBox -message "Каталог ресурсов '$module_name' не найден в /home/live/portapps/." -type ok -icon warning
    }
}

bind . <Control-equal> {increase_font_size}
bind . <Control-minus> {decrease_font_size}

set ::left_query ""
set ::right_query ""

bind .middle_frame.left.query <KeyRelease> {update_lists}
bind .middle_frame.right.query <KeyRelease> {update_lists}

# Сначала загружаем конфигурацию
load_config

# Теперь инициализируем переменные для чекбоксов
set ::theme_check 0
set ::lang_check 0
if {$::config(theme) eq "light"} {set ::theme_check 1}
if {$::config(language) eq "en"} {set ::lang_check 1}

# Применяем стили и язык после инициализации
apply_styles
apply_language
load_modules
