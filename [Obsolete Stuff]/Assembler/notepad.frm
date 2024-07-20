VERSION 5.00
Object = "{831FDD16-0C5C-11D2-A9FC-0000F8754DA1}#2.0#0"; "MSCOMCTL.OCX"
Begin VB.Form notepad 
   Caption         =   "MacroByte Assembler"
   ClientHeight    =   7185
   ClientLeft      =   1200
   ClientTop       =   2040
   ClientWidth     =   11280
   Icon            =   "notepad.frx":0000
   LinkTopic       =   "Form1"
   ScaleHeight     =   479
   ScaleMode       =   3  'Pixel
   ScaleWidth      =   752
   StartUpPosition =   2  'CenterScreen
   Begin VB.CommandButton varBtn 
      Caption         =   "Variables/Arrays..."
      Enabled         =   0   'False
      Height          =   360
      Left            =   6225
      TabIndex        =   14
      Top             =   675
      Width           =   1725
   End
   Begin VB.CommandButton delspBtn 
      Caption         =   "Remove"
      Enabled         =   0   'False
      Height          =   375
      Left            =   1470
      TabIndex        =   6
      Top             =   5310
      Width           =   1125
   End
   Begin VB.CommandButton addspBtn 
      Caption         =   "Add"
      Height          =   375
      Left            =   195
      TabIndex        =   5
      Top             =   5310
      Width           =   1125
   End
   Begin VB.ListBox spList 
      Height          =   3990
      IntegralHeight  =   0   'False
      Left            =   120
      TabIndex        =   3
      Top             =   1275
      Width           =   2550
   End
   Begin MSComctlLib.StatusBar status 
      Align           =   2  'Align Bottom
      Height          =   270
      Left            =   0
      TabIndex        =   1
      Top             =   6915
      Width           =   11280
      _ExtentX        =   19897
      _ExtentY        =   476
      Style           =   1
      SimpleText      =   "Ready."
      _Version        =   393216
      BeginProperty Panels {8E3867A5-8586-11D1-B16A-00C0F0283628} 
         NumPanels       =   1
         BeginProperty Panel1 {8E3867AB-8586-11D1-B16A-00C0F0283628} 
         EndProperty
      EndProperty
   End
   Begin VB.TextBox edit 
      Enabled         =   0   'False
      BeginProperty Font 
         Name            =   "Courier New"
         Size            =   9.75
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   5340
      Left            =   2850
      MultiLine       =   -1  'True
      ScrollBars      =   3  'Both
      TabIndex        =   0
      Top             =   1095
      Width           =   7365
   End
   Begin VB.Frame tbFrame 
      Height          =   600
      Left            =   0
      TabIndex        =   7
      Top             =   0
      Width           =   5925
      Begin VB.CommandButton saveBtn 
         Caption         =   "Save"
         Height          =   375
         Left            =   2010
         TabIndex        =   12
         Top             =   150
         Width           =   750
      End
      Begin VB.CommandButton openBtn 
         Caption         =   "Open "
         Height          =   375
         Left            =   1185
         TabIndex        =   11
         Top             =   150
         Width           =   750
      End
      Begin VB.CommandButton newBtn 
         Caption         =   "New"
         Height          =   375
         Left            =   360
         TabIndex        =   10
         Top             =   150
         Width           =   750
      End
      Begin VB.CommandButton litBtn 
         Caption         =   "Literals"
         Height          =   375
         Left            =   3015
         TabIndex        =   9
         Top             =   150
         Width           =   1050
      End
      Begin VB.CommandButton assembleBtn 
         Caption         =   "Assemble"
         Height          =   375
         Left            =   4335
         TabIndex        =   8
         Top             =   150
         Width           =   1125
      End
      Begin VB.Line Line4 
         BorderColor     =   &H00FFFFFF&
         X1              =   180
         X2              =   180
         Y1              =   150
         Y2              =   510
      End
      Begin VB.Line Line2 
         BorderColor     =   &H00FFFFFF&
         X1              =   105
         X2              =   105
         Y1              =   150
         Y2              =   510
      End
      Begin VB.Line Line1 
         BorderColor     =   &H00808080&
         X1              =   90
         X2              =   90
         Y1              =   150
         Y2              =   510
      End
      Begin VB.Line Line3 
         BorderColor     =   &H00808080&
         X1              =   165
         X2              =   165
         Y1              =   150
         Y2              =   510
      End
      Begin VB.Line Line5 
         BorderColor     =   &H00808080&
         X1              =   2865
         X2              =   2865
         Y1              =   150
         Y2              =   510
      End
      Begin VB.Line Line6 
         BorderColor     =   &H00FFFFFF&
         X1              =   2880
         X2              =   2880
         Y1              =   150
         Y2              =   510
      End
   End
   Begin VB.Frame Frame1 
      Height          =   5910
      Left            =   15
      TabIndex        =   2
      Top             =   600
      Width           =   2760
      Begin VB.Label Label1 
         Alignment       =   2  'Center
         Appearance      =   0  'Flat
         BackColor       =   &H80000002&
         BorderStyle     =   1  'Fixed Single
         Caption         =   "Sub Programs"
         ForeColor       =   &H80000009&
         Height          =   255
         Left            =   105
         TabIndex        =   4
         Top             =   195
         Width           =   2550
      End
   End
   Begin VB.Label Label2 
      Appearance      =   0  'Flat
      BackColor       =   &H80000002&
      BorderStyle     =   1  'Fixed Single
      Caption         =   "SubProg Code: <none>"
      ForeColor       =   &H80000009&
      Height          =   300
      Left            =   2850
      TabIndex        =   13
      Top             =   795
      Width           =   3195
   End
   Begin VB.Menu mnuFile 
      Caption         =   "&File"
      Begin VB.Menu mnuFileNew 
         Caption         =   "&New"
      End
      Begin VB.Menu mnuFileOpen 
         Caption         =   "&Open"
      End
      Begin VB.Menu mnuFileSave 
         Caption         =   "&Save"
      End
      Begin VB.Menu mnuFileSaveAs 
         Caption         =   "Save &As"
      End
      Begin VB.Menu mnuFileSep1 
         Caption         =   "-"
      End
      Begin VB.Menu mnuFileExit 
         Caption         =   "E&xit Assembler"
      End
   End
   Begin VB.Menu mnuEdit 
      Caption         =   "&Edit"
      Begin VB.Menu mnuEditCut 
         Caption         =   "Cu&t"
      End
      Begin VB.Menu mnuEditCopy 
         Caption         =   "&Copy"
      End
      Begin VB.Menu mnuEditPaste 
         Caption         =   "&Paste"
      End
      Begin VB.Menu mnuEditSep1 
         Caption         =   "-"
      End
      Begin VB.Menu mnuEditSelectAll 
         Caption         =   "Select &All"
      End
   End
   Begin VB.Menu mnuFormat 
      Caption         =   "F&ormat"
      Begin VB.Menu mnuFormatFont 
         Caption         =   "&Font"
      End
   End
   Begin VB.Menu mnuSearch 
      Caption         =   "&Search"
      Begin VB.Menu mnuNotAvailable 
         Caption         =   "No Search Available"
      End
   End
   Begin VB.Menu mnuHelp 
      Caption         =   "&Help"
      Begin VB.Menu mnuHelpContents 
         Caption         =   "&Contents"
      End
      Begin VB.Menu mnuHelpSep1 
         Caption         =   "-"
      End
      Begin VB.Menu mnuHelpAbout 
         Caption         =   "&About MacroByte Assembler..."
      End
   End
End
Attribute VB_Name = "notepad"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Dim filename As String



Private Sub addspBtn_Click()

Dim tmpName As String

tmpName = Trim(InputBox("SubProg Name:", "New Sub Program", "SubProg" & CStr(spDefList.itemCount)))

If tmpName = "" Then Exit Sub

spList.AddItem tmpName
spDefList.Add New SubProgDefClass
spDefList.Item(spDefList.itemCount).subProgName = tmpName
spList.ListIndex = spList.ListCount - 1

isChanged = True

End Sub

Private Sub assembleBtn_Click()

Load asmWin
asmWin.Show vbModal

End Sub

Private Sub delspBtn_Click()

If spList.ListIndex < 1 Then Exit Sub

If MsgBox("Remove sub program '" & spList.List(spList.ListIndex) & "' ?", vbYesNo) = vbNo Then Exit Sub

spDefList.Remove spList.ListIndex + 1
spList.RemoveItem spList.ListIndex

spList.ListIndex = 0

isChanged = True

End Sub

Private Sub edit_Change()

spDefList.Item(spList.ListIndex + 1).codeText = edit.Text
isChanged = True

End Sub

Private Sub Form_Load()
    isChanged = False
    filename = ""
    
    spList.AddItem "<main>"
    spDefList.Add New SubProgDefClass
    spDefList.Item(1).subProgName = "<main>"
    spList.ListIndex = 0

End Sub

Private Sub Form_Resize()

    On Error Resume Next
    
    edit.Width = Me.ScaleWidth - 190
    edit.Height = Me.ScaleHeight - 92
    
    Frame1.Height = Me.ScaleHeight - 59
    spList.Height = Me.ScaleHeight - 150
    addspBtn.Top = spList.Top + spList.Height + 5
    delspBtn.Top = spList.Top + spList.Height + 5
    
    tbFrame.Width = Me.ScaleWidth
End Sub


Private Sub Form_Unload(Cancel As Integer)
  If isChanged Then
    r = MsgBox("Save changes made to '" & filename & "' ?", vbYesNoCancel, "SS Notepad")
        If r = vbYes Then Call mnuFileSave_Click
        If r = vbCancel Then Cancel = 1
  End If
End Sub


Private Sub litBtn_Click()

Load litWin

litWin.Show vbModal

End Sub

Private Sub mnuEditCopy_Click()
    If edit.SelText = "" Then Exit Sub
    Clipboard.SetText edit.SelText
End Sub

Private Sub mnuEditCut_Click()
    If edit.SelText = "" Then Exit Sub
    Clipboard.SetText edit.SelText
    edit.SelText = ""
End Sub

Private Sub mnuEditPaste_Click()
    edit.SelText = Clipboard.GetText
End Sub

Private Sub mnuEditSelectAll_Click()
    edit.SelStart = 0
    edit.SelLength = Len(edit.Text)
End Sub


Private Sub mnuFileExit_Click()

End

End Sub

Private Sub mnuFileNew_Click()

  If isChanged Then
    r = MsgBox("Save changes made to '" & filename & "' ?", vbYesNoCancel, "SS Notepad")
        If r = vbYes Then Call mnuFileSave_Click
        If r = vbCancel Then Exit Sub
  End If

notepad.Caption = "MacroByte Asssembler"

LiteralList.Clear
spDefList.Clear
spList.Clear

spList.AddItem "<main>"
spDefList.Add New SubProgDefClass
spDefList.Item(1).subProgName = "<main>"
spList.ListIndex = 0

filename = ""
isChanged = False

End Sub


Private Sub mnuFileOpen_Click()

  Dim tmpTxt As String
  Dim tmpFile As String

  If isChanged Then
    r = MsgBox("Save changes made to '" & filename & "' ?", vbYesNoCancel, "SS Notepad")
        If r = vbYes Then Call mnuFileSave_Click
        If r = vbCancel Then Exit Sub
  End If

  tmpFile = FileDialog("Open Source File", "MacroByte Source File (*.mbs)" & Chr(0) & "*.mbs" & Chr(0), 0)
  If Trim(tmpFile) = "" Then Exit Sub
  filename = tmpFile

  LiteralList.Clear
  spDefList.Clear
  spList.Clear

  LoadProgData filename

  spList.ListIndex = 0

  notepad.Caption = "MacroByte Asssembler - [" & filename & "]"
  isChanged = False

End Sub

Private Sub mnuFileSave_Click()

Dim tmpFile As String

If filename = "" Then
    tmpFile = FileDialog("Save Source File As...", "MacroByte Source File (*.mbs)" & Chr(0) & "*.mbs" & Chr(0), 1)
    If Trim(tmpFile) = "" Then Exit Sub
    filename = tmpFile
    SaveProgData filename
    notepad.Caption = "MacroByte Assembler - [" & filename & "]"
Else
    SaveProgData filename
End If

isChanged = False

End Sub


Private Sub mnuFileSaveAs_Click()

    Dim tmpFile As String

    tmpFile = FileDialog("Save Source File As...", "MacroByte Source File (*.mbs)" & Chr(0) & "*.mbs" & Chr(0), 1)
    If Trim(tmpFile) = "" Then Exit Sub
    SaveProgData tmpFile

End Sub




Private Sub mnuHelpAbout_Click()
    Load about
    about.Show vbModal
End Sub

Private Sub mnuHelpContents_Click()
    MsgBox "No help yet."
End Sub

Private Sub toolbar_ButtonClick(ByVal Button As MSComctlLib.Button)

Select Case Button.Key
    Case "new"
        Call mnuFileNew_Click
    Case "open"
        Call mnuFileOpen_Click
    Case "save"
        Call mnuFileSave_Click
    Case "cut"
        Call mnuEditCut_Click
    Case "copy"
        Call mnuEditCopy_Click
    Case "paste"
        Call mnuEditPaste_Click
    Case "help"
        MsgBox "No help...yet...."
End Select

End Sub


Private Sub openGameBtn_Click()

End Sub


Private Sub spList_Click()

If spList.ListIndex < 0 Then Exit Sub

If spList.ListIndex = 0 Then
delspBtn.Enabled = False
Else
delspBtn.Enabled = True
End If

varBtn.Enabled = True
edit.Enabled = True

edit.Text = spDefList.Item(spList.ListIndex + 1).codeText
Label2.Caption = "SubProg Code: " & spList.List(spList.ListIndex)

End Sub


Private Sub varBtn_Click()

Load varWin

varWin.Show vbModal

End Sub


