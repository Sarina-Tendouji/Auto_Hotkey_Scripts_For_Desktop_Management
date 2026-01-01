#Requires AutoHotkey v2.0
#Include VD.ah2
TrayTip("DesktopSwitch", "XButton1/2: prev/next desktop (cyclic)", 1200)

SwitchRelative(rel) {
    switched := false
    try {
        VD.GoToRelativeDesktopNum(rel)
        switched := true
    } catch Error {
    }
    
    if !switched {
        try {
            VD.goToRelativeDesktopNum(rel)
            switched := true
        } catch Error {
        }
    }
    
    if !switched {
        ; get current desktop index (1-based)
        try {
            cur := VD.getCurrentDesktopNum()
        } catch {
            try {
                cur := VD.GetCurrentDesktopNum()
            } catch Error {
                TrayTip("DesktopSwitch", "Cannot get current desktop", 1200)
                return
            }
        }
        
        ; get total desktop count
        try {
            total := VD.getCount()
        } catch {
            try {
                total := VD.GetCount()
            } catch Error {
                TrayTip("DesktopSwitch", "Cannot get total desktop count", 1200)
                return
            }
        }
        
        ; compute 1-based target with wrap-around
        target := Mod(cur - 1 + rel, total) + 1
        
        try {
            VD.GoToDesktopNum(target)
            switched := true
        } catch Error {
        }
        
        if !switched {
            try {
                VD.goToDesktopNum(target)
                switched := true
            } catch Error {
            }
        }
        
        if !switched {
            TrayTip("DesktopSwitch", "No function available to switch desktops", 1200)
            return
        }
    }
    
    ; status tip showing index/total (best-effort)
    try {
        cur2 := VD.getCurrentDesktopNum()
        total2 := VD.getCount()
        TrayTip("DesktopSwitch", "Desktop " . cur2 . " / " . total2, 700)
    } catch Error {
    }
}

XButton1:: {
    SwitchRelative(-1)
}

XButton2:: {
    SwitchRelative(1)
}