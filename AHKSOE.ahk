IF NOT A_IsAdmin
{
   Run *RunAs "%A_ScriptFullPath%"
   ExitApp
}

if (a_ahkversion < 1.1){
    Msgbox, 0x10
        , % "Error"
        , % "The AutoHotkey installed in your computer is not compatible with`n"
        . "this version of AHKGTAV Doohicky.`n`n"
        . "Please use the compiled version of my script or upgrade your AutoHotkey.`n"
        . "The application will exit now."
    Exitapp
}

#NoEnv
#SingleInstance, Force
SetWorkingDir, %A_ScriptDir%

Menu, Tray, Icon, shell32.dll, 194

global script := {  based               : scriptobj
                    ,name               : "AHKSOE"
                    ,version            : "2"
                    ,author             : "DreadfullyDespized"
                    ,Homepage           : "https://github.com/DreadfullyDespized/ahksoe"
                    ,crtdate            : "20200118"
                    ,moddate            : "20200506"
                    ,conf               : "SOE-Config.ini"
                    ,logurl             : "https://raw.githubusercontent.com/DreadfullyDespized/ahksoe/master/"
                    ,change             : "Changelog-SOE.txt"
                    ,bug                : "https://github.com/DreadfullyDespized/ahksoe/issues/new?assignees=DreadfullyDespized&labels=bug&template=bug_report.md&title="
                    ,feedback           : "https://github.com/DreadfullyDespized/ahksoe/issues/new?assignees=DreadfullyDespized&labels=enhancement&template=feature_request.md&title="
                    ,citlaw             : "https://evolpcgaming.com/forums/topic/4-vehicle-laws-fines/"
                    ,mislaw             : "https://evolpcgaming.com/forums/topic/5-misdemeanor-felony-laws-fines/"
                    ,fellaw             : "https://evolpcgaming.com/forums/topic/5-misdemeanor-felony-laws-fines/"}

global updatefile = % A_Temp "\" script.change
global logurl = % script.logurl script.change
global chrglog = % A_ScriptDir "\Charge_log.txt"
If (A_ComputerName = "Z017032") {
    ; msgbox,,, Asset is %A_ComputerName%
} else {
    UrlDownloadToFile, %logurl%, %updatefile%
    if (ErrorLevel = 1) {
        msgbox, Unable to communicate with update site.
        Return
    }
}
FileRead, BIGFILE, %updatefile%
StringGetPos, last25Location, BIGFILE,`n, L12
StringTrimLeft, smallfile, BIGFILE, %last25Location%

; This will become the new version checker usage at some point.
; This will be used once it is fully flushed out.

FileReadLine, checkdate, %A_ScriptFullPath%, 29
FileReadLine, checkv, %A_ScriptFullPath%, 25
RegexMatch(checkv,"\d",cver)
RegexMatch(checkdate,"\d+",cdate)
checky := cver "." cdate
ochecky := script.version "." script.moddate
; if (checky >= ochecky) {
;     msgbox,, Version Checker, % "Current Version: " cver "   Old Version: " script.version "`n"
;         . "Current Date: " cdate "   Old Date: " script.moddate "`n"
;         . "Main Version: " checky "   Old Main Version: " ochecky
; }

; ============================================ SCRIPT AUTO UPDATER ============================================
update(ochecky) {
    RunWait %ComSpec% /c "Ping -n 1 -w 3000 google.com",, Hide  ; Check if we are connected to the internet
    if connected := !ErrorLevel {
        FileReadLine, line, %updatefile%, 13
        RegexMatch(line, "\d.\d{8}", Version)
        rfile := script.logurl script.name ".ahk"
        if (Version > ochecky) {
            Msgbox, 68, % "New Update Available"
                      , % "There is a new update available for this application.`n"
                        . "Do you wish to upgrade to V" Version "?`n"
                        . "Local Version: " ochecky
                      , 10 ; 10s timeout
            IfMsgbox, Timeout
                return debug ? "* Update message timed out" : 1
            IfMsgbox, No
                return debug ? "* Update aborted by user" : 2
            deposit := A_ScriptDir "\AHKSOE.ahk"
            if (A_ComputerName = "Z017032") {
                msgbox,,, Asset is %A_ComputerName%
            } else {
                UrlDownloadToFile, %rfile%, %deposit%
                if (ErrorLevel = 1) {
                    msgbox, Unable to communicate with update site.
                    Return
                }
            }
            Msgbox, 64, % "Download Complete"
                      , % "New version is now running and the old version will now close'n"
                        . "Enjoy the latest version!"
            Run, %deposit%
            ExitApp
        }
        if (Version = ochecky) {
            MsgBox, 64, % "Up to Date"
                    , % "Source Version: " Version "`n"
                    . "Local Version: " ochecky
        }
        if (Version < ochecky) {
            MsgBox, 64, % "DEV Version!"
                    , % "Source Version: " Version "`n"
                    . "Local Version: " ochecky
        }
    }
}

; FiveM Chat formatting
; ^1 = Red Orange
; ^2 = Light Green
; ^3 = Light Yellow
; ^4 = Dark Blue
; ^5 = Light Blue
; ^6 = Violet
; ^7 = White
; ^8 = Blood Red
; ^9 = Fuchsia
; ^* = Bold
; ^_ = Underline
; ^~ = Strikethrough
; ^= = Underline + Strikethrough
; ^*^ = Bold + Underline + Strikethrough
; ^r = Cancel Formatting

; Hotkey handlers
; ! = Alt
; ^ = Control
; # = Windows
; + = Shift
; < = Left operator
; > = Right operator
; * = Wildcard
; ~ = Allows native function to still be sent along with hotkey
; UP = If put into the hotkey will only fire off on the up stroke of the key

; The example below is a vertical stack
; ^Numpad0::
; ^Numpad1::
; MsgBox Pressing either Control+Numpad0 or Control+Numpad1 will display this message.
; return

; Combination hotkey example
; Numpad0 & Numpad1::MsgBox You pressed Numpad1 while holding down Numpad0.
; Numpad0 & Numpad2::Run Notepad

; Alternate way to handle Alt Tab
; RControl & RShift::AltTab  ; Hold down right-control then press right-shift repeatedly to move forward.
; RControl & Enter::ShiftAltTab  ; Without even having to release right-control, press Enter to reverse direction.

; Unfortunately.  The emojis don't actually save from the ahk to the data entry.
; Though if you enter them in the data entry.  They save within the ini.
; Configure these variables as you wish to be presented
textspace = y+3
towtype = f
config = SOE-Config.ini
; ============================================ INI READING ============================================
; Section to read in the configuration file if it exists
IfExist, %config%
{
    ; Cleanup some of the old ini configuration portions
    IniDelete, %config%, Yourself, rolepick
    IniDelete, %config%, Yourself, |LEO|TOW|CIV|SAFR
    IniDelete, %config%, Normal, val2hkmsg
    IniDelete, %config%, Towing, towmsg1
    IniDelete, %config%, Keys, seatbelthk
    IniDelete, %config%, Keys, lighthk
    IniDelete, %config%, Keys, sirenhk
    IniDelete, %config%, Keys, yelphk
}

GoSub, ReadConfig
eboxmsg = Danger %name% of the %department%

; ============================================ HELP TEXT FORMAT ============================================
; Main portion of the help text that is displayed
subhelptext = 
(
Police Hotkeys:
Control+1 = Config
Control+3 = Reload Script
Control+/ = Vehicle Image Search
Control+- = runplate
Control+. = spikestrip
Control+K = Calls for TOW
Control+J = Lets TOW know information
tmedical - medical rp message
tmic = mic help
tglovebox - Search Glovebox
tstrunk - Search Trunk
)

helptext = 
(
This script is used to well. Help you with some of the repetitive tasks within GTAV RP on SoE.
With the following commands available to you.  Added the ability to change syntax as well.
While running this script the following "side effects...features?"
1. NumLock Key will always be on.
2. ScrollLock Key will always be off
3. WINDOWSKEY + DEL it will empty your recycling bin.
4. WINDOWSKEY + ScrollLock it will pause the hotkeys.
5. WINDOWSKEY + Insert will reload the script.

ms Delay: Take your ping to the server and double it.  To fill this in with.

Police Commands:
--------------------
tdutystart - go on duty (launches mws)
tfrisk - frisks subject
tsearch - searches subject
tmedical - medical rp message
timpound - place impound sticker
tplate - notes the plate
tvin = notes the vin
ttrunk - get itmes from trunk (medbag|slimjim|tintmeter|cones|gsr|breathalizer|bodybag)
tsglovebox - searches through the interior of a vehicle
tstrunk - searches through the trunk of the vehicle - Face the trunk

Control+1 - Configuration screen
Control+3 - Reload Script
Control+4 - Update Checker
Control+5 - Police Overlay
Control+6 - Close Police Overlay
Control+. - SpikeStrip Toggle
Control+/ - vehicle image search (uses google images in browser)
Control+- - preps command for plate running
Control+K - call for tow over radio
Control+J - tell tow whats going on

Tow Commands:
-----------------------
tadv - display your towing advertisement
tstart - start tow shift/company
tsend - initial send it
tonway - showing 76 to them
ttow - towing system
tsecure - secures tow straps
trelease - releases tow straps
tkitty - grabs kitty litter from truck

Help Commands:
--------------------
tmic = help text about fixing mic in local ooc
tpaystate = help text about paying state in local ooc
tsoehelp = display ndg help information in local ooc

General Commands:
---------------------------
F1 - enables/disables seatbelt
tgun - use firearm
tscrap - rp the scrap to truck
F9 - enables/disables engine
Shift+F11 - valet phone check
F11 - Pull vehicle out from valet
F6 - Pull out phone to record
)

helptext2 = 
(
If you wish to change any of the hotkeys.
This is the section to do so. Click on the box and then
hit the keys together to configure the hotkey.
)
; ============================================ CUSTOM SYSTEM TRAY ============================================
; Removes all of the standard options from the system tray
Menu, Tray, NoStandard
Menu, Tray, Add, &Update Checker, ^4
Menu, Tray, Add, GTAV &Car Search, vehimghk
Menu, Tray, Add, &Reconfigure/Help, ^1
Menu, Tray, Add, &Police Overlay, ^5
Menu, Tray, Add, &Reload Script, ^3
Menu, Tray, Add, E&xit,Exit

Gui, 6:Destroy
Gui, 6:-Caption +LastFound +ToolWindow
Gui, 6:Font, s10 cRed, Consolas
Gui, 6:Color, Black, Red
Gui, 6:Add, Text,, % "Name: " script.name
Gui, 6:Add, Text, %textspace% , % "FileName: " script.name ".ahk"
Gui, 6:Add, Text, %textspace% , % "Version: " ochecky
Gui, 6:Add, Text, %textspace% , % "Author: " script.author
Gui, 6:Add, Text, %textspace% , HomePage:
Gui, 6:Font, s10 Underline cTeal, Consolas
Gui, 6:Add, Text, x85 y79 gHomePage, HomePage
HomePage_TT := "Original home page on SOE forums"
Gui, 6:Font
Gui, 6:Font, s10 cRed, Consolas
Gui, 6:Add, Text, x12 y96, % "Create Date: " script.crtdate
Gui, 6:Add, Text, %textspace% , % "Modified Date: " script.moddate
Gui, 6:Add, Text, %textspace% , Config File:
Gui, 6:Font, s10 Underline cTeal, Consolas
Gui, 6:Add, Text, x104 y130 geditconfig, ConfigFile
ConfigFile_TT := "Location of your configuration file"
Gui, 6:Font
Gui, 6:Font, s10 cRed, Consolas
Gui, 6:Add, Text, x12 y150 , Change Log: 
Gui, 6:Font, s10 Underline cTeal, Consolas
Gui, 6:Add, Text, x96 y150 gchangelog, ChangeLog
ChangeLog_TT := "Launches the locally downloaded changelog"
Gui, 6:Font
Gui, 6:Font, s10 cRed, Consolas
Gui, 6:Add, Button, x180 y198 h25 w80 gconfigure, Configure
configure_TT := "Configures the main portion of the application"
Gui, 6:Add, Button, x260 y198 h25 w70 gupdatecheck, Update
update_TT := "Checks for any updates on github compared to your version"
Gui, 6:Add, Button, x330 y198 h25 w40 gbug, BUG
bug_TT := "Brings you to github Issues BUG template"
Gui, 6:Add, Button, x370 y198 h25 w75 gfeedback, Feedback
feedback_TT := "Brings you to github Issues Feedback/Feature template"
Gui, 6:Add, Edit, -Wrap Readonly x200 y8 r11 w550 vupdatetext, % smallfile
updatetext_TT := ""
Gui, 6:Show,, Information
OnMessage(0x200, "WM_MOUSEMOVE")
Return

6GuiEscape:
Gui, 6:Cancel
Return

^5::
Gui, 7:Destroy
Gui, 7:+HwndID +E0x20 -Caption +LastFound +ToolWindow +AlwaysOnTop
Gui, 7:Font, s16 cRed w500, Consolas
Gui, 7:Color, Black
Gui, 7:Add, Text, x0 y0, %subhelptext%
Gui, 7:Show, X90 Y300, Overlay
WinSet, TransColor, Black 255, ahk_id%ID%
Gui, 7:-Caption
Return

^6::
Gui, 7:Cancel
Return

HomePage:
Run, % script.homepage
Return

EditConfig:
Run, % A_ScriptDir "\" script.conf
Return

Changelog:
Run, % A_Temp "\" script.change
Return

configure:
Gui, 6:Cancel
Send, ^1
Return

updatecheck:
Gui, 6:Cancel
Send, ^4
Return

bug:
Run, % script.bug
Return

feedback:
Run, % script.feedback
Return

#z::Menu, Tray, Show

Exit:
ExitApp
Return

^3::
    Reload
Return

^4::
    update(ochecky)
Return

vehimghk:
Gui, Search:Add, Edit, vgtavsearch w100
Gui, Search:Add, Button, Default gSearch, Search
Gui, Search:Show,, Gtav car model
Return

SearchGuiEscape:
SearchGuiClose:
Gui, Search:Cancel
Return

Search:
Gui, Search:Submit
gtavsearch = gta v %gtavsearch%
Run, http://www.google.com/search?tbm=isch&q=%gtavsearch%
Gui, Search:Destroy
Return

Gosub, UpdateConfig
Return

; ============================================ START HOTKEY CONFIRUATION ============================================

; SetKeyDelay , Delay, PressDuration, Play
SetKeyDelay, 0, 100

; Configure Variables to be used
; Do not touch or change this section
spikes = 0

; Default state of lock keys
SetNumLockState, AlwaysOn
SetScrollLockState, AlwaysOff
; SetCapsLockState, AlwaysOff

; Convert CapsLock as a Shift
; Capslock::Shift
; Return

; RControl & RShift::AltTab  ; Hold down right-control then press right-shift repeatedly to move forward.
; Minor issue with this.  It is holding the normal 0 from being sent.  Will need to look into that.
; Numpad0 & Numpad3::AltTab ; Hold down Numpad0 and press Numpad3 to move forward in the AltTab.  Select the window with left click afterwards.

^1::
    gosub, fuckakey
    Gui, 1:Destroy
    Gui, 1:Font,, Consolas
    Gui, 1:Color, Silver
    Gui, 1:Add, Tab3,, Help|Configure ME!
    Gui, 1:Add, Edit, Readonly r36 w600 vhelptext, %helptext%
    Gui, 1:Tab, 2
    Gui, 1:Add, Text,, Role:
    Gui, 1:Add, Text,, CallSign:
    Gui, 1:Add, Text,, MyID:
    Gui, 1:Add, Text,, TowCompany:
    Gui, 1:Add, Text,, Name:
    Gui, 1:Add, Text,, Title:
    Gui, 1:Add, Text,, Department:
    Gui, 1:Add, Text,, ms Delay:
    Gui, 1:Add, Text,, The following should only be modified if playing on a different server.
    Gui, 1:Add, Text,, Radio:
    Gui, 1:Add, Text,, Third Party Action:
    Gui, 1:Add, Text,, First Party Action:
    Gui, 1:Add, Text,, Advertisement:
    Gui, 1:Add, Text,, Local OOC:
    Gui, 1:Add, Text, x210 y34, Phone Number:
    Gui, 1:Add, DropDownList, x90 y30 w110 vrolepick, |LEO|TOW|CIV|SAFR
    rolepick_TT := "Select the character role that you will be playing as"
    Gui, 1:Add, Edit, w110 vcallsign, %callsign%
    callsign_TT := "Callsign for your LEO/EMS character"
    Gui, 1:Add, Edit, w110 vmyid, %myid%
    myid_TT := "Your Train Ticket ID"
    Gui, 1:Add, Edit, w110 vtowcompany, %towcompany%
    towcompany_TT := "Towing company you work for. Name for /clockin command"
    Gui, 1:Add, Edit, w110 vname, %name%
    name_TT := "Name format Fist Initial.Last Name - D.Mallard for instance"
    Gui, 1:Add, Edit, w110 vtitle, %title%
    title_TT := "Title or Rank of your character"
    Gui, 1:Add, Edit, w110 vdepartment, %department%
    department_TT := "Department that your character works for"
    Gui, 1:Add, Edit, w110 vdelay, %delay%
    delay_TT := "milisecond delay.  Take your ping to the server x2"
    Gui, 1:Add, Edit, x140 y272 w60 vrs, %rs%
    Gui, 1:Add, Edit, w60 vds, %ds%
    Gui, 1:Add, Edit, w60 vms, %ms%
    Gui, 1:Add, Edit, w60 vas, %as%
    Gui, 1:Add, Edit, w60 vlos, %los%
    Gui, 1:Add, Edit, x290 y30 w110 vphone, %phone%
    phone_TT := "Your Phone number, after 555-"
    Gui, 1:Add, Checkbox, x100 y470 vtestmode, Enable TestMode? Default, works in-game and notepad.
    Gui, 1:Add, Button, x280 y490 h25 w80 gSave1, Save
    Gui, 1:Add, Button, x511 y490 h25 w40 gbug, BUG
    Gui, 1:Add, Button, x550 y490 h25 w65 gfeedback, Feedback
    Gui, 1:Show,, Making the world a better place
    OnMessage(0x200, "WM_MOUSEMOVE")
    Gosub, ReadConfiguration ; Load configuration previously saved.
    Return

    1GuiEscape: ; Hitting escape key while open
    1GuiClose: ; Hitting the X while open
    Gui, 1:Cancel
    Return

    Save1:
    Gui, 1:Submit
    ; Towing related section
    tadv = %as% I work for [^3%towcompany%^0] and we do cool tow stuff that makes tows happy 555-%phone%!!
    tsend = %rs% [^3TOW%myid%^0] Send it!
    ; Police related section
    medicalmsg = %los% Hello I am ^1%title% %name% %department%^0, Please use this time to perform the medical activities required for the wounds you have received.  Using ^1/do's ^0and ^1/me's ^0to simulate your actions and the Medical staff actions. -Once completed. Use ^1/do Medical staff waves the %title% in^0.
    towmsg1 = %rs% [^1%callsign%^0] to [^3TOW^0]
    GoSub, UpdateConfig

    ; ============================================ CUSTOM MSGS GUI ============================================
    ; Gui for all of the customized messages to display in-game
    Gui, 2:Destroy
    Gui, 2:Font,, Consolas
    Gui, 2:Color, Silver
    if (rolepick = "LEO") {
        Gui, 2:Add, tab3,, LEO|Help|General
    } else if (rolepick = "TOW") {
        Gui, 2:Add, tab3,, TOW|Help|General
        Gui, 2:Tab, 12
    } else if (rolepick = "SAFR") {
        Gui, 2:Add, tab3,, SAFR|Help|General
        Gui, 2:Tab, 12
    } else if (rolepick = "CIV") {
        Gui, 2:Add, tab3,, CIV|Help|General
        Gui, 2:Tab, 12
    } else {
        Gui, 2:Add, Tab3,, LEO|TOW|CIV|SAFR|Help|General
    }
    Gui, 2:Add, Text,, %helptext2%
    Gui, 2:Add, Text,x20 y82, tdutystartmsg:
    Gui, 2:Add, Text,x20 y120, towmsg1:
    Gui, 2:Add, Text,x20 y148, tfriskmsg:
    Gui, 2:Add, Text,x20 y188, tsearchmsg:
    Gui, 2:Add, Text,x20 y228, tmedicalmsg:
    Gui, 2:Add, Text,x20 y370, Spikes:
    Gui, 2:Add, Text,, Vehicle Image Search:
    Gui, 2:Add, Text,, RunPlate:
    Gui, 2:Add, Text,x350 y370, Tow Initiate:
    Gui, 2:Add, Text,, Tow Information:
    Gui, 2:Add, Edit, r2 vdutystartmsg w500 x115 y80, %dutystartmsg%
    dutystartmsg_TT := "Bodycam duty start message"
    Gui, 2:Add, Edit, r1 vtowmsg1 w500, %towmsg1%
    towmsg1_TT := "Initial call to tow on radio"
    Gui, 2:Add, Edit, r2 vfriskmsg w500, %friskmsg%
    friskmsg_TT := "Message for when frisking a subject"
    Gui, 2:Add, Edit, r2 vsearchmsg w500, %searchmsg%
    searchmsg_TT := "Message for when searching a subject completely"
    Gui, 2:Add, Edit, r4 vmedicalmsg w500, %medicalmsg%
    medicalmsg_TT := "OOC message that you would tell someone to perform their own medical process"
    Gui, 2:Add, Hotkey, w150 x150 y365 vspikeshk, %spikeshk%
    spikeshk_TT := "Hotkey to be used to deploy/remove spike strip"
    Gui, 2:Add, Hotkey, w150 vvehimgsearchhk, %vehimgsearchhk%
    vehimgsearchhk_TT := "Hotkey to search for a vehicle's image on google"
    Gui, 2:Add, Hotkey, w150 vrunplatehk, %runplatehk%
    runplatehk_TT := "Hotkey to run a plate"
    Gui, 2:Add, Hotkey, w150 x450 y365 vtowcallhk, %towcallhk%
    towcallhk_TT := "Initiates the request for a tow truck"
    Gui, 2:Add, Hotkey, w150 vtowrespondhk, %towrespondhk%
    towrespondhk_TT := "Lets the tow truck know where you are and what you want them to tow"
    ; This section will pick the TOW
    if (rolepick = "LEO") {
        Gui, 2:Tab, 12
    } else if (rolepick = "TOW") {
        Gui, 2:Tab, 1
    } else if (rolepick = "SAFR") {
        Gui, 2:Tab, 13
    } else if (rolepick = "CIV") {
        Gui, 2:Tab, 13
    } else {
        Gui, 2:Tab, 2
    }
    Gui, 2:Add, Text,r3, tadv:
    Gui, 2:Add, Text,r1, tsend:
    Gui, 2:Add, Text,r2, ttowmsg1:
    Gui, 2:Add, Text,r2, ttowmsg2:
    Gui, 2:Add, Text,r2, tsecure1:
    Gui, 2:Add, Text,r2, tsecure2:
    Gui, 2:Add, Text,r2, treleasemsg1:
    Gui, 2:Add, Text,r2, treleasemsg2:
    Gui, 2:Add, Edit, r3 vtadv w500 x100 y30, %tadv%
    tadv_TT := "Advertisement you use for your tow company"
    Gui, 2:Add, Edit, r1 vtsend w500, %tsend%
    tsend_TT := "Typical send it tow response to call for tow"
    Gui, 2:Add, Edit, r2 vttowmsg1 w500, %ttowmsg1%
    ttowmsg1_TT := "Hooking up vehicle from the front"
    Gui, 2:Add, Edit, r2 vttowmsg2 w500, %ttowmsg2%
    ttowmsg2_TT := "Hooking up vehicle from the rear"
    Gui, 2:Add, Edit, r2 vtsecure1 w500, %tsecure1%
    tsecure1_TT := "Securing the tow straps to the rear"
    Gui, 2:Add, Edit, r2 vtsecure2 w500, %tsecure2%
    tsecure2_TT := "Securing the tow straps to the front"
    Gui, 2:Add, Edit, r2 vtreleasemsg1 w500, %treleasemsg1%
    treleasemsg1_TT := "Releasing the cables and the winch from the rear"
    Gui, 2:Add, Edit, r2 vtreleasemsg2 w500, %treleasemsg2%
    treleasemsg2_TT := "Releasing the cables and the winch from the front"
    ; This section will pick the SAFR
    if (rolepick = "LEO") {
        Gui, 2:Tab, 13
    } else if (rolepick = "TOW") {
        Gui, 2:Tab, 13
    } else if (rolepick = "SAFR") {
        Gui, 2:Tab, 1
    } else if (rolepick = "CIV") {
        Gui, 2:Tab, 14
    } else {
        Gui, 2:Tab, 3
    }
    Gui, 2:Add, Text,r1, SAFR Placeholder - ideas certainly welcome :P
    ; This section will pick the CIV
    if (rolepick = "LEO") {
        Gui, 2:Tab, 14
    } else if (rolepick = "TOW") {
        Gui, 2:Tab, 14
    } else if (rolepick = "SAFR") {
        Gui, 2:Tab, 14
    } else if (rolepick = "CIV") {
        Gui, 2:Tab, 1
    } else {
        Gui, 2:Tab, 4
    }
    Gui, 2:Tab, Help,, Exact
    Gui, 2:Add, Text,x20 y30, tmicmsg:
    Gui, 2:Add, Text,x20 y85, tpaystatemsg:
    Gui, 2:Add, Text,x20 y150, Garbage Items:
    Gui, 2:Add, Edit, r3 w500 x110 y30 vmicmsg, %micmsg%
    micmsg_TT := "Message used to explain how to use/configure microphone"
    Gui, 2:Add, Edit, r4 w500 x110 y85 vpaystatemsg, %paystatemsg%
    paystatemsg_TT := "Message used to explain how to handle state debt"
    Gui, 2:Add, Edit, r5 w500 x110 y150 vItemsar, %Itemsar%
    Itemsar_TT := "Add items into this list, separated by commas to add to the glovebox and trunk search."
    Gui, 2:Tab, General,, Exact
    Gui, 2:Add, Text, , tgunmsg:
    Gui, 2:Add, Text, r2, valet2hkmsg:
    Gui, 2:Add, Text, , phrechkmsg:
    Gui, 2:Add, Text, y200 x20, Engine Hotkey:
    Gui, 2:Add, Text,, Seatbelt Hotkey:
    Gui, 2:Add, Text,, Valet App Hotkey:
    Gui, 2:Add, Text,, Valet Call Hotkey:
    Gui, 2:Add, Text,, Phone Record Hotkey:
    Gui, 2:Add, Edit, r1 vgunmsg w500 x100 y30, %gunmsg%
    gunmsg_TT := "Action message to draw a firearm"
    Gui, 2:Add, Edit, r2 vvalet2hkmsg w500, %valet2hkmsg%
    valet2hkmsg_TT := "Action to be used to pull out a vehicle from the valet"
    Gui, 2:Add, Edit, r1 vphrechkmsg w500, %phrechkmsg%
    phrechkmsg_TT := "Action message to be used when pulling out phone to record"
    Gui, 2:Add, Hotkey, w150 x140 y195 venginehk, %enginehk%
    enginehk_TT := "Hotkey to be used to force the /engine on when cruise doesn't work"
    Gui, 2:Add, Hotkey, w150 vseatbelthk, %seatbelthk%
    seatbelthk_TT := "Hotkey to be used to put the seatbelt in a vehicle on or off"
    Gui, 2:Add, Hotkey, w150 vvalet1hk, %valet1hk%
    valet1hk_TT := "Hotkey to use your phone valet app"
    Gui, 2:Add, Hotkey, w150 vvalet2hk, %valet2hk%
    valet2hk_TT := "Hotkey to call for the valet to get your vehicle"
    Gui, 2:Add, Hotkey, w150 vphrechk, %phrechk%
    phrechk_TT := "Hotkey to start recording with your phone"
    Gui, 2:Tab
    Gui, 2:Add, Button, default x10 y480 w80, OK  ; The label ButtonOK (if it exists) will be run when the button is pressed.
    Gui, 2:Add, Button, x520 y480 h25 w40 gbug, BUG
    Gui, 2:Add, Button, x560 y480 h25 w65 gfeedback, Feedback
    Gui, 2:Show,, Main responses for the system - builds from original variables
    OnMessage(0x200, "WM_MOUSEMOVE")
    Return

    2GuiClose:
    2GuiEscape:
    Msgbox Nope lol
    Gui, 2:Cancel
    Return

    2ButtonOK:
    Gui, 2:Submit  ; Save the input from the user to each control's associated variable.
    Gosub, UpdateConfig
    Gosub, hotkeys
Return

; Empty Recycle Bin
#Del::FileRecycleEmpty ; Windows + Del
Return

; Suspend Hotkey
#ScrollLock::Suspend ; Windows + ScrollLock
Return

; Reload Hotkey
#Insert::Reload ; Windows + Insert
Return

#\::ListVars
Return

; ====================== GTAV Stuff =========================

; not used on SOE - F4 F7 F10 F11
; Pressing T to open chat and then typing unrack/rack

; ============================================ LEO Stuff ============================================
#if (rolepick = "LEO")

    ; This will lay the spikes or remove the spikes based on variable.
    ; ^.:: ; Control + . in-game
    sphk:
    if (WinActive("FiveM") || WinActive("Untitled - Notepad") || WinActive("*Untitled - Notepad") || (testmode = 1)) {
        clipaboard = %clipboard%
        Sleep, %delay%
        if (spikes = 0) {
            Send, {t down}
            Sleep, %delay%
            Send, {t up}
            Sleep, %delay%
            Clipboard = /spikes
            Send, {RCtrl down}v{RCtrl up}{enter}
            spikes = 1
        } else {
            Send, {t down}
            Sleep, %delay%
            Send, {t up}
            Sleep, %delay%
            Clipboard = /rspikes
            Send, {Rctrl down}v{Rctrl up}{enter}
            spikes = 0
        }
        Sleep, %delay%
        Clipboard = %clipaboard%
    }
    Return

    ; Runplate to be ran and save the plate you ran, also caches the name into clipboard
    ; ^-:: ; Control + -
    rphk:
    if (WinActive("FiveM") || WinActive("Untitled - Notepad") || WinActive("*Untitled - Notepad") || (testmode = 1)) {
        Send, {t down}
        Sleep, %delay%
        Send, {t up}
        Sleep, %delay%
        Clipboard := "/runplate "
        Send, {Rctrl down}v{Rctrl up}
    }
    Return

    ; This will be used to set your callsign for the environment.
    :*:tdutystart:: ; Type tdutystart in-game
    if (WinActive("FiveM") || WinActive("Untitled - Notepad") || WinActive("*Untitled - Notepad") || (testmode = 1)) {
        if (!callsign) {
            InputBox, callsign, CallSign, Enter your callsign to use.
        }
        if (!name) {
            Inputbox, name, Name, Enter your name to use.
        }
        clipaboard = %clipboard%
        Sleep, %delay%
        Clipboard = %dutystartmsg%
        Send, {Rctrl down}v{Rctrl up}{enter}
        Sleep, %delay%
        Send, {F7 down}
        Sleep, %delay%
        Send, {F7 up}
        Sleep, %delay%
        Send, {F9 down}
        Sleep, %delay%
        Send, {F9 up}
        Sleep, %delay%
        Clipboard = %clipaboard%
    }
    Return

    ; Changes radio channel to channel 5 and then calls for tow on that channel.
    ; ^k:: ; Control + k
    tchk:
    if (WinActive("FiveM") || WinActive("Untitled - Notepad") || WinActive("*Untitled - Notepad") || (testmode = 1)) {
        clipaboard = %clipboard%
        Sleep, %delay%
        Send, {t down}
        Sleep, %delay%
        Send, {t up}
        Sleep, %delay%
        Clipboard = /rc 5
        Send, {Rctrl down}v{Rctrl up}{enter}
        Sleep, %delay%
        Send, {t down}
        Sleep, %delay%
        Send, {t up}
        Sleep, %delay%
        Clipboard = %towmsg1%
        Send, {Rctrl down}v{Rctrl up}{enter}
        Sleep, %delay%
        Clipboard = %clipaboard%
    }
    Return

    ; Sending out the tow location to towid.
    ; ^j:: ; Control + j
    trhk:
    if (WinActive("FiveM") || WinActive("Untitled - Notepad") || WinActive("*Untitled - Notepad") || (testmode = 1)) {
        InputBox, towloc, Tow Location, Enter Towing Location
        if (towloc = "") {
            MsgBox, No tow Location was entered, Try again.
        } else {
            InputBox, towid, Tow ID, Enter Towing ID
            if (towid = "") {
                Msgbox, No Tow ID was entered.  Try again.
            } else {
                InputBox, veh, Vehicle, Description and color
                if (veh = "") {
                    MsgBox No Vehicle was entered. Try again.
                } else {
                    clipaboard = %clipboard%
                    Sleep, %delay%
                    Send, {t down}
                    Sleep, %delay%
                    Send, {t up}
                    Sleep, %delay%
                    Clipboard = %rs% [^1%callsign%^0] to [^3TOW%towid%^0] I have a %veh% for you at %towloc%
                    Send, {Rctrl down}v{Rctrl up}{enter}
                    Sleep, %delay%
                    Clipboard = %clipaboard%
                }
            }
        }
    }
    Return

    ; Frisks the Subject for weapons.
    :*:tfrisk:: ; Type tfrisk in-game
    if (WinActive("FiveM") || WinActive("Untitled - Notepad") || WinActive("*Untitled - Notepad") || (testmode = 1)) {
        clipaboard = %clipboard%
        Sleep, %delay%
        Clipboard = %friskmsg%
        Send, {Rctrl down}v{Rctrl up}{enter}
        Sleep, %delay%
        Send, {t down}
        Sleep, %delay%
        Send, {t up}
        Sleep, %delay%
        Clipboard = /frisk
        Send, {Rctrl down}v{Rctrl up}{enter}
        Sleep, %delay%
        Clipboard = %clipaboard%
    }
    Return

    ; Fully searches the Subject.
    :*:tsearch:: ; Type tsearch in-game
    if (WinActive("FiveM") || WinActive("Untitled - Notepad") || WinActive("*Untitled - Notepad") || (testmode = 1)) {
        clipaboard = %clipboard%
        Sleep, %delay%
        Clipboard = %searchmsg%
        Send, {Rctrl down}v{Rctrl up}{enter}
        Sleep, %delay%
        Send, {t down}
        Sleep, %delay%
        Send, {t up}
        Sleep, %delay%
        Clipboard = /search
        Send, {Rctrl down}v{Rctrl up}{enter}
        Sleep, %delay%
        Clipboard = %clipaboard%
    }
    Return

    ; Touches the vehicle on approach
    ; cmd is /touchveh
    :*:ttv:: ; Type ttv in-game
    if (WinActive("FiveM") || WinActive("Untitled - Notepad") || WinActive("*Untitled - Notepad") || (testmode = 1)) {
        clipaboard = %clipboard%
        Sleep, %delay%
        Clipboard = %ms% touches the trunk lid of the vehicle
        Send, {Rctrl down}v{Rctrl up}{enter}
        Sleep, %delay%
        Clipboard = %clipaboard%
    }
    Return

    ; Tells subject on how to do the medical RP for themselves.
    :*:tmedical:: ; Type tmedical in-game
    if (WinActive("FiveM") || WinActive("Untitled - Notepad") || WinActive("*Untitled - Notepad") || (testmode = 1)) {
        clipaboard = %clipboard%
        Sleep, %delay%
        Clipboard = %medicalmsg%
        Send, {Rctrl down}v{Rctrl up}{enter}
        Sleep, %delay%
        Clipboard = %clipaboard%
    }
    Return

    ; Test running through timing.
    :*:ttest:: ; Type ttest in-game
    if (WinActive("FiveM") || WinActive("Untitled - Notepad") || WinActive("*Untitled - Notepad") || (testmode = 1)) {
        clipaboard = %clipboard%
        Sleep, %delay%
        Clipboard = /e notepad
        Send, {Rctrl down}v{Rctrl up}{enter}
        Sleep, %delay%
        Send, {t down}
        Sleep, %delay%
        Send, {t up}
        Sleep, %delay%
        Clipboard = %ms% notes a few things to himself that he thinks are important.
        Send, {Rctrl down}v{Rctrl up}{enter}
        Sleep, %delay%
        Clipboard = %clipaboard%
    }
    Return

    ; Pulls out the notepad to write out the plate of the vehicle
    :*:tplate:: ; Type tplate in-game
    if (WinActive("FiveM") || WinActive("Untitled - Notepad") || WinActive("*Untitled - Notepad") || (testmode = 1)) {
        clipaboard = %clipboard%
        Sleep, %delay%
        Clipboard = /e notepad
        Send, {Rctrl down}v{Rctrl up}{enter}
        Sleep, %delay%
        Send, {t down}
        Sleep, %delay%
        Send, {t up}
        Sleep, %delay%
        Clipboard = %ms% notes the plate down
        Send, {Rctrl down}v{Rctrl up}{enter}
        Sleep, %delay%
        Send, {m down}
        Sleep, %delay%
        Send, {m up}
        Sleep, %delay%
        Clipboard = %clipaboard%
    }
    Return

    ; Pulls out notepad to write out the vin of the vehicle.
    :*:tvin:: ;Type tvin in-game
    if (WinActive("FiveM") || WinActive("Untitled - Notepad") || WinActive("*Untitled - Notepad") || (testmode = 1)) {
        clipaboard = %clipboard%
        Sleep, %delay%
        Clipboard = /e notepad
        Send, {Rctrl down}v{Rctrl up}{enter}
        Sleep, %delay%
        Send, {t down}
        Sleep, %delay%
        Send, {t up}
        Sleep, %delay%
        Clipboard = %ms% notes the vin information
        Send, {Rctrl down}v{Rctrl up}{enter}
        Sleep, %delay%
        Send, {t down}
        Sleep, %delay%
        Send, {t up}
        Sleep, %delay%
        Clipboard = /vin
        Send, {Rctrl down}v{Rctrl up}{enter}
        Sleep, %delay%
        Clipboard = %clipaboard%
    }
    Return

    ; Pulls out notepad to write out and plate impound sticker on vehicle
    :*:timpound:: ; Type timpound in-game
    if (WinActive("FiveM") || WinActive("Untitled - Notepad") || WinActive("*Untitled - Notepad") || (testmode = 1)) {
        clipaboard = %clipboard%
        Sleep, %delay%
        Clipboard = /e notepad
        Send, {Rctrl down}v{Rctrl up}{enter}
        Sleep, %delay%
        Send, {t down}
        Sleep, %delay%
        Send, {t up}
        Sleep, %delay%
        Clipboard = %ms% tears off the written impound sticker and places it on the vehicle
        Send, {Rctrl down}v{Rctrl up}{enter}
        Sleep, %delay%
        Send, {t down}
        Sleep, %delay%
        Send, {t up}
        Sleep, %delay%
        Clipboard = /impound
        Send, {Rctrl down}v{Rctrl up}{enter}
        Sleep, %delay%
        Clipboard = %clipaboard%
    }
    Return

    ; Searches through the glovebox of a vehicle
    :*:tsglovebox:: ; Type tsglovebox in-game
    if (WinActive("FiveM") || WinActive("Untitled - Notepad") || WinActive("*Untitled - Notepad") || (testmode = 1)) {
        Items := StrSplit(Itemsar, ",")
        Random, Item, 1, Items.MaxIndex()
        Picked := Items[Item]
        clipaboard = %clipboard%
        Sleep, %delay%
        Clipboard = %ms% begins searching the the interior of the vehicle and finds some %Picked%.
        Send, {Rctrl down}v{Rctrl up}{enter}
        Sleep, %delay%
        Send, {t down}
        Sleep, %delay%
        Send, {t up}
        Sleep, %delay%
        Clipboard = /inv
        Send, {Rctrl down}v{Rctrl up}{enter}
        Sleep, %delay%
        Clipboard = %clipaboard%
    }
    Return

    ; Searches through the trunk of a vehicle
    :*:tstrunk:: ; Type tstrunk in-game
    if (WinActive("FiveM") || WinActive("Untitled - Notepad") || WinActive("*Untitled - Notepad") || (testmode = 1)) {
        Items := StrSplit(Itemsar, ",")
        Random, Item, 1, Items.MaxIndex()
        Picked := Items[Item]
        clipaboard = %clipboard%
        Sleep, %delay%
        Clipboard = /car t open
        Send, {Rctrl down}v{Rctrl up}{enter}
        Sleep, %delay%
        Send, {t down}
        Sleep, %delay%
        Send, {t up}
        Sleep, %delay%
        Clipboard = %ms% begins searching the the trunk of the vehicle and finds some %Picked%.
        Send, {Rctrl down}v{Rctrl up}{enter}
        Sleep, %delay%
        Send, {t down}
        Sleep, %delay%
        Send, {t up}
        Sleep, %delay%
        Clipboard = /inv
        Send, {Rctrl down}v{Rctrl up}{enter}
        Msgbox, Once completed with your inventory actions, Press T
        KeyWait, t, D
        Sleep, %delay%
        Send, {t down}
        Sleep, %delay%
        Send, {t up}
        Sleep, %delay%
        Clipboard = /car t
        Send, {Rctrl down}v{Rctrl up}{enter}
        Sleep, %delay%
        Clipboard = %clipaboard%
    }
    Return

    ; Items that can be pulled out from the trunk of a vehicle.
    :*:ttrunk:: ; Type ttrunk in-game
    if (WinActive("FiveM") || WinActive("Untitled - Notepad") || WinActive("*Untitled - Notepad") || (testmode = 1)) {
        InputBox, titem, Trunk Item, What do you want from your trunk?
        if ErrorLevel
            Return
        else
        if (titem = "medbag" || titem = "slimjim" || titem = "tintmeter" || titem = "cones" || titem = "gsr" || titem = "breathalizer" || titem = "bodybag") {
            clipaboard = %clipboard%
            Sleep, %delay%
            Clipboard = /car t open
            Send, {Rctrl down}v{Rctrl up}{enter}
            Sleep, %delay%
            Send, {t down}
            Sleep, %delay%
            Send, {t up}
            Sleep, %delay%
            if (titem = "cones") {
                Clipboard = %ms% Grabs a few %titem% from the trunk
            } else if (titem = "gsr") {
                Clipboard = %ms% Grabs a %titem% kit from the trunk
            } else {
                Clipboard = %ms% Grabs a %titem% from the trunk
            }
            Send, {Rctrl down}v{Rctrl up}{enter}
            If (titem = "medbag") {
                Sleep, %delay%
                Send, {t down}
                Sleep, %delay%
                Send, {t up}
                Sleep, %delay%
                Clipboard = /inv
                Send, {Rctrl down}v{Rctrl up}{enter}
                Msgbox, Once completed with your inventory actions, Press T
                KeyWait, t, D
            }
            Sleep, %delay%
            Send, {t down}
            Sleep, %delay%
            Send, {t up}
            Sleep, %delay%
            Clipboard = /car t
            Send, {Rctrl down}v{Rctrl up}{enter}
            Sleep, %delay%
            Clipboard = %clipaboard%
        } else {
            Send, {enter}
            MsgBox, That %titem% is not in your trunk. Try again.
        }
    }
    Return
    ; ============================================ CIV Stuff ============================================
#If (rolepick = "CIV")
    ; Proper way to pull out a firearm.
    :*:tgun:: ; Type tgun in-game
    if (WinActive("FiveM") || WinActive("Untitled - Notepad") || WinActive("*Untitled - Notepad") || (testmode = 1)) {
        clipaboard = %clipboard%
        Sleep, %delay%
        Clipboard = %gunmsg%
        Send, {Rctrl down}v{Rctrl up}{enter}
        Sleep, %delay%
        Send, {6 down}
        Sleep, %delay%
        Send, {6 up}
        Sleep, %delay%
        Clipboard = %clipaboard%
    }
    Return
    ; ============================================ TOW Stuff ============================================
#If (rolepick = "TOW")
    :*:tstart:: ; Type tstart in-game
    if (WinActive("FiveM") || WinActive("Untitled - Notepad") || WinActive("*Untitled - Notepad") || (testmode = 1)) {
        clipaboard = %clipboard%
        Sleep, %delay%
        Clipboard = /rc %trc%
        Send, {Rctrl down}v{Rctrl up}{enter}
        Sleep, %delay%
        Send, {t down}
        Sleep, %delay%
        Send, {t up}
        Sleep, %delay%
        Clipboard = /clockin %towcompany%
        Send, {Rctrl down}v{Rctrl up}{enter}
        Sleep, %delay%
        Clipboard = %clipaboard%
    }
    Return

    :*:tadv:: ; Type tadv in-game
    if (WinActive("FiveM") || WinActive("Untitled - Notepad") || WinActive("*Untitled - Notepad") || (testmode = 1)) {
        clipaboard = %clipboard%
        Sleep, %delay%
        Clipboard = %tadv%
        Send, {Rctrl down}v{Rctrl up}{enter}
        Sleep, %delay%
        Clipboard = %clipaboard%
    }
    Return

    :*:tsend:: ; Type tsend in-game
    if (WinActive("FiveM") || WinActive("Untitled - Notepad") || WinActive("*Untitled - Notepad") || (testmode = 1)) {
        clipaboard = %clipboard%
        Sleep, %delay%
        Clipboard = %tsend%
        Send, {Rctrl down}v{Rctrl up}{enter}
        Sleep, %delay%
        Clipboard = %clipaboard%
    }
    Return

    ; Responds to anyone that may be calling for tow.
    :*:tonway:: ; Type tonway in-game
    if (WinActive("FiveM") || WinActive("Untitled - Notepad") || WinActive("*Untitled - Notepad") || (testmode = 1)) {
        InputBox, caller, Tow Location, Enter Caller information
        if (caller = "") {
            MsgBox, No Caller information was entered, Try again.
        } else {
            InputBox, eta, Tow ID, Enter Estimated Time of Arrival (ETA) in minutes.
            if (eta = "") {
                Msgbox, No ETA was entered.  Try again.
            } else {
                clipaboard = %clipboard%
                Sleep, %delay%
                Clipboard = %rs% [^3TOW%myid%^0] to [^1%caller%^0] will be 76 to you ETA %eta% mikes.
                Send, {Rctrl down}v{Rctrl up}{enter}
                Sleep, %delay%
                Clipboard = %clipaboard%
            }
        }
    }
    Return

    ; To start the tow of a front or rear facing vehicle.
    :*:ttow:: ; Type ttow in-game
    if (WinActive("FiveM") || WinActive("Untitled - Notepad") || WinActive("*Untitled - Notepad") || (testmode = 1)) {
        InputBox, towtype, Facing Direction, Type f for front b for back.
        if (towtype = "f" || towtype = "b") {
            clipaboard = %clipboard%
            Sleep, %delay%
            Clipboard = /emote kneel
            Send, {Rctrl down}v{Rctrl up}{enter}
            Sleep, %delay%
            Send, {t down}
            Sleep, %delay%
            Send, {t up}
            Sleep, %delay%
            if (towtype = "f") {
                Clipboard = %ttowmsg1%
            } else if (towtype = "b") {
                Clipboard = %ttowmsg2%
            }
            Send, {Rctrl down}v{Rctrl up}{enter}
            Sleep, %delay%
            Clipboard = /tow
            Send, {Rctrl down}v{Rctrl up}{enter}
            Sleep, %delay%
            Clipboard = %clipaboard%
        } else {
            MsgBox, f or b only. Try again.
        }
    }
    Return

    ; To secure the vehicle to the tow truck.
    :*:tsecure:: ; Type tsecure in-game
    if (WinActive("FiveM") || WinActive("Untitled - Notepad") || WinActive("*Untitled - Notepad") || (testmode = 1)) {
        clipaboard = %clipboard%
        Sleep, %delay%
        Clipboard = /emote kneel
        Send, {Rctrl down}v{Rctrl up}{enter}
        Sleep, %delay%
        Send, {t down}
        Sleep, %delay%
        Send, {t up}
        Sleep, %delay%
        if (towtype = "f") {
            Clipboard = %tsecure1%
        } else {
            Clipboard = %tsecure2%
        }
        Send, {Rctrl down}v{Rctrl up}{enter}
        Sleep, %delay%
        Clipboard = %clipaboard%
    }
    Return

    ; To release the vehicle from the tow truck.
    :*:trelease:: ; Type trelease in-game
    if (WinActive("FiveM") || WinActive("Untitled - Notepad") || WinActive("*Untitled - Notepad") || (testmode = 1)) {
        clipaboard = %clipboard%
        Sleep, %delay%
        if (towtype = "f") {
            Clipboard = %treleasemsg1%
        } else {
            Clipboard = %treleasemsg2%
        }
        Send, {Rctrl down}v{Rctrl up}{enter}
        Sleep, %delay%
        Send, {t down}
        Sleep, %delay%
        Send, {t up}
        Sleep, %delay%
        Clipboard = /tow
        Send, {Rctrl down}v{Rctrl up}{enter}
        Sleep, %delay%
        Clipboard = %clipaboard%
    }
    Return

    ; To pull out Kitty Litter from tow truck for use.
    :*:tkitty:: ; Type tkitty in-game
    if (WinActive("FiveM") || WinActive("Untitled - Notepad") || WinActive("*Untitled - Notepad") || (testmode = 1)) {
        clipaboard = %clipboard%
        Sleep, %delay%
        Clipboard = %ms% opens the toolbox and removes kitty litter from it
        Send, {Rctrl down}v{Rctrl up}{enter}
        Sleep, %delay%
        Clipboard = %clipaboard%
    }
    Return
    ; ============================================ SAFR Stuff ============================================
#If (rolepick = "SAFR")
    ; Items that can be pulled out from the trunk of a vehicle.
    :*:ttrunk:: ; Type ttrunk in-game
    if (WinActive("FiveM") || WinActive("Untitled - Notepad") || WinActive("*Untitled - Notepad") || (testmode = 1)) {
        vehicle = bus
        Inputbox, bside, Choose your side!, Which side of the %vehicle% are you on? Use l or r for left or right.
        if  (bside = "l" || bside = "r") {
            InputBox, bitem, Item, What do you want to get from your %vehicle%?
            if ErrorLevel
                Return
            else
                if (bitem = "medbag" || bitem = "cones" || bitem = "bodybag") {
                    clipaboard = %clipboard%
                    SLeep, %delay%
                    Clipboard = /door b%bside%
                    Send, {Rctrl down}v{Rctrl up}{enter}
                    Sleep, %delay%
                    Send, {t down}
                    Sleep, %delay%
                    Send, {t up}
                    Sleep, %delay%
                    if (bitem = "cones") {
                        Clipboard = %ms% grabs a few %bitem% from the %vehicle%
                    } else {
                        Clipboard = %ms% grabs a %bitem% from the %vehicle%
                    }
                    Send, {Rctrl down}v{Rctrl up}{enter}
                    If (bitem = "medbag") {
                        Sleep, %delay%
                        Send, {t down}
                        Sleep, %delay%
                        Send, {t up}
                        Sleep, %delay%
                        Clipboard = /e %bitem%
                        Send, {Rctrl down}v{Rctrl up}{enter}
                    }
                    Sleep, %delay%
                    Send, {t down}
                    Sleep, %delay%
                    Send, {t up}
                    Sleep, %delay%
                    Clipboard = /door b%bside%
                    Send, {Rctrl down}v{Rctrl up}{enter}
                    Sleep, %delay%
                    Clipboard = %clipaboard%
                } else {
                    Send, {enter}
                    MsgBox, That %bitem% is not in your %vehicle%. Try again.
                }
        } else {
            Send, {enter}
            MsgBox, That %bside% is not a proper %vehicle%. Try agian.
        }
    }
    Return
    ; ============================================ HELP Stuff ============================================
#IF
; This provides the help text for micropohone fixing in local ooc chat
:*:tmic:: ; Type tmic in-game
if (WinActive("FiveM") || WinActive("Untitled - Notepad") || WinActive("*Untitled - Notepad") || (testmode = 1)) {
    clipaboard = %clipboard%
    Sleep, %delay%
    Clipboard = %micmsg%
    Send, {Rctrl down}v{Rctrl up}{enter}
    Sleep, %delay%
    Clipboard = %clipaboard%
}
Return

; This provides help text for the paying of state debt in local ooc chat
:*:tpaystate:: ; Type tpaystate in-game
if (WinActive("FiveM") || WinActive("Untitled - Notepad") || WinActive("*Untitled - Notepad") || (testmode = 1)) {
    clipaboard = %clipboard%
    Sleep, %delay%
    Clipboard = %paystatemsg%
    Send, {Rctrl down}v{Rctrl up}{enter}
    Sleep, %delay%
    Clipboard = %clipaboard%
}
Return

; This is a quick way of buckling or unbuckling your seatbelt
; F1:: ; Press F1 in-game
sbhk:
if (WinActive("FiveM") || WinActive("Untitled - Notepad") || WinActive("*Untitled - Notepad") || (testmode = 1)) {
    clipaboard = %clipboard%
    Sleep, %delay%
    Send, {t down}
    Sleep, %delay%
    Send, {t up}
    Sleep, %delay%
    Clipboard = /seatbelt
    Send, {Rctrl down}v{Rctrl up}{enter}
    Sleep, %delay%
    Clipboard = %clipaboard%
}
Return

; This provides the help text for State of Emergency inforamtion in local ooc chat
:*:tsoehelp:: ; Type tsoehelp in-game
if (WinActive("FiveM") || WinActive("Untitled - Notepad") || WinActive("*Untitled - Notepad") || (testmode = 1)) {
    clipaboard = %clipboard%
    Sleep, %delay%
    Clipboard := "/l State of Emergency information at ^1 https://evolpcgaming.com/ ^0 for the forums and for the player list ^2 https://soe.gg/ ^0 for guides ^1 https://evolpcgaming.com/guidelines/ ^0"
    Send, {Rctrl down}v{Rctrl up}{enter}
    Sleep, %delay%
    Clipboard = %clipaboard%
}
Return

; This will run the /engine command to toggle engine state
; F7:: ; Press F7 in-game
enhk:
if (WinActive("FiveM") || WinActive("Untitled - Notepad") || WinActive("*Untitled - Notepad") || (testmode = 1)) {
    clipaboard = %clipboard%
    Sleep, %delay%
    Send, {t down}
    Sleep, %delay%
    Send, {t up}
    Sleep, %delay%
    Clipboard = /engine
    Send, {Rctrl down}v{Rctrl up}{enter}
    Sleep, %delay%
    Clipboard = %clipaboard%
}
Return

; This is the ability to check your valet on the phone
; +F11:: ; Press Shift+F11 in-game
val1hk:
if (WinActive("FiveM") || WinActive("Untitled - Notepad") || WinActive("*Untitled - Notepad") || (testmode = 1)) {
    clipaboard = %clipboard%
    Sleep, %delay%
    Send, {t down}
    Sleep, %delay%
    Send, {t up}
    Sleep, %delay%
    Clipboard = /e phoneplay
    Send, {Rctrl down}v{Rctrl up}{enter}
    Sleep, %delay%
    Send, {t down}
    Sleep, %delay%
    Send, {t up}
    Sleep, %delay%
    Clipboard = /valet
    Send, {Rctrl down}v{Rctrl up}{enter}
    Sleep, %delay%
    Clipboard = %clipaboard%
}
Return

; This is the ability to do an emote/do with pulling out a vehicle
; F11:: ; Press F11 in-game
val2hk:
if (WinActive("FiveM") || WinActive("Untitled - Notepad") || WinActive("*Untitled - Notepad") || (testmode = 1)) {
    clipaboard = %clipboard%
    Sleep, %delay%
    Send, {t down}
    Sleep, %delay%
    Send, {t up}
    Sleep, %delay%
    Clipboard = %valet2hkmsg%
    Send, {Rctrl down}v{Rctrl up}{enter}
    Sleep, %delay%
    Send, {t down}
    Sleep, %delay%
    Send, {t up}
    Sleep, %delay%
    Clipboard = /e atm
    Send, {Rctrl down}v{Rctrl up}{enter}
    Sleep, %delay%
    Send, {e down}
    Sleep, %delay%
    Send, {e up}
    Sleep, %delay%
    Clipboard = %clipaboard%
}
Return

; This will be used to start the video recording in character civilian
; F6:: ; Press F6 in-game
phrhk:
if (WinActive("FiveM") || WinActive("Untitled - Notepad") || WinActive("*Untitled - Notepad") || (testmode = 1)) {
    clipaboard = %clipboard%
    Sleep, %delay%
    Send, {t down}
    Sleep, %delay%
    Send, {t up}
    Sleep, %delay%
    Clipboard = %phrechkmsg%
    Send, {Rctrl down}v{Rctrl up}{enter}
    Sleep, %delay%
    Send, {t down}
    Sleep, %delay%
    Send, {t up}
    Sleep, %delay%
    Clipboard = /e film
    Send, {Rctrl down}v{Rctrl up}{enter}
    Sleep, %delay%
    Clipboard = %clipaboard%
}
Return

; ============================================ MAIN RUN FUNCTIONS ============================================

ReadConfiguration: ; Read the saved configuration
IfExist, %config% ; First check if it was saved.
{
; IniRead, outputvar, filename, section, key, default
IniRead, rolepick, %config%, Yourself, role
GuiControl, ChooseString, rolepick, %rolepick% ; Submit
}
Return

; ============================================ TOOLTIP FUNCTION ============================================

WM_MOUSEMOVE()
{
    static CurrControl, PrevControl, _TT  ; _TT is kept blank for use by the ToolTip command below.
    CurrControl := A_GuiControl
    If (CurrControl <> PrevControl and not InStr(CurrControl, " "))
    {
        ToolTip  ; Turn off any previous tooltip.
        SetTimer, DisplayToolTip, 500
        PrevControl := CurrControl
    }
    return

    DisplayToolTip:
    SetTimer, DisplayToolTip, Off
    ToolTip % %CurrControl%_TT  ; The leading percent sign tell it to use an expression.
    SetTimer, RemoveToolTip, 3000
    return

    RemoveToolTip:
    SetTimer, RemoveToolTip, Off
    ToolTip
    return
}

; ============================================ CUSTOM DEFINED HOTKEYS ============================================
; Initializes the hotkeys for generation.

hotkeys:
    hotkey, %spikeshk%, sphk, On
    hotkey, %vehimgsearchhk%, vehimghk, On
    hotkey, %runplatehk%, rphk, On
    hotkey, %towcallhk%, tchk, On
    hotkey, %towrespondhk%, trhk, On
    hotkey, %seatbelthk%, sbhk, On
    hotkey, %enginehk%, enhk, On
    hotkey, %valet1hk%, val1hk, On
    hotkey, %valet2hk%, val2hk, On
    hotkey, %phrechk%, phrhk, On
Return

fuckakey:
    hotkey, %spikeshk%, sphk, Off
    hotkey, %vehimgsearchhk%, vehimghk, Off
    hotkey, %runplatehk%, rphk, Off
    hotkey, %towcallhk%, tchk, Off
    hotkey, %towrespondhk%, trhk, Off
    hotkey, %seatbelthk%, sbhk, Off
    hotkey, %enginehk%, enhk, Off
    hotkey, %valet1hk%, val1hk, Off
    hotkey, %valet2hk%, val2hk, Off
    hotkey, %phrechk%, phrhk, Off
Return

ReadConfig:
    ; Back to the reading of the configuration
    IniRead, rolepick, %config%, Yourself, role, LEO
    IniRead, callsign, %config%, Yourself, callsign, A13
    IniRead, myid, %config%, Yourself, myid, 30
    IniRead, towcompany, %config%, Yourself, towcompany, SkinnyDick
    IniRead, name, %config%, Yourself, name, Dread
    IniRead, title, %config%, Yourself, title, Officer
    IniRead, department, %config%, Yourself, department, LSPD
    IniRead, phone, %config%, Yourself, phone, 38915
    ; Client communication and test mode
    IniRead, delay, %config%, Yourself, delay, 80
    IniRead, testmode, %config%, Yourself, testmode, 0
    ; Server related section
    IniRead, rs, %config%, Server, rs, /r
    IniRead, ds, %config%, Server, ds, /do
    IniRead, ms, %config%, Server, ms, /me
    IniRead, as, %config%, Server, as, /ad
    IniRead, los, %config%, Server, los, /l
    ; The hotkey related section
    IniRead, spikeshk, %config%, Keys, spikeshk, ^.
    IniRead, vehimgsearchhk, %config%, Keys, vehimgsearchhk, ^/
    IniRead, runplatehk, %config%, Keys, runplatehk, ^-
    IniRead, towcallhk, %config%, Keys, towcallhk, ^k
    IniRead, towrespondhk, %config%, Keys, towrespondhk, ^j
    IniRead, seatbelthk, %config%, Keys, seatbelthk, F1
    IniRead, enginehk, %config%, Keys, enginehk, F7
    IniRead, valet1hk, %config%, Keys, valet1hk, +F11
    IniRead, valet2hk, %config%, Keys, valet2hk, F11
    IniRead, phrechk, %config%, Keys, phrechk, F10
    ; Messages that correspond with the hotkeys
    ; Police related section
    IniRead, Itemsar, %config%, Police, Itemsar, Twinkie Wrappers,Hotdog buns,Potato chip bags,Used Diappers,Tools,Keyboards
    IniRead, dutystartmsg, %config%, Police, dutystartmsg, %ms% secures bodycam and validates functionality, then turns on the dashcam and validates functionality. Then logs into the MWS
    IniRead, friskmsg, %config%, Police, friskmsg, %ms% Frisks the Subject looking for any weapons and removes ALL of them
    IniRead, searchmsg, %config%, Police, searchmsg, %ms% Searches the Subject completely and stows ALL items into the evidence bags
    IniRead, medicalmsg, %config%, Police, medicalmsg, %los% Hello I am ^1%title% %name% %department%^0, Please use this time to perform the medical activities required for the wounds you have received.  Using ^1/do's ^0and ^1/me's ^0to simulate your actions and the Medical staff actions. -Once completed. Use ^1/do Medical staff waves the %title% in^0.
    IniRead, towmsg1, %config%, Police, towmsg1, %rs% [^1%callsign%^0] to [^3TOW^0]
    ; Towing related section
    IniRead, tadv, %config%, Towing, tadv, %as% I work for [^3%towcompany%^0] and we do cool tow stuff that makes tows happy 555-%phone%!!
    IniRead, tsend, %config%, Towing, tsend, %rs% [^3TOW%myid%^0] Send it!
    IniRead, ttowmsg1, %config%, Towing, ttowmsg1, %ms% attaches the winch cable to the front of the vehicle
    IniRead, ttowmsg2, %config%, Towing, ttowmsg2, %ms% attaches the winch cable to the rear of the vehicle
    IniRead, tsecure1, %config%, Towing, tsecure1, %ms% secures the rear of the vehicle with extra tow straps
    IniRead, tsecure2, %config%, Towing, tsecure2, %ms% secures the front of the vehicle with extra tow straps
    IniRead, treleasemsg1, %config%, Towing, treleasemsg1, %ms% releases the extra tow cables from the rear and pulls the winch release lever
    IniRead, treleasemsg2, %config%, Towing, treleasemsg2, %ms% releases the extra tow cables from the front and pulls the winch release lever
    ; Help related section
    IniRead, micmsg, %config%, Help, micmsg, %los% How to fix your microphone - ^2ESC^0 -> ^2Settings^0 -> ^2Voice Chat^0 -> ^2Toggle On/Off^0 -> ^2Increase Mic Volume and Mic Sensitivity^0 -> Match audio devices to the one you are using.
    IniRead, paystatemsg, %config%, Help, paystatemsg, %los% To be able to see your current state debt type ^1/paystate^0 to pay off state debt ^1/paystate amount^0.
    ; Normal related section
    IniRead, gunmsg, %config%, Normal, gunmsg, %ms% pulls out his ^1pistol ^0from under his shirt
    IniRead, valet2hkmsg, %config%, Normal, valet2hkmsg, %ms% puts in his ticket into the valet and presses the button to receive his selected vehicle
    IniRead, phrechkmsg, %config%, Normal, phrechkmsg, %ms% Pulls out their phone and starts recording audio and video
Return

UpdateConfig:
; ============================================ WRITE INI SECTION ============================================
    IniWrite, %rolepick%, %config%, Yourself, role
    IniWrite, %callsign%, %config%, Yourself, callsign
    IniWrite, %myid%, %config%, Yourself, myid
    IniWrite, %towcompany%, %config%, Yourself, towcompany
    IniWrite, %name%, %config%, Yourself, name
    IniWrite, %title%, %config%, Yourself, title
    IniWrite, %department%, %config%, Yourself, department
    IniWrite, %phone%, %config%, Yourself, phone
    ; Client communication and test mode
    IniWrite, %delay%, %config%, Yourself, delay
    IniWrite, %testmode%, %config%, Yourself, testmode
    ; Server related section
    IniWrite, %rs%, %config%, Server, rs
    IniWrite, %ds%, %config%, Server, ds
    IniWrite, %ms%, %config%, Server, ms
    IniWrite, %as%, %config%, Server, as
    IniWrite, %los%, %config%, Server, los
    ; The hotkey related section
    IniWrite, %spikeshk%, %config%, Keys, spikeshk
    IniWrite, %vehimgsearchhk%, %config%, Keys, vehimgsearchhk
    IniWrite, %runplatehk%, %config%, Keys, runplatehk
    IniWrite, %towcallhk%, %config%, Keys, towcallhk
    IniWrite, %towrespondhk%, %config%, Keys, towrespondhk
    IniWrite, F1, %config%, Keys, seatbelthk
    IniWrite, %enginehk%, %config%, Keys, enginehk
    IniWrite, %valet1hk%, %config%, Keys, valet1hk
    IniWrite, %valet2hk%, %config%, Keys, valet2hk
    IniWrite, %phrechk%, %config%, Keys, phrechk
    ; Messages that correspond with the hotkeys
    ; Police related 
    IniWrite, %Itemsar%, %config%, Police, Itemsar
    IniWrite, %dutystartmsg%, %config%, Police, dutystartmsg
    IniWrite, %friskmsg%, %config%, Police, friskmsg
    IniWrite, %searchmsg%, %config%, Police, searchmsg
    IniWrite, %medicalmsg%, %config%, Police, medicalmsg
    IniWrite, %towmsg1%, %config%, Police, towmsg1
    ; Towing related section
    IniWrite, %tadv%, %config%, Towing, tadv
    IniWrite, %tsend%, %config%, Towing, tsend
    IniWrite, %ttowmsg1%, %config%, Towing, ttowmsg1
    IniWrite, %ttowmsg2%, %config%, Towing, ttowmsg2
    IniWrite, %tsecure1%, %config%, Towing, tsecure1
    IniWrite, %tsecure2%, %config%, Towing, tsecure2
    IniWrite, %treleasemsg1%, %config%, Towing, treleasemsg1
    IniWrite, %treleasemsg2%, %config%, Towing, treleasemsg2
    ; Help related section
    IniWrite, %micmsg%, %config%, Help, micmsg
    IniWrite, %paystatemsg%, %config%, Help, paystatemsg
    ; Normal related section
    IniWrite, %gunmsg%, %config%, Normal, gunmsg
    IniWrite, %valet2hkmsg%, %config%, Normal, valet2hkmsg
    IniWrite, %phrechkmsg%, %config%, Normal, phrechkmsg
; ============================================ READ INI SECTION ============================================
    Gosub, ReadConfig
Return