#Persistent
#SingleInstance Force

moving := false  ; État du script (ON/OFF)

Gui, Add, Text,, Cree par hackerd_825
Gui, Add, Button, gStart, Start
Gui, Add, Button, gStop, Stop
Gui, Show, w220 h120, Anti-AFK

return

Start:
    moving := true
    SetTimer, MoveMouse, 3000
return

Stop:
    moving := false
    SetTimer, MoveMouse, Off
return

MoveMouse:
    if (moving) {
        Random, randX, -50, 50
        Random, randY, -50, 50
        MouseMove, randX, randY, 20, R
    }
return

GuiClose:
    ExitApp
