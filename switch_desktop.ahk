#Requires AutoHotkey v2.0
#Include VD.ah2

TrayTip("DesktopSwitch", "Alt+1..Alt+9 active", 1500)

!1:: GoToDesktop(1)
!2:: GoToDesktop(2)
!3:: GoToDesktop(3)
!4:: GoToDesktop(4)
!5:: GoToDesktop(5)
!6:: GoToDesktop(6)
!7:: GoToDesktop(7)
!8:: GoToDesktop(8)
!9:: GoToDesktop(9)

GoToDesktop(n) {
    TrayTip("DesktopSwitch", "Going to desktop " . n, 800)
    VD.GoToDesktopNum(n)
}
