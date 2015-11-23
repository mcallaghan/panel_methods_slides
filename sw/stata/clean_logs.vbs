
Const ForReading = 1

Set objFSO = CreateObject("Scripting.FileSystemObject")
Set objFolder = objFSO.GetFolder("logs/")

strStartText = "*@*lstart"
strEndText = "*@*lend"

Set colFiles = objFolder.Files
For Each objFile in colFiles
	If instr(objFile.Name,".log") > 0 Then
		strFileName = objFile.Name
		'Wscript.Echo objFile.Name
		Set objFSO = CreateObject("Scripting.FileSystemObject")
		Set objFile = objFSO.OpenTextFile("logs\" & strFileName, ForReading)

		strContents = objFile.ReadAll

		intStart = InStr(strContents, strStartText)
		intStart = intStart + Len(strStartText)

		intEnd = InStr(strContents, strEndText)

		intCharacters = intEnd - intStart - 8

		strText = Mid(strContents, intStart + 3, intCharacters)

		Set newobjFile = objFSO.CreateTextFile(".\cleaned_logs\" & strFileName)

		newobjFile.Write strText

		objFile.Close

			
	End If
Next
