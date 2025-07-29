#Requires AutoHotkey v2.0

global lastClip := ""
global incrementalClipboard := ""
global clipboardFile := A_ScriptDir "\clipboard_data.txt"  ; You can change this path

; Load clipboard data from file if it exists
if FileExist(clipboardFile) {
    FileRead incrementalClipboard, clipboardFile
}

SetTimer(WatchClipboard, 100)  ; check clipboard every 100ms

WatchClipboard() {
    global lastClip, incrementalClipboard  ; 👈 Declare globals inside the function

    if (A_Clipboard != lastClip && A_Clipboard != "") {
        lastClip := A_Clipboard
        incrementalClipboard .= A_Clipboard "`n`n"

        ; 🧠 Save to file
        if FileExist(clipboardFile)
            FileDelete clipboardFile   ; Overwrite safely
        FileAppend incrementalClipboard, clipboardFile
        
        ToolTip("✅ Added to custom clipboard")
        SetTimer(() => ToolTip(), -1000)  ; hide tooltip after 1 sec
    }
}

^+v:: {  ; Ctrl+Shift+V to paste full clipboard
    global incrementalClipboard

    if (incrementalClipboard = "") {
        MsgBox("⚠️ Custom clipboard is empty.")
        return
    }

    A_Clipboard := incrementalClipboard
    Send("^v")
    ToolTip("📋 Pasted full clipboard")
    SetTimer(() => ToolTip(), -1000)
}

^+c:: {  ; Ctrl+Shift+C to clear custom clipboard
    global incrementalClipboard

    incrementalClipboard := ""
    if FileExist(clipboardFile)
        FileDelete clipboardFile  ; Clear saved file too
    ToolTip("🧹 Custom clipboard cleared")
    SetTimer(() => ToolTip(), -1000)
}

^+l:: {  ; Ctrl+Shift+L to view clipboard buffer
    global incrementalClipboard

    myGui := Gui("+AlwaysOnTop +Resize", "📋 Clipboard History")
    myGui.SetFont("s10", "Segoe UI")

    ; Add scrollable Edit control (with Wrap, VScroll, and WantTab for scrolling)
    clipView := myGui.Add("Edit", "w600 h400 ReadOnly -Wrap VScroll WantTab")

    ; Build readable block with dividers
    scrollText := ""
    clips := StrSplit(incrementalClipboard, "`n`n", "`r")

    if clips.Length = 0 || (clips.Length = 1 && clips[1] = "") {
        scrollText := "⚠️ No clips to show."
    } else {
        for i, clip in clips {
            scrollText .= "Clip #" i ":" "`n" clip "`n" . "-----------------------------`n"
        }
    }

    clipView.Value := scrollText

    ; Add close button
    myGui.Add("Button", "wp", "Close").OnEvent("Click", (*) => myGui.Destroy())

    myGui.Show()
    clipView.Focus()  ; 👈 Immediately focus the text box so scroll wheel works
}

^+h:: {
    helpText := "
    (
    📋 CUSTOM MACRO SHORTCUTS

    Ctrl+C           → Normal copy (but also adds to custom clipboard)
    Ctrl+Shift+V     → Paste full custom clipboard buffer
    Ctrl+Shift+C     → Clear custom clipboard buffer
    Ctrl+Shift+L     → Show clipboard history 
    Ctrl+Shift+H     → Show this help window

    All custom clipboard entries are saved across sessions.
    You can build on this system with slot-based saving, editing, and exporting.

    Tip: Use Ctrl+Shift+Z for future 'undo last copy' functionality!
    )"

    MsgBox(helpText, "🔑 Shortcut Help", "64")  ; Icon 64 = info
}

