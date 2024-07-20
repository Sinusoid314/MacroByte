VERSION 5.00
Begin VB.Form editorWin 
   Caption         =   "untitled.bas"
   ClientHeight    =   4560
   ClientLeft      =   60
   ClientTop       =   345
   ClientWidth     =   6645
   Icon            =   "editorWin.frx":0000
   LinkTopic       =   "Form1"
   MDIChild        =   -1  'True
   ScaleHeight     =   304
   ScaleMode       =   3  'Pixel
   ScaleWidth      =   443
   Begin VB.TextBox editor 
      BeginProperty Font 
         Name            =   "Courier New"
         Size            =   9.75
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   3945
      Left            =   75
      MultiLine       =   -1  'True
      ScrollBars      =   3  'Both
      TabIndex        =   0
      Top             =   75
      Width           =   6210
   End
End
Attribute VB_Name = "editorWin"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Public filename As String
Public fileTitle As String
Public hasChanged As Boolean

Private Sub editor_Change()

hasChanged = True

End Sub

Private Sub editor_KeyPress(KeyAscii As Integer)

If KeyAscii = 9 Then
    KeyAscii = 0
    editor.SelText = Space(4)
End If

End Sub


Private Sub Form_Load()

hasChanged = False

End Sub

Private Sub Form_Resize()

On Error Resume Next

editor.Move 0, 0, Me.ScaleWidth, Me.ScaleHeight

End Sub

Private Sub Form_Unload(Cancel As Integer)

If hasChanged Then
  r = MsgBox("Save changes made to '" & filename & "' ?", vbYesNoCancel, "Lithium BASIC")
      If r = vbYes Then Call mainWin.mnuFileSave_Click
      If r = vbCancel Then Cancel = 1
End If

End Sub


