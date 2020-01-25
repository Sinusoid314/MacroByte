VERSION 5.00
Begin VB.Form findDlg 
   BorderStyle     =   1  'Fixed Single
   Caption         =   "Find..."
   ClientHeight    =   2010
   ClientLeft      =   45
   ClientTop       =   330
   ClientWidth     =   4980
   ControlBox      =   0   'False
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   2010
   ScaleWidth      =   4980
   StartUpPosition =   1  'CenterOwner
   Begin VB.CommandButton Command2 
      Caption         =   "Close"
      Height          =   435
      Index           =   1
      Left            =   3810
      TabIndex        =   2
      Top             =   1035
      Width           =   1110
   End
   Begin VB.CommandButton Command1 
      Caption         =   "Find"
      Height          =   435
      Left            =   3810
      TabIndex        =   1
      Top             =   405
      Width           =   1110
   End
   Begin VB.TextBox Text1 
      BeginProperty Font 
         Name            =   "Courier New"
         Size            =   9.75
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   2010
      Left            =   0
      MultiLine       =   -1  'True
      ScrollBars      =   3  'Both
      TabIndex        =   0
      Top             =   0
      Width           =   3645
   End
End
Attribute VB_Name = "findDlg"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private findPos As Long

Private Sub Command1_Click()

Dim fPos As Long
Dim aWin As Form

If mainWin.ActiveForm Is Nothing Then Exit Sub
Set aWin = mainWin.ActiveForm

If Trim(Text1.Text) = "" Then Exit Sub

fPos = aWin.editor.Find(Text1.Text, findPos)

If fPos > -1 Then
    findPos = fPos + Len(Text1.Text)
    aWin.editor.SelStart = fPos
    aWin.editor.SelLength = Len(Text1.Text)
    mainWin.Show
Else
    MsgBox "Finished searching text", vbOKOnly, "Lithium BASIC"
End If

End Sub


Private Sub Command2_Click(Index As Integer)

mainWin.Show
Unload Me

End Sub

Private Sub Form_Load()

findPos = 1

End Sub

Private Sub Text1_Change()

findPos = 1

End Sub


