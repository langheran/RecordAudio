#Persistent
#Include CLR.ahk

SetWorkingDir, %A_ScriptDir%

OnExit, ExitAppSub
CLR_Start()
asm := CLR_LoadLibrary("RecordAudio.dll")
global recordAudio := asm.CreateInstance("RecordAudio.Class1")
FileBaseName:=A_Desktop . "/record_ " 
recordAudio.StartRecording(GetFileName(FileBaseName))
return

ExitAppSub:
recordAudio.StopRecording()
ExitApp

GetFileName(FileBaseName)
{
    SetFormat, float, 04.0
    FileNumber = 0
    Loop
    {
        FileNumber += 1.0
        CandidateFilename = %FileBaseName%%FileNumber%.wav
        IfNotExist, %CandidateFilename%   ; Empty slot found.
            break
    }
    return CandidateFilename
}