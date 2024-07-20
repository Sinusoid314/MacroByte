VERSION 5.00
Object = "{831FDD16-0C5C-11D2-A9FC-0000F8754DA1}#2.0#0"; "Mscomctl.ocx"
Begin VB.Form compileDlg 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "Compiling..."
   ClientHeight    =   2100
   ClientLeft      =   45
   ClientTop       =   330
   ClientWidth     =   6000
   ControlBox      =   0   'False
   Icon            =   "compileDlg.frx":0000
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   140
   ScaleMode       =   3  'Pixel
   ScaleWidth      =   400
   StartUpPosition =   1  'CenterOwner
   Begin VB.CommandButton Command1 
      Caption         =   "Cancel"
      Height          =   450
      Left            =   2400
      TabIndex        =   1
      Top             =   1500
      Width           =   1200
   End
   Begin MSComctlLib.ProgressBar progress 
      Height          =   345
      Left            =   180
      TabIndex        =   0
      Top             =   960
      Width           =   5550
      _ExtentX        =   9790
      _ExtentY        =   609
      _Version        =   393216
      Appearance      =   1
   End
   Begin VB.Label status 
      Alignment       =   2  'Center
      Height          =   450
      Left            =   75
      TabIndex        =   2
      Top             =   225
      Width           =   5775
      WordWrap        =   -1  'True
   End
End
Attribute VB_Name = "compileDlg"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private details As Boolean

Private Sub Command1_Click()

'Setting exitFlag to True will cause the
'compiler to stop and exit out
exitFlag = True

'Since exiting out of the compiler this way
'doesn't close the compile box, it must be
'done here
Unload Me

End Sub
Private Sub Form_Load()

details = False

End Sub


Private Sub Form_Unload(Cancel As Integer)

status.Caption = ""
progress.Value = 0

End Sub

