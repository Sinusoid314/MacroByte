VERSION 5.00
Begin VB.Form startup 
   BorderStyle     =   0  'None
   ClientHeight    =   6000
   ClientLeft      =   0
   ClientTop       =   0
   ClientWidth     =   7485
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   6000
   ScaleWidth      =   7485
   ShowInTaskbar   =   0   'False
   StartUpPosition =   2  'CenterScreen
   Begin VB.CommandButton Command1 
      Caption         =   "OK"
      Height          =   420
      Left            =   3090
      TabIndex        =   0
      Top             =   3705
      Visible         =   0   'False
      Width           =   1215
   End
   Begin VB.Timer Timer1 
      Interval        =   700
      Left            =   600
      Top             =   2205
   End
   Begin VB.Label Label1 
      Alignment       =   2  'Center
      BorderStyle     =   1  'Fixed Single
      Caption         =   "Please register your copy of Lithium BASIC to get rid of this nag screen."
      Height          =   270
      Left            =   1110
      TabIndex        =   1
      Top             =   4410
      Visible         =   0   'False
      Width           =   5130
   End
End
Attribute VB_Name = "startup"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False

Private Sub Command1_Click()

Unload Me

End Sub

Private Sub Form_Load()

If Not isMbr Then
    Timer1.Enabled = False
    Command1.Visible = True
    Label1.Visible = True
End If

End Sub


Private Sub Timer1_Timer()

Unload Me

End Sub


