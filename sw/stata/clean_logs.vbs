
Const ForReading = 1

Set objFSO = CreateObject("Scripting.FileSystemObject")
Set objFolder = objFSO.GetFolder("logs/")

strStartText = "*@*lstart"
strEndText = "*@*lend"

Set colFiles = objFolder.Files
For Each objFile in colFiles
	If instr(objFile.Name,".txt") > 0 Then
		strFileName = objFile.Name
		Wscript.Echo objFile.Name
		Set objFSO = CreateObject("Scripting.FileSystemObject")
		Set objFile = objFSO.OpenTextFile("logs\1_preparation.txt", ForReading)

		strContents = objFile.ReadAll
		

		intStart = InStr(strContents, strStartText)
		intStart = intStart + Len(strStartText)

		intEnd = InStr(strContents, strEndText)

		intCharacters = intEnd - intStart - 6

		strText = Mid(strContents, intStart, intCharacters)

		Set newobjFile = objFSO.CreateTextFile(".\cleaned_logs\" & strFileName)

		newobjFile.Write strText

		objFile.Close

		Wscript.Echo strText
	End If
Next
