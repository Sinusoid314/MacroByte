VERSION 5.00
Begin VB.Form consol 
   Caption         =   "Program Consol"
   ClientHeight    =   4830
   ClientLeft      =   60
   ClientTop       =   390
   ClientWidth     =   7620
   Icon            =   "consol.frx":0000
   LinkTopic       =   "Form1"
   ScaleHeight     =   322
   ScaleMode       =   3  'Pixel
   ScaleWidth      =   508
   StartUpPosition =   3  'Windows Default
   Begin VB.TextBox display 
      BackColor       =   &H00FFFFFF&
      BeginProperty Font 
         Name            =   "Courier New"
         Size            =   9.75
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00000000&
      Height          =   4275
      Left            =   0
      Locked          =   -1  'True
      MultiLine       =   -1  'True
      ScrollBars      =   3  'Both
      TabIndex        =   0
      Top             =   0
      Width           =   6420
   End
End
Attribute VB_Name = "consol"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub display_Change()

display.SelStart = Len(display.Text)

End Sub

Private Sub display_KeyPress(KeyAscii As Integer)

If inputting = False Then Exit Sub

If KeyAscii = 8 Then
  If Len(display.Text) > 0 And Len(userInput) > 0 Then
    display.Text = Left(display.Text, Len(display.Text) - 1)
    userInput = Left(userInput, Len(userInput) - 1)
  End If
ElseIf KeyAscii = 13 Then
  display.Text = display.Text & vbCrLf
  inputting = False
Else
  display.Text = display.Text & Chr(KeyAscii)
  userInput = userInput & Chr(KeyAscii)
End If

display.SelStart = Len(display.Text)

End Sub


Private Sub Form_Load()

inputting = False

consol.Width = Int((400 / 800) * Screen.Width)
consol.Height = Int((300 / 600) * Screen.Height)

End Sub


Private Sub Form_Resize()

On Error Resume Next

display.Width = Me.ScaleWidth
display.Height = Me.ScaleHeight

End Sub


Private Sub Form_Unload(Cancel As Integer)

RuntimeCleanup
End

End Sub


