Attribute VB_Name = "ClassDef_Window"

Public Sub InitObject(ByRef varRef As DataRefClass, ByRef paramList As ArrayClass)

Dim paramRefs As New ArrayClass
Dim a As Long

'Resize paramRefs to paramList size
'For a = 1 To paramList.itemCount
'    paramRefs.Add Nothing
'Next a

'Check argument # against parameter #
If (paramList.itemCount < 6) Or (paramList.itemCount > 7) Then
    ErrorMsg "Wrong number of arguments for new Window object"
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
For a = 1 To 2
    If paramRefs.Item(a).drType <> DT_STRING Then
        ErrorMsg "Type mismatch in argument " & CStr(a) & " of new Window object"
        Exit Sub
    End If
Next a
For a = 3 To 6
    If paramRefs.Item(a).drType <> DT_NUMBER Then
        ErrorMsg "Type mismatch in argument " & CStr(a) & " of new Window object"
        Exit Sub
    End If
Next a
If paramRefs.itemCount = 7 Then
    If paramRefs.Item(7).drType <> DT_NUMBER Then
        ErrorMsg "Type mismatch in argument " & CStr(7) & " of new Window object"
        Exit Sub
    End If
End If

'Write bytecode
GenByteCodeFL IDC_NewObject, varRef.drID, varRef.drIdx, IDCLS_Window

End Sub




Public Function MethodCall(ByRef mcObj As MethodCallClass) As Boolean

MethodCall = True

Select Case LCase(mcObj.methodName)
    Case "onclose"
        ClassDef_Window.Meth_OnClose mcObj
        Exit Function
End Select

MethodCall = False

End Function


Private Sub Meth_OnClose(ByRef mcObj As MethodCallClass)

Dim expRef As DataRefClass
Dim spIdx As Long
Dim a As Long

spIdx = 0

'Check argument # against parameter #
If mcObj.paramList.itemCount > 1 Then
    ErrorMsg "Wrong number of arguments for OnClose method"
    Exit Sub
End If

If mcObj.paramList.itemCount = 1 Then
    'Get index of subprog name
    For a = 1 To spDefList.itemCount
        With spDefList.Item(a)
            If LCase(mcObj.paramList.Item(1)) = LCase(.subProgName) Then
                If .isFunc Then
                    ErrorMsg "OnClose event '" & .subProgName & "' must be a SUB"
                    Exit Sub
                End If
                If .paramNum > 1 Then
                    ErrorMsg "OnClose event '" & .subProgName & "' cannot have more than one parameter"
                    Exit Sub
                End If
                If .paramNum = 1 Then
                    If .varTypeList.Item(1) <> DT_NUMBER Then
                        ErrorMsg "Parameter of OnClose event '" & .subProgName & "' must be a Number"
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
GenByteCodeFL IDC_CallObjectMethod, IDMETH_WinGUI_Window_OnClose, spIdx

If isFuncCall Then
    ErrorMsg "Method OnClose does not return a value"
    Exit Sub
End If

End Sub
