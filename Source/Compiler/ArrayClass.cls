VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "ArrayClass"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Public itemCount As Long
Private items() As Variant


Public Sub Add(ByVal newItem As Variant, Optional ByVal before As Integer)

Dim tmp() As Variant
Dim i As Long

ReDim tmp(itemCount)

If before = Empty Or itemCount = 0 Then
    For i = 1 To itemCount
        If IsObject(items(i)) Then Set tmp(i) = items(i) Else tmp(i) = items(i)
    Next i
    ReDim items(itemCount + 1)
    For i = 1 To itemCount
        If IsObject(tmp(i)) Then Set items(i) = tmp(i) Else items(i) = tmp(i)
    Next i
    If IsObject(newItem) Then Set items(itemCount + 1) = newItem Else items(itemCount + 1) = newItem
ElseIf before > 0 And before <= itemCount Then
    For i = 1 To itemCount
        If IsObject(items(i)) Then Set tmp(i) = items(i) Else tmp(i) = items(i)
    Next i
    ReDim items(itemCount + 1)
    For i = 1 To before - 1
        If IsObject(tmp(i)) Then Set items(i) = tmp(i) Else items(i) = tmp(i)
    Next i
    If IsObject(newItem) Then Set items(before) = newItem Else items(before) = newItem
    For i = before + 1 To itemCount + 1
        If IsObject(tmp(i - 1)) Then Set items(i) = tmp(i - 1) Else items(i) = tmp(i - 1)
    Next i
End If

itemCount = itemCount + 1

End Sub

Public Sub Clear()

ReDim items(0)

itemCount = 0

End Sub

Public Property Get Item(ByVal itemIdx As Integer) As Variant

If itemIdx > 0 And itemIdx <= itemCount Then
    If IsObject(items(itemIdx)) Then Set Item = items(itemIdx) Else Item = items(itemIdx)
Else
    MsgBox "ArrayClass error: Index '" & itemIdx & "' is out of bounds", vbCritical, "PropGET"
    a = 1
End If

End Property
Public Property Let Item(ByVal itemIdx As Integer, newItem As Variant)

If itemIdx > 0 And itemIdx <= itemCount Then
    If IsObject(newItem) Then Set items(itemIdx) = newItem Else items(itemIdx) = newItem
Else
    MsgBox "ArrayClass error: Index '" & itemIdx & "' is out of bounds", vbCritical, "PropLET"
    a = 1
End If

End Property
Public Sub Remove(ByVal itemIdx As Integer)

If itemCount = 0 Or itemIdx <= 0 Or itemIdx > itemCount Then Exit Sub

Dim tmp() As Variant
Dim i As Long

ReDim tmp(itemCount)

For i = 1 To itemCount
    If IsObject(items(i)) Then Set tmp(i) = items(i) Else tmp(i) = items(i)
Next i
ReDim items(itemCount - 1)
For i = 1 To itemIdx - 1
    If IsObject(tmp(i)) Then Set items(i) = tmp(i) Else items(i) = tmp(i)
Next i
For i = itemCount To itemIdx + 1 Step -1
    If IsObject(tmp(i)) Then Set items(i - 1) = tmp(i) Else items(i - 1) = tmp(i)
Next i

itemCount = itemCount - 1

End Sub

Private Sub Class_Initialize()

itemCount = 0

End Sub


