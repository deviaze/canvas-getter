#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%

while (true) {
    Run cmd.exe start /B canvas-getter.exe,,hide
    Sleep, 60 * 60000 ; every hour
}
