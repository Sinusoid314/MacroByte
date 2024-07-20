VERSION 5.00
Begin VB.Form Form1 
   Caption         =   "Form1"
   ClientHeight    =   5280
   ClientLeft      =   60
   ClientTop       =   345
   ClientWidth     =   7770
   LinkTopic       =   "Form1"
   ScaleHeight     =   5280
   ScaleWidth      =   7770
   StartUpPosition =   3  'Windows Default
   Begin VB.TextBox Text1 
      Height          =   5055
      Left            =   120
      MultiLine       =   -1  'True
      ScrollBars      =   2  'Vertical
      TabIndex        =   0
      Top             =   120
      Width           =   7455
   End
End
Attribute VB_Name = "Form1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub Form_Load()

Dim fileHandle As Long
Dim fileName As String
Dim fileSize As Long
Dim fileInput As String
Dim filePtr As Long
Dim n As Long

Open App.Path & "\test.txt" For Binary As #1

fileSize = LOF(1)
Text1.Text = Text1.Text & CStr(fileSize) & vbCrLf & vbCrLf

filePtr = Loc(1)
Text1.Text = Text1.Text & CStr(filePtr) & vbCrLf & vbCrLf

For n = 1 To 7
    fileInput = "  "
    Get #1, , fileInput
    Text1.Text = Text1.Text & fileInput & vbCrLf
    filePtr = Loc(1)
    Text1.Text = Text1.Text & CStr(filePtr) & vbCrLf & vbCrLf
Next n

Close #1

End Sub


