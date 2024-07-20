VERSION 5.00
Begin VB.Form about 
   BorderStyle     =   1  'Fixed Single
   Caption         =   "About MacroByte Assembler..."
   ClientHeight    =   2730
   ClientLeft      =   45
   ClientTop       =   330
   ClientWidth     =   5760
   ControlBox      =   0   'False
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   182
   ScaleMode       =   3  'Pixel
   ScaleWidth      =   384
   StartUpPosition =   1  'CenterOwner
   Begin VB.CommandButton Command1 
      Caption         =   "OK"
      Height          =   375
      Left            =   2220
      TabIndex        =   3
      Top             =   2235
      Width           =   1275
   End
   Begin VB.Label Label3 
      Alignment       =   2  'Center
      Caption         =   """I shouldn't have drank all that ActionBastard BASTARD JUICE®!!"""
      BeginProperty Font 
         Name            =   "Times New Roman"
         Size            =   12
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   630
      Left            =   1035
      TabIndex        =   2
      Top             =   1365
      Width           =   3870
   End
   Begin VB.Label Label2 
      Caption         =   "Copyright © 2007 by ActionBastard Inc."
      Height          =   210
      Left            =   2460
      TabIndex        =   1
      Top             =   855
      Width           =   2925
   End
   Begin VB.Label Label1 
      Caption         =   "MacroByte Assembler"
      BeginProperty Font 
         Name            =   "Times New Roman"
         Size            =   24
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   570
      Left            =   1050
      TabIndex        =   0
      Top             =   300
      Width           =   4470
   End
   Begin VB.Image Image1 
      Height          =   720
      Left            =   120
      Picture         =   "about.frx":0000
      Top             =   525
      Width           =   720
   End
End
Attribute VB_Name = "about"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Declare Function GetAsyncKeyState Lib "user32" (ByVal vKey As Long) As Integer

Private Sub Command1_Click()
    Unload Me
End Sub


Private Sub Image2_Click()

    
End Sub


