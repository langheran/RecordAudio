#Persistent
#Include CLR.ahk

SetWorkingDir, %A_ScriptDir%

OnExit, ExitAppSub
CLR_Start()
asm := CLR_LoadLibrary("RecordAudio.dll")
global recordAudio := asm.CreateInstance("RecordAudio.Class1")
FileBaseName:=A_Desktop . "/record_" 
CandidateFilename:=GetFileName(FileBaseName)
recordAudio.StartRecording(CandidateFilename)
return

ExitAppSub:
recordAudio.StopRecording()
SplitPath, CandidateFilename, name, dir, ext, name_no_ext
CandidateFilename1=%dir%/%name_no_ext%.mp3
RunWait, ffmpeg -i "%CandidateFilename%" "%CandidateFilename1%",,UseErrorLevel
if(FileExist(CandidateFilename1) && !ErrorLevel)
    FileDelete, %CandidateFilename%
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