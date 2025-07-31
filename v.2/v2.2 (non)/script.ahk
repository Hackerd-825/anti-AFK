; --- V2.2 ---
; Anti AFK Mouse Mover
; Fait par hackerd_825

#Persistent
#SingleInstance force
CoordMode, Mouse, Screen

; Paramètres par défaut
minDelay := 1000
maxDelay := 3000
minDist := 20
maxDist := 100
curve := false
teleport := false
zoneX1 := 0
zoneY1 := 0
zoneX2 := A_ScreenWidth
zoneY2 := A_ScreenHeight

running := false
moveCount := 0
startTime := 0

; Créer GUI principale
Gui, Add, Text,, Hack AFK - hackerd_825
Gui, Add, Button, gStartMover w120, Start
Gui, Add, Button, gStopMover w120, Stop
Gui, Add, Button, gSetZone w120, Définir Zone

Gui, Add, Checkbox, vcurve, Mouvement Courbe
Gui, Add, Checkbox, vteleport, Teleportation

Gui, Add, Text,, Min Délai (ms) :
Gui, Add, Edit, vminDelay w100, %minDelay%

Gui, Add, Text,, Max Délai (ms) :
Gui, Add, Edit, vmaxDelay w100, %maxDelay%

Gui, Add, Text,, Min Distance (px) :
Gui, Add, Edit, vminDist w100, %minDist%

Gui, Add, Text,, Max Distance (px) :
Gui, Add, Edit, vmaxDist w100, %maxDist%

Gui, Add, Text, vStats w200, Déplacements : 0

Gui, Show,, Anti AFK Mouse V2.2

return

; --- Démarrer ---
StartMover:
    Gui, Submit, NoHide
    if (running) {
        MsgBox, Deja en cours.
        return
    }
    running := true
    moveCount := 0
    startTime := A_TickCount
    SetTimer, MoveMouse, 100
    SetTimer, UpdateStats, 1000
    SoundBeep, 750, 200
return

; --- Stopper ---
StopMover:
    running := false
    SetTimer, MoveMouse, Off
    SetTimer, UpdateStats, Off
    SoundBeep, 500, 200
return

; --- Déplacer la souris ---
MoveMouse:
    if (!running) {
        return
    }

    Random, delay, %minDelay%, %maxDelay%
    Random, dist, %minDist%, %maxDist%

    ; Générer nouvelle position
    Random, randX, %zoneX1%, %zoneX2%
    Random, randY, %zoneY1%, %zoneY2%

    if (teleport) {
        MouseMove, %randX%, %randY%, 0
    } else {
        MouseGetPos, cx, cy
        dx := randX - cx
        dy := randY - cy

        steps := 50
        Loop, %steps% {
            fx := cx + (dx * A_Index / steps)
            fy := cy + (dy * A_Index / steps)
            MouseMove, %fx%, %fy%, 0
            Sleep, delay / steps
        }
    }

    moveCount++
    Sleep, delay
return

; --- Stats ---
UpdateStats:
    elapsed := (A_TickCount - startTime) / 1000
    GuiControl,, Stats, Déplacements : %moveCount% | Temps : %elapsed%s
return

; --- Définir Zone ---
SetZone:
    cancelZone := false

    ; Mini fenêtre avec Annuler
    Gui, New, +AlwaysOnTop -Caption +ToolWindow
    Gui, Add, Text,, Clique-glisse pour définir la zone.`nClique Annuler pour annuler.
    Gui, Add, Button, gCancelZone w100, Annuler
    Gui, Show,, Sélection Zone

    ; Attendre fermeture mini GUI
    WinWaitClose, Sélection Zone

    if (cancelZone) {
        MsgBox, Sélection annulée.
        return
    }

    ; Attendre VRAI premier clic
    MsgBox, Clique sur le point de départ.
    KeyWait, LButton, D
    MouseGetPos, x1, y1

    MsgBox, Clique sur le point de fin.
    KeyWait, LButton, D
    MouseGetPos, x2, y2

    zoneX1 := Min(x1, x2)
    zoneY1 := Min(y1, y2)
    zoneX2 := Max(x1, x2)
    zoneY2 := Max(y1, y2)

    MsgBox, Zone définie : %zoneX1%, %zoneY1% -> %zoneX2%, %zoneY2%
return

CancelZone:
    cancelZone := true
    Gui, Destroy
return

; --- Raccourcis clavier Start/Stop ---
~F9::Gosub, StartMover
~F10::Gosub, StopMover

; --- Fermer ---
GuiClose:
ExitApp
