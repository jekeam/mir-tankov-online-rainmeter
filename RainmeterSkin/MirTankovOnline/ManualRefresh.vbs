Set shell = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")

scriptDir = fso.GetParentFolderName(WScript.ScriptFullName)
fetchCmd = "powershell.exe -NoProfile -ExecutionPolicy Bypass -File """ & scriptDir & "\Fetch-MirTankovOnline.ps1"" -Output """ & scriptDir & "\@Resources\Data.inc"""
shell.Run fetchCmd, 0, True

rainmeter = shell.ExpandEnvironmentStrings("%ProgramFiles%") & "\Rainmeter\Rainmeter.exe"
If Not fso.FileExists(rainmeter) Then
    rainmeter = shell.ExpandEnvironmentStrings("%ProgramFiles(x86)%") & "\Rainmeter\Rainmeter.exe"
End If
If Not fso.FileExists(rainmeter) Then
    rainmeter = shell.ExpandEnvironmentStrings("%LOCALAPPDATA%") & "\Programs\Rainmeter\Rainmeter.exe"
End If

If fso.FileExists(rainmeter) Then
    shell.Run """" & rainmeter & """ !Refresh MirTankovOnline", 0, False
End If
