Attribute VB_Name = "ClassDef_Button"

Public Sub InitObject(ByRef varRef As DataRefClass, ByRef paramList As ArrayClass)

Dim paramRefs As New ArrayClass
Dim a As Long

'Resize paramRefs to paramList size
'For a = 1 To paramList.itemCount
'    paramRefs.Add Nothing
'Next a

'Check argument # against parameter #
If (paramList.itemCount < 6) Or (paramList.itemCount > 7) Then
    ErrorMsg "Wrong number of arguments for new Button object"
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
If paramRefs.Item(1).drType <> DT_NUMBER Then
    ErrorMsg "Type mismatch in argument 1 of new Button object"
    Exit Sub
End If
If paramRefs.Item(2).drType <> DT_STRING Then
    ErrorMsg "Type mismatch in argument 2 of new Button object"
    Exit Sub
End If
For a = 3 To 6
    If paramRefs.Item(a).drType <> DT_NUMBER Then
        ErrorMsg "Type mismatch in argument " & CStr(a) & " of new Button object"
        Exit Sub
    End If
Next a

'Write bytecode
GenByteCodeFL IDC_NewObject, varRef.drID, varRef.drIdx, IDCLS_Button

End Sub


Public Function MethodCall(ByRef mcObj As MethodCallClass) As Boolean

MethodCall = True

Select Case LCase(mcObj.methodName)
    Case "onclick"
        ClassDef_Button.Meth_OnClick mcObj
        Exit Function
End Select

MethodCall = False

End Function


Private Sub Meth_OnClick(ByRef mcObj As MethodCallClass)

Dim expRef As DataRefClass
Dim spIdx As Long
Dim a As Long

spIdx = 0

'Check argument # against parameter #
If mcObj.paramList.itemCount > 1 Then
    ErrorMsg "Wrong number of arguments for OnClick method"
    Exit Sub
End If

If mcObj.paramList.itemCount = 1 Then
    'Get index of subprog name
    For a = 1 To spDefList.itemCount
        With spDefList.Item(a)
            If LCase(mcObj.paramList.Item(1)) = LCase(.subProgName) Then
                If .isFunc Then
                    ErrorMsg "OnClick event '" & .subProgName & "' must be a SUB"
                    Exit Sub
                End If
                If .paramNum > 1 Then
                    ErrorMsg "OnClick event '" & .subProgName & "' cannot have more than one parameter"
                    Exit Sub
                End If
                If .paramNum = 1 Then
                    If .varTypeList.Item(1) <> DT_NUMBER Then
                        ErrorMsg "Parameter of OnClick event '" & .subProgName & "' must be a Number"
                        Exit Sub
                    End If
                End If
                spIdx = a
                Exit For
            End If
        End With
    Next a
End If

'Compile object ID expression
Set expRef = EvalExpression(mcObj.expStr)
If compileError Then Exit Sub
GenByteCodeFL IDC_ADDDATA, expRef.drID, expRef.drIdx
GenByteCodeFL IDC_REMOVEEXP, 1

'Write bytecode
GenByteCodeFL IDC_CallObjectMethod, IDMETH_WinGUI_Button_OnClick, spIdx

If isFuncCall Then
    ErrorMsg "Method OnClick does not return a value"
    Exit Sub
End If

End Sub
