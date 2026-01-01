#Requires AutoHotkey v2.0
; Alternative approach using process name
^!f:: 
{
    try {
        ProcessClose("FancyWM.exe")
        TrayTip("KillFancyWM", "Killed FancyWM.exe process", 4)
    } catch {
        TrayTip("KillFancyWM", "Failed to kill FancyWM.exe", 6)
    }
}
