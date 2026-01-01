#Requires AutoHotkey v2.0
#Include VD.ah2   ; ensure VD.ah2 and VirtualDesktopAccessor.dll are in same folder

TrayTip("VD Move", "Alt+Shift+1..9 active", 1500)

; Explicit single-line hotkeys (no braces) calling the function
+!1:: MoveToDesktop(1)
+!2:: MoveToDesktop(2)
+!3:: MoveToDesktop(3)
+!4:: MoveToDesktop(4)
+!5:: MoveToDesktop(5)
+!6:: MoveToDesktop(6)
+!7:: MoveToDesktop(7)
+!8:: MoveToDesktop(8)
+!9:: MoveToDesktop(9)

MoveToDesktop(n) {
    TrayTip("VD Move", "Moving focused window to desktop " . n, 800)

    if !IsObject(VD) {
        TrayTip("VD Move", "VD wrapper not found (VD.ah2). Check #Include path.", 2000)
        return
    }

    try {
        VD.MoveWindowToDesktopNum("A", n)
        TrayTip("VD Move", "Move command sent (desktop " . n . ")", 900)
    } catch {
        ; Generic error handling (no 'e' used) to avoid "Invalid class: e" parse issues
        TrayTip("VD Move Error", "An error occurred while moving the window.", 2500)
    }
}
