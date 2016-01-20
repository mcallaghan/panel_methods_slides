
Const ForReading = 1

Set objFSO = CreateObject("Scripting.FileSystemObject")
Set objFolder = objFSO.GetFolder("logs/")

strStartText = "*@*lstart"
strEndText = "*@*lend"

Set colFiles = objFolder.Files
For Each objFile in colFiles
	If instr(objFile.Name,".log") > 0 Then
		strFileName = replace(objFile.Name,".log",".rtf")
		'strFileName2 = replace(objFile.Name,".log",".rtf")
		Wscript.Echo strFileName 
		Set objFSO = CreateObject("Scripting.FileSystemObject")
		Set objFile = objFSO.OpenTextFile("logs\" & objFileName, ForReading)

		strContents = objFile.ReadAll

		intStart = InStr(strContents, strStartText)
		intStart = intStart + Len(strStartText)

		intEnd = InStr(strContents, strEndText)

		intCharacters = intEnd - intStart - 8

		strText = Mid(strContents, intStart + 3, intCharacters)

		Set newobjFile = objFSO.CreateTextFile(".\..\word\" & strFileName)

		strText = replace(strText,"\n","aaa")
		strText = replace(strText,"\r","aaa")
		strText = replace(strText,VbCrLf,"\line")

		newobjFile.Write "{\rtf1\utf-8\deff0{\fonttbl{\f0 courier;}}" & VbCrLf & " {\colortbl\red255\green0\blue0;\red255\green0\blue0;} \cf1 \fs16" & strText & "}"
		'newobjFile.Write strText

		objFile.Close

			
	End If
Next
