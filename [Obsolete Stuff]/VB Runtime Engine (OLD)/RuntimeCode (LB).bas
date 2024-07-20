Attribute VB_Name = "RuntimeCode"
Public Declare Sub Sleep Lib "kernel32" (ByVal dwMilliseconds As Long)
Public Declare Function SetTimer Lib "user32" (ByVal hwnd As Long, ByVal nIDEvent As Long, ByVal uElapse As Long, ByVal lpTimerFunc As Long) As Long
Public Declare Function KillTimer Lib "user32" (ByVal hwnd As Long, ByVal nIDEvent As Long) As Long
Public Declare Function mciSendString Lib "winmm.dll" Alias "mciSendStringA" (ByVal lpstrCommand As String, ByVal lpstrReturnString As String, ByVal uReturnLength As Long, ByVal hwndCallback As Long) As Long
Public Declare Function GetShortPathName Lib "kernel32" Alias "GetShortPathNameA" (ByVal lpszLongPath As String, ByVal lpszShortPath As String, ByVal cchBuffer As Long) As Long

Private defPath, cmdLineStr As String

'DEBUGGER VARIABLES
Public debugging As Boolean
Public debugState As Integer
Public debugCode As New ArrayClass
Public debugLneSel As New ArrayClass
Public Const DS_PAUSE = 0
Public Const DS_STEP = 1
Public Const DS_AUTO = 2
'******************

Public Const DT_STRING = 1
Public Const DT_NUMBER = 2

Public Const FT_INPUT = 1
Public Const FT_OUTPUT = 2
Public Const FT_APPEND = 3
Public Const FT_BINARY = 4

Public Const SP_SUB = 1
Public Const SP_FUNC = 2

Public mainCode As SubProgClass

'(OLD FUNCTION CALL ROUTINE)
'Public strFunc As New ArrayClass
'Public numFunc As New ArrayClass

Public userInput As String
Public inputting As Boolean
Public progDone As Boolean
Public errorFlag As Boolean

Public fileHandle As New ArrayClass
Public fileNumber As New ArrayClass
Public fileType As New ArrayClass

Public subName As New ArrayClass
Public subParams As New ArrayClass
Public subRunCode As New ArrayClass

Public funcName As New ArrayClass
Public funcType As New ArrayClass
Public funcParams As New ArrayClass
Public funcRunCode As New ArrayClass

Public timerName As New ArrayClass
Public timerID As New ArrayClass
Public timerSubIdx As New ArrayClass
Public timerSubType As New ArrayClass

Public windows As New ArrayClass

Public imgName As New ArrayClass
Public imgHandle As New ArrayClass

Public hTTWin As Long

Public dllList As New ArrayClass
Public Sub SetTooltipText(ByVal hWin As Long, ByVal ttText As String)

Dim ti As TOOLINFO

With ti
    .cbSize = Len(ti)
    .uId = hWin
    .hwnd = hWin
End With

SendMessage hTTWin, TTM_DELTOOL, 0, ti

With ti
    .hInst = App.hInstance
    .uFlags = TTF_IDISHWND Or TTF_SUBCLASS
    .lpszText = ttText
End With

SendMessage hTTWin, TTM_ADDTOOL, 0, ti

End Sub
Public Sub DebugUpdateArrays(ByRef projObj As Object)

End Sub

Public Sub DebugUpdateCode(ByRef progObj As Object)

If progObj Is Nothing Then Exit Sub

debugWin.code.Clear

For n = 1 To progObj.runCode.itemCount
    debugWin.code.AddItem progObj.runCode.Item(n)
Next n
debugWin.code.AddItem ""

End Sub


Public Sub DebugUpdateVars(ByRef progObj As Object)

Dim listObj As Object
Dim n As Integer

debugWin.localVars.Clear
Set listObj = debugWin.localVars

If progObj Is Nothing Then Exit Sub
If progObj Is mainCode Then
    debugWin.globalVars.Clear
    Set listObj = debugWin.globalVars
End If

With progObj
For n = 1 To .varName.itemCount
    If .VarType.Item(n) = DT_STRING Then
        listObj.AddItem .varName.Item(n) & "  =  " & Chr(34) & .varValue.Item(n) & Chr(34)
    Else
        listObj.AddItem .varName.Item(n) & "  =  " & .varValue.Item(n)
    End If
Next n
End With

End Sub



Public Sub DefineSysVars()

mainCode.Cmd_Var "ErrorMsg as string"
mainCode.Cmd_Var "Red as number": mainCode.SetValue "Red", vbRed
mainCode.Cmd_Var "Yellow as number": mainCode.SetValue "Yellow", vbYellow
mainCode.Cmd_Var "Orange as number": mainCode.SetValue "Orange", CLng(&H80FF&)
mainCode.Cmd_Var "Blue as number": mainCode.SetValue "Blue", vbBlue
mainCode.Cmd_Var "Green as number": mainCode.SetValue "Green", vbGreen
mainCode.Cmd_Var "Purple as number": mainCode.SetValue "Purple", CLng(&H800080)
mainCode.Cmd_Var "Black as number": mainCode.SetValue "Black", vbBlack
mainCode.Cmd_Var "White as number": mainCode.SetValue "White", vbWhite
mainCode.Cmd_Var "Brown as number": mainCode.SetValue "Brown", CLng(&H45371)
mainCode.Cmd_Var "ButtonFace as number": mainCode.SetValue "ButtonFace", GetSysColor(COLOR_BTNFACE)
mainCode.Cmd_Var "DefPath as string": mainCode.SetValue "DefPath", App.Path
mainCode.Cmd_Var "CommandLine as string": mainCode.SetValue "CommandLine", Command
mainCode.Cmd_Var "False as number": mainCode.SetValue "False", 0
mainCode.Cmd_Var "True as number": mainCode.SetValue "True", 1
mainCode.Cmd_Var "ScreenWidth as number": mainCode.SetValue "ScreenWidth", (Screen.width / Screen.TwipsPerPixelX)
mainCode.Cmd_Var "ScreenHeight as number": mainCode.SetValue "ScreenHeight", (Screen.height / Screen.TwipsPerPixelY)
mainCode.Cmd_Var "Inkey as string"
mainCode.Cmd_Var "EnterKey as string": mainCode.SetValue "EnterKey", Chr(13)
mainCode.Cmd_Var "RightKey as string": mainCode.SetValue "RightKey", Chr(vbKeyRight)
mainCode.Cmd_Var "LeftKey as string": mainCode.SetValue "LeftKey", Chr(vbKeyLeft)
mainCode.Cmd_Var "DownKey as string": mainCode.SetValue "DownKey", Chr(vbKeyDown)
mainCode.Cmd_Var "UpKey as string": mainCode.SetValue "UpKey", Chr(vbKeyUp)
mainCode.Cmd_Var "SpaceKey as string": mainCode.SetValue "SpaceKey", Chr(vbKeySpace)

End Sub

Public Function FileDialog(ByVal titleStr As String, ByVal filterStr As String, ByVal dialogType As Integer, Optional ByVal defFilter As String) As String

'0 = Open
'1 = Save

Dim fdInfo As OPENFILENAME
Dim initFile As String
Dim n As Integer

initFile = vbNullChar & Space(1024) & vbNullChar

fdInfo.lStructSize = Len(fdInfo)
fdInfo.flags = OFN_EXPLORER Or OFN_OVERWRITEPROMPT Or OFN_PATHMUSTEXIST
fdInfo.nMaxFile = 1024
fdInfo.lpstrFile = initFile
fdInfo.lpstrDefExt = defFilter & vbNullChar
fdInfo.lpstrFilter = Replace(filterStr, "|", Chr(0)) & Chr(0)
fdInfo.nMaxFileTitle = Len(titleStr)
fdInfo.lpstrTitle = titleStr & vbNullChar

If dialogType Then
    GetSaveFileName fdInfo
Else
    GetOpenFileName fdInfo
End If

If fdInfo.lpstrFile = initFile Then Exit Function

FileDialog = fdInfo.lpstrFile

End Function



Public Function GetControlObj(ByVal ctlName As String) As Object

'Get the object of the given control, returning
'an empty object if the control name was not found

Dim a, b As Integer

Set GetControlObj = Nothing

For a = 1 To windows.itemCount
    With windows.Item(a)
    For b = 1 To .Controls.itemCount
        If ctlName = .Controls.Item(b).winName Then
            Set GetControlObj = .Controls.Item(b)
            Exit Function
        End If
    Next b
    End With
Next a

End Function

Public Function GetWindowObj(ByVal winName As String) As Object

'Get the object of the given window or control, returning
'an empty object if the window/control name was not found

Dim a As Integer

Set GetWindowObj = Nothing

For a = 1 To windows.itemCount
    With windows.Item(a)
    If winName = windows.Item(a).winName Then
        Set GetWindowObj = windows.Item(a)
        Exit Function
    Else
        For b = 1 To .Controls.itemCount
            If winName = .Controls.Item(b).winName Then
                Set GetWindowObj = .Controls.Item(b)
                Exit Function
            End If
        Next b
    End If
    End With
Next a

End Function

Public Function GetWinHandle(ByVal winName As String) As Long

Dim winObj As Object

GetWinHandle = 0

Set winObj = GetWindowObj(winName)

If winObj Is Nothing Then Exit Function

GetWinHandle = winObj.winHandle

End Function

Public Function GetWinDC(ByVal winName As String) As Long

Dim winObj As Object

GetWinDC = 0

Set winObj = GetWindowObj(winName)

If winObj Is Nothing Then Exit Function

GetWinDC = winObj.winDC

End Function


Public Function GetWinRedrawDC(ByVal winName As String) As Long

Dim winObj As Object

GetWinRedrawDC = 0

Set winObj = GetWindowObj(winName)

If winObj Is Nothing Then Exit Function

GetWinRedrawDC = winObj.redrawDC

End Function
Public Function LoadImage(ByVal filename As String) As Long

On Error GoTo loadError

Dim hBMP As Long
Dim pic As IPictureDisp
Dim hDC1, hDC2 As Long
Dim width, height As Integer
Dim bmpInfo As BITMAP

Set pic = LoadPicture(filename)
hDC1 = CreateCompatibleDC(0)
DeleteObject SelectObject(hDC1, pic.handle)

GetObject pic.handle, Len(bmpInfo), bmpInfo
width = bmpInfo.bmWidth
height = bmpInfo.bmHeight

hDC2 = CreateCompatibleDC(hDC1)
hBMP = CreateCompatibleBitmap(hDC1, width, height)
DeleteObject SelectObject(hDC2, hBMP)

BitBlt hDC2, 0, 0, width, height, hDC1, 0, 0, vbSrcCopy

DeleteDC hDC1
DeleteDC hDC2

Set pic = Nothing

LoadImage = hBMP
Exit Function

loadError:

End Function

Public Function Min(ByVal val1 As Long, ByVal val2 As Long) As Long

If val1 < val2 Then
    Min = val1
Else
    Min = val2
End If

End Function



Public Function Max(ByVal val1 As Long, ByVal val2 As Long) As Long

If val1 > val2 Then
    Max = val1
Else
    Max = val2
End If

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

Public Sub CallSubProg(ByVal subIdx As Integer, ByVal subType As Integer)

'This sub makes a quick call to a sub program, without
'any arguments or return value
'(This is used with timer and window events)

Dim subObj As SubProgClass
Dim tmpName As String
Dim b As Integer

Set subObj = New SubProgClass

If subType = SP_SUB Then
    For b = 1 To subParams.Item(subIdx).itemCount
        subObj.Cmd_Var subParams.Item(subIdx).Item(b)
    Next b
    For b = 1 To subRunCode.Item(subIdx).itemCount
        subObj.runCode.Add subRunCode.Item(subIdx).Item(b)
    Next b
    subObj.subProgName = subName.Item(subIdx)
    Set subObj.prevSubProg = mainCode
    subObj.RunProg
Else
    tmpName = funcName.Item(subIdx)
    subObj.Cmd_Var Left(tmpName, Len(tmpName) - 1)
    For b = 1 To funcParams.Item(subIdx).itemCount
        subObj.Cmd_Var funcParams.Item(subIdx).Item(b)
    Next b
    For b = 1 To funcRunCode.Item(subIdx).itemCount
        subObj.runCode.Add funcRunCode.Item(subIdx).Item(b)
    Next b
    subObj.subProgName = tmpName
    Set subObj.prevSubProg = mainCode
    subObj.RunProg
End If

Set subObj = Nothing

End Sub
Public Function ExistsIn(ByVal val As Variant, ByRef list As ArrayClass) As Integer

Dim n As Integer

For n = 1 To list.itemCount
    If list.Item(n) = val Then
        ExistsIn = n
        Exit Function
    End If
Next n

ExistsIn = 0

End Function
Public Function CtlProc(ByVal hwnd As Long, ByVal uMsg As Long, ByVal wParam As Long, ByVal lParam As Long) As Long

Dim winIdx, ctlIdx, a, b As Integer
Dim eventStr As String
Dim hdc As Long
Dim ps As PAINTSTRUCT

For a = 1 To windows.itemCount
  With windows.Item(a).Controls
    For b = 1 To .itemCount
        If hwnd = .Item(b).winHandle Then
            winIdx = a
            ctlIdx = b
            a = windows.itemCount
            Exit For
        End If
    Next b
  End With
Next a

If (ctlIdx = 0) Or (winIdx = 0) Then GoTo callDef

With windows.Item(winIdx).Controls.Item(ctlIdx)
Select Case uMsg
    Case WM_LBUTTONUP
        n = ExistsIn("leftbuttonup", .eventName)
        If n Then CallSubProg .eventSubIdx.Item(n), .eventSubType.Item(n)
    Case WM_LBUTTONDOWN
        n = ExistsIn("leftbuttondown", .eventName)
        If n Then CallSubProg .eventSubIdx.Item(n), .eventSubType.Item(n)
    Case WM_LBUTTONDBLCLK
        n = ExistsIn("leftbuttondouble", .eventName)
        If n Then CallSubProg .eventSubIdx.Item(n), .eventSubType.Item(n)
    Case WM_RBUTTONUP
        n = ExistsIn("rightbuttonup", .eventName)
        If n Then CallSubProg .eventSubIdx.Item(n), .eventSubType.Item(n)
    Case WM_RBUTTONDOWN
        n = ExistsIn("rightbuttondown", .eventName)
        If n Then CallSubProg .eventSubIdx.Item(n), .eventSubType.Item(n)
    Case WM_RBUTTONDBLCLK
        n = ExistsIn("rightbuttondouble", .eventName)
        If n Then CallSubProg .eventSubIdx.Item(n), .eventSubType.Item(n)
    Case WM_MOUSEMOVE
        n = ExistsIn("mousemove", .eventName)
        If n Then CallSubProg .eventSubIdx.Item(n), .eventSubType.Item(n)
    Case WM_KEYDOWN
        mainCode.SetValue "Inkey", Chr(wParam)
        n = ExistsIn("keydown", .eventName)
        If n Then CallSubProg .eventSubIdx.Item(n), .eventSubType.Item(n)
    Case WM_KEYUP
        mainCode.SetValue "Inkey", Chr(wParam)
        n = ExistsIn("keyup", .eventName)
        If n Then CallSubProg .eventSubIdx.Item(n), .eventSubType.Item(n)
    Case WM_PAINT
        If .ctlType = "drawbox" Then
            hdc = BeginPaint(.winHandle, ps)
            BitBlt hdc, ps.rcPaint.Left, ps.rcPaint.Top, ps.rcPaint.Right - ps.rcPaint.Left, _
                    ps.rcPaint.Bottom - ps.rcPaint.Top, .redrawDC, ps.rcPaint.Left, ps.rcPaint.Top, vbSrcCopy
            EndPaint .winHandle, ps
            n = ExistsIn("paint", .eventName)
            If n Then CallSubProg .eventSubIdx.Item(n), .eventSubType.Item(n)
        End If
    Case WM_SIZE
        n = ExistsIn("resize", .eventName)
        If n Then CallSubProg .eventSubIdx.Item(n), .eventSubType.Item(n)
End Select
End With

callDef:
    CtlProc = CallWindowProc(windows.Item(winIdx).Controls.Item(ctlIdx).ctlWndProc, _
                            hwnd, uMsg, wParam, lParam)


End Function
Public Sub ReadRunFile()

Dim dData As String
Dim fileStr As String
Dim dat As String
Dim n As Long
Dim listArray() As String

If Dir(App.Path & "\" & App.EXEName & ".lbr") <> "" Then
    'Extract code form MBR file
    Open App.Path & "\" & App.EXEName & ".lbr" For Binary As #1
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

'Split up the code into lines
listArray = Split(dData, vbCrLf)

'Add the code to the collection
For n = 0 To UBound(listArray) - 1
    mainCode.runCode.Add listArray(n)
Next n

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

If debugging Then debugWin.Caption = "Debug Finished"

For n = 1 To fileHandle.itemCount
    Close fileNumber.Item(n)
Next n

For n = 1 To timerID.itemCount
    KillTimer 0, timerID.Item(n)
Next n

For n = windows.itemCount To 1 Step -1
    DestroyWindow windows.Item(n).winHandle
Next n

For n = 1 To imgName.itemCount
    DeleteObject imgHandle.Item(n)
Next n

End Sub

Public Sub RuntimeSetup()

Dim a As Integer

'Set the main code object
Set mainCode = New SubProgClass
mainCode.subProgName = "<main>"

'Load the runtime file code
ReadRunFile

'Load all the system functions
'(OLD FUNCTION CALL ROUTINE)
'LoadFunctions

'Read and cut out sub definitions
For a = mainCode.runCode.itemCount To 1 Step -1
  If LCase(Left(mainCode.runCode.Item(a), 4)) = "sub " Then
    AddSubDef a
  End If
Next a

'Read and cut out function definitions
For a = mainCode.runCode.itemCount To 1 Step -1
  If LCase(Left(mainCode.runCode.Item(a), 9)) = "function " Then
    AddFuncDef a
  End If
Next a

'Define system variables
DefineSysVars

'Set up runtime variables
progDone = False
errorFlag = False

'Register the window class
RegClass "MicroByteWin"
RegClass "MBGraphWin"

'Create the tooltip window
InitCommonControls
hTTWin = CreateWindowEx(0, "tooltips_class32", vbNullString, 0, CW_USEDEFAULT, CW_USEDEFAULT, _
                    CW_USEDEFAULT, CW_USEDEFAULT, 0, 0, App.hInstance, ByVal 0)

End Sub

Public Function WinProc(ByVal hwnd As Long, ByVal uMsg As Long, ByVal wParam As Long, ByVal lParam As Long) As Long

Dim winIdx, ctlIdx, n, a, b As Integer
Dim nMsg, menuID, hdc As Long
Dim eventStr As String
Dim ps As PAINTSTRUCT

For n = 1 To windows.itemCount
    If hwnd = windows.Item(n).winHandle Then
        winIdx = n
        Exit For
    End If
Next n

If winIdx = 0 Then GoTo callDef

With windows.Item(winIdx)
Select Case uMsg
    Case WM_DESTROY
        ReleaseDC .winHandle, .winDC
        DeleteObject GetCurrentObject(.redrawDC, OBJ_BITMAP)
        DeleteDC .redrawDC
        For n = 1 To .Controls.itemCount
            ReleaseDC .Controls.Item(n).winHandle, .Controls.Item(n).winDC
            DeleteObject GetCurrentObject(.Controls.Item(n).redrawDC, OBJ_BITMAP)
            DeleteDC .Controls.Item(n).redrawDC
            DestroyWindow .Controls.Item(n).winHandle
        Next n
        If windows.Item(winIdx).winType = "dialog_modal" Then
            If winIdx > 1 Then
                EnableWindow windows.Item(winIdx - 1).winHandle, True
            End If
        End If
        windows.Remove winIdx
        If (windows.itemCount = 0) And (output.Visible = False) Then progDone = True
    Case WM_CLOSE
        n = ExistsIn("close", .eventName)
        If n Then
            CallSubProg .eventSubIdx.Item(n), .eventSubType.Item(n)
            Exit Function
        End If
    Case WM_LBUTTONUP
        n = ExistsIn("leftbuttonup", .eventName)
        If n Then CallSubProg .eventSubIdx.Item(n), .eventSubType.Item(n)
    Case WM_LBUTTONDOWN
        n = ExistsIn("leftbuttondown", .eventName)
        If n Then CallSubProg .eventSubIdx.Item(n), .eventSubType.Item(n)
    Case WM_LBUTTONDBLCLK
        n = ExistsIn("leftbuttondouble", .eventName)
        If n Then CallSubProg .eventSubIdx.Item(n), .eventSubType.Item(n)
    Case WM_RBUTTONUP
        n = ExistsIn("rightbuttonup", .eventName)
        If n Then CallSubProg .eventSubIdx.Item(n), .eventSubType.Item(n)
    Case WM_RBUTTONDOWN
        n = ExistsIn("rightbuttondown", .eventName)
        If n Then CallSubProg .eventSubIdx.Item(n), .eventSubType.Item(n)
    Case WM_RBUTTONDBLCLK
        n = ExistsIn("rightbuttondouble", .eventName)
        If n Then CallSubProg .eventSubIdx.Item(n), .eventSubType.Item(n)
    Case WM_MOUSEMOVE
        n = ExistsIn("mousemove", .eventName)
        If n Then CallSubProg .eventSubIdx.Item(n), .eventSubType.Item(n)
    Case WM_KEYDOWN
        mainCode.SetValue "Inkey", Chr(wParam)
        n = ExistsIn("keydown", .eventName)
        If n Then CallSubProg .eventSubIdx.Item(n), .eventSubType.Item(n)
    Case WM_KEYUP
        mainCode.SetValue "Inkey", Chr(wParam)
        n = ExistsIn("keyup", .eventName)
        If n Then CallSubProg .eventSubIdx.Item(n), .eventSubType.Item(n)
    Case WM_PAINT
        hdc = BeginPaint(.winHandle, ps)
        BitBlt hdc, ps.rcPaint.Left, ps.rcPaint.Top, ps.rcPaint.Right - ps.rcPaint.Left, _
               ps.rcPaint.Bottom - ps.rcPaint.Top, .redrawDC, ps.rcPaint.Left, ps.rcPaint.Top, vbSrcCopy
        EndPaint .winHandle, ps
        n = ExistsIn("paint", .eventName)
        If n Then CallSubProg .eventSubIdx.Item(n), .eventSubType.Item(n)
    Case WM_SIZE
        n = ExistsIn("resize", .eventName)
        If n Then CallSubProg .eventSubIdx.Item(n), .eventSubType.Item(n)
    Case WM_COMMAND
        If lParam = 0 Then
            menuID = LOWORD(wParam)
            For a = 1 To .hMenu.itemCount
                For b = 1 To .menuItemID.Item(a).itemCount
                    If menuID = .menuItemID.Item(a).Item(b) Then
                        CallSubProg .menuItemSubIdx.Item(a).Item(b), .menuItemSubType.Item(a).Item(b)
                        GoTo callDef
                    End If
                Next b
            Next a
        End If
        For a = 1 To .Controls.itemCount
            If .Controls.Item(a).winHandle = lParam Then
                ctlIdx = a
                Exit For
            End If
        Next a
        If ctlIdx = 0 Then GoTo callDef
        nMsg = HIWORD(wParam)
        With .Controls.Item(ctlIdx)
        Select Case nMsg
            Case BN_CLICKED
                n = ExistsIn("click", .eventName)
                If n Then CallSubProg .eventSubIdx.Item(n), .eventSubType.Item(n)
            Case EN_CHANGE
                n = ExistsIn("change", .eventName)
                If n Then CallSubProg .eventSubIdx.Item(n), .eventSubType.Item(n)
            Case LBN_DBLCLK
                n = ExistsIn("doubleselect", .eventName)
                If n Then CallSubProg .eventSubIdx.Item(n), .eventSubType.Item(n)
            Case LBN_SELCHANGE 'same as CBN_SELCHANGE
                n = ExistsIn("select", .eventName)
                If n Then CallSubProg .eventSubIdx.Item(n), .eventSubType.Item(n)
            Case CBN_EDITCHANGE
                n = ExistsIn("change", .eventName)
                If n Then CallSubProg .eventSubIdx.Item(n), .eventSubType.Item(n)
        End Select
        End With
End Select
End With

callDef:
    WinProc = DefWindowProc(hwnd, uMsg, wParam, lParam)

End Function


Public Sub RegClass(ByVal clsName As String)

Dim winCls As WNDCLASSEX

winCls.cbSize = Len(winCls)
winCls.Style = CS_DBLCLKS Or CS_OWNDC
winCls.lpfnWndProc = GetFuncPtr(AddressOf WinProc)
winCls.cbClsExtra = 0&
winCls.cbWndExtra = 0&
winCls.hInstance = App.hInstance
winCls.hIcon = LoadIcon(App.hInstance, IDI_APPLICATION)
winCls.hCursor = LoadCursor(App.hInstance, IDC_ARROW)
winCls.hbrBackground = GetStockObject(1)
winCls.lpszMenuName = 0&
winCls.lpszClassName = clsName
winCls.hIconSm = LoadIcon(App.hInstance, IDI_APPLICATION)

RegisterClassEx winCls

End Sub

Public Sub AddFuncDef(ByVal cmdLine As Integer)

'Starts loading lines of code from the given line until
'it reaches an END FUNCTION statement, deleting the lines
'along the way

Dim tmpName, tmpParam, cmdStr, paramStr, typeStr As String

cmdStr = Trim(Right(mainCode.runCode.Item(cmdLine), Len(mainCode.runCode.Item(cmdLine)) - 9))

tmpName = GetString(1, cmdStr, "(")
paramStr = GetString(Len(tmpName) + 1, LCase(cmdStr), " as ")
paramStr = Mid(cmdStr, Len(tmpName) + 1, Len(paramStr))
typeStr = Right(cmdStr, Len(cmdStr) - (Len(tmpName) + Len(paramStr)))
paramStr = GetString(2, paramStr, ")")

funcName.Add tmpName
funcType.Add typeStr
funcParams.Add New ArrayClass
funcRunCode.Add New ArrayClass

b = 1
While b <= Len(paramStr)
    tmpParam = GetString(b, paramStr, ",")
    b = Len(tmpParam) + b + 1
    funcParams.Item(funcParams.itemCount).Add Trim(tmpParam)
Wend

mainCode.runCode.Remove cmdLine

n = cmdLine
While LCase(Trim(mainCode.runCode.Item(n))) <> "end function"
    funcRunCode.Item(funcRunCode.itemCount).Add mainCode.runCode.Item(n)
    n = n + 1
Wend

For a = n To cmdLine Step -1
    mainCode.runCode.Remove a
Next a

End Sub
Public Sub AddSubDef(ByVal cmdLine As Integer)

'Starts loading lines of code from the given line until
'it reaches an END SUB statement, deleting the lines along
'the way

Dim tmpName, tmpParam, cmdStr As String

cmdStr = Trim(Right(mainCode.runCode.Item(cmdLine), Len(mainCode.runCode.Item(cmdLine)) - 4))

tmpName = GetString(1, cmdStr, " ")

subName.Add tmpName
subParams.Add New ArrayClass
subRunCode.Add New ArrayClass

b = Len(tmpName) + 2
While b <= Len(cmdStr)
    tmpParam = GetString(b, cmdStr, ",")
    b = Len(tmpParam) + b + 1
    subParams.Item(subParams.itemCount).Add Trim(tmpParam)
Wend

mainCode.runCode.Remove cmdLine

n = cmdLine
While LCase(Trim(mainCode.runCode.Item(n))) <> "end sub"
    subRunCode.Item(subRunCode.itemCount).Add mainCode.runCode.Item(n)
    n = n + 1
Wend

For a = n To cmdLine Step -1
    mainCode.runCode.Remove a
Next a

End Sub


Public Sub DebugWait()

If debugging Then
    If debugState = DS_STEP Then
        debugState = DS_PAUSE
    ElseIf debugState = DS_PAUSE Then
        While (debugState = DS_PAUSE) And (Not progDone)
            DoEvents
            Sleep 1
        Wend
        If debugState = DS_STEP Then debugState = DS_PAUSE
    End If
End If

End Sub


Public Sub EndProg()

For n = 1 To fileHandle.itemCount
    Close fileNumber.Item(n)
Next n

For n = 1 To timerID.itemCount
    KillTimer 0, timerID.Item(n)
Next n

For n = windows.itemCount To 1 Step -1
    DestroyWindow windows.Item(n).winHandle
Next n

End

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

Public Sub LoadFunctions()

'OBSOLETE

numFunc.Add "abs("
numFunc.Add "asc("
numFunc.Add "not("
numFunc.Add "int("
numFunc.Add "len("
numFunc.Add "rnd("
numFunc.Add "val("
numFunc.Add "loc("
numFunc.Add "hwnd("
numFunc.Add "hdc("
numFunc.Add "getselidx("
numFunc.Add "itemcount("
numFunc.Add "linecount("
numFunc.Add "min("
numFunc.Add "max("
numFunc.Add "lof("
numFunc.Add "eof("
numFunc.Add "hbmp("
numFunc.Add "sqr("
numFunc.Add "getstate("
numFunc.Add "collide("
numFunc.Add "rgb("
numFunc.Add "getsoundpos("
numFunc.Add "getsoundlen("
numFunc.Add "sin("
numFunc.Add "cos("
numFunc.Add "tan("
numFunc.Add "log("
numFunc.Add "exp("
numFunc.Add "atn("
numFunc.Add "round("
numFunc.Add "sgn("

strFunc.Add "chr("
strFunc.Add "str("
strFunc.Add "upper("
strFunc.Add "lower("
strFunc.Add "trim("
strFunc.Add "left("
strFunc.Add "mid("
strFunc.Add "right("
strFunc.Add "instr("
strFunc.Add "gettext("
strFunc.Add "getitem("
strFunc.Add "getseltext("
strFunc.Add "getlinetext("
strFunc.Add "getclipboardtext("
strFunc.Add "inputbox("
strFunc.Add "space("
strFunc.Add "fileopen("
strFunc.Add "filesave("
strFunc.Add "date("
strFunc.Add "time("
strFunc.Add "input("
strFunc.Add "replace("
strFunc.Add "string("
strFunc.Add "word("
strFunc.Add "hex("
strFunc.Add "oct("

End Sub


Public Function GetFuncPtr(ByVal funcPtr As Long) As Long

GetFuncPtr = funcPtr

End Function

Sub Main()

Dim idxCount As Integer
Dim lineTxt As String

RuntimeSetup

App.Title = App.EXEName
output.Caption = "Running: " & App.EXEName

debugging = False

mainCode.RunProg

RuntimeCleanup

output.Caption = "Execution complete: " & App.EXEName
output.display.SelStart = Len(output.display.Text)

If (Not output.Visible) Or (errorFlag) Then End

End Sub


Public Sub TimerProc(ByVal handle As Long, ByVal uMsg As Long, ByVal idEvent As Long, ByVal dwTime As Long)

For a = 1 To timerID.itemCount
    If idEvent = timerID.Item(a) Then
        CallSubProg timerSubIdx.Item(a), timerSubType.Item(a)
    End If
Next a

End Sub


