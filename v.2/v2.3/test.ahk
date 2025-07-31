#Persistent
#SingleInstance Force
SetBatchLines, -1
CoordMode, Mouse, Screen

; === Variables ===
moving := false
moveCount := 0
startTime := 0

distanceMax := 100
interval := 3000
pauseMin := 1000
pauseMax := 5000
maxMinutes := 5

zoneX1 := 0
zoneY1 := 0
zoneX2 := A_ScreenWidth
zoneY2 := A_ScreenHeight

curve := false
teleport := false
antiDetect := false

; === GUI ===
Gui, Add, Text,, Cree par hackerd_825

Gui, Add, Text,, Distance max (px) :
Gui, Add, Edit, vDistance w60, %distanceMax%

Gui, Add, Text,, Intervalle entre mouvements (ms) :
Gui, Add, Edit, vInterval w60, %interval%

Gui, Add, Text,, Pause min (ms) :
Gui, Add, Edit, vPauseMin w60, %pauseMin%

Gui, Add, Text,, Pause max (ms) :
Gui, Add, Edit, vPauseMax w60, %pauseMax%

Gui, Add, Text,, Duree max (min) :
Gui, Add, Edit, vMaxMinutes w60, %maxMinutes%

Gui, Add, CheckBox, vCurve, Mouvements courbes
Gui, Add, CheckBox, vTeleport, Mode teleportation
Gui, Add, CheckBox, vAntiDetect, Mode Anti-Detection

Gui, Add, Button, gSetZone, Definir zone
Gui, Add, Button, gStart, Start (F8)
Gui, Add, Button, gStop, Stop (F9)

Gui, Add, Text, vStats, Mouvements : 0`nTemps actif : 0 sec

Gui, Show, w300 h470, Anti-AFK V2.5

; === Raccourcis clavier ===
F8::Gosub, Start
F9::Gosub, Stop

return

; === Definir la zone ===
SetZone:
    MsgBox, Clique et glisse pour definir la zone.
    KeyWait, LButton, D
    MouseGetPos, x1, y1
    KeyWait, LButton
    MouseGetPos, x2, y2

    zoneX1 := Min(x1, x2)
    zoneY1 := Min(y1, y2)
    zoneX2 := Max(x1, x2)
    zoneY2 := Max(y1, y2)

    MsgBox, Zone definie : `n%zoneX1%, %zoneY1% -> %zoneX2%, %zoneY2%
return

; === Start ===
Start:
    Gui, Submit, NoHide
    moving := true
    moveCount := 0
    startTime := A_TickCount

    ; Appliquer les valeurs
    distanceMax := Distance
    interval := Interval
    pauseMin := PauseMin
    pauseMax := PauseMax
    maxMinutes := MaxMinutes
    curve := Curve
    teleport := Teleport
    antiDetect := AntiDetect

    SoundBeep, 750, 200
    SetTimer, MoveMouse, %interval%
    SetTimer, UpdateStats, 1000
return

; === Stop ===
Stop:
    moving := false
    SoundBeep, 400, 200
    SetTimer, MoveMouse, Off
    SetTimer, UpdateStats, Off
return

; === Mouvement souris ===
MoveMouse:
    if (!moving) {
        return
    }

    elapsedMin := (A_TickCount - startTime) / 60000
    if (elapsedMin >= maxMinutes) {
        Gosub, Stop
        MsgBox, Temps ecoule ! Script arrete.
        return
    }

    Random, randX, %zoneX1%, %zoneX2%
    Random, randY, %zoneY1%, %zoneY2%

    if (teleport) {
        MouseMove, randX, randY, 0
    } else if (curve) {
        ; === Mouvement courbe ===
        MouseGetPos, startX, startY
        steps := 10
        Loop, %steps% {
            t := A_Index / steps
            Random, offsetX, -20, 20
            Random, offsetY, -20, 20
            midX := (startX + randX) / 2 + offsetX
            midY := (startY + randY) / 2 + offsetY
            curX := (1 - t)**2 * startX + 2*(1 - t)*t*midX + t**2 * randX
            curY := (1 - t)**2 * startY + 2*(1 - t)*t*midY + t**2 * randY
            MouseMove, %curX%, %curY%, 0
            Sleep, 20
        }
    } else {
        MouseMove, randX, randY, 10
    }

    moveCount++

    if (antiDetect) {
        Random, offX, -3, 3
        Random, offY, -3, 3
        MouseMove, randX + offX, randY + offY, 0
    }

    Random, randPause, %pauseMin%, %pauseMax%
    SetTimer, MoveMouse, %randPause%
return

; === Update stats ===
UpdateStats:
    elapsedSec := Floor((A_TickCount - startTime) / 1000)
    GuiControl,, Stats, Mouvements : %moveCount%`nTemps actif : %elapsedSec% sec
return

; === Quit ===
GuiClose:
    ExitApp
