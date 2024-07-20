Attribute VB_Name = "AssemblerCode"
Public LiteralList As New ArrayClass
Public spDefList As New ArrayClass

Public isChanged As Boolean

Public rawDat As String
Public currSpIdx As Long
Public currLine As Long

Public Sub AssembleCmd(ByVal cmdStr As String)

Dim params As New ArrayClass
Dim n As Long

cmdStr = Trim(cmdStr)

ParseParams cmdStr, params

rawDat = rawDat & CStr(params.itemCount) & vbCrLf

Select Case LCase(params.Item(1))
    Case "addexp"
        rawDat = rawDat & CStr(IDI_ADDEXP) & vbCrLf

    Case "removeexp"
        rawDat = rawDat & CStr(IDI_REMOVEEXP) & vbCrLf

    Case "clearexpstack"
        rawDat = rawDat & CStr(IDI_CLEAREXPSTACK) & vbCrLf

    Case "adddata"
        rawDat = rawDat & CStr(IDI_ADDDATA) & vbCrLf

    Case "removedata"
        rawDat = rawDat & CStr(IDI_REMOVEDATA) & vbCrLf

    Case "cleardatastack"
        rawDat = rawDat & CStr(IDI_CLEARDATASTACK) & vbCrLf

    Case "copydata"
        rawDat = rawDat & CStr(IDI_COPYDATA) & vbCrLf

    Case "callsubprog"
        rawDat = rawDat & CStr(IDI_CALLSUBPROG) & vbCrLf

    Case "printtoconsol"
        rawDat = rawDat & CStr(IDG_PrintToConsol) & vbCrLf

    Case "inputfromconsol"
        rawDat = rawDat & CStr(IDG_InputFromConsol) & vbCrLf

    Case "showconsol"
        rawDat = rawDat & CStr(IDG_ShowConsol) & vbCrLf

    Case "hideconsol"
        rawDat = rawDat & CStr(IDG_HideConsol) & vbCrLf
    Case Else
        MsgBox "Error on line " & CStr(currLine) & " of SubProg " & CStr(currSpIdx), vbCritical, "Assembly Error"
        Exit Sub
End Select

For n = 2 To params.itemCount
    rawDat = rawDat & CStr(params.Item(n)) & vbCrLf
Next n

End Sub






























Public Function GetConstVal(ByVal idTag As Variant) As Variant

'Returns the value of the constant given by idTag.
'If idTag is not a valid constant name, idTag is returned.

idTag = Trim(idTag)

Select Case idTag
    
    Case Else
        GetConstVal = idTag
End Select

End Function

Public Sub ParseParams(ByVal paramStr As String, ByRef paramList As ArrayClass)

Dim b As Integer
Dim tmpParam As String

b = 1
While b <= Len(paramStr)
    tmpParam = GetString(b, paramStr, ",")
    b = Len(tmpParam) + b + 1
    paramList.Add Trim(tmpParam)
Wend

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
    If parNum = 0 And inString = False Then
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

Dim n As Long
Dim eDat As String

rawDat = ""

'Write literals
asmWin.status.Caption = "Assembling literals..."
rawDat = rawDat & CStr(LiteralList.itemCount) & vbCrLf
For n = 1 To LiteralList.itemCount
    rawDat = rawDat & CStr(LiteralList.Item(n)) & vbCrLf
Next n

'Write subprog data
asmWin.status.Caption = "Assembling sub programs..."
rawDat = rawDat & CStr(spDefList.itemCount) & vbCrLf
For n = 1 To spDefList.itemCount
    AssembleSubProg n
Next n

'Encrypt raw data
asmWin.status.Caption = "Encrypting data..."
eDat = ETask(rawDat)

'Write final program data to file
asmWin.status.Caption = "Writing bytecode file..."
Open App.Path & "\Runtime.mbr" For Output As #1
    Print #1, eDat;
Close #1

asmWin.status.Caption = "Assembly Complete."
asmWin.Command1.Enabled = True

End Sub


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
    eData = eData & Chr(Int((Rnd * 127) + 1))
Next n

ETask = eData

End Function
Public Sub AssembleSubProg(ByVal spIdx As Long)

Dim b As Long
Dim c As Long
Dim listArray As New ArrayClass

currSpIdx = spIdx

With spDefList.Item(spIdx)
    'Write subprog name
    rawDat = rawDat & .subProgName & vbCrLf
    
    'Write parameter count
    rawDat = rawDat & CStr(.paramNum) & vbCrLf
    
    'Write variable definitions
    rawDat = rawDat & CStr(.varTypeList.itemCount) & vbCrLf
    For b = 1 To .varTypeList.itemCount
        rawDat = rawDat & CStr(.varTypeList.Item(b)) & vbCrLf
    Next b
    
    'Write array definitions
    rawDat = rawDat & CStr(.arrayTypeList.itemCount) & vbCrLf
    For b = 1 To .arrayTypeList.itemCount
        rawDat = rawDat & CStr(.arrayTypeList.Item(b)) & vbCrLf
        rawDat = rawDat & CStr(.arrayDimNumList.Item(b)) & vbCrLf
        For c = 1 To .arrayDimNumList.Item(b)
          rawDat = rawDat & CStr(.arrayDimValList.Item(b).Item(c)) & vbCrLf
        Next c
    Next b
    
    'Write branch label line #s
    rawDat = rawDat & CStr(.labelLineList.itemCount) & vbCrLf
    For b = 1 To .labelLineList.itemCount
        rawDat = rawDat & CStr(.labelLineList.Item(b)) & vbCrLf
    Next b
    
    'Split codeText into lines
    SplitLines .codeText, listArray
    
    'Cut out comment lines
    For b = listArray.itemCount To 1 Step -1
        If Left(listArray.Item(b), 1) = "'" Then
            listArray.Remove b
        End If
    Next b
    
    'Convert and write each command
    rawDat = rawDat & CStr(listArray.itemCount) & vbCrLf
    For currLine = 1 To listArray.itemCount
        AssembleCmd listArray.Item(currLine)
    Next currLine
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

Public Sub SaveProgData(ByVal fName As String)

Dim a As Long
Dim b As Long
Dim c As Long
Dim tmpCount1 As Long
Dim tmpCount2 As Long
Dim tmpCount3 As Long
Dim tmpStr As String

Open fName For Output As #1
    'Save literals
    Print #1, LiteralList.itemCount
    For a = 1 To LiteralList.itemCount
        Print #1, LiteralList.Item(a)
    Next a
    
    'Save subProg definitions from spDefList() objects
    Print #1, spDefList.itemCount
    For a = 1 To spDefList.itemCount
        With spDefList.Item(a)
      'Save SubProg name
        Print #1, .subProgName
      'Save number of parameters
        Print #1, .paramNum
      'Save varable definitions
        Print #1, .varTypeList.itemCount
        For b = 1 To .varTypeList.itemCount
            Print #1, .varNameList.Item(b)
            Print #1, .varTypeList.Item(b)
        Next b
      'Save array definitions
        Print #1, .arrayTypeList.itemCount
        For b = 1 To .arrayTypeList.itemCount
            Print #1, .arrayNameList.Item(b)
            Print #1, .arrayTypeList.Item(b)
            Print #1, .arrayDimNumList.Item(b)
            For c = 1 To .arrayDimNumList.Item(b)
                Print #1, .arrayDimValList.Item(b).Item(c)
            Next c
        Next b
      'Save branch label line #s
        Print #1, .labelLineList.itemCount
        For b = 1 To .labelLineList.itemCount
            Print #1, .labelLineList.Item(b)
        Next b
      'Save code text
        Print #1, Len(.codeText)
        Print #1, .codeText;
        End With
    Next a
Close #1

End Sub


Public Sub LoadProgData(ByVal fName As String)

Dim a As Long
Dim b As Long
Dim c As Long
Dim tmpCount1 As Long
Dim tmpCount2 As Long
Dim tmpCount3 As Long
Dim tmpStr As String

Open fName For Input As #1
    'Load literals
    Input #1, tmpCount1
    For a = 1 To tmpCount1
        Input #1, tmpStr
        LiteralList.Add tmpStr
    Next a
    'Load subProg definitions into spDefList() objects
    Input #1, tmpCount1
    For a = 1 To tmpCount1
        spDefList.Add New SubProgDefClass
        With spDefList.Item(spDefList.itemCount)
      'Load SubProg name
        Input #1, tmpStr
        .subProgName = tmpStr
        notepad.spList.AddItem .subProgName
      'Load number of parameters
        Input #1, tmpStr
        .paramNum = Val(tmpStr)
      'Load varable definitions
        Input #1, tmpCount2
        For b = 1 To tmpCount2
            Input #1, tmpStr
            .varNameList.Add tmpStr
            Input #1, tmpStr
            .varTypeList.Add Val(tmpStr)
        Next b
      'Load array definitions
        Input #1, tmpCount2
        For b = 1 To tmpCount2
            Input #1, tmpStr
            .arrayNameList.Add tmpStr
            Input #1, tmpStr
            .arrayTypeList.Add Val(tmpStr)
            Input #1, tmpCount3
            .arrayDimNumList.Add tmpCount3
            .arrayDimValList.Add New ArrayClass
            For c = 1 To tmpCount3
                Input #1, tmpStr
                .arrayDimValList.Item(.arrayDimValList.itemCount).Add Val(tmpStr)
            Next c
        Next b
      'Load branch label line #s
        Input #1, tmpCount2
        For b = 1 To tmpCount2
            Input #1, tmpStr
            .labelLineList.Add Val(tmpStr)
        Next b
      'Load code text
        Input #1, tmpCount2
        .codeText = Input(tmpCount2, 1)
        End With
    Next a
Close #1

End Sub
