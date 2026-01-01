#Requires AutoHotkey v2.0
; Alternative approach using process name
^!y:: 
{
    try {
        ProcessClose("yasb.exe")
        TrayTip("KillYasb", "Killed yasb.exe process", 4)
    } catch {
        TrayTip("KillYasb", "Failed to kill yasb.exe", 6)
    }
}
