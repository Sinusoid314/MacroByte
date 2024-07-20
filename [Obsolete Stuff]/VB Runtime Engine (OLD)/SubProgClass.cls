VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "SubProgClass"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
'Runtime data reference lists (global/local)
Public varList As New ArrayClass
Public arrayList As New ArrayClass
Public arrayDimNumList As New ArrayClass

'Number of parameters
Public paramNum As Long

'Function flag
Public isFunc As Boolean

'Stack of line numbers used with GOSUB
Public gosubStack As New ArrayClass

'ByteCode list (local)
Public codeList As New ArrayClass

'Flag for when subprog code is running
Public isRunning As Boolean

'Current command index
Public lineNum As Long

Public Sub Cmd_Str()
    DataStack.Item(1) = CStr(DataStack.Item(1))
End Sub

Public Sub IntCmd_For()

Dim counter As Variant
Dim fromVal As Variant
Dim toVal As Variant
Dim stepVal As Variant
Dim codeBLen As Long
Dim forLine As Long
Dim startLine As Long
Dim endLine As Long

fromVal = DataStack.Item(1)
  DataStack.Remove 1
toVal = DataStack.Item(1)
  DataStack.Remove 1
stepVal = DataStack.Item(1)
  DataStack.Remove 1

codeBLen = codeList.Item(lineNum).Item(4)

forLine = lineNum
startLine = forLine + 1
endLine = forLine + codeBLen

For counter = fromVal To toVal Step stepVal
    SetVal forLine, 2, counter
    For lineNum = startLine To endLine
        RunCmd
        If (lineNum < (startLine - 1)) Or (lineNum > endLine) Then Exit Sub
    Next lineNum
Next counter

lineNum = forLine + codeBLen

End Sub

Public Sub IntCmd_HideConsol()
    consol.Hide
End Sub

Public Sub IntCmd_ShowConsol()
    consol.Show
End Sub

Public Function GetVal(ByVal lineIdx As Long, ByVal tagIdx As Long) As Variant

With codeList.Item(lineIdx)
Select Case .Item(tagIdx)
    Case IDD_EXPLST
        GetVal = ExpStack.Item(.Item(tagIdx + 1))
    Case IDD_DATLST
        GetVal = DataStack.Item(.Item(tagIdx + 1))
    Case IDD_LITLST
        GetVal = LiteralList.Item(.Item(tagIdx + 1))
    Case IDD_GVARLST
        GetVal = mainSubProg.varList.Item(.Item(tagIdx + 1))
    Case IDD_GARRAYLST
        Select Case mainSubProg.arrayDimNumList.Item(.Item(tagIdx + 1))
            Case 1
                GetVal = mainSubProg.arrayList.Item(.Item(tagIdx + 1)) _
                        .Item(ArrayIdxStack.Item(1))
                ArrayIdxStack.Remove 1
            Case 2
                GetVal = mainSubProg.arrayList.Item(.Item(tagIdx + 1)) _
                        .Item(ArrayIdxStack.Item(1)) _
                        .Item(ArrayIdxStack.Item(2))
                ArrayIdxStack.Remove 1
                ArrayIdxStack.Remove 1
        End Select
    Case IDD_LVARLST
        GetVal = varList.Item(.Item(tagIdx + 1))
    Case IDD_LARRAYLST
        Select Case arrayDimNumList.Item(.Item(tagIdx + 1))
            Case 1
                GetVal = arrayList.Item(.Item(tagIdx + 1)) _
                        .Item(ArrayIdxStack.Item(1))
                ArrayIdxStack.Remove 1
            Case 2
                GetVal = arrayList.Item(.Item(tagIdx + 1)) _
                        .Item(ArrayIdxStack.Item(1)) _
                        .Item(ArrayIdxStack.Item(2))
                ArrayIdxStack.Remove 1
                ArrayIdxStack.Remove 1
        End Select
End Select
End With

End Function


Public Sub IntCmd_ArrayIdx()
    ArrayIdxStack.Add GetVal(lineNum, 2), 1
End Sub

Public Sub IntCmd_EvalExp()

Dim operandNum As Long
Dim operator As New ArrayClass

'Read in operand count
operandNum = codeList.Item(lineNum).Item(2)

'Read in operator ID tags
For n = 3 To codeList.Item(lineNum).itemCount
    operator.Add codeList.Item(lineNum).Item(n), 1
Next n

'Check operand count
If ExpStack.itemCount < operandNum Then
    'ERROR
    Exit Sub
End If

'Check operator count
If Not (operandNum = (operator.itemCount + 1)) Then
    'ERROR
    Exit Sub
End If

'Evaluate operator: ^
For a = operator.itemCount To 1 Step -1
    If operator.Item(a) = IDO_EXP Then
        ExpStack.Item(a) = Val(ExpStack.Item(a + 1)) ^ Val(ExpStack.Item(a))
        ExpStack.Remove (a + 1): operator.Remove (a)
    End If
Next a

'Evaluate operators: *, /, and %
For a = operator.itemCount To 1 Step -1
  Select Case operator.Item(a)
    Case IDO_MULTIPLY
        ExpStack.Item(a) = Val(ExpStack.Item(a + 1)) * Val(ExpStack.Item(a))
        ExpStack.Remove (a + 1): operator.Remove (a)
    Case IDO_DIVIDE
        ExpStack.Item(a) = Val(ExpStack.Item(a + 1)) / Val(ExpStack.Item(a))
        ExpStack.Remove (a + 1): operator.Remove (a)
    Case IDO_MOD
        ExpStack.Item(a) = Val(ExpStack.Item(a + 1)) Mod Val(ExpStack.Item(a))
        ExpStack.Remove (a + 1): operator.Remove (a)
  End Select
Next a

'Evaluate operators: + and -
For a = operator.itemCount To 1 Step -1
    Select Case operator.Item(a)
        Case IDO_ADDITION
            ExpStack.Item(a) = Val(ExpStack.Item(a + 1)) + Val(ExpStack.Item(a))
            ExpStack.Remove (a + 1): operator.Remove (a)
        Case IDO_SUBTRACT
            ExpStack.Item(a) = Val(ExpStack.Item(a + 1)) - Val(ExpStack.Item(a))
            ExpStack.Remove (a + 1): operator.Remove (a)
    End Select
Next a

'Evaluate operator: &
For a = operator.itemCount To 1 Step -1
    If operator.Item(a) = IDO_STRCON Then
        ExpStack.Item(a) = ExpStack.Item(a + 1) & ExpStack.Item(a)
        ExpStack.Remove (a + 1): operator.Remove (a)
    End If
Next a

'Evaluate operators: =, <, >, <=, >=, and <>
For a = operator.itemCount To 1 Step -1
    Select Case operator.Item(a)
        Case IDO_EQUAL
            ExpStack.Item(a) = CDbl(ExpStack.Item(a + 1) = ExpStack.Item(a))
            ExpStack.Remove (a + 1): operator.Remove (a)
        Case IDO_LESS
            ExpStack.Item(a) = CDbl(ExpStack.Item(a + 1) < ExpStack.Item(a))
            ExpStack.Remove (a + 1): operator.Remove (a)
        Case IDO_GREATER
            ExpStack.Item(a) = CDbl(ExpStack.Item(a + 1) > ExpStack.Item(a))
            ExpStack.Remove (a + 1): operator.Remove (a)
        Case IDO_LESSOREQUAL
            ExpStack.Item(a) = CDbl(ExpStack.Item(a + 1) <= ExpStack.Item(a))
            ExpStack.Remove (a + 1): operator.Remove (a)
        Case IDO_GREATEROREQUAL
            ExpStack.Item(a) = CDbl(ExpStack.Item(a + 1) >= ExpStack.Item(a))
            ExpStack.Remove (a + 1): operator.Remove (a)
        Case IDO_NOTEQUAL
            ExpStack.Item(a) = CDbl(ExpStack.Item(a + 1) <> ExpStack.Item(a))
            ExpStack.Remove (a + 1): operator.Remove (a)
    End Select
Next a

'Evaluate operators: AND, OR, and XOR
For a = operator.itemCount To 1 Step -1
    Select Case operator.Item(a)
        Case IDO_AND
            ExpStack.Item(a) = (ExpStack.Item(a + 1) And ExpStack.Item(a))
            ExpStack.Remove (a + 1): operator.Remove (a)
        Case IDO_OR
            ExpStack.Item(a) = (ExpStack.Item(a + 1) Or ExpStack.Item(a))
            ExpStack.Remove (a + 1): operator.Remove (a)
        Case IDO_XOR
            ExpStack.Item(a) = (ExpStack.Item(a + 1) Xor ExpStack.Item(a))
            ExpStack.Remove (a + 1): operator.Remove (a)
    End Select
Next a

End Sub

Public Sub IntCmd_Goto()
    lineNum = codeList.Item(lineNum).Item(2) - 1
End Sub


Public Sub IntCmd_Gosub()
    gosubStack.Add lineNum + 1, 1
    lineNum = codeList.Item(lineNum).Item(2) - 1
End Sub


Public Sub IntCmd_If()
    Dim testVal As Variant
    Dim trueBLen As Long
    Dim falseBLen As Long
    Dim ifLine As Long
    Dim startLine As Long
    Dim endLine As Long
    
    testVal = DataStack.Item(1)
    DataStack.Remove 1
    trueBLen = codeList.Item(lineNum).Item(2)
    falseBLen = codeList.Item(lineNum).Item(3)
    ifLine = lineNum
    
    If testVal Then
        startLine = ifLine + 1
        endLine = ifLine + trueBLen
        For lineNum = startLine To endLine
            RunCmd
            If (lineNum < (startLine - 1)) Or (lineNum > endLine) Then Exit Sub
        Next lineNum
    Else
        startLine = ifLine + trueBLen + 1
        endLine = ifLine + trueBLen + falseBLen
        For lineNum = startLine To endLine
            RunCmd
            If (lineNum < (startLine - 1)) Or (lineNum > endLine) Then Exit Sub
        Next lineNum
    End If
    
    lineNum = ifLine + trueBLen + falseBLen

End Sub


Public Sub IntCmd_PopData()
    SetVal lineNum, 2, DataStack.Item(1)
    DataStack.Remove 1
End Sub

Public Sub IntCmd_PopExp()
    SetVal lineNum, 2, ExpStack.Item(1)
    ExpStack.Remove 1
End Sub


Public Sub IntCmd_PrintBlank()

consol.display.Text = consol.display.Text & vbCrLf

End Sub

Public Sub IntCmd_Return()
    If gosubStack.itemCount = 0 Then
        'ERROR
        Exit Sub
    End If
    'Return to stored line number
    lineNum = gosubStack.Item(1) - 1
    gosubStack.Remove 1
End Sub


Public Sub RunCmd()

Select Case codeList.Item(lineNum).Item(1)
    Case IDC_ADDEXP  'AddExp
        IntCmd_AddExp
    Case IDC_REMOVEEXP
        IntCmd_RemoveExp
    Case IDC_CLEAREXPSTACK
        IntCmd_ClearExpStack
    Case IDC_ADDDATA
        IntCmd_AddData
    Case IDC_REMOVEDATA
        IntCmd_RemoveData
    Case IDC_CLEARDATASTACK
        IntCmd_ClearDataStack
    Case IDC_COPYDATA
        IntCmd_CopyData
    Case IDC_CALLSUBPROG
        IntCmd_CallSubProg
    Case IDC_EVALEXP
        IntCmd_EvalExp
    Case IDC_POPDATA
        IntCmd_PopData
    Case IDC_POPEXP
        IntCmd_PopExp
    Case IDC_LABEL
        'NOOP
    Case IDC_ARRAYIDX
        IntCmd_ArrayIdx
    Case IDC_GOTO
        IntCmd_Goto
    Case IDC_GOSUB
        IntCmd_Gosub
    Case IDC_RETURN
        IntCmd_Return
    Case IDC_IF
        IntCmd_If
    Case IDC_PrintToConsol
        IntCmd_PrintToConsol
    Case IDC_InputFromConsol
        IntCmd_InputFromConsol
    Case IDC_ShowConsol
        IntCmd_ShowConsol
    Case IDC_HideConsol
        IntCmd_HideConsol
    Case IDC_PrintBlank
        IntCmd_PrintBlank
    Case IDC_FOR
        IntCmd_For

    Case IDC_Str
        Cmd_Str
End Select

End Sub


Public Sub IntCmd_InputFromConsol()

Dim inputType As Long

inputting = True

inputType = codeList.Item(lineNum).Item(2)

While inputting And Not progDone
  DoEvents
  Sleep 1
Wend

Select Case inputType
    Case DT_STRING
        DataStack.Add userInput, 1
    Case DT_NUMBER
        DataStack.Add Val(userInput), 1
End Select

userInput = ""

End Sub

Public Sub IntCmd_PrintToConsol()

consol.display.Text = consol.display.Text & DataStack.Item(1)

DataStack.Remove 1

End Sub


Public Sub IntCmd_AddData()
    DataStack.Add GetVal(lineNum, 2), 1
End Sub


Public Sub IntCmd_AddExp()
    ExpStack.Add GetVal(lineNum, 2), 1
End Sub


Public Sub IntCmd_CallSubProg()
    LoadSubProg codeList.Item(lineNum).Item(2)
    spList.Item(spList.itemCount).RunProg
End Sub


Public Sub IntCmd_ClearDataStack()
    DataStack.Clear
End Sub


Public Sub IntCmd_ClearExpStack()
    ExpStack.Clear
End Sub


Public Sub IntCmd_CopyData()
    SetVal lineNum, 2, GetVal(lineNum, 4)
End Sub

Public Sub IntCmd_RemoveData()
    DataStack.Remove codeList.Item(lineNum).Item(2)
End Sub


Public Sub IntCmd_RemoveExp()
    ExpStack.Remove codeList.Item(lineNum).Item(2)
End Sub

Public Sub RunProg()

'Run code
For lineNum = 1 To codeList.itemCount
    RunCmd
Next lineNum

'Place return value on data stack (if function)
If isFunc Then
    DataStack.Add varList.Item(paramNum + 1), 1
End If

End Sub


Public Sub SetVal(ByVal lineIdx As Long, ByVal tagIdx As Long, ByVal newVal As Variant)

With codeList.Item(lineIdx)
Select Case .Item(tagIdx)
    Case IDD_EXPLST
        ExpStack.Item(.Item(tagIdx + 1)) = newVal
    Case IDD_DATLST
        DataStack.Item(.Item(tagIdx + 1)) = newVal
    Case IDD_LITLST
        LiteralList.Item(.Item(tagIdx + 1)) = newVal
    Case IDD_GVARLST
        mainSubProg.varList.Item(.Item(tagIdx + 1)) = newVal
    Case IDD_GARRAYLST
        Select Case mainSubProg.arrayDimNumList.Item(.Item(tagIdx + 1))
            Case 1
                mainSubProg.arrayList.Item(.Item(tagIdx + 1)) _
                    .Item(ArrayIdxStack.Item(1)) = newVal
                ArrayIdxStack.Remove 1
            Case 2
                mainSubProg.arrayList.Item(.Item(tagIdx + 1)) _
                    .Item(ArrayIdxStack.Item(1)) _
                    .Item(ArrayIdxStack.Item(2)) = newVal
                ArrayIdxStack.Remove 1
                ArrayIdxStack.Remove 1
        End Select
    Case IDD_LVARLST
        varList.Item(.Item(tagIdx + 1)) = newVal
    Case IDD_LARRAYLST
        Select Case arrayDimNumList.Item(.Item(tagIdx + 1))
            Case 1
                arrayList.Item(.Item(tagIdx + 1)) _
                    .Item(ArrayIdxStack.Item(1)) = newVal
                ArrayIdxStack.Remove 1
            Case 2
                arrayList.Item(.Item(tagIdx + 1)) _
                    .Item(ArrayIdxStack.Item(1)) _
                    .Item(ArrayIdxStack.Item(2)) = newVal
                ArrayIdxStack.Remove 1
                ArrayIdxStack.Remove 1
        End Select
End Select
End With

End Sub


