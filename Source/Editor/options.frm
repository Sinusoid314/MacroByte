VERSION 5.00
Begin VB.Form options 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "Options"
   ClientHeight    =   1800
   ClientLeft      =   45
   ClientTop       =   330
   ClientWidth     =   4800
   ControlBox      =   0   'False
   BeginProperty Font 
      Name            =   "Lucida Sans Unicode"
      Size            =   8.25
      Charset         =   0
      Weight          =   700
      Underline       =   0   'False
      Italic          =   0   'False
      Strikethrough   =   0   'False
   EndProperty
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   120
   ScaleMode       =   3  'Pixel
   ScaleWidth      =   320
   ShowInTaskbar   =   0   'False
   StartUpPosition =   1  'CenterOwner
   Begin VB.CommandButton Command3 
      Caption         =   "Apply"
      Height          =   450
      Left            =   3645
      TabIndex        =   3
      Top             =   1275
      Width           =   1080
   End
   Begin VB.CommandButton Command2 
      Caption         =   "Cancel"
      Height          =   450
      Left            =   2505
      TabIndex        =   2
      Top             =   1275
      Width           =   1080
   End
   Begin VB.CommandButton Command1 
      Caption         =   "OK"
      Height          =   450
      Left            =   1350
      TabIndex        =   1
      Top             =   1275
      Width           =   1080
   End
   Begin VB.Frame Frame1 
      Caption         =   "Editor"
      Height          =   975
      Left            =   75
      TabIndex        =   0
      Top             =   75
      Width           =   4650
      Begin VB.CommandButton Command4 
         Caption         =   "Change"
         Enabled         =   0   'False
         Height          =   375
         Left            =   3210
         TabIndex        =   6
         Top             =   405
         Width           =   1020
      End
      Begin VB.TextBox editorFont 
         Enabled         =   0   'False
         Height          =   300
         Left            =   795
         TabIndex        =   5
         Top             =   435
         Width           =   2295
      End
      Begin VB.Label Label3 
         Caption         =   "Font:"
         Enabled         =   0   'False
         Height          =   225
         Left            =   240
         TabIndex        =   4
         Top             =   450
         Width           =   510
      End
   End
End
Attribute VB_Name = "options"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub bcolor_Click()

dialog.ShowColor
If Not dialog.CancelError Then bcolor.BackColor = dialog.Color

End Sub
Private Sub Command1_Click()


Command3_Click

Unload Me


End Sub

Private Sub Command2_Click()

Unload Me

End Sub

Private Sub Command3_Click()

Open App.Path & "\options.dat" For Output As #1
Close #1

LoadOptions

End Sub

Private Sub fcolor_Click()

dialog.ShowColor
If Not dialog.CancelError Then fcolor.BackColor = dialog.Color

End Sub
Private Sub Form_Load()

bcolor.BackColor = editorWin.editor.BackColor
fcolor.BackColor = editorWin.editor.SelColor

End Sub
