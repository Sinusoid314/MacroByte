VERSION 5.00
Begin VB.Form varWin 
   BorderStyle     =   1  'Fixed Single
   Caption         =   "Variable/Array Editor"
   ClientHeight    =   6600
   ClientLeft      =   45
   ClientTop       =   330
   ClientWidth     =   7725
   ControlBox      =   0   'False
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   440
   ScaleMode       =   3  'Pixel
   ScaleWidth      =   515
   StartUpPosition =   2  'CenterScreen
   Begin VB.CommandButton closeBtn 
      Caption         =   "Close"
      Height          =   435
      Left            =   6000
      TabIndex        =   3
      Top             =   5955
      Width           =   1125
   End
   Begin VB.PictureBox Picture1 
      Appearance      =   0  'Flat
      ForeColor       =   &H80000008&
      Height          =   5130
      Left            =   75
      ScaleHeight     =   340
      ScaleMode       =   3  'Pixel
      ScaleWidth      =   504
      TabIndex        =   0
      Top             =   600
      Width           =   7590
      Begin VB.ListBox vNameList 
         Height          =   3615
         IntegralHeight  =   0   'False
         Left            =   1335
         TabIndex        =   7
         Top             =   435
         Width           =   4950
      End
      Begin VB.Frame Frame1 
         Height          =   735
         Left            =   90
         TabIndex        =   4
         Top             =   4275
         Width           =   7260
         Begin VB.CommandButton editVBtn 
            Caption         =   "Edit"
            Enabled         =   0   'False
            Height          =   435
            Left            =   4605
            TabIndex        =   13
            Top             =   210
            Width           =   1230
         End
         Begin VB.CommandButton delVBtn 
            Caption         =   "Remove"
            Enabled         =   0   'False
            Height          =   435
            Left            =   3075
            TabIndex        =   6
            Top             =   210
            Width           =   1230
         End
         Begin VB.CommandButton addVBtn 
            Caption         =   "Add"
            Height          =   435
            Left            =   1530
            TabIndex        =   5
            Top             =   210
            Width           =   1230
         End
      End
   End
   Begin VB.PictureBox Picture2 
      Appearance      =   0  'Flat
      ForeColor       =   &H80000008&
      Height          =   5130
      Left            =   75
      ScaleHeight     =   340
      ScaleMode       =   3  'Pixel
      ScaleWidth      =   504
      TabIndex        =   8
      Top             =   600
      Visible         =   0   'False
      Width           =   7590
      Begin VB.Frame Frame4 
         Height          =   735
         Left            =   90
         TabIndex        =   10
         Top             =   4275
         Width           =   7260
         Begin VB.CommandButton editABtn 
            Caption         =   "Edit"
            Enabled         =   0   'False
            Height          =   435
            Left            =   4575
            TabIndex        =   14
            Top             =   210
            Width           =   1230
         End
         Begin VB.CommandButton addABtn 
            Caption         =   "Add"
            Height          =   435
            Left            =   1485
            TabIndex        =   12
            Top             =   210
            Width           =   1230
         End
         Begin VB.CommandButton delABtn 
            Caption         =   "Remove"
            Enabled         =   0   'False
            Height          =   435
            Left            =   3030
            TabIndex        =   11
            Top             =   210
            Width           =   1230
         End
      End
      Begin VB.ListBox aNameList 
         Height          =   3615
         IntegralHeight  =   0   'False
         Left            =   1335
         TabIndex        =   9
         Top             =   435
         Width           =   4950
      End
   End
   Begin VB.Label tab1 
      Alignment       =   2  'Center
      Appearance      =   0  'Flat
      BackColor       =   &H80000002&
      BorderStyle     =   1  'Fixed Single
      Caption         =   "Variables"
      ForeColor       =   &H80000009&
      Height          =   300
      Left            =   75
      TabIndex        =   2
      Top             =   300
      Width           =   1125
   End
   Begin VB.Label tab2 
      Alignment       =   2  'Center
      Appearance      =   0  'Flat
      BackColor       =   &H80000003&
      BorderStyle     =   1  'Fixed Single
      Caption         =   "Arrays"
      ForeColor       =   &H80000013&
      Height          =   300
      Left            =   1200
      TabIndex        =   1
      Top             =   300
      Width           =   1125
   End
End
Attribute VB_Name = "varWin"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub addABtn_Click()

Dim cmdStr As String
Dim varStr As String
Dim idxStr As String
Dim typeStr As String
Dim typeVal As Integer
Dim idxList As New ArrayClass
Dim n As Long

cmdStr = Trim(InputBox("Array Definition:", "New Array", ""))
If cmdStr = "" Then Exit Sub

'Parse definition *******************************************
varStr = GetString(1, cmdStr, "(")
If varStr = cmdStr Then
    MsgBox "Syntax error", vbCritical
    Exit Sub
End If
idxStr = GetString(Len(varStr) + 1, LCase(cmdStr), " as ")
If Len(idxStr) = Len(Mid(cmdStr, Len(varStr) + 1)) Then
    MsgBox "Syntax error", vbCritical
    Exit Sub
End If
typeStr = Trim(Mid(cmdStr, Len(varStr) + Len(idxStr) + 5))
idxStr = Trim(idxStr)
varStr = Trim(varStr)
If Right(idxStr, 1) <> ")" Then
    MsgBox "Syntax error", vbCritical
    Exit Sub
End If
If typeStr = "number" Then
    typeVal = DT_NUMBER
ElseIf typeStr = "string" Then
    typeVal = DT_STRING
Else
    MsgBox "Illegal array type: " & typeStr, vbCritical
    Exit Sub
End If
idxStr = Mid(idxStr, 2, Len(idxStr) - 2)
ParseParams idxStr, idxList
If (idxList.itemCount = 0) Or (idxList.itemCount > 2) Then
    MsgBox "Illegal number of array dimensions", vbCritical
    Exit Sub
End If
MsgBox varStr
MsgBox typeStr
For n = 1 To idxList.itemCount
MsgBox idxList.Item(n)
    idxList.Item(n) = Val(idxList.Item(n))
    If idxList.Item(n) < 1 Then
        MsgBox "Illegal value for dimension " & str(n), vbCritical
        Exit Sub
    End If
Next n
'************************************************************

aNameList.AddItem cmdStr

With spDefList.Item(notepad.spList.ListIndex + 1)
    .arrayNameList.Add varStr
    .arrayTypeList.Add typeVal
    .arrayDimNumList.Add idxList.itemCount
    .arrayDimValList.Add New ArrayClass
    For n = 1 To idxList.itemCount
        .arrayDimValList.Item(.arrayDimValList.itemCount).Add idxList.Item(n)
    Next n
End With

aNameList.ListIndex = aNameList.ListCount - 1

isChanged = True

End Sub

Private Sub addVBtn_Click()

Dim cmdStr As String
Dim typeStr As String
Dim varStr As String
Dim typeVal As Integer

cmdStr = Trim(InputBox("Variable Definition:", "New Variable", ""))
If cmdStr = "" Then Exit Sub

'Parse definition *******************************************
varStr = GetString(1, LCase(cmdStr), " as ")
varStr = Left(cmdStr, Len(varStr))

If Len(varStr) = Len(cmdStr) Then
    typeStr = "number"
Else
    typeStr = LCase(Trim(Right(cmdStr, Len(cmdStr) - (Len(varStr) + 4))))
End If

If typeStr = "number" Then
    typeVal = DT_NUMBER
ElseIf typeStr = "string" Then
    typeVal = DT_STRING
Else
    MsgBox "Illegal variable type: " & typeStr, vbCritical
    Exit Sub
End If
'************************************************************

vNameList.AddItem cmdStr
spDefList.Item(notepad.spList.ListIndex + 1).varNameList.Add varStr
spDefList.Item(notepad.spList.ListIndex + 1).varTypeList.Add typeVal
vNameList.ListIndex = vNameList.ListCount - 1

isChanged = True

End Sub

Private Sub closeBtn_Click()
    Unload Me
End Sub

Private Sub delABtn_Click()

If aNameList.ListIndex < 0 Then Exit Sub

If MsgBox("Remove array '" & aNameList.List(aNameList.ListIndex) & "' ?", vbYesNo) = vbNo Then Exit Sub

With spDefList.Item(notepad.spList.ListIndex + 1)
.arrayNameList.Remove aNameList.ListIndex + 1
.arrayTypeList.Remove aNameList.ListIndex + 1
.arrayDimNumList.Remove aNameList.ListIndex + 1
.arrayDimValList.Remove aNameList.ListIndex + 1
End With

aNameList.RemoveItem aNameList.ListIndex

isChanged = True

End Sub

Private Sub delVBtn_Click()

If vNameList.ListIndex < 0 Then Exit Sub

If MsgBox("Remove variable '" & vNameList.List(vNameList.ListIndex) & "' ?", vbYesNo) = vbNo Then Exit Sub

spDefList.Item(notepad.spList.ListIndex + 1).varNameList.Remove vNameList.ListIndex + 1
spDefList.Item(notepad.spList.ListIndex + 1).varTypeList.Remove vNameList.ListIndex + 1
vNameList.RemoveItem vNameList.ListIndex

isChanged = True

End Sub

Private Sub editVBtn_Click()

Dim cmdStr As String
Dim typeStr As String
Dim varStr As String
Dim typeVal As Integer

If vNameList.ListIndex < 0 Then Exit Sub

cmdStr = Trim(InputBox("Variable Definition:", "Edit Variable", vNameList.List(vNameList.ListIndex)))
If cmdStr = "" Then Exit Sub

'Parse definition *******************************************
varStr = GetString(1, LCase(cmdStr), " as ")
varStr = Left(cmdStr, Len(varStr))

If Len(varStr) = Len(cmdStr) Then
    typeStr = "number"
Else
    typeStr = LCase(Trim(Right(cmdStr, Len(cmdStr) - (Len(varStr) + 4))))
End If

If typeStr = "number" Then
    typeVal = DT_NUMBER
ElseIf typeStr = "string" Then
    typeVal = DT_STRING
Else
    MsgBox "Illegal variable type: " & typeStr, vbCritical
    Exit Sub
End If
'************************************************************

vNameList.List(vNameList.ListIndex) = cmdStr
spDefList.Item(notepad.spList.ListIndex + 1).varNameList.Item(vNameList.ListIndex + 1) = varStr
spDefList.Item(notepad.spList.ListIndex + 1).varTypeList.Item(vNameList.ListIndex + 1) = typeVal

isChanged = True

End Sub

Private Sub Form_Load()

Dim tmpStr As String
Dim n As Long
Dim b As Integer

'Load variables
With spDefList.Item(notepad.spList.ListIndex + 1)
    For n = 1 To .varNameList.itemCount
        tmpStr = .varNameList.Item(n) & " as "
        If .varTypeList.Item(n) = DT_NUMBER Then
            tmpStr = tmpStr & "number"
        Else
            tmpStr = tmpStr & "string"
        End If
        vNameList.AddItem tmpStr
    Next n
End With

'Load arrays
With spDefList.Item(notepad.spList.ListIndex + 1)
    For n = 1 To .arrayNameList.itemCount
        tmpStr = .arrayNameList.Item(n) & "("
        For b = 1 To .arrayDimNumList.Item(n)
            tmpStr = tmpStr & str(.arrayDimValList.Item(n).Item(b))
            If b < .arrayDimNumList.Item(n) Then
                tmpStr = tmpStr & ","
            Else
                tmpStr = tmpStr & ") as "
            End If
        Next b
        If .arrayTypeList.Item(n) = DT_NUMBER Then
            tmpStr = tmpStr & "number"
        Else
            tmpStr = tmpStr & "string"
        End If
        aNameList.AddItem tmpStr
    Next n
End With

End Sub

Private Sub tab1_Click()

Picture2.Visible = False
tab2.BackColor = &H80000003
tab2.ForeColor = &H80000013

Picture1.Visible = True
tab1.BackColor = &H80000002
tab1.ForeColor = &H80000009

End Sub


Private Sub tab2_Click()

Picture2.Visible = True
tab2.BackColor = &H80000002
tab2.ForeColor = &H80000009

Picture1.Visible = False
tab1.BackColor = &H80000003
tab1.ForeColor = &H80000013

End Sub


Private Sub tab3_Click()

Picture3.Visible = True
tab3.BackColor = &H80000002
tab3.ForeColor = &H80000009

Picture2.Visible = False
tab2.BackColor = &H80000003
tab2.ForeColor = &H80000013

Picture1.Visible = False
tab1.BackColor = &H80000003
tab1.ForeColor = &H80000013

End Sub


Private Sub vNameList_Click()

If vNameList.ListIndex < 0 Then Exit Sub

delVBtn.Enabled = True
editVBtn.Enabled = True

End Sub


Private Sub vType_Change()

If vNameList.ListIndex < 0 Then Exit Sub

spDefList.Item(notepad.spList.ListIndex + 1).varTypeList.Item(vNameList.ListIndex + 1) = vType.ListIndex

isChanged = True

End Sub


Private Sub vNameList_DblClick()

If vNameList.ListIndex < 0 Then Exit Sub

Call editVBtn_Click

End Sub


