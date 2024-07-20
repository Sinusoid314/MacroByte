Attribute VB_Name = "FileDialogCode"
Public Declare Function GetOpenFileName Lib "comdlg32.dll" Alias "GetOpenFileNameA" (pOpenfilename As OPENFILENAME) As Long
Public Declare Function GetSaveFileName Lib "comdlg32.dll" Alias "GetSaveFileNameA" (pOpenfilename As OPENFILENAME) As Long

Public Const OFN_EXPLORER = &H80000
Public Const OFN_NODEREFERENCELINKS = &H100000
Public Const OFN_OVERWRITEPROMPT = &H2
Public Const OFN_PATHMUSTEXIST = &H800

Public Type OPENFILENAME
        lStructSize As Long
        hwndOwner As Long
        hInstance As Long
        lpstrFilter As String
        lpstrCustomFilter As String
        nMaxCustFilter As Long
        nFilterIndex As Long
        lpstrFile As String
        nMaxFile As Long
        lpstrFileTitle As String
        nMaxFileTitle As Long
        lpstrInitialDir As String
        lpstrTitle As String
        flags As Long
        nFileOffset As Integer
        nFileExtension As Integer
        lpstrDefExt As String
        lCustData As Long
        lpfnHook As Long
        lpTemplateName As String
End Type


Public Function FileDialog(ByVal titleStr As String, ByVal filterStr As String, ByVal dialogType As Integer, Optional ByVal defFilter As String) As String

'0 = Open
'1 = Save

Dim fdInfo As OPENFILENAME
Dim initFile As String
Dim n As Integer

initFile = vbNullChar & Space(1024) '& vbNullChar

fdInfo.lStructSize = Len(fdInfo)
fdInfo.flags = OFN_EXPLORER Or OFN_OVERWRITEPROMPT 'Or OFN_PATHMUSTEXIST
fdInfo.nMaxFile = 1024
fdInfo.lpstrFile = initFile
fdInfo.lpstrDefExt = defFilter & vbNullChar
fdInfo.lpstrFilter = filterStr & Chr(0)
fdInfo.nMaxFileTitle = Len(titleStr)
fdInfo.lpstrTitle = titleStr & vbNullChar

If dialogType Then
    GetSaveFileName fdInfo
Else
    GetOpenFileName fdInfo
End If

If fdInfo.lpstrFile = initFile Then Exit Function

FileDialog = Trim(fdInfo.lpstrFile)
FileDialog = Mid(FileDialog, 1, Len(FileDialog) - 1)

End Function

