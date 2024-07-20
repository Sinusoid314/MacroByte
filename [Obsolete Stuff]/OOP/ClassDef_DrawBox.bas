Attribute VB_Name = "ClassDef_DrawBox"
Public Sub InitObject(ByRef varRef As DataRefClass, ByRef paramList As ArrayClass)

Dim paramRefs As New ArrayClass
Dim a As Long

'Resize paramRefs to paramList size
'For a = 1 To paramList.itemCount
'    paramRefs.Add Nothing
'Next a

'Check argument # against parameter #
If (paramList.itemCount <> 5) Then
    ErrorMsg "Wrong number of arguments for new DrawBox object"
    Exit Sub
End If

For a = paramList.itemCount To 1 Step -1
    'Evaluate each argument
    paramRefs.Add EvalExpression(paramList.Item(a)), 1
    If compileError Then Exit Sub
    'Write bytecode for argument stacking
      GenByteCodeFL IDC_ADDDATA, paramRefs.Item(1).drID, paramRefs.Item(1).drIdx
      GenByteCodeFL IDC_REMOVEEXP, 1
Next a

'Check argument types against parameter types
For a = 1 To 5
    If paramRefs.Item(a).drType <> DT_NUMBER Then
        ErrorMsg "Type mismatch in argument " & CStr(a) & " of new DrawBox object"
        Exit Sub
    End If
Next a

'Write bytecode
GenByteCodeFL IDC_NewObject, varRef.drID, varRef.drIdx, IDCLS_DrawBox

End Sub


Private Sub Meth_Redraw(ByRef mcObj As MethodCallClass)

Dim expRef As DataRefClass

'Check argument # against parameter #
If mcObj.paramList.itemCount > 0 Then
    ErrorMsg "Wrong number of arguments for Redraw method"
    Exit Sub
End If

'Compile object ID expression
Set expRef = EvalExpression(mcObj.expStr)
If compileError Then Exit Sub
GenByteCodeFL IDC_ADDDATA, expRef.drID, expRef.drIdx
GenByteCodeFL IDC_REMOVEEXP, 1

'Write bytecode
GenByteCodeFL IDC_CallObjectMethod, IDMETH_WinGUI_DrawBox_Redraw

If isFuncCall Then
    ErrorMsg "Method Redraw does not return a value"
    Exit Sub
End If

End Sub


Private Sub Meth_Stick(ByRef mcObj As MethodCallClass)

Dim expRef As DataRefClass

'Check argument # against parameter #
If mcObj.paramList.itemCount > 0 Then
    ErrorMsg "Wrong number of arguments for Stick method"
    Exit Sub
End If

'Compile object ID expression
Set expRef = EvalExpression(mcObj.expStr)
If compileError Then Exit Sub
GenByteCodeFL IDC_ADDDATA, expRef.drID, expRef.drIdx
GenByteCodeFL IDC_REMOVEEXP, 1

'Write bytecode
GenByteCodeFL IDC_CallObjectMethod, IDMETH_WinGUI_DrawBox_Stick

If isFuncCall Then
    ErrorMsg "Method Stick does not return a value"
    Exit Sub
End If

End Sub


Private Sub Meth_CopyTo(ByRef mcObj As MethodCallClass)

Dim expRef As DataRefClass
Dim paramRefs As New ArrayClass
Dim a As Long

'Resize paramRefs to tmpParamList size
'For a = 1 To mcObj.paramList.itemCount
'    paramRefs.Add Nothing
'Next a

'Check argument # against parameter #
If mcObj.paramList.itemCount <> 7 Then
    ErrorMsg "Wrong number of arguments for CopyTo method"
    Exit Sub
End If

For a = mcObj.paramList.itemCount To 1 Step -1
    'Evaluate each argument
    paramRefs.Add EvalExpression(mcObj.paramList.Item(a)), 1
    If compileError Then Exit Sub
    'Write bytecode for argument stacking
      GenByteCodeFL IDC_ADDDATA, paramRefs.Item(1).drID, paramRefs.Item(1).drIdx
      GenByteCodeFL IDC_REMOVEEXP, 1
Next a
'Check argument types against parameter types
For a = 1 To paramRefs.itemCount
    If paramRefs.Item(a).drType <> DT_NUMBER Then
        ErrorMsg "Type mismatch in argument " & CStr(a) & " of CopyTo method"
        Exit Sub
    End If
Next a


'Compile object ID expression
Set expRef = EvalExpression(mcObj.expStr)
If compileError Then Exit Sub
GenByteCodeFL IDC_ADDDATA, expRef.drID, expRef.drIdx
GenByteCodeFL IDC_REMOVEEXP, 1

'Write bytecode
GenByteCodeFL IDC_CallObjectMethod, IDMETH_WinGUI_DrawBox_CopyTo

If isFuncCall Then
    ErrorMsg "Method CopyTo does not return a value"
    Exit Sub
End If

End Sub
Private Sub Meth_Line(ByRef mcObj As MethodCallClass)

Dim expRef As DataRefClass
Dim paramRefs As New ArrayClass
Dim a As Long

'Resize paramRefs to tmpParamList size
'For a = 1 To mcObj.paramList.itemCount
'    paramRefs.Add Nothing
'Next a

'Check argument # against parameter #
If mcObj.paramList.itemCount <> 4 Then
    ErrorMsg "Wrong number of arguments for Line method"
    Exit Sub
End If

For a = mcObj.paramList.itemCount To 1 Step -1
    'Evaluate each argument
    paramRefs.Add EvalExpression(mcObj.paramList.Item(a)), 1
    If compileError Then Exit Sub
    'Write bytecode for argument stacking
      GenByteCodeFL IDC_ADDDATA, paramRefs.Item(1).drID, paramRefs.Item(1).drIdx
      GenByteCodeFL IDC_REMOVEEXP, 1
Next a
'Check argument types against parameter types
For a = 1 To paramRefs.itemCount
    If paramRefs.Item(a).drType <> DT_NUMBER Then
        ErrorMsg "Type mismatch in argument " & CStr(a) & " of Line method"
        Exit Sub
    End If
Next a


'Compile object ID expression
Set expRef = EvalExpression(mcObj.expStr)
If compileError Then Exit Sub
GenByteCodeFL IDC_ADDDATA, expRef.drID, expRef.drIdx
GenByteCodeFL IDC_REMOVEEXP, 1

'Write bytecode
GenByteCodeFL IDC_CallObjectMethod, IDMETH_WinGUI_DrawBox_Line

If isFuncCall Then
    ErrorMsg "Method Line does not return a value"
    Exit Sub
End If

End Sub


Private Sub Meth_Box(ByRef mcObj As MethodCallClass)

Dim expRef As DataRefClass
Dim paramRefs As New ArrayClass
Dim a As Long

'Resize paramRefs to tmpParamList size
'For a = 1 To mcObj.paramList.itemCount
'    paramRefs.Add Nothing
'Next a

'Check argument # against parameter #
If mcObj.paramList.itemCount <> 4 Then
    ErrorMsg "Wrong number of arguments for Box method"
    Exit Sub
End If

For a = mcObj.paramList.itemCount To 1 Step -1
    'Evaluate each argument
    paramRefs.Add EvalExpression(mcObj.paramList.Item(a)), 1
    If compileError Then Exit Sub
    'Write bytecode for argument stacking
      GenByteCodeFL IDC_ADDDATA, paramRefs.Item(1).drID, paramRefs.Item(1).drIdx
      GenByteCodeFL IDC_REMOVEEXP, 1
Next a
'Check argument types against parameter types
For a = 1 To paramRefs.itemCount
    If paramRefs.Item(a).drType <> DT_NUMBER Then
        ErrorMsg "Type mismatch in argument " & CStr(a) & " of Box method"
        Exit Sub
    End If
Next a


'Compile object ID expression
Set expRef = EvalExpression(mcObj.expStr)
If compileError Then Exit Sub
GenByteCodeFL IDC_ADDDATA, expRef.drID, expRef.drIdx
GenByteCodeFL IDC_REMOVEEXP, 1

'Write bytecode
GenByteCodeFL IDC_CallObjectMethod, IDMETH_WinGUI_DrawBox_Box

If isFuncCall Then
    ErrorMsg "Method Box does not return a value"
    Exit Sub
End If

End Sub


Private Sub Meth_Circle(ByRef mcObj As MethodCallClass)

Dim expRef As DataRefClass
Dim paramRefs As New ArrayClass
Dim a As Long

'Resize paramRefs to tmpParamList size
'For a = 1 To mcObj.paramList.itemCount
'    paramRefs.Add Nothing
'Next a

'Check argument # against parameter #
If mcObj.paramList.itemCount <> 3 Then
    ErrorMsg "Wrong number of arguments for Circle method"
    Exit Sub
End If

For a = mcObj.paramList.itemCount To 1 Step -1
    'Evaluate each argument
    paramRefs.Add EvalExpression(mcObj.paramList.Item(a)), 1
    If compileError Then Exit Sub
    'Write bytecode for argument stacking
      GenByteCodeFL IDC_ADDDATA, paramRefs.Item(1).drID, paramRefs.Item(1).drIdx
      GenByteCodeFL IDC_REMOVEEXP, 1
Next a
'Check argument types against parameter types
For a = 1 To paramRefs.itemCount
    If paramRefs.Item(a).drType <> DT_NUMBER Then
        ErrorMsg "Type mismatch in argument " & CStr(a) & " of Circle method"
        Exit Sub
    End If
Next a


'Compile object ID expression
Set expRef = EvalExpression(mcObj.expStr)
If compileError Then Exit Sub
GenByteCodeFL IDC_ADDDATA, expRef.drID, expRef.drIdx
GenByteCodeFL IDC_REMOVEEXP, 1

'Write bytecode
GenByteCodeFL IDC_CallObjectMethod, IDMETH_WinGUI_DrawBox_Circle

If isFuncCall Then
    ErrorMsg "Method Circle does not return a value"
    Exit Sub
End If

End Sub
Public Function MethodCall(ByRef mcObj As MethodCallClass) As Boolean

MethodCall = True

Select Case LCase(mcObj.methodName)

    Case "redraw"
        ClassDef_DrawBox.Meth_Redraw mcObj
        Exit Function
        
    Case "stick"
        ClassDef_DrawBox.Meth_Stick mcObj
        Exit Function
        
    Case "copyto"
        ClassDef_DrawBox.Meth_CopyTo mcObj
        Exit Function
        
    Case "line"
        ClassDef_DrawBox.Meth_Line mcObj
        Exit Function
        
    Case "box"
        ClassDef_DrawBox.Meth_Box mcObj
        Exit Function
        
    Case "circle"
        ClassDef_DrawBox.Meth_Circle mcObj
        Exit Function
        
End Select

MethodCall = False

End Function


