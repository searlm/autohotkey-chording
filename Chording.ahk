; Boilerplate copypasta
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

global ChordHook := InputHook("L0") ; Don't track/buffer input, just run our handlers
global ActiveChord := {}
global IsChordActive := False

; Modifier toggles active for the next key only
global ChordShift := False
global ChordAlt := False
global ChordCtrl := False
global ChordNumLock := False

; Persistent toggle to swap to a number-pad layout
global ChordNumPadLock := False

; Is the current chord a modifier toggle? (don't nuke modifiers if so -- we haven't sent the
; chord to be modified yet)
global IsModifierToggle := False

; Key pressed -- add the pressed key to the current chord
ChordKeyDown(ih, vk, sc)
{
    Critical ; Don't interrupt -- we're modifying global state

    ; Set the chord active. Releasing any key will then send the chord
    ActiveChord["" . vk] := True
    IsChordActive := True

    Critical Off
}
    
; Key released -- send the assembled chord, if any
ChordKeyUp(ih, vk, sc)
{
    Critical ; Don't interrupt -- we're modifying global state

    If IsChordActive
    {
        chordIdx := 0
        chordStr := ""
        For key, value in ActiveChord
        {
            If chordIdx > 0
                chordStr .= "_"
            chordStr .= key
            chordIdx = chordIdx + 1
        }

        Sort chordStr, N D_
        handlerName := "HandleChord_" . chordStr
        if ChordNumLock
        {
            handlerName := "HandleNumLockChord_" . chordStr
        }
        else if ChordNumPadLock
        {
            handlerName := "HandleNumPadLockChord_" . chordStr
        }

        ; ToolTip % "Chord: " . chordStr

        handler := Func(handlerName)
        if handler != 0
        {
            IsModifier := chordStr = "32" or chordStr = "82" or chordStr = "70" or chordStr = "52" or chordStr = "53"
            if IsModifier = 0
            {
                if ChordAlt
                    SendInput {LAlt down}
                if ChordShift
                    SendInput {LShift down}
                if ChordCtrl
                    SendInput {LCtrl down}
            }

            %handlerName%()
            
            if IsModifier = 0
            {
                if ChordAlt
                    SendInput {LAlt up}
                if ChordShift
                    SendInput {LShift up}
                if ChordCtrl
                    SendInput {LCtrl up}
            }
        }
    }

    ; Remove the key from the chord
    ActiveChord.Delete("" . vk)
    IsChordActive := False

    if !IsModifierToggle
    {
        ChordAlt := False
        ChordShift := False
        ChordCtrl := False
        ChordNumLock := False
    }

    IsModifierToggle := False

    Critical Off
}
   
; Handle key up/down for all keys, and suppress input
ChordHook.KeyOpt("{All}", "NS")
ChordHook.NotifyNonText := True

; Don't eat our own output
ChordHook.MinSendLevel := 1

; Wire up key up/down handlers
ChordHook.OnKeyDown := Func("ChordKeyDown")
ChordHook.OnKeyUp := Func("ChordKeyUp")

ChordHook.Start()

;
; Chord handlers
;

; Tartarus v2 default keycodes:
;  49  50  51  52  53
;   9  81  87  69  82
;  20  65  83  68  70
;  86  90  88  67
;  *
;  \--> Remap lshift (160) to v in Synapse. Haven't worked out buggy shift behavior
;       with the default binding...
;
; Thumb top    : 164 (probably needs a similar rebind as the shift key above)
; Thumb bottom :  32

HandleChord_82()
{
    if ChordAlt
    {
        ChordAlt := False
    }
    else
    {
        ChordAlt := True
    }

    IsModifierToggle := True
}

HandleChord_70()
{
    if ChordCtrl
    {
        ChordCtrl := False
    }
    else
    {
        ChordCtrl := True
    }

    IsModifierToggle := True
}

HandleChord_52()
{
    if ChordShift
    {
        ChordShift := False
    }
    else
    {
        ChordShift := True
    }
    
    IsModifierToggle := True
}

HandleChord_53()
{
    if ChordNumLock
    {
        ChordNumLock := False
    }
    else
    {
        ChordNumLock := True
    }
    
    IsModifierToggle := True
}

HandleChord_32()
{
    if ChordNumPadLock
    {
        ChordNumPadLock := False
    }
    else
    {
        ChordNumPadLock := True
    }
    
    IsModifierToggle := True
}

HandleNumPadLockChord_32() {
    HandleChord_32()
}

HandleChord_86() {
    SendInput {BackSpace}
}

HandleChord_9() {
    SendInput {Space}
}

HandleChord_20() {
    SendInput {Space}
}

HandleChord_91() {
    SendInput {LWin}
}

HandleChord_9_164() {
    SendInput {LAlt down}{Tab}{LAlt up}
}

HandleChord_65_69_83() {
    SendInput {Enter}
}

HandleChord_67() {
    SendInput i
}

HandleChord_68() {
    SendInput e
}

HandleChord_69() {
    SendInput o
}

HandleChord_88() {
    SendInput n
}

HandleChord_83() {
    SendInput t
}

HandleChord_87() {
    SendInput r
}

HandleChord_90() {
    SendInput a
}

HandleChord_65() {
    SendInput h
}

HandleChord_81() {
    SendInput s
}

HandleNumPadLockChord_53() {
    SendInput 9
}

HandleNumPadLockChord_52() {
    SendInput 8
}

HandleNumPadLockChord_51() {
    SendInput 7
}

HandleNumPadLockChord_82() {
    SendInput 6
}

HandleNumPadLockChord_69() {
    SendInput 5
}

HandleNumPadLockChord_87() {
    SendInput 4
}

HandleNumPadLockChord_70() {
    SendInput 3
}

HandleNumPadLockChord_68() {
    SendInput 2
}

HandleNumPadLockChord_83() {
    SendInput 1
}

HandleNumPadLockChord_67() {
    SendInput 0
}

HandleNumPadLockChord_49() {
    SendInput {PgUp}
}

HandleNumPadLockChord_9() {
    SendInput {PgDn}
}

HandleNumPadLockChord_50() {
    SendInput {Home}
}

HandleNumPadLockChord_81() {
    SendInput {End}
}

HandleChord_69_83_90() {
    SendInput `*
}

HandleChord_9_91() {
    Send #{tab}
}

HandleChord_68_81_83() {
    SendInput {{}
}

HandleChord_68_83_90() {
    SendInput {}}
}

HandleChord_68_81_87() {
    SendInput `[
}

HandleChord_68_88_90() {
    SendInput `]
}

HandleChord_65_68_83()
{
    SendInput x
}

HandleChord_86_88_90()
{
    SendInput {z}
}

HandleChord_67_88_90()
{
    SendInput b
}

HandleChord_9_81_87()
{
    SendInput v
}

HandleChord_69_81_87()
{
    SendInput y
}

HandleChord_20_65_83()
{
    SendInput g
}

HandleChord_69_86()
{
    SendInput `\
}

HandleChord_68_87()
{
    SendInput `;
}

HandleChord_69_83()
{
    SendInput {^}
}

HandleChord_20_65()
{
    SendInput {:}
}

HandleChord_9_68_81()
{
    SendInput {<}
}

HandleChord_68_86_90()
{
    SendInput {>}
}

HandleChord_9_81()
{
    SendInput {@}
}

HandleChord_9_67()
{
    SendInput `/
}

HandleChord_68_88()
{
    SendInput `,
}

HandleChord_65_88()
{
    SendInput {!}
}

HandleChord_83_90()
{
    SendInput `%
}

HandleChord_37()
{
    SendInput {Left}
}

HandleChord_39()
{
    SendInput {Right}
}

HandleChord_38()
{
    SendInput {Up}
}

HandleChord_40()
{
    SendInput {Down}
}

HandleChord_86_87()
{
    SendInput `&
}

HandleChord_9_87()
{
    SendInput {~}
}

HandleChord_86_88()
{
    SendInput ``
}

HandleChord_9_69_87()
{
    SendInput {+}
}

HandleChord_20_68_83()
{
    SendInput {=}
}

HandleChord_20_83()
{
    SendInput {|}
}

HandleChord_9_65()
{
    SendInput {$}
}

HandleChord_65_86()
{
    SendInput {#}
}

HandleChord_65_87()
{
    SendInput {?}
}

HandleChord_81_83()
{
    SendInput {_}
}

HandleChord_67_90()
{
    SendInput j
}

HandleChord_69_81()
{
    SendInput k
}

HandleChord_65_68()
{
    SendInput l
}

HandleChord_9_68()
{
    SendInput p
}

HandleChord_68_86()
{
    SendInput q
}

HandleChord_67_86()
{
    SendInput {c}
}

HandleChord_20_68()
{
    SendInput m
}

HandleChord_9_69()
{
    SendInput w
}

HandleChord_69_87()
{
    SendInput -
}

HandleChord_67_88()
{
    SendInput `'
}

HandleChord_86_90()
{
    SendInput `"
}

HandleChord_68_83()
{
    SendInput .
}

HandleChord_81_87()
{
    SendInput u
}

HandleChord_65_83()
{
    SendInput d
}

HandleChord_88_90()
{
    SendInput f
}

HandleChord_68_81()
{
    SendInput +9
}

HandleChord_68_90()
{
    SendInput +0
}

HandleChord_9_69_81_87() {
    SendInput {Esc}
}

HandleChord_20_65_68_83()
{
    SendInput {Tab}
}

HandleChord_49_52_53() 
{
    ExitApp
}
