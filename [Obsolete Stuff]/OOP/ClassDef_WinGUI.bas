Attribute VB_Name = "ClassDef_WinGUI"
Private Sub Meth_SetText(ByRef mcObj As MethodCallClass)

Dim expRef As DataRefClass
Dim paramRefs As New ArrayClass
Dim a As Long

'Resize paramRefs to tmpParamList size
'For a = 1 To mcObj.paramList.itemCount
'    paramRefs.Add Nothing
'Next a

'Check argument # against parameter #
If mcObj.paramList.itemCount <> 1 Then
    ErrorMsg "Wrong number of arguments for SetText method"
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
    If paramRefs.Item(a).drType <> DT_STRING Then
        ErrorMsg "Type mismatch in argument " & CStr(a) & " of SetText method"
        Exit Sub
    End If
Next a


'Compile object ID expression
Set expRef = EvalExpression(mcObj.expStr)
If compileError Then Exit Sub
GenByteCodeFL IDC_ADDDATA, expRef.drID, expRef.drIdx
GenByteCodeFL IDC_REMOVEEXP, 1

'Write bytecode
GenByteCodeFL IDC_CallObjectMethod, IDMETH_WinGUI_SetText

If isFuncCall Then
    ErrorMsg "Method SetText does not return a value"
    Exit Sub
End If

End Sub

Public Function MethodCall(ByRef mcObj As MethodCallClass) As Boolean

MethodCall = True

Select Case LCase(mcObj.methodName)
    Case "gethwnd"
        ClassDef_WinGUI.Meth_GetHWND mcObj
        Exit Function
        
    Case "settext"
        ClassDef_WinGUI.Meth_SetText mcObj
        Exit Function
        
    Case "gettext"
        ClassDef_WinGUI.Meth_GetText mcObj
        Exit Function
End Select

MethodCall = False

End Function


Private Sub Meth_GetHWND(ByRef mcObj As MethodCallClass)

Dim expRef As DataRefClass

'Check argument # against parameter #
If mcObj.paramList.itemCount > 0 Then
    ErrorMsg "Wrong number of arguments for GetHWND method"
    Exit Sub
End If

'Compile object ID expression
Set expRef = EvalExpression(mcObj.expStr)
If compileError Then Exit Sub
GenByteCodeFL IDC_ADDDATA, expRef.drID, expRef.drIdx
GenByteCodeFL IDC_REMOVEEXP, 1

'Write bytecode
GenByteCodeFL IDC_CallObjectMethod, IDMETH_WinGUI_GetHWND

If isFuncCall Then
    'Fill out return reference
    Set mcObj.retRef = New DataRefClass
    mcObj.retRef.drID = IDD_DATLST
    mcObj.retRef.drIdx = 1
    mcObj.retRef.drType = DT_NUMBER
Else
    'Throw out return data
    GenByteCodeFL IDC_REMOVEDATA, 1
End If

End Sub



Private Sub Meth_GetText(ByRef mcObj As MethodCallClass)

Dim expRef As DataRefClass

'Check argument # against parameter #
If mcObj.paramList.itemCount > 0 Then
    ErrorMsg "Wrong number of arguments for GetText method"
    Exit Sub
End If

'Compile object ID expression
Set expRef = EvalExpression(mcObj.expStr)
If compileError Then Exit Sub
GenByteCodeFL IDC_ADDDATA, expRef.drID, expRef.drIdx
GenByteCodeFL IDC_REMOVEEXP, 1

'Write bytecode
GenByteCodeFL IDC_CallObjectMethod, IDMETH_WinGUI_GetText

If isFuncCall Then
    'Fill out return reference
    Set mcObj.retRef = New DataRefClass
    mcObj.retRef.drID = IDD_DATLST
    mcObj.retRef.drIdx = 1
    mcObj.retRef.drType = DT_STRING
Else
    'Throw out return data
    GenByteCodeFL IDC_REMOVEDATA, 1
End If

End Sub


