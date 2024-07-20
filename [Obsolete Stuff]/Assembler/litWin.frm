VERSION 5.00
Begin VB.Form litWin 
   BorderStyle     =   1  'Fixed Single
   Caption         =   "Literals Editor"
   ClientHeight    =   6450
   ClientLeft      =   45
   ClientTop       =   330
   ClientWidth     =   9210
   ControlBox      =   0   'False
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   430
   ScaleMode       =   3  'Pixel
   ScaleWidth      =   614
   StartUpPosition =   2  'CenterScreen
   Begin VB.Frame Frame1 
      Height          =   735
      Left            =   465
      TabIndex        =   2
      Top             =   5595
      Width           =   5250
      Begin VB.CommandButton delBtn 
         Caption         =   "Remove"
         Enabled         =   0   'False
         Height          =   435
         Left            =   1875
         TabIndex        =   5
         Top             =   195
         Width           =   1230
      End
      Begin VB.CommandButton editBtn 
         Caption         =   "Edit"
         Enabled         =   0   'False
         Height          =   435
         Left            =   3630
         TabIndex        =   4
         Top             =   195
         Width           =   1230
      End
      Begin VB.CommandButton addBtn 
         Caption         =   "Add"
         Height          =   435
         Left            =   330
         TabIndex        =   3
         Top             =   195
         Width           =   1230
      End
   End
   Begin VB.CommandButton closeBtn 
      Caption         =   "Close"
      Height          =   435
      Left            =   6990
      TabIndex        =   1
      Top             =   5805
      Width           =   1125
   End
   Begin VB.ListBox litList 
      Height          =   5325
      Left            =   90
      TabIndex        =   0
      Top             =   150
      Width           =   9030
   End
End
Attribute VB_Name = "litWin"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub addBtn_Click()

Dim tmpLit As String

tmpLit = Trim(InputBox("Value:", "New Literal"))

If tmpLit = "" Then Exit Sub

LiteralList.Add tmpLit
litList.AddItem tmpLit

isChanged = True

End Sub

Private Sub closeBtn_Click()
    Unload Me
End Sub


Private Sub editBtn_Click()

Dim tmpLit As String
Dim n As Long

If litList.ListIndex < 0 Then Exit Sub

n = litList.ListIndex + 1

tmpLit = Trim(InputBox("Value:", "Edit Literal", LiteralList.Item(n)))
If tmpLit = "" Then Exit Sub

LiteralList.Item(n) = tmpLit
litList.List(n - 1) = tmpLit

isChanged = True

End Sub

Private Sub Form_Load()

Dim n As Long

For n = 1 To LiteralList.itemCount
    litList.AddItem LiteralList.Item(n)
Next n

End Sub


Private Sub litList_Click()

If litList.ListIndex < 0 Then Exit Sub

delBtn.Enabled = True
editBtn.Enabled = True

End Sub

Private Sub delBtn_Click()

If litList.ListIndex < 0 Then Exit Sub

If MsgBox("Remove literal  '" & CStr(litList.ListIndex + 1) & "' ?", vbYesNo) = vbNo Then Exit Sub

LiteralList.Remove litList.ListIndex + 1
litList.RemoveItem litList.ListIndex

If litList.ListIndex < 0 Then
    delBtn.Enabled = False
    editBtn.Enabled = False
End If

isChanged = True

End Sub


Private Sub litList_DblClick()

If litList.ListIndex < 0 Then Exit Sub

Call editBtn_Click

End Sub


