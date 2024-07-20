Attribute VB_Name = "ClassDef_StaticText"
Public Sub InitObject(ByRef varRef As DataRefClass, ByRef paramList As ArrayClass)

Dim paramRefs As New ArrayClass
Dim a As Long

'Resize paramRefs to paramList size
'For a = 1 To paramList.itemCount
'    paramRefs.Add Nothing
'Next a

'Check argument # against parameter #
If (paramList.itemCount <> 6) Then
    ErrorMsg "Wrong number of arguments for new StaticText object"
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
    ErrorMsg "Type mismatch in argument 1 of new StaticText object"
    Exit Sub
End If
If paramRefs.Item(2).drType <> DT_STRING Then
    ErrorMsg "Type mismatch in argument 2 of new StaticText object"
    Exit Sub
End If
For a = 3 To 6
    If paramRefs.Item(a).drType <> DT_NUMBER Then
        ErrorMsg "Type mismatch in argument " & CStr(a) & " of new StaticText object"
        Exit Sub
    End If
Next a

'Write bytecode
GenByteCodeFL IDC_NewObject, varRef.drID, varRef.drIdx, IDCLS_StaticText

End Sub


Public Function MethodCall(ByRef mcObj As MethodCallClass) As Boolean

MethodCall = True

Select Case LCase(mcObj.methodName)

'    Case "*"
'        ClassDef_StaticText.Meth_* mcObj
'        Exit Function

End Select

MethodCall = False

End Function

