VERSION 5.00
Begin VB.Form asmWin 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "Assembling File..."
   ClientHeight    =   2385
   ClientLeft      =   45
   ClientTop       =   330
   ClientWidth     =   6690
   ControlBox      =   0   'False
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   2385
   ScaleWidth      =   6690
   ShowInTaskbar   =   0   'False
   StartUpPosition =   1  'CenterOwner
   Begin VB.CommandButton Command1 
      Caption         =   "Close"
      Enabled         =   0   'False
      Height          =   495
      Left            =   2805
      TabIndex        =   1
      Top             =   1710
      Width           =   1350
   End
   Begin VB.Timer Timer1 
      Interval        =   100
      Left            =   3120
      Top             =   105
   End
   Begin VB.Label status 
      Alignment       =   2  'Center
      Caption         =   "Ready."
      BeginProperty Font 
         Name            =   "MS Reference Sans Serif"
         Size            =   12
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   390
      Left            =   1320
      TabIndex        =   0
      Top             =   1035
      Width           =   4215
   End
End
Attribute VB_Name = "asmWin"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub Command1_Click()
    Unload Me
End Sub

Private Sub Timer1_Timer()

Timer1.Enabled = False

Call AssembleFile

End Sub


