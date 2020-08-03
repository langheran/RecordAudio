#Persistent
#Include CLR.ahk

Menu, Tray, NoStandard
Menu, Tray, Add, &Salir, ExitAppSub

SetWorkingDir, %A_ScriptDir%

OnExit, ExitAppSub
CLR_Start()
asm := CLR_LoadLibrary("RecordAudio.dll")
global recordAudio := asm.CreateInstance("RecordAudio.Class1")
FileBaseName:=A_Desktop . "/record_" 
CandidateFilename:=GetFileName(FileBaseName)
recordAudio.StartRecording(CandidateFilename)
return

F12::
MsgBox, 4,Monitorear, Monitor window for recording %Title%? (Si o No)
IfMsgBox, Yes
{
    guid_id:=WinExist("A")
    DetectHiddenWindows, Off
    SetTimer, MonitorWindow, 5000
}
else
{
    SetTimer, MonitorWindow, Off
}
return

MonitorWindow:
if(guid_id && !WinExist("ahk_id " . guid_id))
    GoSub, ExitAppSub
return

ExitAppSub:
recordAudio.StopRecording()
SplitPath, CandidateFilename, name, dir, ext, name_no_ext
CandidateFilename1=%dir%/%name_no_ext%.mp3
;RunWait, ffmpeg -i "%CandidateFilename%" "%CandidateFilename1%",,UseErrorLevel
CandidateFilename_i=%dir%/%name_no_ext%_i.wav
CandidateFilename_m=%dir%/%name_no_ext%_m.wav
command=ffmpeg -i "%CandidateFilename_i%" -i "%CandidateFilename_m%" -filter_complex "[0:a]volume=1.0[a0];[1:a]volume=5.0[a1];[a0][a1]amerge=inputs=2[out]" -map "[out]" -ac 2 -c:a libmp3lame -q:a 4 "%CandidateFilename1%"
Clipboard:=command
RunWait, %command%,,UseErrorLevel
if(FileExist(CandidateFilename1) && !ErrorLevel)
{
    FileDelete, %CandidateFilename%
    FileDelete, %CandidateFilename_i%
    FileDelete, %CandidateFilename_m%
}
ExitApp

GetFileName(FileBaseName)
{
    SetFormat, float, 04.0
    FileNumber = 0
    Loop
    {
        FileNumber += 1.0
        CandidateFilename = %FileBaseName%%FileNumber%.wav
        CandidateFilename1 = %FileBaseName%%FileNumber%.mp3
        If (!FileExist(CandidateFilename) && !FileExist(CandidateFilename1))   ; Empty slot found.
            break
    }
    return CandidateFilename
}