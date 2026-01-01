#Requires AutoHotkey v2.0

; Notify script loaded
TrayTip("WindowCtrl", "Alt+M Minimize | Alt+C Close | Alt+Z Toggle Maximize", 1800)

; Alt+M -> minimize active window
!m:: {
    if !WinExist("A") {
        TrayTip("WindowCtrl", "No active window found", 1000)
        return
    }
    WinMinimize("A")
}

; Alt+C -> close active window
!c:: {
    if !WinExist("A") {
        TrayTip("WindowCtrl", "No active window found", 1000)
        return
    }
    WinClose("A")
}

; Alt+Z -> toggle maximize / restore
!z:: {
    if !WinExist("A") {
        TrayTip("WindowCtrl", "No active window found", 1000)
        return
    }
    state := WinGetMinMax("A")  ; -1 = minimized, 0 = normal, 1 = maximized
    if (state = 1) {
        ; if maximized -> restore
        WinRestore("A")
    } else if (state = -1) {
        ; if minimized -> restore then maximize
        WinRestore("A")
        Sleep 80
        WinMaximize("A")
    } else {
        ; normal -> maximize
        WinMaximize("A")
    }
}
