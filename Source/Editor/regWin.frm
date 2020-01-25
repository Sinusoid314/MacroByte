VERSION 5.00
Begin VB.Form regWin 
   BorderStyle     =   1  'Fixed Single
   Caption         =   "Register Lithium BASIC"
   ClientHeight    =   2445
   ClientLeft      =   45
   ClientTop       =   330
   ClientWidth     =   4680
   ControlBox      =   0   'False
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   2445
   ScaleWidth      =   4680
   StartUpPosition =   1  'CenterOwner
   Begin VB.CommandButton Command2 
      Caption         =   "Cancel"
      Height          =   435
      Left            =   2475
      TabIndex        =   5
      Top             =   1200
      Width           =   1170
   End
   Begin VB.CommandButton Command1 
      Caption         =   "OK"
      Height          =   435
      Left            =   1065
      TabIndex        =   4
      Top             =   1200
      Width           =   1170
   End
   Begin VB.TextBox Text2 
      Height          =   300
      IMEMode         =   3  'DISABLE
      Left            =   945
      TabIndex        =   3
      Top             =   630
      Width           =   3450
   End
   Begin VB.TextBox Text1 
      Height          =   300
      Left            =   945
      TabIndex        =   2
      Top             =   135
      Width           =   3450
   End
   Begin VB.Label Label3 
      BackStyle       =   0  'Transparent
      Caption         =   "Get your registration code here"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   -1  'True
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00FF0000&
      Height          =   240
      Left            =   1230
      TabIndex        =   6
      Top             =   1980
      Width           =   2235
   End
   Begin VB.Label Label2 
      Caption         =   "Reg. Code:"
      Height          =   195
      Left            =   60
      TabIndex        =   1
      Top             =   645
      Width           =   840
   End
   Begin VB.Label Label1 
      Caption         =   "User Name:"
      Height          =   225
      Left            =   45
      TabIndex        =   0
      Top             =   180
      Width           =   870
   End
End
Attribute VB_Name = "regWin"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Declare Function ShellExecute Lib "shell32.dll" Alias "ShellExecuteA" (ByVal hwnd As Long, ByVal lpOperation As String, ByVal lpFile As String, ByVal lpParameters As String, ByVal lpDirectory As String, ByVal nShowCmd As Long) As Long

Private Sub Command2_Click()

Unload Me

End Sub


Private Sub Command1_Click()

Dim eData As String

If Trim(Text1.Text) = "" Or Trim(Text2.Text) = "" Then Exit Sub

If CmpMbr(Text1.Text, Text2.Text) Then
    Open rFile For Output As #1
        eData = ETask(Text1.Text & vbCrLf & Text2.Text)
        Print #1, eData;
    Close #1
    isMbr = True
    mainWin.mnuProgramCreate.Enabled = True
    MsgBox "Thanks for registering your copy of Lithium BASIC!", vbOKOnly, "Lithium BASIC"
    Unload Me
Else
    MsgBox "The registration code you entered is incorrect.", vbCritical, "Lithium BASIC"
End If

End Sub


Private Sub Form_Load()

End Sub

Private Sub Label3_Click()

ShellExecute 0, "open", "http://sircodezalot.britcoms.com/lithium_basic/register.html", "", "", 1

End Sub


