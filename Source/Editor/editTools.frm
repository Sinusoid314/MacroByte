VERSION 5.00
Begin VB.Form editTools 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "Edit Tools"
   ClientHeight    =   5730
   ClientLeft      =   45
   ClientTop       =   330
   ClientWidth     =   6660
   ControlBox      =   0   'False
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   382
   ScaleMode       =   3  'Pixel
   ScaleWidth      =   444
   ShowInTaskbar   =   0   'False
   StartUpPosition =   3  'Windows Default
   Begin VB.CheckBox startOpt 
      Caption         =   "Run when Editor starts"
      Height          =   285
      Left            =   3240
      TabIndex        =   12
      Top             =   3060
      Width           =   1965
   End
   Begin VB.Frame Frame1 
      Caption         =   "CommandLine Options"
      Height          =   930
      Left            =   3045
      TabIndex        =   10
      Top             =   3690
      Width           =   3510
      Begin VB.CheckBox cmdOpt 
         Caption         =   "Editor Window Handle"
         Height          =   270
         Index           =   0
         Left            =   315
         TabIndex        =   11
         Top             =   405
         Width           =   1995
      End
   End
   Begin VB.TextBox progName 
      Height          =   300
      Left            =   3045
      TabIndex        =   8
      Top             =   765
      Width           =   3525
   End
   Begin VB.CommandButton Command4 
      Caption         =   "Browse..."
      Height          =   450
      Left            =   3045
      TabIndex        =   7
      Top             =   2175
      Width           =   1125
   End
   Begin VB.CommandButton Command3 
      Caption         =   "OK"
      Height          =   450
      Left            =   5370
      TabIndex        =   6
      Top             =   5145
      Width           =   1125
   End
   Begin VB.CommandButton Command2 
      Caption         =   "Remove Tool"
      Height          =   450
      Left            =   1410
      TabIndex        =   5
      Top             =   5145
      Width           =   1125
   End
   Begin VB.CommandButton Command1 
      Caption         =   "Add Tool"
      Height          =   450
      Left            =   135
      TabIndex        =   4
      Top             =   5145
      Width           =   1125
   End
   Begin VB.TextBox progPath 
      Height          =   300
      Left            =   3045
      TabIndex        =   3
      Top             =   1740
      Width           =   3525
   End
   Begin VB.ListBox programs 
      Height          =   4605
      IntegralHeight  =   0   'False
      Left            =   75
      TabIndex        =   0
      Top             =   420
      Width           =   2805
   End
   Begin VB.Label Label3 
      Caption         =   "Name:"
      Height          =   195
      Left            =   3045
      TabIndex        =   9
      Top             =   480
      Width           =   465
   End
   Begin VB.Label Label2 
      Caption         =   "Filename:"
      Height          =   180
      Left            =   3060
      TabIndex        =   2
      Top             =   1470
      Width           =   705
   End
   Begin VB.Label Label1 
      Caption         =   "Programs:"
      Height          =   195
      Left            =   75
      TabIndex        =   1
      Top             =   150
      Width           =   720
   End
End
Attribute VB_Name = "editTools"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False

Private Sub cmdOpt_Click(Index As Integer)

Dim coList() As String
Dim tmpStr As String

If programs.ListIndex < 0 Then Exit Sub

coList = Split(ToolCmdOpt.Item(programs.ListIndex + 1), ",")

coList(Index) = cmdOpt(Index).Value

For n = 0 To UBound(coList) - 1
    tmpStr = tmpStr & coList(n) & ","
Next n
tmpStr = tmpStr & coList(UBound(coList))

ToolCmdOpt.Item(programs.ListIndex + 1) = tmpStr

End Sub

Private Sub Command1_Click()

Dim nameStr As String

nameStr = InputBox("Enter programs name:", "MicroByte", "Program" & Str(ToolName.itemCount + 1))
    If Trim(nameStr) = "" Then Exit Sub

ToolName.Add nameStr
ToolProg.Add ""
ToolStartOpt.Add 0
ToolCmdOpt.Add "0"

programs.AddItem nameStr
programs.ListIndex = programs.ListCount - 1

progName.Text = nameStr
progPath.Text = ""
startOpt.Value = 0
cmdOpt(0).Value = 0

End Sub
Private Sub Command2_Click()

If programs.ListIndex < 0 Then Exit Sub

res = MsgBox("Are you sure you want to remove tool '" & programs.List(programs.ListIndex) & "'?", vbYesNo, "MicroByte")
    If res = vbNo Then Exit Sub

ToolName.Remove programs.ListIndex + 1
ToolProg.Remove programs.ListIndex + 1
ToolStartOpt.Remove programs.ListIndex + 1
ToolCmdOpt.Remove programs.ListIndex + 1

programs.RemoveItem programs.ListIndex

progName.Text = ""
progPath.Text = ""
startOpt.Value = 0
cmdOpt(0).Value = 0

End Sub
Private Sub Command3_Click()

mainWin.tools.Clear

Open App.Path & "\tools.dat" For Output As #1
    Print #1, ToolProg.itemCount
    For n = 1 To ToolProg.itemCount
        Print #1, ToolName.Item(n)
        Print #1, ToolProg.Item(n)
        Print #1, ToolStartOpt.Item(n)
        Print #1, ToolCmdOpt.Item(n)
        mainWin.tools.AddItem ToolName.Item(n)
    Next n
Close #1

Unload Me

End Sub


Private Sub Command4_Click()

'Dim tmpFile As String

dialog.filename = ""
dialog.DialogTitle = "Choose a program..."
dialog.Filter = "Executable (*.exe) | *.exe"
dialog.ShowOpen

If dialog.filename = "" Then Exit Sub

progPath.Text = dialog.filename

'tmpFile = FileDialog("Choose a program...", "Executable (*.exe) | *.exe", _
'                0, "exe")
'If tmpFile = "" Then Exit Sub
'progPath.Text = tmpFile

End Sub

Private Sub Form_Load()

For n = 1 To ToolProg.itemCount
    programs.AddItem ToolName.Item(n)
Next n

End Sub


Private Sub progName_Change()

If programs.ListIndex < 0 Then Exit Sub

ToolName.Item(programs.ListIndex + 1) = progName.Text
programs.List(programs.ListIndex) = progName.Text

End Sub


Private Sub progPath_Change()

If programs.ListIndex < 0 Then Exit Sub

ToolProg.Item(programs.ListIndex + 1) = progPath.Text

End Sub


Private Sub programs_Click()

Dim coList() As String

coList = Split(ToolCmdOpt.Item(programs.ListIndex + 1))

progName.Text = ToolName.Item(programs.ListIndex + 1)
progPath.Text = ToolProg.Item(programs.ListIndex + 1)

startOpt.Value = ToolStartOpt.Item(programs.ListIndex + 1)

For n = 0 To UBound(coList)
    cmdOpt(n).Value = CInt(Trim(coList(n)))
Next n

End Sub


Private Sub startOpt_Click()

If programs.ListIndex < 0 Then Exit Sub

ToolStartOpt.Item(programs.ListIndex + 1) = startOpt.Value

End Sub

