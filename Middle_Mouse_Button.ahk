; middlebutton.ahk
; AutoHotkey v2
#Requires AutoHotkey v2.0
#Include VD.ah2

; Remembered desktop index (set only when we switch to N via middle button)
prevDesktop := ""

; --- Helper wrappers (try multiple casing / function names used by different VD versions) ---
GetCurrentDesktopNum() {
    try {
        return VD.getCurrentDesktopNum()
    } catch {
        try {
            return VD.GetCurrentDesktopNum()
        } catch {
            throw "Cannot get current desktop number"
        }
    }
}

GetTotalDesktopCount() {
    try {
        return VD.getCount()
    } catch {
        try {
            return VD.GetCount()
        } catch {
            throw "Cannot get total desktop count"
        }
    }
}

GoToDesktopNum(target) {
    switched := false
    try {
        VD.GoToDesktopNum(target)
        switched := true
    } catch {
    }
    if !switched {
        try {
            VD.goToDesktopNum(target)
            switched := true
        } catch {
        }
    }
    return switched
}

; --- Middle button behaviour ---
; If on desktops 1..N-1 => goto N and remember current
; If on N => return to remembered desktop (if valid), else stay on N
MButton:: {
    global prevDesktop

    ; get current desktop and total count (best-effort)
    try {
        cur := GetCurrentDesktopNum()
    } catch {
        TrayTip("MiddleButton", "Cannot determine current desktop.", 1200)
        return
    }

    try {
        total := GetTotalDesktopCount()
    } catch {
        TrayTip("MiddleButton", "Cannot determine total desktop count.", 1200)
        return
    }

    ; target desktop N is the last desktop (total)
    targetN := total

    ; If we're not on N (i.e., cur in 1..N-1), go to N and remember cur
    if (cur < targetN) {
        if GoToDesktopNum(targetN) {
            ; Save the desktop we came from so we can toggle back later
            prevDesktop := cur
            TrayTip("MiddleButton", "Switched to desktop " . targetN . " (remembered " . cur . ")", 700)
        } else {
            TrayTip("MiddleButton", "Failed to switch to desktop " . targetN, 1200)
        }
        return
    }

    ; If we are on N, attempt to return to prevDesktop (if valid)
    if (cur = targetN) {
        ; validate prevDesktop: not empty, integer, within current range, and not equal to current
        if (prevDesktop != "" && prevDesktop >= 1 && prevDesktop <= total && prevDesktop != cur) {
            if GoToDesktopNum(prevDesktop) {
                TrayTip("MiddleButton", "Returned to desktop " . prevDesktop, 700)
                ; Clear remembered desktop after returning
                prevDesktop := ""
            } else {
                TrayTip("MiddleButton", "Failed to return to desktop " . prevDesktop, 1200)
                ; clear it on failure
                prevDesktop := ""
            }
        } else {
            ; No valid previous desktop to return to — stay on N
            TrayTip("MiddleButton", "No previous desktop remembered (staying on " . targetN . ")", 700)
            if (prevDesktop != "" && (prevDesktop < 1 || prevDesktop > total || prevDesktop = cur))
                prevDesktop := ""
        }
        return
    }

    ; Fallback (shouldn't get here)
    TrayTip("MiddleButton", "Unexpected desktop state.", 700)
}
