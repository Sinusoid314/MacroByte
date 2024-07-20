Attribute VB_Name = "CompilerCode"
Public rtMode As Long
Public workingDir As String

Public sourceFile As String
Public rtExeFile As String
Public resultFile As String

Public rawSourceCodeStr As String
Public rawSourceCodeList As New ArrayClass

Public LiteralList As New ArrayClass
Public spDefList As New ArrayClass

Public rawData As String

Public currDefObj As Object
Public currDefIdx As Long
Public currCodeLine As Long

Public exitFlag As Boolean
Public debugStr As String
Public resultVal As Long
Public resultStr As String


Public Const OPEN_ALWAYS As Long = 4
Public Const FILE_BEGIN As Long = 0
Public Const GENERIC_WRITE As Long = &H40000000
Public Const GENERIC_READ As Long = &H80000000
Public Const FILE_ATTRIBUTE_NORMAL As Long = &H80

Public Declare Function CreateFile Lib "kernel32" _
   Alias "CreateFileA" _
  (ByVal lpFileName As String, _
   ByVal dwDesiredAccess As Long, _
   ByVal dwShareMode As Long, _
   ByVal lpSecurityAttributes As Long, _
   ByVal dwCreationDisposition As Long, _
   ByVal dwFlagsAndAttributes As Long, _
   ByVal hTemplateFile As Long) As Long

Public Declare Function GetFileSize Lib "kernel32" _
   (ByVal hFile As Long, lpFileSizeHigh As Long) As Long

Public Declare Function SetFilePointer Lib "kernel32" _
   (ByVal hFile As Long, _
    ByVal lDistanceToMove As Long, _
    lpDistanceToMoveHigh As Long, _
    ByVal dwMoveMethod As Long) As Long

Public Declare Function SetEndOfFile Lib "kernel32" _
  (ByVal hFile As Long) As Long

Public Declare Function CloseHandle Lib "kernel32" _
   (ByVal hFile As Long) As Long
   
Public Declare Sub ExitProcess Lib "kernel32" (ByVal uExitCode As Long)



Public Sub AppendToFile(ByVal targetFile As String, ByRef dataBuffer As String)

Dim oldDataSize As Long
Dim dataSize As Long
Dim dataPos As Long
Dim footerID As String
Dim truncSize As Long

Open targetFile For Binary As #1

'Get footerID string (if present)
footerID = String(Len("MACROBYTE-RUNTIME"), " ")
Get #1, LOF(1) - Len("MACROBYTE-RUNTIME") + 1, footerID

'Get new append data size
dataSize = Len(dataBuffer)

'Old append data is in the EXE
If footerID = "MACROBYTE-RUNTIME" Then

    'Get append data position in file
    Get #1, LOF(1) - Len(footerID) - Len(dataPos) + 1, dataPos
        
    'Get old append data size
    Get #1, LOF(1) - Len(footerID) - Len(dataPos) - Len(oldDataSize) + 1, oldDataSize
    
    'Write new append data to and close EXE file
    Put #1, dataPos, dataBuffer
    Put #1, , dataSize
    Put #1, , dataPos
    Put #1, , footerID
    Close #1
    
    'If new data size is less than old data, truncate EXE file
    If dataSize < oldDataSize Then
        truncSize = oldDataSize - dataSize
        TruncateFile targetFile, truncSize
    End If

Else
    
    footerID = "MACROBYTE-RUNTIME"
    dataPos = LOF(1) + 1
    
    'Write new append data to and close EXE file
    Put #1, dataPos, dataBuffer
    Put #1, , dataSize
    Put #1, , dataPos
    Put #1, , footerID
    Close #1
    
End If

End Sub


Public Function CheckForOperator(ByRef expStr As String, ByRef charIdx As Long, ByRef operatorID As Long, ByVal isBoolExp As Boolean) As Boolean

'Check to see if the characters in expStr, starting at charIdx, indicate an operator.
'If so, set operatorID to the corresponding operator command ID, increment charIdx
'(if applicable), and return True. If not, return False.

CheckForOperator = True

If Mid(expStr, charIdx, 1) = "+" Then
    operatorID = IDC_ADD
    
ElseIf Mid(expStr, charIdx, 1) = "-" Then
    operatorID = IDC_SUB
    
ElseIf Mid(expStr, charIdx, 1) = "%" Then
    operatorID = IDC_MOD
    
ElseIf Mid(expStr, charIdx, 1) = "*" Then
    operatorID = IDC_MUL
    
ElseIf Mid(expStr, charIdx, 1) = "/" Then
    operatorID = IDC_DIV
    
ElseIf Mid(expStr, charIdx, 1) = "^" Then
    operatorID = IDC_EXP
    
ElseIf Mid(expStr, charIdx, 2) = ">=" Then
    operatorID = IDC_GREATEROREQUAL
    charIdx = charIdx + 1
    
ElseIf Mid(expStr, charIdx, 2) = "<=" Then
    operatorID = IDC_LESSOREQUAL
    charIdx = charIdx + 1
    
ElseIf Mid(expStr, charIdx, 2) = "<>" Then
    operatorID = IDC_NOTEQUAL
    charIdx = charIdx + 1
    
ElseIf Mid(expStr, charIdx, 1) = "=" Then
    operatorID = IDC_EQUAL
    
ElseIf Mid(expStr, charIdx, 1) = "<" Then
    operatorID = IDC_LESS
    
ElseIf Mid(expStr, charIdx, 1) = ">" Then
    operatorID = IDC_GREATER
    
ElseIf Mid(expStr, charIdx, 1) = "&" Then
    operatorID = IDC_STRCON
    
ElseIf UCase(Mid(expStr, charIdx, 5)) = " AND " Then
    If isBoolExp Then
        operatorID = IDC_LAND
    Else
        operatorID = IDC_BAND
    End If
    charIdx = charIdx + 4
    
ElseIf UCase(Mid(expStr, charIdx, 5)) = " XOR " Then
    If isBoolExp Then
        operatorID = IDC_LXOR
    Else
        operatorID = IDC_BXOR
    End If
    charIdx = charIdx + 4
    
ElseIf UCase(Mid(expStr, charIdx, 4)) = " OR " Then
    If isBoolExp Then
        operatorID = IDC_LOR
    Else
        operatorID = IDC_BOR
    End If
    charIdx = charIdx + 3
    
Else
    CheckForOperator = False
    
End If

End Function


Public Sub Cmd_ExitFor()

If forBlockNum > 0 Then
    GenByteCodeFL IDC_ExitFor
Else
    CompileError "Exit For outside of For block"
End If

End Sub

Public Sub Cmd_ExitWhile()

If whileBlockNum > 0 Then
    GenByteCodeFL IDC_ExitWhile
Else
    CompileError "Exit While outside of While block"
End If

End Sub

Public Sub Cmd_ExitSub()

If (currDefIdx = 1) Or (currDefObj.isFunc) Then
    CompileError "Exit Sub outside of Sub"
    Exit Sub
End If

GenByteCodeFL IDC_ExitSubProg

End Sub

Public Sub Cmd_ExitFunction()

If (currDefIdx = 1) Or (Not currDefObj.isFunc) Then
    CompileError "Exit Function outside of Function"
    Exit Sub
End If

GenByteCodeFL IDC_ExitSubProg

End Sub
Public Sub Cmd_OnError(ByVal cmdStr As String)

Dim tmpParamList As New ArrayClass
Dim spIdx As Long

cmdStr = Trim(cmdStr)

'Get arguments
ParseParams cmdStr, tmpParamList, ",", True

'Check argument # against parameter #
If tmpParamList.itemCount <> 1 Then
    CompileError "Wrong number of arguments for command OnError"
    Exit Sub
End If

'To avoid a shitload 'o calls to Item() function
cmdStr = tmpParamList.Item(1)

'Get index of subprog name
For spIdx = 1 To spDefList.itemCount
    With spDefList.Item(spIdx)
    
        If LCase(tmpParamList.Item(1)) = LCase(.subProgName) Then
            If .isFunc Then
                CompileError "'" & .subProgName & "' must be a SUB"
                Exit Sub
            End If
            If .paramNum > 1 Then
                CompileError "'" & .subProgName & "' cannot have more than one parameter"
                Exit Sub
            End If
            If .paramNum = 1 Then
                If .varTypeList.Item(1) <> DT_STRING Then
                    CompileError "Parameter of '" & .subProgName & "' must be a String"
                    Exit Sub
                End If
            End If
            
            'Write bytecode
            '[C++ CONVERSION: Adjusted for Base0]
            GenByteCodeFL IDC_OnError, spIdx - 1
            Exit Sub
        End If
        
    End With
Next spIdx

'The sub was not found
CompileError "Undefined sub '" & tmpParamList.Item(1) & "'"

End Sub

Public Sub Cmd_Close(ByVal cmdStr As String)

Dim tmpParamList As New ArrayClass
Dim paramRef As DataRefClass
Dim a As Long

cmdStr = Trim(cmdStr)

'Get arguments
ParseParams cmdStr, tmpParamList, ",", True

'Check argument # against parameter #
If tmpParamList.itemCount <> 1 Then
    CompileError "Wrong number of arguments for command CLOSE"
    Exit Sub
End If

'To avoid a shitload 'o calls to Item() function
cmdStr = tmpParamList.Item(1)

'cHOP OFF #
If Left(cmdStr, 1) = "#" Then
    cmdStr = Right(cmdStr, Len(cmdStr) - 1)
End If

'Evaluate argument
Set paramRef = EvalExpression(cmdStr)
If exitFlag Then Exit Sub

'Check argument type against parameter type
If paramRef.drType <> DT_NUMBER Then
    CompileError "Type mismatch in argument " & CStr(a) & " of command CLOSE"
    Exit Sub
End If

'Write bytecode for command call
    GenByteCodeFL IDC_CloseFile

End Sub


Public Sub Cmd_LineInput(ByVal cmdStr As String)

Dim tmpParamList As New ArrayClass
Dim paramRefList As New ArrayClass
Dim a As Long

cmdStr = Trim(cmdStr)

'Get rid of '#'
If Left(cmdStr, 1) = "#" Then
    cmdStr = Trim(Right(cmdStr, Len(cmdStr) - 1))
End If

'Get arguments
ParseParams cmdStr, tmpParamList, ",", True

'Check argument # against parameter #
If tmpParamList.itemCount <> 2 Then
    CompileError "Wrong number of arguments for command LINE INPUT #"
    Exit Sub
End If

'Get variable/array reference
paramRefList.Add CompileSubProgDataRef(tmpParamList.Item(2)), 1
If exitFlag Then Exit Sub

'Evaluate handle expression
paramRefList.Add EvalExpression(tmpParamList.Item(1)), 1
If exitFlag Then Exit Sub

'Check argument type against parameter type
If paramRefList.Item(1).drType <> DT_NUMBER Then
    CompileError "Type mismatch in argument " & CStr(a) & " of command LINE INPUT #"
    Exit Sub
End If

'Write bytecode for command call
    '[C++ CONVERSION: Adjusted for Base0]
    GenByteCodeFL IDC_InputLineFromFile, paramRefList.Item(2).drID, paramRefList.Item(2).drIdx - 1

End Sub

Public Sub Cmd_Open(ByVal cmdStr As String)

Dim tmpParamList As New ArrayClass
Dim fileNameRef As DataRefClass
Dim fileHandleRef As DataRefClass
Dim fileType As Long

cmdStr = Trim(cmdStr)

ParseParamsEx cmdStr, tmpParamList, " for ", " as "

'Check argument #
If tmpParamList.itemCount <> 3 Then
    CompileError "Syntax error"
    Exit Sub
End If

'Get file type ID tag
Select Case LCase(tmpParamList.Item(2))
    Case "input"
        fileType = FT_INPUT
    Case "output"
        fileType = FT_OUTPUT
    Case "append"
        fileType = FT_APPEND
    Case "binary"
        fileType = FT_BINARY
    Case Else
        CompileError "File type '" & tmpParamList.Item(2) & "' does not exist"
        Exit Sub
End Select

'Get rid of '#'
If Left(tmpParamList.Item(3), 1) = "#" Then
    tmpParamList.Item(3) = Trim(Right(tmpParamList.Item(3), Len(tmpParamList.Item(3)) - 1))
End If

'Evaluate file handle reference
Set fileHandleRef = EvalExpression(tmpParamList.Item(3))
If exitFlag Then Exit Sub
If fileHandleRef.drType <> DT_NUMBER Then
    CompileError "Type mismatch: File handle must be a numeric expression"
    Exit Sub
End If

'Evaluate file name reference
Set fileNameRef = EvalExpression(tmpParamList.Item(1))
If exitFlag Then Exit Sub
If fileNameRef.drType <> DT_STRING Then
    CompileError "Type mismatch: File name must be a string expression"
    Exit Sub
End If

'Write bytecode for command call
GenByteCodeFL IDC_OpenFile, fileType

End Sub


Public Sub Cmd_Redim(ByVal cmdStr As String)

Dim nameStr As String
Dim idxStr As String
Dim idxList As New ArrayClass
Dim arrayDataRef As DataRefClass
Dim paramRefList As New ArrayClass
Dim a As Long
Dim b As Long

cmdStr = Trim(cmdStr)

'Parse name
nameStr = GetString(1, cmdStr, "(")
If (Len(nameStr) = Len(cmdStr)) Or (Len(nameStr) + 1 = Len(cmdStr)) Then
    CompileError "Syntax error"
    Exit Sub
End If

'Parse dimensions
idxStr = GetString(Len(nameStr) + 2, cmdStr, ")")
If Len(nameStr) + Len(idxStr) + 1 = Len(cmdStr) Then
    CompileError "Syntax error"
    Exit Sub
End If
ParseParams idxStr, idxList, ",", True

'Get array data refernce
Set arrayDataRef = CompileArrayRef(nameStr)
If exitFlag Then Exit Sub

'Check array dimension count
With arrayDataRef.drSPDefRef
    If .arrayDimNumList.Item(arrayDataRef.drIdx) <> idxList.itemCount Then
        CompileError "Wrong number of dimensions for array '" & .arrayNameList.Item(arrayDataRef.drIdx) & "'"
        Exit Sub
    End If
End With

'Add new dimension sizes to DataStack
For a = idxList.itemCount To 1 Step -1
    'Evaluate each dimension expression
    paramRefList.Add EvalExpression(idxList.Item(a)), 1
    If exitFlag Then Exit Sub
Next a

'Check argument types against parameter types
For a = 1 To paramRefList.itemCount
    If paramRefList.Item(a).drType <> DT_NUMBER Then
        CompileError "Array dimension " & CStr(a) & " must be a Number"
        Exit Sub
    End If
Next a

'Write bytecode
'[C++ CONVERSION: Adjusted for Base0]
GenByteCodeFL IDC_Redim, arrayDataRef.drID, arrayDataRef.drIdx - 1

End Sub


Public Sub Cmd_RedimAdd(ByVal cmdStr As String)

Dim tmpParamList As New ArrayClass
Dim paramRefList As New ArrayClass
Dim arrayDataRef As DataRefClass
Dim a As Long

cmdStr = Trim(cmdStr)

'Get arguments
ParseParams cmdStr, tmpParamList, ",", True

'Check argument # against parameter #
If (tmpParamList.itemCount < 2) Or (tmpParamList.itemCount > 3) Then
    CompileError "Wrong number of arguments for command RedimAdd"
    Exit Sub
End If

'Add 'beforeIdx' argument to tmpParamList if not specified
If tmpParamList.itemCount = 2 Then
    tmpParamList.Add "-1"
End If

'Get array data refernce
Set arrayDataRef = CompileArrayRef(tmpParamList.Item(1))
If exitFlag Then Exit Sub

'Check array dimension count
With arrayDataRef.drSPDefRef
    If .arrayDimNumList.Item(arrayDataRef.drIdx) <> 1 Then
        CompileError "Array '" & .arrayNameList.Item(arrayDataRef.drIdx) & "' must be one-dimensional"
        Exit Sub
    End If
End With

'Evaluate each argument and write bytecode
'to put it on DataStack
For a = tmpParamList.itemCount To 2 Step -1
    paramRefList.Add EvalExpression(tmpParamList.Item(a)), 1
    If exitFlag Then Exit Sub
Next a

'Check argument types against parameter types
If paramRefList.Item(1).drType <> arrayDataRef.drType Then
    CompileError "Type mismatch in argument 2 of command RedimAdd"
    Exit Sub
End If
If paramRefList.Item(2).drType <> DT_NUMBER Then
    CompileError "Type mismatch in argument 3 of command RedimAdd"
    Exit Sub
End If

'Write bytecode
'[C++ CONVERSION: Adjusted for Base0]
GenByteCodeFL IDC_RedimAdd, arrayDataRef.drID, arrayDataRef.drIdx - 1

End Sub


Public Sub Cmd_RedimRemove(ByVal cmdStr As String)

Dim tmpParamList As New ArrayClass
Dim paramRefList As New ArrayClass
Dim arrayDataRef As DataRefClass
Dim a As Long

cmdStr = Trim(cmdStr)

'Get arguments
ParseParams cmdStr, tmpParamList, ",", True

'Check argument # against parameter #
If tmpParamList.itemCount <> 2 Then
    CompileError "Wrong number of arguments for command RedimRemove"
    Exit Sub
End If

'Get array data refernce
Set arrayDataRef = CompileArrayRef(tmpParamList.Item(1))
If exitFlag Then Exit Sub

'Check array dimension count
With arrayDataRef.drSPDefRef
    If .arrayDimNumList.Item(arrayDataRef.drIdx) <> 1 Then
        CompileError "Array '" & .arrayNameList.Item(arrayDataRef.drIdx) & "' must be one-dimensional"
        Exit Sub
    End If
End With

'Evaluate each argument and write bytecode
'to put it on DataStack
paramRefList.Add EvalExpression(tmpParamList.Item(2)), 1
If exitFlag Then Exit Sub

'Check argument types against parameter types
If paramRefList.Item(1).drType <> DT_NUMBER Then
    CompileError "Type mismatch in argument 2 of command RedimRemove"
    Exit Sub
End If

'Write bytecode
'[C++ CONVERSION: Adjusted for Base0]
GenByteCodeFL IDC_RedimRemove, arrayDataRef.drID, arrayDataRef.drIdx - 1


End Sub
Public Sub Cmd_Seek(ByVal cmdStr As String)

Dim tmpParamList As New ArrayClass
Dim paramRefList As New ArrayClass
Dim a As Long

cmdStr = Trim(cmdStr)

'Get arguments
ParseParams cmdStr, tmpParamList, ",", True

'Check argument # against parameter #
If tmpParamList.itemCount <> 2 Then
    CompileError "Wrong number of arguments for command SEEK"
    Exit Sub
End If

'cHOP OFF #
If Left(tmpParamList.Item(1), 1) = "#" Then
    tmpParamList.Item(1) = Right(tmpParamList.Item(1), Len(tmpParamList.Item(1)) - 1)
End If

'Evaluate argument
For a = tmpParamList.itemCount To 1 Step -1
    paramRefList.Add EvalExpression(tmpParamList.Item(a)), 1
    If exitFlag Then Exit Sub
Next a

'Check argument type against parameter type
For a = 1 To tmpParamList.itemCount
    If paramRefList.Item(a).drType <> DT_NUMBER Then
        CompileError "Type mismatch in argument " & CStr(a) & " of command SEEK"
        Exit Sub
    End If
Next a

'Write bytecode for command call
    GenByteCodeFL IDC_SetFilePos

End Sub

Public Sub CompilerCleanup()

'Delete currDefObj
Set currDefObj = Nothing

'Clear literals
For n = LiteralList.itemCount To 1 Step -1
    LiteralList.Remove n
Next n

'Clear subprog definitions
For n = spDefList.itemCount To 1 Step -1
    spDefList.Remove n
Next n

'Close compile window
Unload compileDlg

End Sub

Public Sub CompilerMain()

'Compile source code
Compile

'Write result to file
Open resultFile For Output As #1
    Print #1, CStr(resultVal)
    Print #1, resultStr
Close #1

End Sub


Public Sub CompilerSetup()

Dim clArgList As New ArrayClass

'Dim tmpCommand As String
'tmpCommand = "Run|C:\Documents and Settings\MrBudGood\My Documents\[Programs]\MacroByte\Editor\Examples|C:\Documents and Settings\MrBudGood\My Documents\[Programs]\MacroByte\Editor\tmpSrc.bas|C:\Documents and Settings\MrBudGood\My Documents\[Programs]\MacroByte\Editor\..\Runtime Engine\Run.exe|C:\Documents and Settings\MrBudGood\My Documents\[Programs]\MacroByte\Editor\mbcRes.txt"

'Set up the compiler dialog box
Load compileDlg
compileDlg.progress.Value = 0
compileDlg.status.Caption = "Initializing compiler..."
compileDlg.Show

'Parse command line arguments
ParseParams Command, clArgList, "|", True

'Check argument count
If clArgList.itemCount <> 5 Then
    MsgBox "Wrong number of compiler arguments", vbCritical, "Macrobyte Compiler"
    End
End If

'Set rtMode
Select Case LCase(clArgList.Item(1))
    Case "run"
        rtMode = RTMODE_RUN
    Case "debug"
        rtMode = RTMODE_DEBUG
    Case "deploy"
        rtMode = RTMODE_DEPLOY
    Case Else
        MsgBox "Runtime mode:" & vbCrLf & vbCrLf & _
               clArgList.Item(1) & vbCrLf & vbCrLf & _
               "is  not understood", vbCritical, "Macrobyte Compiler"
        End
End Select

'Set workingDir
workingDir = clArgList.Item(2)
If Dir(workingDir, vbDirectory) = "" Then
    MsgBox "Woring directory:" & vbCrLf & vbCrLf & _
           "'" & clArgList.Item(2) & "'" & vbCrLf & vbCrLf & _
           "does not exist", vbCritical, "Macrobyte Compiler"
    End
End If

'Set sourceFile
sourceFile = clArgList.Item(3)
If Dir(sourceFile) = "" Then
    MsgBox "Source code file:" & vbCrLf & vbCrLf & _
           "'" & clArgList.Item(3) & "'" & vbCrLf & vbCrLf & _
           "does not exist", vbCritical, "Macrobyte Compiler"
    End
End If

'Set rtExeFile
rtExeFile = clArgList.Item(4)
If Dir(rtExeFile) = "" Then
    MsgBox "Runtime executable file:" & vbCrLf & vbCrLf & _
           "'" & clArgList.Item(4) & "'" & vbCrLf & vbCrLf & _
           "does not exist", vbCritical, "Macrobyte Compiler"
    End
End If

'Set resultFile
resultFile = clArgList.Item(5)

'Read in source code
Open sourceFile For Input As #1
  rawSourceCodeStr = Input(LOF(1), 1)
Close #1

'Result assumed successful until proven not
resultVal = 0
resultStr = "Compile successful"
exitFlag = False

End Sub


Public Sub CreateSubProgs()

Dim tmpLine As String
Dim tmpLineNum As Long
Dim tmpStr As String
Dim a, b, n As Integer
Dim tmpCodeList As New ArrayClass
Dim tmpCodeIndexList As New ArrayClass
Dim inSub As Boolean
Dim inFunc As Boolean

tmpLineNum = 0
inSub = False
inFunc = False

'Seperate the rawSourceCodeStr string into individual statements in tmpCodeList
For a = 1 To Len(rawSourceCodeStr)
  If Mid(rawSourceCodeStr, a, 2) = vbCrLf Or a = Len(rawSourceCodeStr) Then
    If a = Len(rawSourceCodeStr) Then tmpLine = tmpLine & Right(rawSourceCodeStr, 1)
    tmpLineNum = tmpLineNum + 1
    If rtMode = RTMODE_DEBUG Then
        rawSourceCodeList.Add tmpLine
    End If
    tmpLine = Trim(tmpLine)
    If (tmpLine <> "") And (Left(tmpLine, 1) <> "'") And (LCase(Left(tmpLine, 4)) <> "rem ") Then
        b = 1
        While b <= Len(tmpLine)
            tmpStr = GetString(b, tmpLine, ":")
            b = Len(tmpStr) + b + 1
            tmpCodeList.Add Trim(tmpStr)
            tmpCodeIndexList.Add tmpLineNum
        Wend
        tmpLine = "": a = a + 1
    Else
        tmpLine = "": a = a + 1
    End If
  Else
    tmpLine = tmpLine & Mid(rawSourceCodeStr, a, 1)
  End If
Next a
rawSourceCodeStr = ""

'Cut out any comments that may be at the end of a line
For a = 1 To tmpCodeList.itemCount
  tmpCodeList.Item(a) = Trim(GetString(1, tmpCodeList.Item(a), "'"))
    tmpStr = Trim(GetString(1, LCase(tmpCodeList.Item(a) & " "), " rem "))
  tmpCodeList.Item(a) = Left(tmpCodeList.Item(a), Len(tmpStr))
Next a

'Append lines to any line ending with a "_"
For a = tmpCodeList.itemCount To 1 Step -1
    If Right(tmpCodeList.Item(a), 1) = "_" Then
        'Make sure there is a line of code to append
        If a < tmpCodeList.itemCount Then
            tmpCodeList.Item(a) = Left(tmpCodeList.Item(a), Len(tmpCodeList.Item(a)) - 1)
            tmpCodeList.Item(a) = tmpCodeList.Item(a) & tmpCodeList.Item(a + 1)
            tmpCodeList.Remove a + 1
            tmpCodeIndexList.Remove a + 1
        End If
    End If
Next a

'Check statement count if unregistered
'If Not isMbr Then
'    If tmpCodeList.itemCount > 150 Then
'        CompileError "This unregistered copy only allows 150 statements to be compiled", tmpCodeIndexList.item(150)
'        Exit Sub
'    End If
'End If

'Read subs/functions and load the raw code into current spDefList item
For a = tmpCodeList.itemCount To 1 Step -1
    
    If inSub Then
        If (LCase(Left(tmpCodeList.Item(a), 4)) = "sub ") Then
            inSub = False
        ElseIf (LCase(Left(tmpCodeList.Item(a), 9)) = "function ") Then
            'ERROR
            CompileError "", tmpCodeIndexList.Item(a)
            Exit Sub
        ElseIf (LCase(Trim(tmpCodeList.Item(a))) = "end sub") Then
            'ERROR
            CompileError "", tmpCodeIndexList.Item(a)
            Exit Sub
        ElseIf (LCase(Trim(tmpCodeList.Item(a))) = "end function") Then
            'ERROR
            CompileError "", tmpCodeIndexList.Item(a)
            Exit Sub
        End If
        spDefList.Item(1).sourceCodeList.Add tmpCodeList.Item(a), 1
        spDefList.Item(1).rawCodeIndexList.Add tmpCodeIndexList.Item(a), 1
        tmpCodeList.Remove a
        tmpCodeIndexList.Remove a
        
    ElseIf inFunc Then
        If (LCase(Left(tmpCodeList.Item(a), 9)) = "function ") Then
            inFunc = False
        ElseIf (LCase(Left(tmpCodeList.Item(a), 4)) = "sub ") Then
            'ERROR
            CompileError "", tmpCodeIndexList.Item(a)
            Exit Sub
        ElseIf (LCase(Trim(tmpCodeList.Item(a))) = "end sub") Then
            'ERROR
            CompileError "", tmpCodeIndexList.Item(a)
            Exit Sub
        ElseIf (LCase(Trim(tmpCodeList.Item(a))) = "end function") Then
            'ERROR
            CompileError "", tmpCodeIndexList.Item(a)
            Exit Sub
        End If
        spDefList.Item(1).sourceCodeList.Add tmpCodeList.Item(a), 1
        spDefList.Item(1).rawCodeIndexList.Add tmpCodeIndexList.Item(a), 1
        tmpCodeList.Remove a
        tmpCodeIndexList.Remove a
    
    Else
        If (LCase(Trim(tmpCodeList.Item(a))) = "end sub") Then
            spDefList.Add New SubProgDefClass, 1
            spDefList.Item(1).isFunc = False
            tmpCodeList.Remove a
            tmpCodeIndexList.Remove a
            inSub = True
        ElseIf (LCase(Trim(tmpCodeList.Item(a))) = "end function") Then
            spDefList.Add New SubProgDefClass, 1
            spDefList.Item(1).isFunc = True
            tmpCodeList.Remove a
            tmpCodeIndexList.Remove a
            inFunc = True
        ElseIf (LCase(Left(tmpCodeList.Item(a), 4)) = "sub ") Then
            'ERROR
            CompileError "", tmpCodeIndexList.Item(a)
            Exit Sub
        ElseIf (LCase(Left(tmpCodeList.Item(a), 9)) = "function ") Then
            'ERROR
            CompileError "", tmpCodeIndexList.Item(a)
            Exit Sub
        End If
        
    End If
        
Next a


'Load remaining raw lines into mainCodeSP (spDefList(1))
spDefList.Add New SubProgDefClass, 1
spDefList.Item(1).isFunc = False
spDefList.Item(1).subProgName = "<main>"
For a = 1 To tmpCodeList.itemCount
    spDefList.Item(1).sourceCodeList.Add tmpCodeList.Item(a)
    spDefList.Item(1).rawCodeIndexList.Add tmpCodeIndexList.Item(a)
Next a

End Sub

Public Function EvalOperand(ByRef operandStr As String, ByVal isBoolExp As Boolean) As DataRefClass

'Call the appropriate operand-evaluation function, and return its DataRefClass object.

operandStr = Trim(operandStr)

If IsNumeric(operandStr) Then
    Set EvalOperand = CompileLitRef(operandStr, DT_NUMBER)
    'Write bytecode
      '[C++ CONVERSION: Adjusted for Base0]
      GenByteCodeFL IDC_ADDDATA, EvalOperand.drID, EvalOperand.drIdx - 1
    
ElseIf (Left(operandStr, 1) = Chr(34)) And (Right(operandStr, 1) = Chr(34)) Then
    Set EvalOperand = CompileLitRef(Mid(operandStr, 2, Len(operandStr) - 2), DT_STRING)
    'Write bytecode
      '[C++ CONVERSION: Adjusted for Base0]
      GenByteCodeFL IDC_ADDDATA, EvalOperand.drID, EvalOperand.drIdx - 1
    
ElseIf (Left(operandStr, 1) = "(") And (Right(operandStr, 1) = ")") Then
    operandStr = Mid(operandStr, 2, Len(operandStr) - 2)
    Set EvalOperand = EvalExpression(operandStr, isBoolExp)
    If exitFlag Then Exit Function
    
ElseIf EvalFunction(operandStr, EvalOperand) Then
    If exitFlag Then Exit Function
    If Not (Right(operandStr, 1) = ")") Then
        CompileError "Syntax error"
        Exit Function
    End If
      
ElseIf EvalUserFunc(operandStr, EvalOperand) Then
    If exitFlag Then Exit Function
    If Not (Right(operandStr, 1) = ")") Then
        CompileError "Syntax error"
        Exit Function
    End If
Else
    'Get variable/array reference
    Set EvalOperand = CompileSubProgDataRef(operandStr)
    If exitFlag Then Exit Function
    
    'Write bytecode
      '[C++ CONVERSION: Adjusted for Base0]
      GenByteCodeFL IDC_ADDDATA, EvalOperand.drID, EvalOperand.drIdx - 1
End If

operandStr = ""

End Function


Public Sub EvalOperator(ByVal operatorID As Long, ByRef operatorStack As ArrayClass)

'Write bytecode command for, and pop, each top item in
'operatorStack while the stack is not empty and the top
'item 's precedence is greater than or equal to the precedence
'of operatorID. Once done, push operatorID onto operatorStack.

Do While operatorStack.itemCount > 0
    If GetOperatorPrecedence(operatorStack.Item(1)) < GetOperatorPrecedence(operatorID) Then Exit Do
    GenByteCodeFL operatorStack.Item(1)
    operatorStack.Remove (1)
Loop

operatorStack.Add operatorID, 1

End Sub


Public Function Func_EOF(ByVal cmdStr As String) As DataRefClass

Dim tmpParamList As New ArrayClass
Dim paramRefList As New ArrayClass
Dim a As Long

cmdStr = Trim(cmdStr)
Set Func_EOF = New DataRefClass

'Get arguments
ParseParams cmdStr, tmpParamList, ",", True

'Check argument # against parameter #
If tmpParamList.itemCount <> 1 Then
    CompileError "Wrong number of arguments for function EOF()"
    Exit Function
End If

For a = tmpParamList.itemCount To 1 Step -1
    'Evaluate each argument
    paramRefList.Add EvalExpression(tmpParamList.Item(a)), 1
    If exitFlag Then Exit Function
Next a

'Check argument types against parameter types
For a = 1 To paramRefList.itemCount
    If paramRefList.Item(a).drType <> DT_NUMBER Then
        CompileError "Type mismatch in argument " & CStr(a) & " of function EOF()"
        Exit Function
    End If
Next a

'Write bytecode for function call
    GenByteCodeFL IDC_EndOfFile

'Fill out return reference and exit
Func_EOF.drID = IDD_DATLST
Func_EOF.drIdx = 0
Func_EOF.drType = DT_NUMBER

End Function


Public Function Func_Input(ByVal cmdStr As String) As DataRefClass

Dim tmpParamList As New ArrayClass
Dim paramRefList As New ArrayClass
Dim a As Long

cmdStr = Trim(cmdStr)
Set Func_Input = New DataRefClass

'Get arguments
ParseParams cmdStr, tmpParamList, ",", True

'Check argument # against parameter #
If tmpParamList.itemCount <> 2 Then
    CompileError "Wrong number of arguments for function INPUT()"
    Exit Function
End If

For a = tmpParamList.itemCount To 1 Step -1
    'Evaluate each argument
    paramRefList.Add EvalExpression(tmpParamList.Item(a)), 1
    If exitFlag Then Exit Function
Next a

'Check argument types against parameter types
For a = 1 To paramRefList.itemCount
    If paramRefList.Item(a).drType <> DT_NUMBER Then
        CompileError "Type mismatch in argument " & CStr(a) & " of function INPUT()"
        Exit Function
    End If
Next a

'Write bytecode for function call
    GenByteCodeFL IDC_InputBytesFromFile

'Fill out return reference and exit
Func_Input.drID = IDD_DATLST
Func_Input.drIdx = 0
Func_Input.drType = DT_STRING

End Function


Public Function Func_Loc(ByVal cmdStr As String) As DataRefClass

Dim tmpParamList As New ArrayClass
Dim paramRefList As New ArrayClass
Dim a As Long

cmdStr = Trim(cmdStr)
Set Func_Loc = New DataRefClass

'Get arguments
ParseParams cmdStr, tmpParamList, ",", True

'Check argument # against parameter #
If tmpParamList.itemCount <> 1 Then
    CompileError "Wrong number of arguments for function LOC()"
    Exit Function
End If

For a = tmpParamList.itemCount To 1 Step -1
    'Evaluate each argument
    paramRefList.Add EvalExpression(tmpParamList.Item(a)), 1
    If exitFlag Then Exit Function
Next a

'Check argument types against parameter types
For a = 1 To paramRefList.itemCount
    If paramRefList.Item(a).drType <> DT_NUMBER Then
        CompileError "Type mismatch in argument " & CStr(a) & " of function LOC()"
        Exit Function
    End If
Next a

'Write bytecode for function call
    GenByteCodeFL IDC_GetFilePos

'Fill out return reference and exit
Func_Loc.drID = IDD_DATLST
Func_Loc.drIdx = 0
Func_Loc.drType = DT_NUMBER

End Function


Public Function Func_LOF(ByVal cmdStr As String) As DataRefClass

Dim tmpParamList As New ArrayClass
Dim paramRefList As New ArrayClass
Dim a As Long

cmdStr = Trim(cmdStr)
Set Func_LOF = New DataRefClass

'Get arguments
ParseParams cmdStr, tmpParamList, ",", True

'Check argument # against parameter #
If tmpParamList.itemCount <> 1 Then
    CompileError "Wrong number of arguments for function LOF()"
    Exit Function
End If

For a = tmpParamList.itemCount To 1 Step -1
    'Evaluate each argument
    paramRefList.Add EvalExpression(tmpParamList.Item(a)), 1
    If exitFlag Then Exit Function
Next a

'Check argument types against parameter types
For a = 1 To paramRefList.itemCount
    If paramRefList.Item(a).drType <> DT_NUMBER Then
        CompileError "Type mismatch in argument " & CStr(a) & " of function LOF()"
        Exit Function
    End If
Next a

'Write bytecode for function call
    GenByteCodeFL IDC_FileLength

'Fill out return reference and exit
Func_LOF.drID = IDD_DATLST
Func_LOF.drIdx = 0
Func_LOF.drType = DT_NUMBER

End Function


Public Function GetOperatorPrecedence(ByVal operatorID As Long) As Long

'Return the precedence number of operatorID.

If operatorID = IDC_EXP Then
    GetOperatorPrecedence = 6
ElseIf (operatorID = IDC_MUL) Or (operatorID = IDC_DIV) Or (operatorID = IDC_MOD) Then
    GetOperatorPrecedence = 5
ElseIf (operatorID = IDC_ADD) Or (operatorID = IDC_SUB) Then
    GetOperatorPrecedence = 4
ElseIf operatorID = IDC_STRCON Then
    GetOperatorPrecedence = 3
ElseIf (operatorID = IDC_EQUAL) Or (operatorID = IDC_LESS) Or (operatorID = IDC_GREATER) Or _
       (operatorID = IDC_LESSOREQUAL) Or (operatorID = IDC_GREATEROREQUAL) Or (operatorID = IDC_NOTEQUAL) Then
    GetOperatorPrecedence = 2
ElseIf (operatorID = IDC_LAND) Or (operatorID = IDC_LOR) Or (operatorID = IDC_LXOR) Or _
       (operatorID = IDC_BAND) Or (operatorID = IDC_BOR) Or (operatorID = IDC_BXOR) Then
    GetOperatorPrecedence = 1
Else
    GetOperatorPrecedence = 0
End If

End Function

Public Sub Main()

'Setup compiler data
CompilerSetup

'All the main action happens here
CompilerMain

'Cleanup compiler data
CompilerCleanup

End

End Sub

Public Sub TruncateFile(ByVal truncFile As String, ByVal truncSize As Long)

Dim hFile As Long
Dim newFileSize As Long
Dim dwFileSizeLow As Long
Dim dwFileSizeHigh As Long

'Open the file
hFile = CreateFile(truncFile, GENERIC_WRITE Or GENERIC_READ, 0&, ByVal 0&, _
                   OPEN_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0&)
      
'Get the file size
dwFileSizeLow = GetFileSize(hFile, dwFileSizeHigh)

If dwFileSizeHigh = 0 Then
    
    'Calcoolate new size
    newFileSize = dwFileSizeLow - truncSize
    
    'Move file pointer to the new end position
    If SetFilePointer(hFile, newFileSize, dwFileSizeHigh, FILE_BEGIN) > 0 Then
        
        'Resize file
        Call SetEndOfFile(hFile)
        
    End If
    
End If

'Close the file
CloseHandle hFile

End Sub




Public Sub Cmd_Call(ByVal cmdStr As String)

Dim tmpName, paramStr As String
Dim tmpParamList As New ArrayClass
Dim paramRefList As New ArrayClass
Dim n As Long
Dim a As Long

cmdStr = Trim(cmdStr)

'Get sub name
tmpName = GetString(1, cmdStr, " ")

'What if the sub has no parameters? GOOOOOOoOoO!!!
'If Len(tmpName) = Len(cmdStr) Then
'    CompileError "Syntax error"
'    Exit Sub
'End If

For n = 1 To spDefList.itemCount
With spDefList.Item(n)
    If LCase(tmpName) = LCase(.subProgName) Then
        If Not (.isFunc) Then
        
            'Get arguments
            paramStr = Mid(cmdStr, Len(tmpName) + 2)
            ParseParams paramStr, tmpParamList, ",", True
            
            'Resize paramRefList to tmpParamList size
            'For a = 1 To tmpParamList.itemCount
            '    paramRefList.Add Nothing
            'Next a
            
            'Check argument # against parameter #
            If tmpParamList.itemCount <> .paramNum Then
                CompileError "Wrong number of arguments for sub " & .subProgName
                Exit Sub
            End If
            
            For a = tmpParamList.itemCount To 1 Step -1
                'Evaluate each argument
                paramRefList.Add EvalExpression(tmpParamList.Item(a)), 1
                If exitFlag Then Exit Sub
            Next a
            
            'Check argument types against parameter types
            For a = 1 To paramRefList.itemCount
                If (paramRefList.Item(a).drType <> .varTypeList.Item(a)) Then
                    CompileError "Type mismatch in argument " & CStr(a) & " of sub " & .subProgName
                    Exit Sub
                End If
            Next a
            
            'Write bytecode for sub call
            '[C++ CONVERSION: Adjusted for Base0]
              GenByteCodeFL IDC_CALLSUBPROG, n - 1
            
            Exit Sub
        
        End If
    End If
End With
Next n

CompileError "Undefined sub " & tmpName

End Sub




Public Sub Cmd_For(ByVal cmdStr As String)

Dim counterStr As String
Dim fromStr As String
Dim toStr As String
Dim stepStr As String
Dim params As New ArrayClass

Dim counterRef As DataRefClass
Dim fromRef As DataRefClass
Dim toRef As DataRefClass
Dim stepRef As DataRefClass

Dim forLine As Long
Dim forPos As Long

cmdStr = Trim(cmdStr)

'Parse oOt varStr,fromStr,toStr, and stepStr
ParseParamsEx cmdStr, params, "=", " to ", " step "

'Check argument #
If (params.itemCount < 3) Or (params.itemCount > 4) Then
    CompileError "Syntax error"
    Exit Sub
End If

'Add STEP value if omitted
If params.itemCount = 3 Then params.Add "1"

'Get variable/array reference
Set counterRef = CompileSubProgDataRef(params.Item(1))
If exitFlag Then Exit Sub
If counterRef.drType <> DT_NUMBER Then
    CompileError "Type mismatch: Expected numeric variable/array"
    Exit Sub
End If

'Write bytecode
    'stepRef expression
        Set stepRef = EvalExpression(params.Item(4))
        If exitFlag Then Exit Sub
        If stepRef.drType <> DT_NUMBER Then
            CompileError "Type mismatch: Expected numeric expression"
            Exit Sub
        End If
    'toRef expression
        Set toRef = EvalExpression(params.Item(3))
        If exitFlag Then Exit Sub
        If toRef.drType <> DT_NUMBER Then
            CompileError "Type mismatch: Expected numeric expression"
            Exit Sub
        End If
    'fromRef expression
        Set fromRef = EvalExpression(params.Item(2))
        If exitFlag Then Exit Sub
        If fromRef.drType <> DT_NUMBER Then
            CompileError "Type mismatch: Expected numeric expression"
            Exit Sub
        End If
    'FOR command
        '[C++ CONVERSION: Adjusted for Base0]
        GenByteCodeFL IDC_FOR, counterRef.drID, counterRef.drIdx - 1, 0

'Record bytecode position of FOR command
forPos = currDefObj.byteCodeList.itemCount

'Record rawCode position of FOR command
forLine = currCodeLine


'Loop through raw code directly after FOR command

forBlockNum = forBlockNum + 1

With currDefObj
For currCodeLine = currCodeLine + 1 To .sourceCodeList.itemCount
    If LCase(.sourceCodeList.Item(currCodeLine)) = "next" Then
        'Set codeBLen in FOR byte-command
        .byteCodeList.Item(forPos).Item(4) = (.byteCodeList.itemCount - forPos)
        Exit Sub
    ElseIf LCase(Left(.sourceCodeList.Item(currCodeLine), 5)) = "next " Then
        If LCase(Trim(Mid(.sourceCodeList.Item(currCodeLine), 6))) = LCase(params.Item(1)) Then
            'Set codeBLen in FOR byte-command
            .byteCodeList.Item(forPos).Item(4) = (.byteCodeList.itemCount - forPos)
        Else
            CompileError "NEXT variable '" & Trim(Mid(.sourceCodeList.Item(currCodeLine), 6)) & _
                     "' does not match variable '" & params.Item(1) & "' given in FOR"
        End If
        Exit Sub
    Else
        'Compile command
        CompileCmd .sourceCodeList.Item(currCodeLine)
        If exitFlag Then Exit Sub
    End If
Next currCodeLine
End With

forBlockNum = forBlockNum - 1

'Restore currCodeLine to the beginning of FOR block
currCodeLine = forLine

'If not exited out yet, then no NEXT was found
CompileError "FOR block without NEXT"

End Sub

Public Sub Cmd_GoSub(ByVal cmdStr As String)

Dim n As Long

cmdStr = Trim(cmdStr)

With currDefObj
For n = 1 To .labelNameList.itemCount
    If cmdStr = .labelNameList.Item(n) Then
        GenByteCodeFL IDC_GOSUB, n
        Exit Sub
    End If
Next n
End With

CompileError "Branch label '" & cmdStr & "' does not exist"

End Sub


Public Sub Cmd_Goto(ByVal cmdStr As String)

Dim n As Long

cmdStr = Trim(cmdStr)

With currDefObj
For n = 1 To .labelNameList.itemCount
    If cmdStr = .labelNameList.Item(n) Then
        GenByteCodeFL IDC_GOTO, n
        Exit Sub
    End If
Next n
End With

CompileError "Branch label '" & cmdStr & "' does not exist"

End Sub



Public Sub Cmd_If(ByVal cmdStr As String)

Dim testStr As String
Dim testRef As DataRefClass
Dim appendStr As String
Dim startPos As Long
Dim ifPos As Long
Dim inElseBlock As Boolean
Dim ifLine As Long

cmdStr = Trim(cmdStr)

'If block-IF
If LCase(Right(cmdStr, 5)) = " then" Then
    'Parse out test expression
    testStr = Left(cmdStr, Len(cmdStr) - 5)
    appendStr = ""
'If one-line-IF
Else
    'Parse out test expression and appended command
    testStr = GetString(1, LCase(cmdStr), " then ")
    appendStr = Trim(Mid(cmdStr, Len(testStr) + 7))
    testStr = Trim(Mid(cmdStr, 1, Len(testStr)))
    If (Trim(testStr) = "") Or (Len(testStr) = Len(cmdStr)) Then
        CompileError "Syntax Error"
        Exit Sub
    End If
End If

'Compile test expression
Set testRef = EvalExpression(testStr, True)
If exitFlag Then Exit Sub
If testRef.drType <> DT_NUMBER Then
    CompileError "Type mismatch: Expected numeric expression"
    Exit Sub
End If

'Write bytecode
GenByteCodeFL IDC_IF, 0, 0

'Record bytecode position of IF command
ifPos = currDefObj.byteCodeList.itemCount

'Record rawCode position of IF command
ifLine = currCodeLine

'If one-line-IF
If Not (appendStr = "") Then
    'Compile TRUE command
    CompileCmd appendStr
    If exitFlag Then Exit Sub
    'Set trueBLen in IF byte-command
    With currDefObj.byteCodeList
        .Item(ifPos).Item(2) = (.itemCount - ifPos)
    End With

'If block-IF
Else
    With currDefObj
    'Record start of trueBlock
    startPos = ifPos
    'Not in ELSE block yet
    inElseBlock = False
    'Loop through raw code directly after IF command
    For currCodeLine = currCodeLine + 1 To .sourceCodeList.itemCount
        If LCase(.sourceCodeList.Item(currCodeLine)) = "else" Then
            If inElseBlock Then
                CompileError "Two ELSE commands in one IF block"
                Exit Sub
            Else
                'Set trueBLen in IF byte-command
                .byteCodeList.Item(ifPos).Item(2) = (.byteCodeList.itemCount - startPos)
                'Record start of falseBlock
                startPos = .byteCodeList.itemCount
                'Now within ELSE block
                inElseBlock = True
            End If
            
        ElseIf LCase(Left(.sourceCodeList.Item(currCodeLine), 7)) = "elseif " Then
            If inElseBlock Then
                CompileError "ElseIf after Else not allowed."
                Exit Sub
            Else
                'Set trueBLen in IF byte-command
                .byteCodeList.Item(ifPos).Item(2) = (.byteCodeList.itemCount - startPos)
                'Record start of falseBlock
                startPos = .byteCodeList.itemCount
                'Now within ELSE block
                inElseBlock = True
            End If
        
            'Make sure ElseIf is a multi-line If statement
            If LCase(Right(.sourceCodeList.Item(currCodeLine), 5)) = " then" Then
                'Compile ElseIf as an If command
                CompileCmd "if " & Mid(.sourceCodeList.Item(currCodeLine), 8)
                If exitFlag Then Exit Sub
            Else
                CompileError "ElseIf without the ending Then statement"
                Exit Sub
            End If
            'Set the current compile line back
            'to before the End IF statement
            currCodeLine = currCodeLine - 1
            
        ElseIf LCase(.sourceCodeList.Item(currCodeLine)) = "end if" Then
            If inElseBlock Then
                'Set falseBLen in IF byte-command
                .byteCodeList.Item(ifPos).Item(3) = (.byteCodeList.itemCount - startPos)
            Else
                'Set trueBLen in IF byte-command
                .byteCodeList.Item(ifPos).Item(2) = (.byteCodeList.itemCount - startPos)
            End If
            Exit Sub
            
        Else
            'Compile command
            CompileCmd .sourceCodeList.Item(currCodeLine)
            If exitFlag Then Exit Sub
            
        End If
    Next currCodeLine
    End With
    'Restore currCodeLine to the beginning of IF block
    currCodeLine = ifLine
    'If not exited out yet, then no END IF was found
    CompileError "IF block without END IF"
End If

End Sub


Public Sub Cmd_While(ByVal cmdStr As String)

Dim testStr As String
Dim testRef As DataRefClass
Dim codeBlockPos As Long
Dim whilePos As Long
Dim whileLine As Long

testStr = Trim(cmdStr)

With currDefObj

'Write bytecode for WHILE command
GenByteCodeFL IDC_While, 0, 0

'Record bytecode position of WHILE command
whilePos = .byteCodeList.itemCount

'Record rawCode position of WHILE command
whileLine = currCodeLine

'Compile test expression
Set testRef = EvalExpression(testStr, True)
If exitFlag Then Exit Sub
If testRef.drType <> DT_NUMBER Then
    CompileError "Type mismatch: Expected numeric expression"
    Exit Sub
End If

'Set testBlockLen in WHILE byte-command
.byteCodeList.Item(whilePos).Item(2) = (.byteCodeList.itemCount - whilePos)

'Record start of codeBlock
codeBlockPos = .byteCodeList.itemCount

'Loop through raw code directly after WHILE command

whileBlockNum = whileBlockNum + 1

For currCodeLine = currCodeLine + 1 To .sourceCodeList.itemCount
    If LCase(.sourceCodeList.Item(currCodeLine)) = "wend" Then
        'Set codeBlockLen in WHILE byte-command
        .byteCodeList.Item(whilePos).Item(3) = (.byteCodeList.itemCount - codeBlockPos)
        Exit Sub
    Else
        'Compile command
        CompileCmd .sourceCodeList.Item(currCodeLine)
        If exitFlag Then Exit Sub
    End If
Next currCodeLine

whileBlockNum = whileBlockNum - 1

End With

'Restore currCodeLine to the beginning of IF block
currCodeLine = whileLine

'If not exited out yet, then no WEND was found
CompileError "WHILE block without WEND"

End Sub


Public Sub Cmd_Pause(ByVal cmdStr As String)

Dim tmpParamList As New ArrayClass
Dim paramRefList As New ArrayClass
Dim a As Long

cmdStr = Trim(cmdStr)

'Get arguments
ParseParams cmdStr, tmpParamList, ",", True

'Resize paramRefList to tmpParamList size
'For a = 1 To tmpParamList.itemCount
'    paramRefList.Add Nothing
'Next a

'Check argument # against parameter #
If tmpParamList.itemCount <> 1 Then
    CompileError "Wrong number of arguments for command PAUSE"
    Exit Sub
End If

For a = tmpParamList.itemCount To 1 Step -1
    'Evaluate each argument
    paramRefList.Add EvalExpression(tmpParamList.Item(a)), 1
    If exitFlag Then Exit Sub
Next a

'Check argument types against parameter types
For a = 1 To paramRefList.itemCount
    If paramRefList.Item(a).drType <> DT_NUMBER Then
        CompileError "Type mismatch in argument " & CStr(a) & " of command PAUSE"
        Exit Sub
    End If
Next a

'Write bytecode for command call
    GenByteCodeFL IDC_Pause

End Sub

Public Sub CompileArrayArgs(ByVal arrayStr As String, ByRef arrayRef As DataRefClass)

Dim tmpName, paramStr As String
Dim tmpParamList As New ArrayClass
Dim paramRefList As New ArrayClass
Dim tmpDefObj As Object
Dim a As Long
Dim n As Long

If arrayRef.drID = IDD_GARRAYLST Then
    Set tmpDefObj = spDefList.Item(1)
ElseIf arrayRef.drID = IDD_LARRAYLST Then
    Set tmpDefObj = spDefList.Item(currDefIdx)
End If

With tmpDefObj
    'Get array name
    tmpName = GetString(1, arrayStr, "(")
    'Get index arguments
    paramStr = GetString(Len(tmpName) + 2, arrayStr, ")")
    ParseParams paramStr, tmpParamList, ",", True
    
    'Check argument # against dimension #
    If tmpParamList.itemCount <> .arrayDimNumList.Item(arrayRef.drIdx) Then
        CompileError "Wrong number of dimensions for array " & .arrayNameList.Item(arrayRef.drIdx) & "()"
        Exit Sub
    End If
    
    For a = tmpParamList.itemCount To 1 Step -1
        'Evaluate each index argument
        paramRefList.Add EvalExpression(tmpParamList.Item(a)), 1
        If exitFlag Then Exit Sub
    Next a
    
    'Write bytecode for index stacking
    GenByteCodeFL IDC_ARRAYIDX, paramRefList.itemCount

    'Check argument types
    For a = 1 To paramRefList.itemCount
        If paramRefList.Item(a).drType <> DT_NUMBER Then
            CompileError "Type mismatch in dimension " & CStr(a) & " of array " & .arrayNameList.Item(arrayRef.drIdx) & "()"
            Exit Sub
        End If
    Next a
End With

End Sub






Public Function CompileSubProgDataRef(ByVal dataRefStr As String) As DataRefClass

Dim tmpRef As DataRefClass
Dim n As Long

dataRefStr = Trim(dataRefStr)

'Get variable/array reference
If InStr(1, dataRefStr, "(") > 0 Then

    If Right(dataRefStr, 1) = ")" Then
        Set tmpRef = CompileArrayRef(Left(dataRefStr, InStr(1, dataRefStr, "(") - 1))
        If exitFlag Then Exit Function
        'Write bytecode for array index expression(s)
        CompileArrayArgs dataRefStr, tmpRef
        If exitFlag Then Exit Function
    Else
        CompileError "Syntax error": Exit Function
    End If
    
Else

    Set tmpRef = CompileVarRef(dataRefStr)
    If exitFlag Then Exit Function

End If

'Return data reference object
Set CompileSubProgDataRef = tmpRef

End Function

Public Function Func_Str(ByVal cmdStr As String) As DataRefClass

Dim tmpParamList As New ArrayClass
Dim paramRefList As New ArrayClass
Dim a As Long

cmdStr = Trim(cmdStr)
Set Func_Str = New DataRefClass

'Get arguments
ParseParams cmdStr, tmpParamList, ",", True

'Resize paramRefList to tmpParamList size
'For a = 1 To tmpParamList.itemCount
'    paramRefList.Add Nothing
'Next a

'Check argument # against parameter #
If tmpParamList.itemCount <> 1 Then
    CompileError "Wrong number of arguments for function STR$()"
    Exit Function
End If

For a = tmpParamList.itemCount To 1 Step -1
    'Evaluate each argument
    paramRefList.Add EvalExpression(tmpParamList.Item(a)), 1
    If exitFlag Then Exit Function
Next a

'Check argument types against parameter types
For a = 1 To paramRefList.itemCount
    If paramRefList.Item(a).drType <> DT_NUMBER Then
        CompileError "Type mismatch in argument " & CStr(a) & " of function STR$()"
        Exit Function
    End If
Next a
'Write bytecode for function call
    GenByteCodeFL IDC_Str
'Fill out return reference and exit
Func_Str.drID = IDD_DATLST
Func_Str.drIdx = 0
Func_Str.drType = DT_STRING

End Function


Private Sub Cmd_Message(ByVal cmdStr As String)

Dim tmpParamList As New ArrayClass
Dim paramRefList As New ArrayClass
Dim a As Long

cmdStr = Trim(cmdStr)

'Get arguments
ParseParams cmdStr, tmpParamList, ",", True

'Check argument # against parameter #
If tmpParamList.itemCount <> 2 Then
    CompileError "Wrong number of arguments for command MESSAGE"
    Exit Sub
End If

For a = tmpParamList.itemCount To 1 Step -1
    'Evaluate each argument
    paramRefList.Add EvalExpression(tmpParamList.Item(a)), 1
    If exitFlag Then Exit Sub
Next a

'Check argument types against parameter types
For a = 1 To paramRefList.itemCount
    If paramRefList.Item(a).drType <> DT_STRING Then
        CompileError "Type mismatch in argument " & CStr(a) & " of command MESSAGE"
        Exit Sub
    End If
Next a

'Write bytecode for command call
    GenByteCodeFL IDC_Message

End Sub


Private Sub Cmd_ConsolTitle(ByVal cmdStr As String)

Dim tmpParamList As New ArrayClass
Dim expRef As DataRefClass

cmdStr = Trim(cmdStr)

'Get arguments
ParseParams cmdStr, tmpParamList, ",", True

'Check argument # against parameter #
If tmpParamList.itemCount <> 1 Then
    CompileError "Wrong number of arguments for command COnsolTitle"
    Exit Sub
End If

'Evaluate argument
Set expRef = EvalExpression(tmpParamList.Item(1))
If exitFlag Then Exit Sub

'Check argument type
If expRef.drType <> DT_STRING Then
    CompileError "Consol title should be a String"
    Exit Sub
End If

'Write bytecode for command call
GenByteCodeFL IDC_ConsolTitle

End Sub
Public Function Func_Int(ByVal cmdStr As String) As DataRefClass

Dim tmpParamList As New ArrayClass
Dim paramRefList As New ArrayClass
Dim a As Long

cmdStr = Trim(cmdStr)
Set Func_Int = New DataRefClass

'Get arguments
ParseParams cmdStr, tmpParamList, ",", True

'Resize paramRefList to tmpParamList size
'For a = 1 To tmpParamList.itemCount
'    paramRefList.Add Nothing
'Next a

'Check argument # against parameter #
If tmpParamList.itemCount <> 1 Then
    CompileError "Wrong number of arguments for function INT()"
    Exit Function
End If

For a = tmpParamList.itemCount To 1 Step -1
    'Evaluate each argument
    paramRefList.Add EvalExpression(tmpParamList.Item(a)), 1
    If exitFlag Then Exit Function
Next a

'Check argument types against parameter types
For a = 1 To paramRefList.itemCount
    If paramRefList.Item(a).drType <> DT_NUMBER Then
        CompileError "Type mismatch in argument " & CStr(a) & " of function INT()"
        Exit Function
    End If
Next a
'Write bytecode for function call
    GenByteCodeFL IDC_Int
'Fill out return reference and exit
Func_Int.drID = IDD_DATLST
Func_Int.drIdx = 0
Func_Int.drType = DT_NUMBER

End Function


Public Function Func_Abs(ByVal cmdStr As String) As DataRefClass

Dim tmpParamList As New ArrayClass
Dim paramRefList As New ArrayClass
Dim a As Long

cmdStr = Trim(cmdStr)
Set Func_Abs = New DataRefClass

'Get arguments
ParseParams cmdStr, tmpParamList, ",", True

'Check argument # against parameter #
If tmpParamList.itemCount <> 1 Then
    CompileError "Wrong number of arguments for function ABS()"
    Exit Function
End If

For a = tmpParamList.itemCount To 1 Step -1
    'Evaluate each argument
    paramRefList.Add EvalExpression(tmpParamList.Item(a)), 1
    If exitFlag Then Exit Function
Next a

'Check argument types against parameter types
For a = 1 To paramRefList.itemCount
    If paramRefList.Item(a).drType <> DT_NUMBER Then
        CompileError "Type mismatch in argument " & CStr(a) & " of function ABS()"
        Exit Function
    End If
Next a

'Write bytecode for function call
    GenByteCodeFL IDC_Abs

'Fill out return reference and exit
Func_Abs.drID = IDD_DATLST
Func_Abs.drIdx = 0
Func_Abs.drType = DT_NUMBER

End Function


Public Function Func_Not(ByVal cmdStr As String) As DataRefClass

Dim tmpParamList As New ArrayClass
Dim paramRefList As New ArrayClass
Dim a As Long

cmdStr = Trim(cmdStr)
Set Func_Not = New DataRefClass

'Get arguments
ParseParams cmdStr, tmpParamList, ",", True

'Check argument # against parameter #
If tmpParamList.itemCount <> 1 Then
    CompileError "Wrong number of arguments for function NOT()"
    Exit Function
End If

For a = tmpParamList.itemCount To 1 Step -1
    'Evaluate each argument
    paramRefList.Add EvalExpression(tmpParamList.Item(a)), 1
    If exitFlag Then Exit Function
Next a

'Check argument types against parameter types
For a = 1 To paramRefList.itemCount
    If paramRefList.Item(a).drType <> DT_NUMBER Then
        CompileError "Type mismatch in argument " & CStr(a) & " of function NOT()"
        Exit Function
    End If
Next a

'Write bytecode for function call
    GenByteCodeFL IDC_Not

'Fill out return reference and exit
Func_Not.drID = IDD_DATLST
Func_Not.drIdx = 0
Func_Not.drType = DT_NUMBER

End Function
Public Function Func_Val(ByVal cmdStr As String) As DataRefClass

Dim tmpParamList As New ArrayClass
Dim paramRefList As New ArrayClass
Dim a As Long

cmdStr = Trim(cmdStr)
Set Func_Val = New DataRefClass

'Get arguments
ParseParams cmdStr, tmpParamList, ",", True

'Check argument # against parameter #
If tmpParamList.itemCount <> 1 Then
    CompileError "Wrong number of arguments for function VAL()"
    Exit Function
End If

For a = tmpParamList.itemCount To 1 Step -1
    'Evaluate each argument
    paramRefList.Add EvalExpression(tmpParamList.Item(a)), 1
    If exitFlag Then Exit Function
Next a

'Check argument types against parameter types
For a = 1 To paramRefList.itemCount
    If paramRefList.Item(a).drType <> DT_STRING Then
        CompileError "Type mismatch in argument " & CStr(a) & " of function VAL()"
        Exit Function
    End If
Next a

'Write bytecode for function call
    GenByteCodeFL IDC_Val

'Fill out return reference and exit
Func_Val.drID = IDD_DATLST
Func_Val.drIdx = 0
Func_Val.drType = DT_NUMBER

End Function


Public Function Func_Upper(ByVal cmdStr As String) As DataRefClass

Dim tmpParamList As New ArrayClass
Dim paramRefList As New ArrayClass
Dim a As Long

cmdStr = Trim(cmdStr)
Set Func_Upper = New DataRefClass

'Get arguments
ParseParams cmdStr, tmpParamList, ",", True

'Check argument # against parameter #
If tmpParamList.itemCount <> 1 Then
    CompileError "Wrong number of arguments for function UPPER()"
    Exit Function
End If

For a = tmpParamList.itemCount To 1 Step -1
    'Evaluate each argument
    paramRefList.Add EvalExpression(tmpParamList.Item(a)), 1
    If exitFlag Then Exit Function
Next a

'Check argument types against parameter types
For a = 1 To paramRefList.itemCount
    If paramRefList.Item(a).drType <> DT_STRING Then
        CompileError "Type mismatch in argument " & CStr(a) & " of function UPPER()"
        Exit Function
    End If
Next a

'Write bytecode for function call
    GenByteCodeFL IDC_Upper

'Fill out return reference and exit
Func_Upper.drID = IDD_DATLST
Func_Upper.drIdx = 0
Func_Upper.drType = DT_STRING

End Function


Public Function Func_Lower(ByVal cmdStr As String) As DataRefClass

Dim tmpParamList As New ArrayClass
Dim paramRefList As New ArrayClass
Dim a As Long

cmdStr = Trim(cmdStr)
Set Func_Lower = New DataRefClass

'Get arguments
ParseParams cmdStr, tmpParamList, ",", True

'Check argument # against parameter #
If tmpParamList.itemCount <> 1 Then
    CompileError "Wrong number of arguments for function LOWER()"
    Exit Function
End If

For a = tmpParamList.itemCount To 1 Step -1
    'Evaluate each argument
    paramRefList.Add EvalExpression(tmpParamList.Item(a)), 1
    If exitFlag Then Exit Function
Next a

'Check argument types against parameter types
For a = 1 To paramRefList.itemCount
    If paramRefList.Item(a).drType <> DT_STRING Then
        CompileError "Type mismatch in argument " & CStr(a) & " of function LOWER()"
        Exit Function
    End If
Next a

'Write bytecode for function call
    GenByteCodeFL IDC_Lower

'Fill out return reference and exit
Func_Lower.drID = IDD_DATLST
Func_Lower.drIdx = 0
Func_Lower.drType = DT_STRING

End Function


Public Function Func_Left(ByVal cmdStr As String) As DataRefClass

Dim tmpParamList As New ArrayClass
Dim paramRefList As New ArrayClass
Dim a As Long

cmdStr = Trim(cmdStr)
Set Func_Left = New DataRefClass

'Get arguments
ParseParams cmdStr, tmpParamList, ",", True

'Check argument # against parameter #
If tmpParamList.itemCount <> 2 Then
    CompileError "Wrong number of arguments for function LEFT()"
    Exit Function
End If

For a = tmpParamList.itemCount To 1 Step -1
    'Evaluate each argument
    paramRefList.Add EvalExpression(tmpParamList.Item(a)), 1
    If exitFlag Then Exit Function
Next a

'Check argument types against parameter types
If paramRefList.Item(1).drType <> DT_STRING Then
    CompileError "Type mismatch in argument " & CStr(1) & " of function LEFT()"
    Exit Function
End If
If paramRefList.Item(2).drType <> DT_NUMBER Then
    CompileError "Type mismatch in argument " & CStr(2) & " of function LEFT()"
    Exit Function
End If

'Write bytecode for function call
    GenByteCodeFL IDC_Left

'Fill out return reference and exit
Func_Left.drID = IDD_DATLST
Func_Left.drIdx = 0
Func_Left.drType = DT_STRING

End Function


Public Function Func_Right(ByVal cmdStr As String) As DataRefClass

Dim tmpParamList As New ArrayClass
Dim paramRefList As New ArrayClass
Dim a As Long

cmdStr = Trim(cmdStr)
Set Func_Right = New DataRefClass

'Get arguments
ParseParams cmdStr, tmpParamList, ",", True

'Check argument # against parameter #
If tmpParamList.itemCount <> 2 Then
    CompileError "Wrong number of arguments for function RIGHT()"
    Exit Function
End If

For a = tmpParamList.itemCount To 1 Step -1
    'Evaluate each argument
    paramRefList.Add EvalExpression(tmpParamList.Item(a)), 1
    If exitFlag Then Exit Function
Next a

'Check argument types against parameter types
If paramRefList.Item(1).drType <> DT_STRING Then
    CompileError "Type mismatch in argument " & CStr(1) & " of function RIGHT()"
    Exit Function
End If
If paramRefList.Item(2).drType <> DT_NUMBER Then
    CompileError "Type mismatch in argument " & CStr(2) & " of function RIGHT()"
    Exit Function
End If

'Write bytecode for function call
    GenByteCodeFL IDC_Right

'Fill out return reference and exit
Func_Right.drID = IDD_DATLST
Func_Right.drIdx = 0
Func_Right.drType = DT_STRING

End Function


Public Function Func_Mid(ByVal cmdStr As String) As DataRefClass

Dim tmpParamList As New ArrayClass
Dim paramRefList As New ArrayClass
Dim a As Long

cmdStr = Trim(cmdStr)
Set Func_Mid = New DataRefClass

'Get arguments
ParseParams cmdStr, tmpParamList, ",", True

'Check argument # against parameter #
If (tmpParamList.itemCount < 2) Or (tmpParamList.itemCount > 3) Then
    CompileError "Wrong number of arguments for function MID()"
    Exit Function
End If

For a = tmpParamList.itemCount To 1 Step -1
    'Evaluate each argument
    paramRefList.Add EvalExpression(tmpParamList.Item(a)), 1
    If exitFlag Then Exit Function
Next a

'Check argument types against parameter types
If paramRefList.Item(1).drType <> DT_STRING Then
    CompileError "Type mismatch in argument " & CStr(1) & " of function MID()"
    Exit Function
End If
If paramRefList.Item(2).drType <> DT_NUMBER Then
    CompileError "Type mismatch in argument " & CStr(2) & " of function MID()"
    Exit Function
End If
If paramRefList.itemCount = 3 Then
    If paramRefList.Item(3).drType <> DT_NUMBER Then
        CompileError "Type mismatch in argument " & CStr(3) & " of function MID()"
        Exit Function
    End If
End If

'Write bytecode for function call
    GenByteCodeFL IDC_Mid

'Fill out return reference and exit
Func_Mid.drID = IDD_DATLST
Func_Mid.drIdx = 0
Func_Mid.drType = DT_STRING

End Function



Public Function Func_LTrim(ByVal cmdStr As String) As DataRefClass

Dim tmpParamList As New ArrayClass
Dim paramRefList As New ArrayClass
Dim a As Long

cmdStr = Trim(cmdStr)
Set Func_LTrim = New DataRefClass

'Get arguments
ParseParams cmdStr, tmpParamList, ",", True

'Check argument # against parameter #
If tmpParamList.itemCount <> 1 Then
    CompileError "Wrong number of arguments for function LTRIM()"
    Exit Function
End If

For a = tmpParamList.itemCount To 1 Step -1
    'Evaluate each argument
    paramRefList.Add EvalExpression(tmpParamList.Item(a)), 1
    If exitFlag Then Exit Function
Next a

'Check argument types against parameter types
For a = 1 To paramRefList.itemCount
    If paramRefList.Item(a).drType <> DT_STRING Then
        CompileError "Type mismatch in argument " & CStr(a) & " of function LTRIM()"
        Exit Function
    End If
Next a

'Write bytecode for function call
    GenByteCodeFL IDC_LTrim

'Fill out return reference and exit
Func_LTrim.drID = IDD_DATLST
Func_LTrim.drIdx = 0
Func_LTrim.drType = DT_STRING

End Function



Public Function Func_RTrim(ByVal cmdStr As String) As DataRefClass

Dim tmpParamList As New ArrayClass
Dim paramRefList As New ArrayClass
Dim a As Long

cmdStr = Trim(cmdStr)
Set Func_RTrim = New DataRefClass

'Get arguments
ParseParams cmdStr, tmpParamList, ",", True

'Check argument # against parameter #
If tmpParamList.itemCount <> 1 Then
    CompileError "Wrong number of arguments for function RTRIM()"
    Exit Function
End If

For a = tmpParamList.itemCount To 1 Step -1
    'Evaluate each argument
    paramRefList.Add EvalExpression(tmpParamList.Item(a)), 1
    If exitFlag Then Exit Function
Next a

'Check argument types against parameter types
For a = 1 To paramRefList.itemCount
    If paramRefList.Item(a).drType <> DT_STRING Then
        CompileError "Type mismatch in argument " & CStr(a) & " of function RTRIM()"
        Exit Function
    End If
Next a

'Write bytecode for function call
    GenByteCodeFL IDC_RTrim

'Fill out return reference and exit
Func_RTrim.drID = IDD_DATLST
Func_RTrim.drIdx = 0
Func_RTrim.drType = DT_STRING

End Function


Public Function Func_Trim(ByVal cmdStr As String) As DataRefClass

Dim tmpParamList As New ArrayClass
Dim paramRefList As New ArrayClass
Dim a As Long

cmdStr = Trim(cmdStr)
Set Func_Trim = New DataRefClass

'Get arguments
ParseParams cmdStr, tmpParamList, ",", True

'Check argument # against parameter #
If tmpParamList.itemCount <> 1 Then
    CompileError "Wrong number of arguments for function TRIM()"
    Exit Function
End If

For a = tmpParamList.itemCount To 1 Step -1
    'Evaluate each argument
    paramRefList.Add EvalExpression(tmpParamList.Item(a)), 1
    If exitFlag Then Exit Function
Next a

'Check argument types against parameter types
For a = 1 To paramRefList.itemCount
    If paramRefList.Item(a).drType <> DT_STRING Then
        CompileError "Type mismatch in argument " & CStr(a) & " of function TRIM()"
        Exit Function
    End If
Next a

'Write bytecode for function call
    GenByteCodeFL IDC_Trim

'Fill out return reference and exit
Func_Trim.drID = IDD_DATLST
Func_Trim.drIdx = 0
Func_Trim.drType = DT_STRING

End Function


Public Function Func_Len(ByVal cmdStr As String) As DataRefClass

Dim tmpParamList As New ArrayClass
Dim paramRefList As New ArrayClass
Dim a As Long

cmdStr = Trim(cmdStr)
Set Func_Len = New DataRefClass

'Get arguments
ParseParams cmdStr, tmpParamList, ",", True

'Check argument # against parameter #
If tmpParamList.itemCount <> 1 Then
    CompileError "Wrong number of arguments for function LEN()"
    Exit Function
End If

For a = tmpParamList.itemCount To 1 Step -1
    'Evaluate each argument
    paramRefList.Add EvalExpression(tmpParamList.Item(a)), 1
    If exitFlag Then Exit Function
Next a

'Check argument types against parameter types
For a = 1 To paramRefList.itemCount
    If paramRefList.Item(a).drType <> DT_STRING Then
        CompileError "Type mismatch in argument " & CStr(a) & " of function LEN()"
        Exit Function
    End If
Next a

'Write bytecode for function call
    GenByteCodeFL IDC_Len

'Fill out return reference and exit
Func_Len.drID = IDD_DATLST
Func_Len.drIdx = 0
Func_Len.drType = DT_NUMBER

End Function

Public Function Func_Chr(ByVal cmdStr As String) As DataRefClass

Dim tmpParamList As New ArrayClass
Dim paramRefList As New ArrayClass
Dim a As Long

cmdStr = Trim(cmdStr)
Set Func_Chr = New DataRefClass

'Get arguments
ParseParams cmdStr, tmpParamList, ",", True

'Check argument # against parameter #
If tmpParamList.itemCount <> 1 Then
    CompileError "Wrong number of arguments for function CHR()"
    Exit Function
End If

For a = tmpParamList.itemCount To 1 Step -1
    'Evaluate each argument
    paramRefList.Add EvalExpression(tmpParamList.Item(a)), 1
    If exitFlag Then Exit Function
Next a

'Check argument types against parameter types
For a = 1 To paramRefList.itemCount
    If paramRefList.Item(a).drType <> DT_NUMBER Then
        CompileError "Type mismatch in argument " & CStr(a) & " of function CHR()"
        Exit Function
    End If
Next a

'Write bytecode for function call
    GenByteCodeFL IDC_Chr

'Fill out return reference and exit
Func_Chr.drID = IDD_DATLST
Func_Chr.drIdx = 0
Func_Chr.drType = DT_STRING

End Function


Public Function Func_Asc(ByVal cmdStr As String) As DataRefClass

Dim tmpParamList As New ArrayClass
Dim paramRefList As New ArrayClass
Dim a As Long

cmdStr = Trim(cmdStr)
Set Func_Asc = New DataRefClass

'Get arguments
ParseParams cmdStr, tmpParamList, ",", True

'Check argument # against parameter #
If tmpParamList.itemCount <> 1 Then
    CompileError "Wrong number of arguments for function ASC()"
    Exit Function
End If

For a = tmpParamList.itemCount To 1 Step -1
    'Evaluate each argument
    paramRefList.Add EvalExpression(tmpParamList.Item(a)), 1
    If exitFlag Then Exit Function
Next a

'Check argument types against parameter types
For a = 1 To paramRefList.itemCount
    If paramRefList.Item(a).drType <> DT_STRING Then
        CompileError "Type mismatch in argument " & CStr(a) & " of function ASC()"
        Exit Function
    End If
Next a

'Write bytecode for function call
    GenByteCodeFL IDC_Asc

'Fill out return reference and exit
Func_Asc.drID = IDD_DATLST
Func_Asc.drIdx = 0
Func_Asc.drType = DT_NUMBER

End Function


Public Function Func_Rnd(ByVal cmdStr As String) As DataRefClass

Dim tmpParamList As New ArrayClass
Dim paramRefList As New ArrayClass
Dim a As Long

cmdStr = Trim(cmdStr)
Set Func_Rnd = New DataRefClass

'Get arguments
ParseParams cmdStr, tmpParamList, ",", True

'Check argument # against parameter #
If tmpParamList.itemCount > 0 Then
    CompileError "Wrong number of arguments for function RND()"
    Exit Function
End If

'Write bytecode for function call
    GenByteCodeFL IDC_Rnd
'Fill out return reference and exit
Func_Rnd.drID = IDD_DATLST
Func_Rnd.drIdx = 0
Func_Rnd.drType = DT_NUMBER

End Function

Public Sub GenByteCodeFL(ParamArray pList() As Variant)

'Generates fixed-length bytecode command

Dim n As Long

currDefObj.byteCodeList.Add New ArrayClass
With currDefObj.byteCodeList
    For n = LBound(pList) To UBound(pList)
        .Item(.itemCount).Add pList(n)
    Next n
End With

End Sub


Public Sub GenByteCodeVL(ByRef pList As ArrayClass)

'Generates variable-length bytecode command

Dim n As Long

currDefObj.byteCodeList.Add New ArrayClass
With currDefObj.byteCodeList
    For n = 1 To pList.itemCount
        .Item(.itemCount).Add pList.Item(n)
    Next n
End With

End Sub




Public Sub Cmd_Let(ByVal cmdStr As String)

Dim varStr As String
Dim expStr As String
Dim destRef As DataRefClass
Dim srcRef As DataRefClass

cmdStr = Trim(cmdStr)

'Get variable/array name
varStr = GetString(1, cmdStr, "=")
If (Len(varStr) = Len(cmdStr)) Or (Len(varStr) + 1 = Len(cmdStr)) Then
    CompileError "Syntax error"
    Exit Sub
End If

'Get expression string
expStr = Mid(cmdStr, Len(varStr) + 2)

'Get variable/array reference
Set destRef = CompileSubProgDataRef(varStr)
If exitFlag Then Exit Sub

'Get expression reference
Set srcRef = EvalExpression(expStr)
If exitFlag Then Exit Sub


'Type check
If srcRef.drType <> destRef.drType Then
    CompileError "Type mismatch: Expression type and variable/array type do not match"
    Exit Sub
End If

'Write bytecode
'[C++ CONVERSION: Adjusted for Base0]
GenByteCodeFL IDC_COPYDATA, destRef.drID, destRef.drIdx - 1

End Sub

Public Sub CompileSubProgCode()

Dim n As Long
Dim tmpIdx As Long

With currDefObj

'Loop forwards through spDefList(spIdx).sourceCodeList using counter currCodeLine
For currCodeLine = 1 To .sourceCodeList.itemCount
    'Send line to CompileCmd()
    CompileCmd .sourceCodeList.Item(currCodeLine)
    If exitFlag Then Exit Sub
Next currCodeLine

'Replace index reference with line number reference
'in all GOTO and GOSUB byte-code commands
For n = 1 To .byteCodeList.itemCount
    If (.byteCodeList.Item(n).Item(1) = IDC_GOTO) Or _
       (.byteCodeList.Item(n).Item(1) = IDC_GOSUB) Then
            tmpIdx = .byteCodeList.Item(n).Item(2)
            '[C++ CONVERSION: Adjusted for Base0]
            .byteCodeList.Item(n).Item(2) = .labelLocList.Item(tmpIdx) - 1
    End If
Next n

End With

End Sub

Public Function EvalFunction(ByVal funcStr As String, ByRef retRef As DataRefClass) As Boolean

funcStr = Trim(funcStr)
EvalFunction = True

If LCase(Left(funcStr, 4)) = "loc(" Then
    Set retRef = Func_Loc((GetString(5, funcStr, ")")))
    
ElseIf LCase(Left(funcStr, 6)) = "input(" Then
    Set retRef = Func_Input((GetString(7, funcStr, ")")))
    
ElseIf LCase(Left(funcStr, 4)) = "lof(" Then
    Set retRef = Func_LOF((GetString(5, funcStr, ")")))

ElseIf LCase(Left(funcStr, 4)) = "eof(" Then
    Set retRef = Func_EOF((GetString(5, funcStr, ")")))

ElseIf LCase(Left(funcStr, 4)) = "str(" Then
    Set retRef = Func_Str(GetString(5, funcStr, ")"))
    
ElseIf LCase(Left(funcStr, 4)) = "int(" Then
    Set retRef = Func_Int(GetString(5, funcStr, ")"))
    
ElseIf LCase(Left(funcStr, 4)) = "rnd(" Then
    Set retRef = Func_Rnd(GetString(5, funcStr, ")"))

ElseIf LCase(Left(funcStr, 4)) = "val(" Then
    Set retRef = Func_Val(GetString(5, funcStr, ")"))

ElseIf LCase(Left(funcStr, 4)) = "chr(" Then
    Set retRef = Func_Chr(GetString(5, funcStr, ")"))

ElseIf LCase(Left(funcStr, 4)) = "asc(" Then
    Set retRef = Func_Asc(GetString(5, funcStr, ")"))

ElseIf LCase(Left(funcStr, 4)) = "abs(" Then
    Set retRef = Func_Abs(GetString(5, funcStr, ")"))

ElseIf LCase(Left(funcStr, 4)) = "not(" Then
    Set retRef = Func_Not(GetString(5, funcStr, ")"))

ElseIf LCase(Left(funcStr, 4)) = "len(" Then
    Set retRef = Func_Len(GetString(5, funcStr, ")"))


ElseIf LCase(Left(funcStr, 6)) = "upper(" Then
    Set retRef = Func_Upper(GetString(7, funcStr, ")"))

ElseIf LCase(Left(funcStr, 6)) = "lower(" Then
    Set retRef = Func_Lower(GetString(7, funcStr, ")"))
    
ElseIf LCase(Left(funcStr, 6)) = "ltrim(" Then
    Set retRef = Func_LTrim(GetString(7, funcStr, ")"))
    
ElseIf LCase(Left(funcStr, 6)) = "rtrim(" Then
    Set retRef = Func_RTrim(GetString(7, funcStr, ")"))

ElseIf LCase(Left(funcStr, 5)) = "trim(" Then
    Set retRef = Func_Trim(GetString(6, funcStr, ")"))

ElseIf LCase(Left(funcStr, 5)) = "left(" Then
    Set retRef = Func_Left(GetString(6, funcStr, ")"))

ElseIf LCase(Left(funcStr, 4)) = "mid(" Then
    Set retRef = Func_Mid(GetString(5, funcStr, ")"))

ElseIf LCase(Left(funcStr, 6)) = "right(" Then
    Set retRef = Func_Right(GetString(7, funcStr, ")"))


'ElseIf LCase(Left(funcStr, 6)) = "instr(" Then
'    retRef = Func_InStr(GetString(7, funcStr, ")"))
'ElseIf LCase(Left(funcStr, 17)) = "getclipboardtext(" Then
'    retRef.drType = DT_STRING
'ElseIf LCase(Left(funcStr, 9)) = "inputbox(" Then
'    retRef = Func_InputBox((GetString(10, funcStr, ")")))
'ElseIf LCase(Left(funcStr, 5)) = "date(" Then
'    retRef.drType = DT_STRING
'ElseIf LCase(Left(funcStr, 5)) = "time(" Then
'    retRef.drType = DT_STRING
'ElseIf LCase(Left(funcStr, 4)) = "min(" Then
'    retRef = Func_Min((GetString(5, funcStr, ")")))
'ElseIf LCase(Left(funcStr, 4)) = "max(" Then
'    retRef = Func_Max((GetString(5, funcStr, ")")))
'ElseIf LCase(Left(funcStr, 4)) = "sqr(" Then
'    retRef = Func_Sqr((GetString(5, funcStr, ")")))
'ElseIf LCase(Left(funcStr, 6)) = "space(" Then
'    retRef = Func_Space((GetString(7, funcStr, ")")))
'ElseIf LCase(Left(funcStr, 4)) = "rgb(" Then
'    retRef = Func_RGB((GetString(5, funcStr, ")")))
'ElseIf LCase(Left(funcStr, 8)) = "replace(" Then
'    retRef = Func_Replace((GetString(9, funcStr, ")")))
'ElseIf LCase(Left(funcStr, 7)) = "string(" Then
'    retRef = Func_String((GetString(8, funcStr, ")")))
'ElseIf LCase(Left(funcStr, 5)) = "word(" Then
'    retRef = Func_Word((GetString(6, funcStr, ")")))
'ElseIf LCase(Left(funcStr, 4)) = "sin(" Then
'    retRef = Func_Sin((GetString(5, funcStr, ")")))
'ElseIf LCase(Left(funcStr, 4)) = "cos(" Then
'    retRef = Func_Cos((GetString(5, funcStr, ")")))
'ElseIf LCase(Left(funcStr, 4)) = "tan(" Then
'    retRef = Func_Tan((GetString(5, funcStr, ")")))
'ElseIf LCase(Left(funcStr, 4)) = "log(" Then
'    retRef = Func_Log((GetString(5, funcStr, ")")))
'ElseIf LCase(Left(funcStr, 4)) = "exp(" Then
'    retRef = Func_Exp((GetString(5, funcStr, ")")))
'ElseIf LCase(Left(funcStr, 4)) = "atn(" Then
'    retRef = Func_Atn((GetString(5, funcStr, ")")))
'ElseIf LCase(Left(funcStr, 4)) = "hex(" Then
'    retRef = Func_Hex((GetString(5, funcStr, ")")))
'ElseIf LCase(Left(funcStr, 4)) = "oct(" Then
'    retRef = Func_Oct((GetString(5, funcStr, ")")))
'ElseIf LCase(Left(funcStr, 4)) = "sgn(" Then
'    retRef = Func_Sgn((GetString(5, funcStr, ")")))
'ElseIf LCase(Left(funcStr, 6)) = "round(" Then
'    retRef = Func_Round((GetString(7, funcStr, ")")))
'ElseIf LCase(Left(funcStr, 10)) = "structptr(" Then
'    retRef = Func_StructPtr((GetString(11, funcStr, ")")))

Else
    EvalFunction = False
End If

End Function


Public Function EvalUserFunc(ByVal funcStr As String, ByRef retRef As DataRefClass) As Boolean

Dim tmpName, paramStr As String
Dim tmpParamList As New ArrayClass
Dim paramRefList As New ArrayClass
Dim n As Long
Dim a As Long

EvalUserFunc = True
funcStr = Trim(funcStr)
Set retRef = New DataRefClass

For n = 1 To spDefList.itemCount
With spDefList.Item(n)
    If Left(LCase(funcStr), Len(.subProgName) + 1) = (LCase(.subProgName) & "(") Then
        If .isFunc Then
            'Get function name
            tmpName = GetString(1, funcStr, "(")
            'Get arguments
            paramStr = GetString(Len(tmpName) + 2, funcStr, ")")
            ParseParams paramStr, tmpParamList, ",", True
            
            'Resize paramRefList to tmpParamList size
            'For a = 1 To tmpParamList.itemCount
            '    paramRefList.Add Nothing
            'Next a
            
            'Check argument # against parameter #
            If tmpParamList.itemCount <> .paramNum Then
                CompileError "Wrong number of arguments for function " & .subProgName & "()"
                Exit Function
            End If
            
            For a = tmpParamList.itemCount To 1 Step -1
                'Evaluate each argument
                paramRefList.Add EvalExpression(tmpParamList.Item(a)), 1
                If exitFlag Then Exit Function
            Next a
            
            'Check argument types against parameter types
            For a = 1 To paramRefList.itemCount
                If paramRefList.Item(a).drType <> .varTypeList.Item(a) Then
                    CompileError "Type mismatch in argument " & CStr(a) & " of function " & .subProgName & "()"
                    Exit Function
                End If
            Next a
            'Write bytecode for function call
            '[C++ CONVERSION: Adjusted for Base0]
              GenByteCodeFL IDC_CALLSUBPROG, n - 1
            'Fill out return reference and exit
            retRef.drID = IDD_DATLST
            retRef.drIdx = 0
            retRef.drType = .varTypeList.Item(.paramNum + 1)
            Exit Function
        End If
    End If
End With
Next n

EvalUserFunc = False

End Function

Public Sub Cmd_Array(ByVal cmdStr As String)

Dim params As New ArrayClass
Dim arrayStrList As New ArrayClass
Dim nameStr As String
Dim idxStr As String
Dim idxList As New ArrayClass
Dim a As Long
Dim b As Long

cmdStr = Trim(cmdStr)

'Parse parameters
ParseParamsEx cmdStr, params, " as "
If params.itemCount <> 2 Then
    CompileError "Syntax error"
    Exit Sub
End If

'Parse array declarations
ParseParams params.Item(1), arrayStrList, ",", True

'Process each array
For a = 1 To arrayStrList.itemCount
    
    'Parse name
    nameStr = GetString(1, arrayStrList.Item(a), "(")
    If (Len(nameStr) = Len(arrayStrList.Item(a))) Or (Len(nameStr) + 1 = Len(arrayStrList.Item(a))) Then
        CompileError "Syntax error"
        Exit Sub
    End If
    
    'Parse dimensions
    idxStr = GetString(Len(nameStr) + 2, arrayStrList.Item(a), ")")
    If Len(nameStr) + Len(idxStr) + 1 = Len(arrayStrList.Item(a)) Then
        CompileError "Syntax error"
        Exit Sub
    End If
    
    ParseParams idxStr, idxList, ",", True
    
    If (idxList.itemCount < 1) Then
        CompileError "Array '" & nameStr & "' needs at least one dimension."
        Exit Sub
    End If
    
    For b = 1 To idxList.itemCount
        idxList.Item(b) = Trim(idxList.Item(b))
        If Not (IsNumeric(idxList.Item(b))) Then
            CompileError "Size of dimension " & CStr(b) & " in array '" & nameStr & "' must be an integer number"
            Exit Sub
        End If
        If Val(idxList.Item(b)) <= 0 Then
            CompileError "Size of dimension " & CStr(b) & " in array '" & nameStr & "' must be greater than zero"
            Exit Sub
        End If
    Next b
    
    nameStr = Trim(nameStr)
    
    'Check for a valid array name
    If NameCheck(nameStr) Then
        CompileError "Illegal array name: '" & nameStr & "'"
        Exit Sub
    End If
    
    With currDefObj
    
        'Check name against existing arrays (in current subprog)
        For b = 1 To .arrayNameList.itemCount
            If LCase(nameStr) = LCase(.arrayNameList.Item(b)) Then
                CompileError "Array '" & nameStr & "' already declared."
                Exit Sub
            End If
        Next b
        
        'Add array name
        .arrayNameList.Add nameStr
        
        'Add array type
        If LCase(params.Item(2)) = "string" Then
            .arrayTypeList.Add DT_STRING
        ElseIf LCase(params.Item(2)) = "number" Then
            .arrayTypeList.Add DT_NUMBER
        Else
            CompileError "Type '" & params.Item(2) & "' does not exist."
            Exit Sub
        End If
        
        'Add array dimensions
        .arrayDimNumList.Add idxList.itemCount
        .arrayDimValList.Add New ArrayClass
        For b = 1 To idxList.itemCount
            .arrayDimValList.Item(.arrayDimValList.itemCount).Add CLng(idxList.Item(b))
        Next b
        
        'Cleanup for next array declaration
        nameStr = ""
        idxStr = ""
        idxList.Clear
    
    End With
    
Next a

End Sub




Public Sub Cmd_Input(ByVal cmdStr As String)

Dim tmpParamList As New ArrayClass
Dim paramRefList As New ArrayClass

Dim varStr, expStr, tmpHandle As String
Dim expRef As DataRefClass
Dim destRef As DataRefClass

Dim a As Long
Dim b As Integer

cmdStr = Trim(cmdStr)
  
If Left(cmdStr, 1) = "#" Then

    'Get rid of '#'
    cmdStr = Trim(Right(cmdStr, Len(cmdStr) - 1))

    'Get arguments
    ParseParams cmdStr, tmpParamList, ",", True
    
    'Check argument # against parameter #
    If tmpParamList.itemCount <> 2 Then
        CompileError "Wrong number of arguments for command INPUT #"
        Exit Sub
    End If
    
    'Get variable/array reference
    paramRefList.Add CompileSubProgDataRef(tmpParamList.Item(2)), 1
    If exitFlag Then Exit Sub
    
    'Evaluate handle expression
    paramRefList.Add EvalExpression(tmpParamList.Item(1)), 1
    If exitFlag Then Exit Sub
    
    'Check argument type against parameter type
    If paramRefList.Item(1).drType <> DT_NUMBER Then
        CompileError "Type mismatch in argument " & CStr(a) & " of command INPUT #"
        Exit Sub
    End If
    
    'Write bytecode for command call
        '[C++ CONVERSION: Adjusted for Base0]
        GenByteCodeFL IDC_InputFieldFromFile, paramRefList.Item(2).drID, paramRefList.Item(2).drIdx - 1

Else

    'Get prompt expression (if present)
    expStr = GetString(1, cmdStr, ",")
    If Len(expStr) < Len(cmdStr) Then
        'If there is a prompt in the command, print it
        Cmd_Print expStr & ";"
        If exitFlag Then Exit Sub
        'Get variable/array name
        varStr = Mid(cmdStr, Len(expStr) + 2)
    Else
        'Get variable/array name
        varStr = cmdStr
    End If
    
    'Get variable/array reference
    Set destRef = CompileSubProgDataRef(varStr)
    If exitFlag Then Exit Sub
    
    'Write bytecode
      '[C++ CONVERSION: Adjusted for Base0]
      GenByteCodeFL IDC_InputFromConsol, destRef.drID, destRef.drIdx - 1

End If

End Sub

Public Sub Cmd_Print(ByVal cmdStr As String)

Dim tmpParamList As New ArrayClass
Dim paramRefList As New ArrayClass
Dim tmpHandle, tmpExp As String
Dim expRef As DataRefClass
Dim hasCR As Boolean
Dim a As Long

cmdStr = Trim(cmdStr)

If Right(cmdStr, 1) = ";" Then
    cmdStr = Trim(Left(cmdStr, Len(cmdStr) - 1))
    hasCR = False
Else
    hasCR = True
End If

If Left(cmdStr, 1) = "#" Then

    'Get rid of '#'
    cmdStr = Trim(Right(cmdStr, Len(cmdStr) - 1))

    'Get arguments
    ParseParams cmdStr, tmpParamList, ",", True
    
    'Check argument # against parameter #
    If tmpParamList.itemCount <> 2 Then
        CompileError "Wrong number of arguments for command PRINT #"
        Exit Sub
    End If
    
    For a = tmpParamList.itemCount To 1 Step -1
        'Evaluate each argument
        paramRefList.Add EvalExpression(tmpParamList.Item(a)), 1
        If exitFlag Then Exit Sub
    Next a
    
    'Check argument types against parameter types
    If paramRefList.Item(1).drType <> DT_NUMBER Then
        CompileError "Type mismatch in argument 1 of command PRINT #"
        Exit Sub
    End If
    
    'Write bytecode for command call
        GenByteCodeFL IDC_PrintToFile, CLng(hasCR)
    
Else
    
    If Not (cmdStr = "") Then
        Set expRef = EvalExpression(cmdStr)
        If exitFlag Then Exit Sub
        'Write bytecode
          GenByteCodeFL IDC_PrintToConsol
    End If
    If hasCR Then
        'Write bytecode
          GenByteCodeFL IDC_PrintBlank
    End If
    
End If

End Sub



Public Sub Cmd_Var(ByVal cmdStr As String)

Dim a As Long
Dim b As Long
Dim params As New ArrayClass
Dim varStrList As New ArrayClass

cmdStr = Trim(cmdStr)

'Parse parameters
ParseParamsEx cmdStr, params, " as "
If params.itemCount <> 2 Then
    CompileError "Syntax error"
    Exit Sub
End If

'Parse variable names
ParseParams params.Item(1), varStrList, ",", True

'Process each variable
For a = 1 To varStrList.itemCount
    
    'Check for valid variable name
    If NameCheck(varStrList.Item(a)) Then
        CompileError "Illegal variable name: '" & varStrList.Item(a) & "'"
        Exit Sub
    End If
    
    With currDefObj
    
        'Check name against existing variables (in current subprog)
        For b = 1 To .varNameList.itemCount
            If LCase(varStrList.Item(a)) = LCase(.varNameList.Item(b)) Then
                CompileError "Variable '" & varStrList.Item(a) & "' already declared"
                Exit Sub
            End If
        Next b
        
        'Add variable name
        .varNameList.Add varStrList.Item(a)
        
        'Add variable type
        If LCase(params.Item(2)) = "string" Then
            .varTypeList.Add DT_STRING
        ElseIf LCase(params.Item(2)) = "number" Then
            .varTypeList.Add DT_NUMBER
        Else
            CompileError "Type '" & params.Item(2) & "' does not exist."
            Exit Sub
        End If
    
    End With
    
Next a

End Sub



Public Function NameCheck(ByVal cmdStr As String) As Boolean

NameCheck = False

cmdStr = Trim(UCase(cmdStr))

'If Not ((Asc(Left(cmdStr, 1)) >= 65) And (Asc(Left(cmdStr, 1)) <= 90)) Then
'  NameCheck = True
'  Exit Function
'End If

'For n = 2 To Len(cmdStr)
'  If (Asc(Mid(cmdStr, n, 1)) < 65 Or Asc(Mid(cmdStr, n, 1)) > 90) And _
'  (Not (IsNumeric(Mid(cmdStr, n, 1)))) And Mid(cmdStr, n, 1) <> "_" Then
'    NameCheck = True
'    Exit Function
'  End If
'Next n

cmdStr = LCase(cmdStr)

If (cmdStr = "print") Or (cmdStr = "input") Or (cmdStr = "let") Or (cmdStr = "var") _
    Or (cmdStr = "if") Or (cmdStr = "else") Or (cmdStr = "elseif") Or (cmdStr = "end") _
    Or (cmdStr = "while") Or (cmdStr = "wend") Or (cmdStr = "for") Or (cmdStr = "next") _
    Or (cmdStr = "goto") Or (cmdStr = "gosub") Or (cmdStr = "return") Or (cmdStr = "consoltitle") _
    Or (cmdStr = "array") Or (cmdStr = "redim") Or (cmdStr = "bindvar") Or (cmdStr = "unbindvar") _
    Or (cmdStr = "sub") Or (cmdStr = "call") Or (cmdStr = "function") Or (cmdStr = "dim") _
    Or (cmdStr = "open") Or (cmdStr = "close") Or (cmdStr = "onerror") Or (cmdStr = "rem") _
    Or (cmdStr = "swap") Or (cmdStr = "on") Or (cmdStr = "data") Or (cmdStr = "read") _
    Or (cmdStr = "restore") Or (cmdStr = "select") Or (cmdStr = "case") Or (cmdStr = "textcolor") _
    Or (cmdStr = "bgcolor") Or (cmdStr = "pause") Or (cmdStr = "timer") Or (cmdStr = "stoptimer") _
    Or (cmdStr = "window") Or (cmdStr = "closewindow") Or (cmdStr = "event") Or (cmdStr = "message") _
    Or (cmdStr = "error") Or (cmdStr = "question") Or (cmdStr = "run") Or (cmdStr = "control") Then
      NameCheck = True
End If


End Function
Public Function CompileArrayRef(ByVal arrayStr As String) As DataRefClass

Dim n As Long

arrayStr = Trim(arrayStr)
Set CompileArrayRef = Nothing

'Check in local arrays
If currDefIdx > 1 Then
    With currDefObj
    For n = 1 To .arrayNameList.itemCount
        If LCase(arrayStr) = LCase(.arrayNameList.Item(n)) Then
            'Fill out return reference and exit
            Set CompileArrayRef = New DataRefClass
            CompileArrayRef.drID = IDD_LARRAYLST
            CompileArrayRef.drIdx = n
            CompileArrayRef.drType = .arrayTypeList.Item(n)
            Set CompileArrayRef.drSPDefRef = currDefObj
            Exit Function
        End If
    Next n
    End With
End If

'Check in global arrays
With spDefList.Item(1)
For n = 1 To .arrayNameList.itemCount
    If LCase(arrayStr) = LCase(.arrayNameList.Item(n)) Then
        'Fill out return reference and exit
        Set CompileArrayRef = New DataRefClass
        CompileArrayRef.drID = IDD_GARRAYLST
        CompileArrayRef.drIdx = n
        CompileArrayRef.drType = .arrayTypeList.Item(n)
        Set CompileArrayRef.drSPDefRef = spDefList.Item(1)
        Exit Function
    End If
Next n
End With

CompileError "Array '" & GetString(1, arrayStr, "(") & "()' has not been declared"

End Function

Public Function CompileLitRef(ByVal literalStr As String, ByVal literalType As Integer) As DataRefClass

Dim n As Long

Set CompileLitRef = New DataRefClass

For n = 1 To LiteralList.itemCount
    'Literal already exists?
    If literalStr = LiteralList.Item(n) Then
        CompileLitRef.drID = IDD_LITLST
        CompileLitRef.drIdx = n
        CompileLitRef.drType = literalType
        Exit Function
    End If
Next n

'Add new literal
LiteralList.Add literalStr
CompileLitRef.drID = IDD_LITLST
CompileLitRef.drIdx = LiteralList.itemCount
CompileLitRef.drType = literalType

End Function

Public Function CompileVarRef(ByVal varStr As String) As DataRefClass

Dim n As Long

varStr = Trim(varStr)
Set CompileVarRef = Nothing

'Check in local variables
If currDefIdx > 1 Then
    With currDefObj
    For n = 1 To .varNameList.itemCount
        If LCase(varStr) = LCase(.varNameList.Item(n)) Then
            Set CompileVarRef = New DataRefClass
            CompileVarRef.drID = IDD_LVARLST
            CompileVarRef.drIdx = n
            CompileVarRef.drType = .varTypeList.Item(n)
            Set CompileVarRef.drSPDefRef = currDefObj
            Exit Function
        End If
    Next n
    End With
End If

'Check in global variables
With spDefList.Item(1)
For n = 1 To .varNameList.itemCount
    If LCase(varStr) = LCase(.varNameList.Item(n)) Then
        Set CompileVarRef = New DataRefClass
        CompileVarRef.drID = IDD_GVARLST
        CompileVarRef.drIdx = n
        CompileVarRef.drType = .varTypeList.Item(n)
        Set CompileVarRef.drSPDefRef = spDefList.Item(1)
        Exit Function
    End If
Next n
End With

CompileError "Variable '" & varStr & "' has not been declared"

End Function


Public Function EvalExpression(ByVal expStr As String, Optional ByVal isBoolExp As Boolean = False) As DataRefClass

Dim operandList As New ArrayClass
Dim operandStr As String
Dim operatorList As New ArrayClass
Dim operatorStack As New ArrayClass
Dim operatorID As Long
Dim charIdx As Long
Dim inString As Boolean
Dim tmpStr As String
Dim a As Long

Set EvalExpression = New DataRefClass

If Trim(expStr) = "" Then Exit Function

'***************( PARSE OPERANDS )***************

For charIdx = 1 To Len(expStr)

    If Mid(expStr, charIdx, 1) = Chr(34) Then
      If inString = False Then inString = True Else inString = False
    End If

    If Not (inString) Then
        If Mid(expStr, charIdx, 1) = "(" Then
            tmpStr = GetString(charIdx + 1, expStr, ")")
            If charIdx + Len(tmpStr) = Len(expStr) Then
                CompileError "Syntax error"
                Exit Function
            End If
            operandStr = operandStr & "(" & tmpStr & ")"
            charIdx = charIdx + Len(tmpStr) + 1
            
        ElseIf CheckForOperator(expStr, charIdx, operatorID, isBoolExp) Then
            If operatorID = IDC_SUB Then
                If Len(Trim(operandStr)) > 0 Then
                    operandList.Add EvalOperand(operandStr, isBoolExp)
                    If exitFlag Then Exit Function
                    EvalOperator IDC_SUB, operatorStack
                    operatorList.Add IDC_SUB
                    
                Else
                    operandStr = operandStr & "-"
                    
                End If
                
            Else
                operandList.Add EvalOperand(operandStr, isBoolExp)
                If exitFlag Then Exit Function
                EvalOperator operatorID, operatorStack
                operatorList.Add operatorID
                
            End If
            
        Else
            operandStr = operandStr & Mid(expStr, charIdx, 1)
        
        End If
        
    Else
        operandStr = operandStr & Mid(expStr, charIdx, 1)
        
    End If
    
Next charIdx

operandList.Add EvalOperand(operandStr, isBoolExp)
If exitFlag Then Exit Function

Do While operatorStack.itemCount > 0
    GenByteCodeFL operatorStack.Item(1)
    operatorStack.Remove (1)
Loop
    
'************************************************


'***************( TYPE CHECK )***************

For a = operatorList.itemCount To 1 Step -1
    If operatorList.Item(a) = IDC_STRCON Then
        If Not ((operandList.Item(a).drType = DT_STRING) And (operandList.Item(a + 1).drType = DT_STRING)) Then
            'ERROR
            CompileError "Type mismatch": Exit Function
        End If
        EvalExpression.drType = DT_STRING
        
    ElseIf operatorList.Item(a) = IDC_ADD Then
        If operandList.Item(a).drType <> operandList.Item(a + 1).drType Then
            'ERROR
            CompileError "Type mismatch": Exit Function
        End If
        EvalExpression.drType = operandList.Item(a).drType
        
    ElseIf (operatorList.Item(a) >= IDC_EQUAL) And (operatorList.Item(a) <= IDC_NOTEQUAL) Then
        If operandList.Item(a).drType <> operandList.Item(a + 1).drType Then
            'ERROR
            CompileError "Type mismatch": Exit Function
        End If
        EvalExpression.drType = DT_NUMBER
        
    Else
        If Not ((operandList.Item(a).drType = DT_NUMBER) And (operandList.Item(a + 1).drType = DT_NUMBER)) Then
            'ERROR
            CompileError "Type mismatch": Exit Function
        End If
        EvalExpression.drType = DT_NUMBER
        
    End If
Next a

If operatorList.itemCount = 0 Then
    EvalExpression.drType = operandList.Item(1).drType
End If

'********************************************

'End result of expression evaluation
EvalExpression.drID = IDD_DATLST
EvalExpression.drIdx = 0

End Function

































Public Sub Compile()

'Parse raw source code into seperate sub programs
compileDlg.status.Caption = "Parsing source code..."
CreateSubProgs

'Compile sub program definitions
compileDlg.progress.Value = 0
compileDlg.progress.Min = 0
compileDlg.progress.Max = spDefList.itemCount
compileDlg.status.Caption = "Compiling program definitions..."
For currDefIdx = 1 To spDefList.itemCount
    compileDlg.progress.Value = currDefIdx
    Set currDefObj = spDefList.Item(currDefIdx)
    CompileSubProgDef
    If exitFlag Then Exit Sub
Next currDefIdx

'Compile sub program code
compileDlg.progress.Value = 0
compileDlg.progress.Min = 0
compileDlg.progress.Max = spDefList.itemCount
compileDlg.status.Caption = "Compiling program code..."
For currDefIdx = 1 To spDefList.itemCount
    compileDlg.progress.Value = currDefIdx
    Set currDefObj = spDefList.Item(currDefIdx)
    CompileSubProgCode
    If exitFlag Then Exit Sub
Next currDefIdx

'Assemble compiled definitions into runtime file
compileDlg.status.Caption = "Assembling program file..."
AssembleFile


End Sub


Public Sub CompileCmd(ByVal cmdStr As String)

cmdStr = Trim(cmdStr)

'Write bytecode for the debugging breakpoint
If rtMode = RTMODE_DEBUG Then
    '[C++ CONVERSION: Adjusted for Base0]
    GenByteCodeFL IDC_DebugBreakpoint, currDefObj.rawCodeIndexList.Item(currCodeLine) - 1
End If

If LCase(Left(cmdStr, 6)) = "print " Then
  Cmd_Print Mid(cmdStr, 7)

ElseIf LCase(cmdStr) = "print" Then
  Cmd_Print ""

ElseIf LCase(Left(cmdStr, 6)) = "input " Then
  Cmd_Input Mid(cmdStr, 7)

ElseIf LCase(Left(cmdStr, 4)) = "let " Then
  Cmd_Let Mid(cmdStr, 5)
  
ElseIf LCase(cmdStr) = "cls" Then
  GenByteCodeFL IDC_ClearConsol

ElseIf LCase(Left(cmdStr, 5)) = "goto " Then
  Cmd_Goto Mid(cmdStr, 6)

ElseIf LCase(Left(cmdStr, 6)) = "gosub " Then
  Cmd_GoSub Mid(cmdStr, 7)

ElseIf LCase(cmdStr) = "return" Then
  GenByteCodeFL IDC_RETURN

ElseIf LCase(Left(cmdStr, 3)) = "if " Then
  Cmd_If Mid(cmdStr, 4)
  
'Check for End If outside of If block
ElseIf LCase(cmdStr) = "end if" Then
    CompileError "End IF without matching If statement."
    
'Check for Else outside of If block
ElseIf LCase(cmdStr) = "else" Then
    CompileError "Else without matching If statement."
  
'Check for ElseIf outside of If block
ElseIf LCase(Left(cmdStr, 7)) = "elseif " Then
    CompileError "ElseIf without matching If statement."

ElseIf LCase(Left(cmdStr, 4)) = "for " Then
  Cmd_For Mid(cmdStr, 5)
  
'Check for ElseIf outside of If block
ElseIf LCase(Left(cmdStr, 5)) = "next " Then
    CompileError "Next without matching For statement."
  
ElseIf LCase(Left(cmdStr, 5)) = "call " Then
  Cmd_Call Mid(cmdStr, 6)
  
ElseIf LCase(Trim(cmdStr)) = "showconsol" Then
  GenByteCodeFL IDC_ShowConsol
  
ElseIf LCase(Trim(cmdStr)) = "hideconsol" Then
  GenByteCodeFL IDC_HideConsol

ElseIf LCase(Trim(cmdStr)) = "inputevents" Then
  GenByteCodeFL IDC_InputEvents

ElseIf LCase(Trim(cmdStr)) = "flushevents" Then
  GenByteCodeFL IDC_FlushEvents
  
ElseIf LCase(Left(cmdStr, 6)) = "pause " Then
  Cmd_Pause Mid(cmdStr, 7)
  
ElseIf LCase(cmdStr) = "end" Then
  GenByteCodeFL IDC_End
  
ElseIf LCase(Left(cmdStr, 5)) = "open " Then
  Cmd_Open Mid(cmdStr, 6)
  
ElseIf LCase(Left(cmdStr, 6)) = "close " Then
  Cmd_Close Mid(cmdStr, 7)
  
ElseIf LCase(Left(cmdStr, 5)) = "seek " Then
  Cmd_Seek Mid(cmdStr, 6)
  
ElseIf LCase(Left(cmdStr, 11)) = "line input " Then
  Cmd_LineInput Mid(cmdStr, 12)
  
ElseIf LCase(Left(cmdStr, 8)) = "message " Then
  Cmd_Message Mid(cmdStr, 9)
  
ElseIf LCase(Left(cmdStr, 8)) = "onerror " Then
  Cmd_OnError Mid(cmdStr, 9)
  
ElseIf LCase(Left(cmdStr, 6)) = "redim " Then
  Cmd_Redim Mid(cmdStr, 7)

ElseIf LCase(Left(cmdStr, 12)) = "consoltitle " Then
  Cmd_ConsolTitle Mid(cmdStr, 13)
  
ElseIf LCase(Left(cmdStr, 9)) = "redimadd " Then
  Cmd_RedimAdd Mid(cmdStr, 10)
  
ElseIf LCase(Left(cmdStr, 12)) = "redimremove " Then
  Cmd_RedimRemove Mid(cmdStr, 13)
  
ElseIf LCase(Left(cmdStr, 6)) = "while " Then
  Cmd_While Mid(cmdStr, 7)
  
ElseIf LCase(Trim(cmdStr)) = "exit for" Then
  Cmd_ExitFor

ElseIf LCase(Trim(cmdStr)) = "exit while" Then
  Cmd_ExitWhile
  
ElseIf LCase(Trim(cmdStr)) = "exit sub" Then
  Cmd_ExitSub

ElseIf LCase(Trim(cmdStr)) = "exit function" Then
  Cmd_ExitFunction

'ElseIf LCase(Left(cmdStr, 5)) = "swap " Then
  'Cmd_Swap Mid(cmdStr, 6)
'ElseIf LCase(Left(cmdStr, 3)) = "on " Then
  'Cmd_On Mid(cmdStr, 4)
'ElseIf LCase(Left(cmdStr, 5)) = "read " Then
  'Cmd_Read Mid(cmdStr, 6)
'ElseIf LCase(Left(cmdStr, 5)) = "data " Then
  'Cmd_Data Mid(cmdStr, 6)
'ElseIf LCase(Left(cmdStr, 8)) = "restore " Then
  'Cmd_Restore Mid(cmdStr, 9)
'ElseIf LCase(cmdStr) = "restore" Then
  'NOOP
'ElseIf LCase(Left(cmdStr, 10)) = "textcolor " Then
  'Cmd_TextColor Mid(cmdStr, 11)
'ElseIf LCase(Left(cmdStr, 8)) = "bgcolor " Then
  'Cmd_BGColor Mid(cmdStr, 9)
'ElseIf LCase(Left(cmdStr, 6)) = "timer " Then
  'Cmd_Timer Mid(cmdStr, 7)
'ElseIf LCase(Left(cmdStr, 10)) = "stoptimer " Then
  'Cmd_StopTimer Mid(cmdStr, 11)
'ElseIf LCase(Left(cmdStr, 9)) = "question " Then
  'Cmd_Question Mid(cmdStr, 10)
'ElseIf LCase(Left(cmdStr, 6)) = "error " Then
  'Cmd_Message Mid(cmdStr, 7)
'ElseIf LCase(Left(cmdStr, 4)) = "run " Then
  'Cmd_Run Mid(cmdStr, 5)
'ElseIf LCase(Trim(cmdStr)) = "beep" Then
  'NOOP
'ElseIf LCase(Left(cmdStr, 9)) = "getfiles " Then
  'Cmd_GetFiles Mid(cmdStr, 10)
'ElseIf LCase(Left(cmdStr, 8)) = "getdirs " Then
  'Cmd_GetDirs Mid(cmdStr, 9)
'ElseIf LCase(Left(cmdStr, 5)) = "name " Then
 'Cmd_Name Mid(cmdStr, 6)
'ElseIf LCase(Left(cmdStr, 6)) = "mkdir " Then
  'Cmd_MkDir Mid(cmdStr, 7)
'ElseIf LCase(Left(cmdStr, 6)) = "rmdir " Then
  'Cmd_RmDir Mid(cmdStr, 7)
'ElseIf LCase(Left(cmdStr, 11)) = "getmousepos " Then
  'Cmd_GetMousePos Mid(cmdStr, 12)
'ElseIf LCase(Left(cmdStr, 4)) = "mid " Then
  'Cmd_Mid Mid(cmdStr, 5)
'ElseIf LCase(Left(cmdStr, 5)) = "kill " Then
  'Cmd_Kill Mid(cmdStr, 6)


ElseIf Left(cmdStr, 1) = "@" Then
    Cmd_Label
  

    
'
  
'This checks to see if a variable or array is being assigned
'a value, in which case the line is passed to the Let command
Else
    'If there isn't an equal sign in the command
    If Len(GetString(1, cmdStr, "=")) = Len(cmdStr) Then
        CompileError "Syntax error"
    'If there is an equal sign in the command
    Else
        Cmd_Let cmdStr
    End If

End If

End Sub


Public Sub CompileSubProgDef()

'Dim varLneNumList As New ArrayClass
'Dim arrayLneNumList As New ArrayClass
Dim tmpIdxList As New ArrayClass
Dim n As Long
Dim paramList As New ArrayClass
Dim spParamList As New ArrayClass
Dim tmpName As String
Dim tmpParams As String
Dim tmpType As String

With currDefObj

'Process sub/function definition/params (if not main subprog)
If currDefIdx > 1 Then

  'Parse out subprog name, parameters, and return type
    ParseParamsEx .sourceCodeList.Item(1), paramList, "(", ")"
    If (paramList.itemCount < 2) Or (paramList.itemCount > 3) Then
        CompileError "Syntax error", .rawCodeIndexList.Item(1): Exit Sub
    End If
    
  'Add parameter variables
    ParseParams paramList.Item(2), spParamList, ",", True
    .paramNum = spParamList.itemCount
    For n = 1 To spParamList.itemCount
        Cmd_Var spParamList.Item(n)
    Next n
    
  'Add return variable
    If .isFunc Then
        If paramList.itemCount <> 3 Then
            CompileError "Must specify a return type for this function.", .rawCodeIndexList.Item(1)
            Exit Sub
        End If
        paramList.Item(1) = Trim(Mid(paramList.Item(1), 9))
        Cmd_Var paramList.Item(1) & " " & paramList.Item(3)
    Else
        paramList.Item(1) = Trim(Mid(paramList.Item(1), 4))
    End If
    .subProgName = paramList.Item(1)
    .sourceCodeList.Remove 1
    .rawCodeIndexList.Remove 1
End If

'Compile variable/array definitions, and store each
'line number for removal
For currCodeLine = 1 To .sourceCodeList.itemCount
    If LCase(Left(.sourceCodeList.Item(currCodeLine), 4)) = "var " Then
        Cmd_Var Mid(.sourceCodeList.Item(currCodeLine), 5)
        tmpIdxList.Add currCodeLine
    ElseIf LCase(Left(.sourceCodeList.Item(currCodeLine), 6)) = "array " Then
        Cmd_Array Mid(.sourceCodeList.Item(currCodeLine), 7)
        tmpIdxList.Add currCodeLine
    ElseIf LCase(Left(.sourceCodeList.Item(currCodeLine), 4)) = "dim " Then
        Cmd_Array Mid(.sourceCodeList.Item(currCodeLine), 5)
        tmpIdxList.Add currCodeLine
    End If
    If exitFlag Then Exit Sub
Next currCodeLine

'Remove variable/array definition lines
For n = tmpIdxList.itemCount To 1 Step -1
    .sourceCodeList.Remove tmpIdxList.Item(n)
    .rawCodeIndexList.Remove tmpIdxList.Item(n)
    tmpIdxList.Remove n
Next n

'Compile branch label names
For n = 1 To .sourceCodeList.itemCount
    If Left(.sourceCodeList.Item(n), 1) = "@" Then
        .labelNameList.Add Trim(.sourceCodeList.Item(n))
    End If
Next n

End With

End Sub





Public Sub Cmd_Label()

'Add location of next byte-code command to labelLocList
With currDefObj
    .labelLocList.Add (.byteCodeList.itemCount + 1)
End With

End Sub













Public Sub ParseParams(ByVal paramStr As String, ByRef paramList As ArrayClass, ByVal delimStr As String, ByVal trimParams As Boolean)

Dim b As Integer
Dim tmpParam As String

b = 1
While b <= Len(paramStr)
    tmpParam = GetString(b, paramStr, delimStr)
    b = Len(tmpParam) + b + 1
    If trimParams Then
        paramList.Add Trim(tmpParam)
    Else
        paramList.Add tmpParam
    End If
Wend

End Sub


Public Sub ParseParamsEx(ByVal paramStr As String, ByRef paramList As ArrayClass, ParamArray delimList())

Dim a As Long
Dim b As Long
Dim tmpParam As String

'Init paramStr position
b = 1

'Loop through each delimiter
For a = LBound(delimList) To UBound(delimList)
    tmpParam = GetString(b, LCase(paramStr), LCase(delimList(a)))
    tmpParam = Mid(paramStr, b, Len(tmpParam))
    paramList.Add Trim(tmpParam)
    b = Len(tmpParam) + b + Len(delimList(a))
    If b > Len(paramStr) Then Exit Sub
Next a

'Add remaining bit of paramStr
paramList.Add Trim(Mid(paramStr, b))

End Sub
Public Function GetString(ByVal start As Integer, ByVal str As String, ByVal endStr As String) As String

'This sub sections out a substring from within the given string,
'starting at the given point, ending at the given character,
'and not counting any character within parentheses or quotes.

Dim inString As Boolean
Dim parNum As Integer

inString = False
parNum = 0

For a = start To Len(str)

  If Mid(str, a, Len(endStr)) = endStr Then
    If (parNum = 0) And (inString = False) Then
      Exit Function
    End If
  End If
  
  If Mid(str, a, 1) = Chr(34) Then
    If inString = False Then inString = True Else inString = False
  End If
  
  If Mid(str, a, 1) = "(" And inString = False Then
    parNum = parNum + 1
  ElseIf Mid(str, a, 1) = ")" And inString = False Then
    If parNum > 0 Then parNum = parNum - 1
  End If
  
  GetString = GetString & Mid(str, a, 1)
  
Next a

End Function
Public Sub AssembleFile()

Dim eDat As String
Dim n As Long

rawData = ""

'Write version number
WriteRawData versionStr

'Write runtime mode
WriteRawData CStr(rtMode)

'Write working directory
If rtMode <> RTMODE_DEPLOY Then
    WriteRawData workingDir
Else
    WriteRawData ""
End If

'Write source code for Debug mode
If rtMode = RTMODE_DEBUG Then
    WriteRawData CStr(rawSourceCodeList.itemCount)
    For n = 1 To rawSourceCodeList.itemCount
        WriteRawData rawSourceCodeList.Item(n)
    Next n
End If

'Write literals
WriteRawData CStr(LiteralList.itemCount)
For n = 1 To LiteralList.itemCount
    If IsNumeric(LiteralList.Item(n)) Then
        WriteRawData CStr(DT_NUMBER)
    Else
        WriteRawData CStr(DT_STRING)
    End If
    WriteRawData CStr(LiteralList.Item(n))
Next n

'Write subprog data
WriteRawData CStr(spDefList.itemCount)
For n = 1 To spDefList.itemCount
    AssembleSubProg n
Next n

'Write unencrypted MBR file
'Open App.Path & "\MBRData.txt" For Output As #1
'    Print #1, rawData;
'Close #1

'Encrypt raw data
eDat = ETask(rawData)

'Clear raw data
rawData = ""

'Write final program data
If rtMode = RTMODE_DEPLOY Then
    AppendToFile rtExeFile, eDat
Else
    Open ParseFilePath(rtExeFile) & "\mbcDat.mbr" For Output As #1
        Print #1, eDat;
    Close #1
End If

End Sub


Public Function ParseFilePath(ByVal fName As String) As String

Dim pathLen As Long
Dim n As Long

For n = Len(fName) To 1 Step -1
    If Mid(fName, n, 1) = "\" Then
        pathLen = n - 1
        Exit For
    End If
Next n

ParseFilePath = Mid(fName, 1, pathLen)

End Function
Public Function ETask(ByVal dat As String) As String

Dim eData, eKey, tmpDat As String

Randomize
eKey = Chr(Int((Rnd * 10) + 10))

'Add key and beginning padding
For n = 1 To 10
    Randomize
    eData = eData & Chr(Int((Rnd * 127) + 1))
Next n
eData = eData & eKey
For n = 1 To 8
    Randomize
    eData = eData & Chr(Int((Rnd * 127) + 1))
Next n

'Add encrypted data
For n = 1 To Len(dat)
    tmpDat = tmpDat & Chr(Asc(Mid(dat, n, 1)) + Asc(eKey))
Next n
For n = 1 To Len(tmpDat) Step 2
    Mid(tmpDat, n, 1) = Chr(Asc(Mid(tmpDat, n, 1)) - 3)
Next n
eData = eData & tmpDat

'Add end padding
For n = 1 To 10
    Randomize
    eData = eData & Chr(Int((Rnd * 127) + 1))
Next n

ETask = eData

End Function


Public Sub CompileError(ByVal msgStr As String, Optional ByVal daLine As Long)

If daLine = 0 Then
    daLine = currDefObj.rawCodeIndexList.Item(currCodeLine)
End If

resultVal = daLine
resultStr = "Compile error on line " & daLine & ": " & msgStr

exitFlag = True

End Sub


Public Sub AssembleSubProg(ByVal spIdx As Long)

Dim b As Long
Dim c As Long

With spDefList.Item(spIdx)
    'Write subprog name
    If rtMode = RTMODE_DEBUG Then
        WriteRawData .subProgName
    End If
    
    'Write function flag
    WriteRawData CStr(.isFunc)
    
    'Write parameter count
    WriteRawData CStr(.paramNum)
    
    'Write variable definitions
    WriteRawData CStr(.varTypeList.itemCount)
    For b = 1 To .varTypeList.itemCount
        If rtMode = RTMODE_DEBUG Then
            WriteRawData .varNameList.Item(b)
        End If
        WriteRawData CStr(.varTypeList.Item(b))
    Next b
    
    'Write array definitions
    WriteRawData CStr(.arrayTypeList.itemCount)
    For b = 1 To .arrayTypeList.itemCount
        If rtMode = RTMODE_DEBUG Then
            WriteRawData .arrayNameList.Item(b)
        End If
        WriteRawData CStr(.arrayTypeList.Item(b))
        WriteRawData CStr(.arrayDimNumList.Item(b))
        For c = 1 To .arrayDimValList.Item(b).itemCount
          WriteRawData CStr(.arrayDimValList.Item(b).Item(c))
        Next c
    Next b
    
    'Write bytecode commands
    WriteRawData CStr(.byteCodeList.itemCount)
    For b = 1 To .byteCodeList.itemCount
        WriteRawData CStr(.byteCodeList.Item(b).itemCount)
        For c = 1 To .byteCodeList.Item(b).itemCount
            WriteRawData CStr(.byteCodeList.Item(b).Item(c))
        Next c
    Next b
End With

End Sub


Public Sub SplitLines(ByVal textStr As String, ByRef lineList As ArrayClass)

Dim n As Long
Dim tmpStr As String

For n = 1 To Len(textStr)
    If Mid(textStr, n, 2) = vbCrLf Then
        lineList.Add tmpStr
        tmpStr = ""
        n = n + 1
    Else
        tmpStr = tmpStr & Mid(textStr, n, 1)
    End If
Next n

If Trim(tmpStr) <> "" Then lineList.Add tmpStr

End Sub


Public Sub WriteRawData(ByVal newDat As String)

rawData = rawData & newDat & vbLf

End Sub


