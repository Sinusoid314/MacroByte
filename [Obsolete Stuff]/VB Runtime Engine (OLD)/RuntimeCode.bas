Attribute VB_Name = "RuntimeCode"
Public Declare Sub Sleep Lib "kernel32" (ByVal dwMilliseconds As Long)
Public Declare Function SetTimer Lib "user32" (ByVal hwnd As Long, ByVal nIDEvent As Long, ByVal uElapse As Long, ByVal lpTimerFunc As Long) As Long
Public Declare Function KillTimer Lib "user32" (ByVal hwnd As Long, ByVal nIDEvent As Long) As Long
Public Declare Function mciSendString Lib "winmm.dll" Alias "mciSendStringA" (ByVal lpstrCommand As String, ByVal lpstrReturnString As String, ByVal uReturnLength As Long, ByVal hwndCallback As Long) As Long
Public Declare Function GetShortPathName Lib "kernel32" Alias "GetShortPathNameA" (ByVal lpszLongPath As String, ByVal lpszShortPath As String, ByVal cchBuffer As Long) As Long

'Runtime data reference lists (global)
Public ArrayIdxStack As New ArrayClass
Public ExpStack As New ArrayClass     '(dynamic)
Public DataStack As New ArrayClass   '(dynamic)
Public LiteralList As New ArrayClass '(static)

'FUNCTION and SUB definitions
Public spDefList As New ArrayClass '(list of SubProgDefClass objects)
Public spList As New ArrayClass '(list of SubProgClass objects)

'Runtime variables
Public userInput As String
Public inputting As Boolean
Public progDone As Boolean
Public errorFlag As Boolean

'Main code block
Public mainSubProg As SubProgClass


Sub Main()

RuntimeSetup

App.Title = App.EXEName
consol.Caption = "Running: " & App.EXEName
consol.Show

mainSubProg.RunProg

RuntimeCleanup

consol.Caption = "Execution complete: " & App.EXEName
consol.display.SelStart = Len(consol.display.Text)

If (Not consol.Visible) Then End

End Sub


Public Sub LoadSubProg(ByVal spIdx As Integer)

'Loads a subprogram definition onto the top of spList()

Dim spObj As SubProgClass

If spIdx = 1 Then
    Set mainSubProg = New SubProgClass
    Set spObj = mainSubProg
Else
    spList.Add New SubProgClass
    Set spObj = spList.Item(spList.itemCount)
End If

With spDefList.Item(spIdx)
  'Load variables
    For a = 1 To .varTypeList.itemCount
        Select Case .varTypeList.Item(a)
            Case DT_NUMBER
                spObj.varList.Add 0
            Case DT_STRING
                spObj.varList.Add ""
        End Select
    Next a
  'Load arrays
    For a = 1 To .arrayTypeList.itemCount
        spObj.arrayList.Add New ArrayClass
        spObj.arrayDimNumList.Add .arrayDimNumList.Item(a)
        Select Case .arrayDimNumList.Item(a)
            'One-dimensional array
            Case 1
                Select Case .arrayTypeList.Item(a)
                    Case DT_NUMBER
                        For b = 1 To .arrayDimValList.Item(a).Item(1)
                            spObj.arrayList.Item(a).Add 0
                        Next b
                    Case DT_STRING
                        For b = 1 To .arrayDimValList.Item(a).Item(1)
                            spObj.arrayList.Item(a).Add ""
                        Next b
                End Select
            'Two-dimensional array
            Case 2
                Select Case .arrayTypeList.Item(a)
                    Case DT_NUMBER
                        For b = 1 To .arrayDimValList.Item(a).Item(1)
                            spObj.arrayList.Item(a).Add New ArrayClass
                            For c = 1 To .arrayDimValList.Item(a).Item(2)
                                spObj.arrayList.Item(a).Item(b).Add 0
                            Next c
                        Next b
                    Case DT_STRING
                        For b = 1 To .arrayDimValList.Item(a).Item(1)
                            spObj.arrayList.Item(a).Add New ArrayClass
                            For c = 1 To .arrayDimValList.Item(a).Item(2)
                                spObj.arrayList.Item(a).Item(b).Add ""
                            Next c
                        Next b
                End Select
        End Select
    Next a
  'Load parameter count
    spObj.paramNum = .paramNum
  'Load isFunc flag
    spObj.isFunc = .isFunc
  'Load code list
    For a = 1 To .codeList.itemCount
        spObj.codeList.Add .codeList.Item(a)
    Next a
  'Load parameter values from the stack
    For a = 1 To .paramNum
        spObj.varList.Item(a) = DataStack.Item(1)
        DataStack.Remove 1
    Next a
End With

End Sub

Public Sub ReadRunFile()

Dim dData As String
Dim fileStr As String
Dim dat As String
Dim n As Long
Dim listArray As New ArrayClass
Dim tmpCount1 As Long
Dim tmpCount2 As Long
Dim tmpCount3 As Long
Dim a As Integer
Dim b As Integer
Dim c As Integer
Dim listPos As Long
Dim tmpVal As Long

If Dir(App.Path & "\" & App.EXEName & ".mbr") <> "" Then
    'Extract code form MBR file
    Open App.Path & "\" & App.EXEName & ".mbr" For Binary As #1
        dat = Input(LOF(1), 1)
    Close #1
Else
    'Open the EXE
    Open App.Path & "\" & App.EXEName & ".exe" For Binary As #1
        fileStr = Space(LOF(1))
        Get #1, , fileStr
        'fileStr = Input(LOF(1), 1) 'Too sloooooooooowwwww
    Close #1
    'Get the position of the code
    n = InStr(1, fileStr, "lib")
    If n = 0 Then Exit Sub
    'Extract the code
    dat = Mid(fileStr, n + 3)
End If

'Decrypt the code
dData = DTask(dat)

'Split up the data/code into lines
SplitLines dData, listArray

'Load literals
tmpCount1 = Val(listArray.Item(1))
listPos = 2
For a = 1 To tmpCount1
    tmpVal = listArray.Item(listPos)
    listPos = listPos + 1
    Select Case tmpVal
        Case DT_NUMBER
            LiteralList.Add Val(listArray.Item(listPos))
        Case DT_STRING
            LiteralList.Add CStr(listArray.Item(listPos))
    End Select
    listPos = listPos + 1
Next a

'Load subProg definitions into spDefList() objects
tmpCount1 = Val(listArray.Item(listPos))
listPos = listPos + 1
For a = 1 To tmpCount1
    spDefList.Add New SubProgDefClass
    With spDefList.Item(spDefList.itemCount)
  'Load SubProg name
    .subProgName = listArray.Item(listPos)
    listPos = listPos + 1
  'Load isFunc flag
    .isFunc = Val(listArray.Item(listPos))
    listPos = listPos + 1
  'Load number of parameters
    .paramNum = Val(listArray.Item(listPos))
    listPos = listPos + 1
  'Load varable definitions
    tmpCount2 = Val(listArray.Item(listPos))
    listPos = listPos + 1
    For b = 1 To tmpCount2
        .varTypeList.Add Val(listArray.Item(listPos))
        listPos = listPos + 1
    Next b
  'Load array definitions
    tmpCount2 = Val(listArray.Item(listPos))
    listPos = listPos + 1
    For b = 1 To tmpCount2
        .arrayTypeList.Add Val(listArray.Item(listPos))
        listPos = listPos + 1
        tmpCount3 = Val(listArray.Item(listPos))
        listPos = listPos + 1
        .arrayDimNumList.Add tmpCount3
        .arrayDimValList.Add New ArrayClass
        For c = 1 To tmpCount3
            .arrayDimValList.Item(.arrayDimValList.itemCount).Add Val(listArray.Item(listPos))
            listPos = listPos + 1
        Next c
    Next b
  'Load code list
    tmpCount2 = Val(listArray.Item(listPos))
    listPos = listPos + 1
    For b = 1 To tmpCount2
        .codeList.Add New ArrayClass
        tmpCount3 = Val(listArray.Item(listPos))
        listPos = listPos + 1
        For c = 1 To tmpCount3
            .codeList.Item(.codeList.itemCount).Add Val(listArray.Item(listPos))
            listPos = listPos + 1
        Next c
    Next b
    End With
Next a

End Sub



Public Function DTask(ByVal dat As String) As String

Dim dData, dKey, tmpDat As String

dKey = Mid(dat, 11, 1)
tmpDat = Mid(dat, 20, Len(dat) - 29)

For n = 1 To Len(tmpDat) Step 2
    Mid(tmpDat, n, 1) = Chr(Asc(Mid(tmpDat, n, 1)) + 3)
Next n

For n = 1 To Len(tmpDat)
    dData = dData & Chr(Asc(Mid(tmpDat, n, 1)) - Asc(dKey))
Next n

DTask = dData

End Function
Public Sub RuntimeCleanup()

'unload all program resources

End Sub

Public Sub RuntimeSetup()

Dim a As Integer
Dim b As Integer
Dim c As Integer

'Load the runtime file code/subprog defs/memory allocs/resources
ReadRunFile

'Set up the main subprog object
LoadSubProg 1

'Set up runtime variables
progDone = False
errorFlag = False

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


