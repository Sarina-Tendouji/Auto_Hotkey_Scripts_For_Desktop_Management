#Requires AutoHotkey v2.0
; Alternative approach using process name
^!c:: 
{
    try {
        ProcessClose("ClipShelf.exe")
        TrayTip("KillClipShelf", "Killed ClipShelf.exe process", 4)
    } catch {
        TrayTip("KillClipShelf", "Failed to kill ClipShelf.exe", 6)
    }
}