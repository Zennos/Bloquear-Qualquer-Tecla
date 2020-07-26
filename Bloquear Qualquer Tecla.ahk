#SingleInstance Force
CoordMode, Mouse, Screen
fading := 1
trans := 255

Menu, Tray, NoStandard
Menu, Tray, Add, Opções, OpenOptions
Menu, Tray, Add, Reiniciar, ReloadScript
Menu, Tray, Add, Sair, SaveAndExit
Menu, Tray, Default, Opções
Menu, Tray, Click, 1

settingsFolder := A_AppData . "\Zennos\Bloquear Qualquer Tecla"
settingsFilePath := A_AppData . "\Zennos\Bloquear Qualquer Tecla\BloquearQualquerTecla.ini"

IniRead, enabled, %settingsFilePath%, Setting, enabled, 0
IniRead, disabledBgColor, %settingsFilePath%, Setting, disabledBgColor, FFA963
IniRead, enabledBgColor, %settingsFilePath%, Setting, enabledBgColor, Default
IniRead, fontSize, %settingsFilePath%, Setting, fontSize, 11
IniRead, paddingTop, %settingsFilePath%, Setting, paddingTop, 30
IniRead, idleTimeMs, %settingsFilePath%, Setting, idleTimeMs, 8000
IniRead, width, %settingsFilePath%, Setting, width, 638

disabledText := "🚫 Teclas Desabilitadas, para habilita-las novamente aperte Shift + 2. Para sair aperte Shift + 1"
; disabledBgColor := "FFA963"
enabledText := "✔️ Teclas Habilitadas, para desabilita-las aperte Shift + 2. Para sair aperte Shift + 1"
; enabledBgColor := "Default"
gosub, CreateWindow

Return

CreateWindow:
    WinTitle := "Bloquear Qualquer Tecla"
    Gui, 1:New, +E0x20 -Caption +LastFound +ToolWindow +AlwaysOnTop +Owner, %WinTitle%
    Gui, 1:Font, s%fontSize% w700, Calibri
    Gui, 1:Add, Text, w%width% vWinText,% enabled = 1 ? enabledText : disabledText
    WinSet, Transparent, 255
    gosub, SetWindowTextAndColor
    Gui, 1:Show, y%paddingTop% NA

    SetTimer, CheckIdleTime, 100
    gosub, ToggleKeys
Return

SetWindowTextAndColor:
    bgColor := enabled = 1? enabledBgColor : disabledBgColor
    text := enabled = 1 ? enabledText : disabledText

    GuiControl, 1:Text, WinText, %text%
    Gui, 1:Color, %bgColor%
Return

CheckIdleTime:
    if (A_TimeIdlePhysical > idleTimeMs){ ; 8 seg
        gosub, FadeOut
    } else {
        gosub, FadeIn
    }
Return

#if (enabled == false)
    +2::
        gosub, ToggleKeys
    Return
    +1::
        gosub, SaveAndExit
    Return

#if (enabled == true)
    WheelUp::Return
    WheelDown::Return
    LButton::Return
    RButton::Return
    MButton::Return
    LWin::Return
    RWin::Return
    LControl::Return
    RControl::Return
    LAlt::Return
    XButton1::Return
    XButton2::Return
#if

ToggleKeys:
    gosub, SetWindowTextAndColor
    enabled := !enabled
    if (enabled){
        Input, result,, !@
        if (ErrorLevel == "EndKey:!"){
            gosub, SaveAndExit
        }
        gosub, ToggleKeys
    }
Return

SaveAndExit:
    gosub, Save
    ExitApp
Return

Save:
    if !FileExist(settingsFilePath){
        FileCreateDir, %settingsFolder%

        IniWrite, %A_Space%%disabledBgColor%, %settingsFilePath%, Setting, disabledBgColor
        IniWrite, %A_Space%%enabledBgColor%, %settingsFilePath%, Setting, enabledBgColor
        IniWrite, %A_Space%%fontSize%, %settingsFilePath%, Setting, fontSize
        IniWrite, %A_Space%%paddingTop%, %settingsFilePath%, Setting, paddingTop
        IniWrite, %A_Space%%idleTimeMs%, %settingsFilePath%, Setting, idleTimeMs
        IniWrite, %A_Space%%width%, %settingsFilePath%, Setting, width
    }

    enabledValue := !enabled

    IniWrite, %A_Space%%enabledValue%, %settingsFilePath%, Setting, enabled
Return

OpenOptions:
    if !FileExist(settingsFilePath){
        gosub, Save
    }
    Run, %settingsFilePath%
Return

ReloadScript:
    Reload
Return

; Windows fading
FadeIn:
    SetTimer, FadingOut, Off
    SetTimer, FadingIn, 10
Return

FadeOut:
    SetTimer, FadingIn, Off
    SetTimer, FadingOut, 10
Return

FadingIn:
    trans := 255
    
    WinSet, Transparent, %trans%, %WinTitle%
    SetTimer, FadingIn, Off
Return

FadingOut:
    trans -= 10
    if (trans < 0){
        SetTimer, FadingOut, Off
        trans := 0
    }
    
    WinSet, Transparent, %trans%, %WinTitle%
Return