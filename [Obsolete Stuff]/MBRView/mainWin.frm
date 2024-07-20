VERSION 5.00
Begin VB.MDIForm mainWin 
   BackColor       =   &H8000000C&
   Caption         =   "mainWin"
   ClientHeight    =   6600
   ClientLeft      =   165
   ClientTop       =   735
   ClientWidth     =   10275
   LinkTopic       =   "MDIForm1"
   StartUpPosition =   3  'Windows Default
   Begin VB.Menu mnuFile 
      Caption         =   "&File"
      Begin VB.Menu mnuFileOpen 
         Caption         =   "&Open"
      End
      Begin VB.Menu mnuFileClose 
         Caption         =   "&Close"
      End
   End
   Begin VB.Menu mnuMods 
      Caption         =   "&Modules"
      WindowList      =   -1  'True
   End
End
Attribute VB_Name = "mainWin"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False

Private Sub ClearModules()

While Not (mainWin.ActiveForm Is Nothing)
    Unload mainWin.ActiveForm
Wend

End Sub


Private Sub LoadMBR(ByVal fileStr As String)

Dim dat As String
Dim dData As String
Dim tmpCount1 As Long
Dim tmpCount2 As Long
Dim tmpCount3 As Long
Dim a As Long
Dim b As Long
Dim c As Long
Dim tmpStr As String
Dim frmNew As docWin

ClearModules

If Dir(fileStr) = "" Then Exit Sub

'Extract code form MBR file
Open fileStr For Binary As #1
    dat = input(LOF(1), 1)
Close #1

'Decrypt the code
dData = DTask(dat)

'Write to new file
Open App.Path & "\mbrdump.txt" For Output As #1
    Print #1, dData;
Close #1

'Load decrypted file
Open App.Path & "\mbrdump.txt" For Input As #1
    'Literals
    Set frmNew = New docWin
    frmNew.Caption = "Literals"
    Input #1, tmpCount1
    For a = 1 To tmpCount1
        Input #1, tmpStr
        frmNew.Text1.Text = frmNew.Text1.Text & tmpStr & vbCrLf
    Next a
    frmNew.Show
    
    'Subprogs
    Input #1, tmpCount1
    For a = 1 To tmpCount1
        Set frmNew = New docWin
        'Subprog Name
        Input #1, tmpStr
        frmNew.Caption = "[SubProg] - " & tmpStr
        
        frmNew.Show
    Next a
Close #1

End Sub

Private Function DTask(ByVal dat As String) As String

Dim dData, dKey, tmpDat As String

dKey = Mid(dat, 11, 1)
tmpDat = Mid(dat, 20, Len(dat) - 29)

For n = 1 To Len(tmpDat) Step 2
    Mid(tmpDat, n, 1) = Chr(Asc(Mid(tmpDat, n, 1)) + 3)
Next n

For n = 1 To Len(tmpDat)
    dData = dData & Chr(Asc(Mid(tmpDat, n, 1)) - Asc(dKey))
Next n

DTask = dData

End Function

Private Sub mnuFileClose_Click()
    ClearModules
End Sub

Private Sub mnuFileOpen_Click()

Dim tmpFile As String

tmpFile = FileDialog("Open...", "MBR file (*.mbr)" & Chr(0) & "*.mbr" & Chr(0), 0)
If tmpFile = "" Then Exit Sub

LoadMBR tmpFile

End Sub


