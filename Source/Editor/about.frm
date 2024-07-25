VERSION 5.00
Begin VB.Form about 
   Appearance      =   0  'Flat
   BorderStyle     =   1  'Fixed Single
   Caption         =   "About MicroByte..."
   ClientHeight    =   2925
   ClientLeft      =   45
   ClientTop       =   390
   ClientWidth     =   5895
   ControlBox      =   0   'False
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   195
   ScaleMode       =   3  'Pixel
   ScaleWidth      =   393
   StartUpPosition =   2  'CenterScreen
   Begin VB.CommandButton Command1 
      Caption         =   "OK"
      Height          =   390
      Left            =   2280
      Style           =   1  'Graphical
      TabIndex        =   0
      Top             =   2400
      Width           =   1320
   End
   Begin VB.Label Label3 
      Alignment       =   2  'Center
      Caption         =   "A BASIC language for creating Windows programs."
      BeginProperty Font 
         Name            =   "Calibri"
         Size            =   12
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   375
      Left            =   0
      TabIndex        =   4
      Top             =   1080
      Width           =   5895
   End
   Begin VB.Label Label2 
      Alignment       =   2  'Center
      Caption         =   "MacroByte v1.0.2"
      BeginProperty Font 
         Name            =   "Calibri"
         Size            =   20.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   615
      Left            =   0
      TabIndex        =   3
      Top             =   240
      Width           =   5895
   End
   Begin VB.Label Label1 
      Caption         =   "See more projects at"
      BeginProperty Font 
         Name            =   "Calibri"
         Size            =   9.75
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   255
      Left            =   1200
      TabIndex        =   2
      Top             =   1800
      Width           =   1815
   End
   Begin VB.Label link 
      Caption         =   "https://sinusoft.com"
      BeginProperty Font 
         Name            =   "Calibri"
         Size            =   9.75
         Charset         =   0
         Weight          =   400
         Underline       =   -1  'True
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00FF0000&
      Height          =   255
      Left            =   3000
      MousePointer    =   1  'Arrow
      TabIndex        =   1
      Top             =   1800
      Width           =   1815
   End
End
Attribute VB_Name = "about"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Declare Function ShellExecute Lib "shell32.dll" Alias "ShellExecuteA" (ByVal hwnd As Long, ByVal lpOperation As String, ByVal lpFile As String, ByVal lpParameters As String, ByVal lpDirectory As String, ByVal nShowCmd As Long) As Long

Private Sub Command1_Click()
    Unload Me
End Sub

Private Sub link_Click()
    ShellExecute 0, "open", "http://sinusoft.com/", "", "", 1
End Sub
