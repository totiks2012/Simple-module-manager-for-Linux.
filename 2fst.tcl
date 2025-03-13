#!/usr/bin/env wish
#totiks+Grok 12_03_2025
package require Tk

proc load_config {} {
    global config
    set config_file "config.conf"
    array set config {
        font_size 10
        entry_font_size 16
        bg_color "#3F2F2F"
        fg_color "#577079"
        entry_bg_color "#F0CEB2"
        entry_fg_color "#380D08"
        border_color "#193B54"
        highlight_color "#0000ff"
        highlight_thickness 2
        highlight_bg_color "#192CCD"
    }
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
}

proc save_config {} {
    global config
    set config_file "config.conf"
    if {[catch {open $config_file w} file]} {
        puts "Ошибка при открытии файла конфигурации для записи: $file"
        return
    }
    set params {
        font_size
        entry_font_size
        bg_color
        fg_color
        entry_bg_color
        entry_fg_color
        border_color
        highlight_color
        highlight_thickness
        highlight_bg_color
    }
    foreach param $params {
        if {[info exists config($param)]} {
            puts $file "$param $config($param)"
        }
    }
    close $file
}

# Улучшенная функция нечёткого поиска с оценкой релевантности
proc fuzzy_match {query item} {
    set query [string tolower $query]
    set item [string tolower $item]

    # Если запрос пустой, возвращаем минимальный вес
    if {$query eq ""} {
        return [list 1 0]
    }

    set pos 0
    set score 0
    set matched_chars 0
    set query_chars [split $query ""]

    # Проверяем совпадение символов по порядку
    foreach char $query_chars {
        set idx [string first $char $item $pos]
        if {$idx == -1} {
            return [list 0 0] ;# Нет совпадения
        }
        incr matched_chars
        # Добавляем вес: чем раньше найдено совпадение, тем выше балл
        set score [expr {$score + (100 - $idx)}]
        set pos [expr {$idx + 1}]
    }

    # Дополнительный бонус за совпадение в начале строки
    if {[string first $query $item] == 0} {
        set score [expr {$score + 1000}]
    }

    # Возвращаем флаг совпадения и оценку
    return [list 1 $score]
}

# Обновление списка с сортировкой по релевантности
proc update_list {} {
    global query items filtered_items mainWindow config
    set query [$mainWindow.query_frame.query get]
    set scored_items {}

    # Собираем элементы с оценками
    foreach item $items {
        set match_result [fuzzy_match $query $item]
        set matched [lindex $match_result 0]
        set score [lindex $match_result 1]
        if {$matched} {
            lappend scored_items [list $item $score]
        }
    }

    # Сортируем по убыванию оценки
    set scored_items [lsort -index 1 -integer -decreasing $scored_items]
    set filtered_items [lmap pair $scored_items {lindex $pair 0}]

    # Обновляем listbox
    $mainWindow.listbox delete 0 end
    foreach item $filtered_items {
        $mainWindow.listbox insert end $item
    }
    # Автоматически выделяем первый элемент
    if {[llength $filtered_items] > 0} {
        $mainWindow.listbox selection set 0
        $mainWindow.listbox activate 0
        $mainWindow.listbox see 0
    }
}

proc open_selected_item {} {
    global mainWindow
    set selection [$mainWindow.listbox curselection]
    if {[llength $selection] == 0} {
        return
    }
    set index [lindex $selection 0]
    set selected_item [$mainWindow.listbox get $index]
    puts $selected_item
    exit
}

proc increase_font_size {} {
    global mainWindow config
    set max_font_size 48
    if {$config(font_size) < $max_font_size} {
        incr config(font_size) 2
        incr config(entry_font_size) 2
        $mainWindow.listbox configure -font [list Helvetica $config(font_size)]
        $mainWindow.query_frame.query configure -font [list Helvetica $config(entry_font_size)]
        save_config
    }
}

proc decrease_font_size {} {
    global mainWindow config
    set min_font_size 8
    if {$config(font_size) > $min_font_size} {
        incr config(font_size) -2
        incr config(entry_font_size) -2
        $mainWindow.listbox configure -font [list Helvetica $config(font_size)]
        $mainWindow.query_frame.query configure -font [list Helvetica $config(entry_font_size)]
        save_config
    }
}

proc move_cursor_up {} {
    global mainWindow
    focus $mainWindow.listbox
    set current_selection [$mainWindow.listbox curselection]
    if {[llength $current_selection] == 0} {
        $mainWindow.listbox selection set 0
    } else {
        set current_index [lindex $current_selection 0]
        if {$current_index > 0} {
            $mainWindow.listbox selection clear $current_index
            $mainWindow.listbox selection set [expr {$current_index - 1}]
            $mainWindow.listbox activate [expr {$current_index - 1}]
            $mainWindow.listbox see [expr {$current_index - 1}]
        }
    }
}

proc move_cursor_down {} {
    global mainWindow
    focus $mainWindow.listbox
    set current_selection [$mainWindow.listbox curselection]
    if {[llength $current_selection] == 0} {
        $mainWindow.listbox selection set 0
    } else {
        set current_index [lindex $current_selection 0]
        if {$current_index < [$mainWindow.listbox index end] - 1} {
            $mainWindow.listbox selection clear $current_index
            $mainWindow.listbox selection set [expr {$current_index + 1}]
            $mainWindow.listbox activate [expr {$current_index + 1}]
            $mainWindow.listbox see [expr {$current_index + 1}]
        }
    }
}

set target_directory ""
load_config
set mainWindow [toplevel ".main"]
wm withdraw .
wm title $mainWindow "Fuzzy File Search"
wm state $mainWindow normal

set width 800
set height 600
set screenwidth [winfo screenwidth .]
set screenheight [winfo screenheight .]
set x [expr {($screenwidth - $width) / 2}]
set y [expr {($screenheight - $height) / 2}]
wm geometry $mainWindow ${width}x${height}+${x}+${y}

set items [split [read stdin] "\n"]
set items [lsearch -all -inline -not -exact $items ""]

frame $mainWindow.query_frame -bg $config(entry_bg_color)
pack $mainWindow.query_frame -side top -fill x -pady 5

entry $mainWindow.query_frame.query -textvariable query -width 50 -bg $config(entry_bg_color) -fg $config(entry_fg_color) -highlightbackground $config(entry_bg_color) -highlightcolor $config(highlight_color) -highlightthickness $config(highlight_thickness) -font [list Helvetica $config(entry_font_size)] -relief flat -bd 0
pack $mainWindow.query_frame.query -fill x -expand true

listbox $mainWindow.listbox -height 30 -width 150 -selectmode single -font [list Helvetica $config(font_size)] -bg $config(bg_color) -fg $config(fg_color) -highlightbackground $config(border_color)
pack $mainWindow.listbox -fill both -expand true

focus $mainWindow.listbox

set query ""
set filtered_items $items
foreach item $filtered_items {
    $mainWindow.listbox insert end $item
}
bind $mainWindow.query_frame.query <KeyRelease> {update_list}
bind $mainWindow.listbox <Return> {open_selected_item}
bind $mainWindow.listbox <Double-Button-1> {open_selected_item}
bind $mainWindow <Control-equal> {increase_font_size}
bind $mainWindow <Control-minus> {decrease_font_size}
bind $mainWindow <Up> {move_cursor_up}
bind $mainWindow <Down> {
    move_cursor_down
    focus $mainWindow.listbox
}

wm protocol $mainWindow WM_DELETE_WINDOW {exit}
tkwait window $mainWindow
