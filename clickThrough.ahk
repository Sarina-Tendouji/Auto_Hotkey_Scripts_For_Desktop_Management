#Requires AutoHotkey v2.0
; clickthrough_safe_exit.ahk (Desktop-Aware - Fixed)
; Alt+X : toggle transparency + click-through for active window
; Alt+D : restore windows on CURRENT desktop only
; Ctrl+Alt+Q : restore ALL windows across all desktops then exit
; Alt+Shift+D : DEBUG - show all tracked windows and their desktops
#Include VD.ah2

DEFAULT_OPACITY := 180            ; 0 (invisible) .. 255 (opaque)
origEx := Map()                   ; map: key = hwnd string, value = saved exstyle

; ---------------- VD Helpers ----------------------------------------------
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

GetDesktopNumOfWindow(hwnd) {
    ; Try multiple function name variations
    try {
        return VD.getDesktopNumOfWindow(hwnd)
    } catch {
        try {
            return VD.GetDesktopNumOfWindow(hwnd)
        } catch {
            try {
                return VD.GetDesktopNumberOfWindow(hwnd)
            } catch {
                return -1  ; unknown/error
            }
        }
    }
}

; ---------------- Window Helpers ------------------------------------------
GetExStyle(hwnd) {
    GWL_EXSTYLE := -20
    if (A_PtrSize = 8)
        return DllCall("GetWindowLongPtr", "Ptr", hwnd, "Int", GWL_EXSTYLE, "Ptr")
    return DllCall("GetWindowLong", "Int", hwnd, "Int", GWL_EXSTYLE)
}

SetExStyle(hwnd, newStyle) {
    GWL_EXSTYLE := -20
    if (A_PtrSize = 8)
        DllCall("SetWindowLongPtr", "Ptr", hwnd, "Int", GWL_EXSTYLE, "Ptr", newStyle)
    else
        DllCall("SetWindowLong", "Int", hwnd, "Int", GWL_EXSTYLE, "Int", newStyle)
}

SetAlpha(hwnd, opacity) {
    ; LWA_ALPHA = 0x02
    return DllCall("SetLayeredWindowAttributes", "Ptr", hwnd, "UInt", 0, "UChar", opacity, "UInt", 0x02)
}

ShowToast(text, ms := 900) {
    ToolTip(text)
    SetTimer(() => ToolTip(""), -ms)
}

GetWindowTitle(hwnd) {
    try {
        return WinGetTitle("ahk_id " hwnd)
    } catch {
        return "(unknown)"
    }
}

; Check if window truly exists (not just on current desktop)
WindowExists(hwnd) {
    ; Use DllCall to check if window handle is valid
    ; IsWindow returns true even for windows on other desktops
    return DllCall("IsWindow", "Ptr", hwnd)
}

; ---------------- Restore Functions ---------------------------------------
; Restore windows on CURRENT desktop only
RestoreCurrentDesktop() {
    global origEx
    if (!IsObject(origEx) || origEx.Count = 0)
        return 0
    
    try {
        curDesktop := GetCurrentDesktopNum()
    } catch {
        ShowToast("Cannot determine current desktop.", 1200)
        return 0
    }
    
    keys := []
    for k, v in origEx
        keys.Push(k)
    
    restored := 0
    
    for idx, k in keys {
        hwnd := k + 0
        saved := origEx.Get(k)
        
        ; Check if window truly exists (across all desktops)
        if (!WindowExists(hwnd)) {
            ; Window genuinely closed, remove from map
            origEx.Delete(k)
            continue
        }
        
        ; Get window's desktop
        winDesktop := GetDesktopNumOfWindow(hwnd)
        
        ; Only restore if on current desktop
        if (winDesktop = curDesktop) {
            try SetAlpha(hwnd, 255)
            try SetExStyle(hwnd, saved)
            origEx.Delete(k)
            restored++
        }
        ; If winDesktop = -1 (unknown), leave in map and don't restore
        ; If on different desktop, leave in map for later
    }
    
    return restored
}

; Restore ALL windows across all desktops (for safe exit)
RestoreAllDesktops() {
    global origEx
    if (!IsObject(origEx))
        return 0
    
    keys := []
    for k, v in origEx
        keys.Push(k)
    
    restored := 0
    for idx, k in keys {
        hwnd := k + 0
        saved := origEx.Get(k)
        
        ; Check if window truly exists
        if (WindowExists(hwnd)) {
            try SetAlpha(hwnd, 255)
            try SetExStyle(hwnd, saved)
            restored++
        }
        origEx.Delete(k)
    }
    return restored
}

; ---------------- Debug Function ------------------------------------------
ShowDebugInfo() {
    global origEx
    
    try {
        curDesktop := GetCurrentDesktopNum()
    } catch {
        MsgBox("Cannot determine current desktop.")
        return
    }
    
    if (!IsObject(origEx) || origEx.Count = 0) {
        MsgBox("No windows are currently tracked.")
        return
    }
    
    info := "Current Desktop: " . curDesktop . "`n`nTracked Windows:`n"
    
    for k, v in origEx {
        hwnd := k + 0
        exists := WindowExists(hwnd)
        if (exists) {
            title := GetWindowTitle(hwnd)
            winDesktop := GetDesktopNumOfWindow(hwnd)
            info .= "`nHWND: " . hwnd
            info .= "`nTitle: " . title
            info .= "`nDesktop: " . (winDesktop = -1 ? "Unknown" : winDesktop)
            info .= "`n---"
        } else {
            info .= "`nHWND: " . hwnd . " (window genuinely closed)`n---"
        }
    }
    
    MsgBox(info, "Debug: Tracked Windows")
}

; ---------------- Hotkeys -------------------------------------------------
!x:: {  ; Alt+X toggle for active window
    hwnd := WinExist("A")
    if (!hwnd) {
        ShowToast("No active window.")
        return
    }
    key := Format("{:d}", hwnd)
    
    if (origEx.Has(key)) {
        ; Restore this window
        saved := origEx.Get(key)
        try SetAlpha(hwnd, 255)
        try SetExStyle(hwnd, saved)
        origEx.Delete(key)
        ShowToast("Restored — clicks enabled.")
    } else {
        ; Make click-through
        oldEx := GetExStyle(hwnd)
        origEx.Set(key, oldEx)
        ; WS_EX_LAYERED = 0x80000, WS_EX_TRANSPARENT = 0x20
        newEx := oldEx | 0x80000 | 0x20
        try SetExStyle(hwnd, newEx)
        try SetAlpha(hwnd, DEFAULT_OPACITY)
        ShowToast("Enabled — Alt+X to restore.")
    }
    return
}

!d:: {  ; Alt+D restore windows on CURRENT desktop only
    restored := RestoreCurrentDesktop()
    if (restored = 0)
        ShowToast("No windows to restore on this desktop.")
    else
        ShowToast(Format("Restored {} window(s) on this desktop.", restored), 1400)
    return
}

!+d:: {  ; Alt+Shift+D - DEBUG info
    ShowDebugInfo()
    return
}

^!q:: {  ; Ctrl+Alt+Q: restore ALL windows across all desktops and exit
    restored := RestoreAllDesktops()
    if (restored = 0)
        ShowToast("No windows to restore. Exiting...", 900)
    else
        ShowToast(Format("Restored {} window(s) across all desktops. Exiting...", restored), 1100)
    Sleep(150)
    ExitApp()
    return
}

; Optional: show menu hint on load
ShowToast("Alt+X toggle  •  Alt+D restore current desktop  •  Ctrl+Alt+Q restore all+exit", 2000)