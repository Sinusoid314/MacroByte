VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "SubProgClass"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False

  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior = 0   'vbNone
  MTSTransactionMode = 0   'NotAnMTSObject
End
Public subProgName As String

Public lineNum As Integer

Public varName As New ArrayClass
Public varType As New ArrayClass
Public varValue As New ArrayClass
Public varBindList As New ArrayClass

Public arrayName As New ArrayClass
Public arrayType As New ArrayClass
Public arrayValue As New ArrayClass
Public isMultiDim As New ArrayClass

Public runCode As New ArrayClass

Public labelName As New ArrayClass
Public labelLine As New ArrayClass

Public gosubLine As Integer

Public onErrorCmd As String

Public dataList As New ArrayClass
Public readPos As Integer

Public prevSubProg As Object


Public Sub Cmd_Cls()

output.display.Text = ""

End Sub

Public Sub Cmd_ExitFunction()

lineNum = runCode.itemCount

End Sub

Public Sub Cmd_ExitSub()

lineNum = runCode.itemCount

End Sub



Public Sub Cmd_GetMouseXY(ByVal cmdStr As String)

Dim params As New ArrayClass
Dim xVar, yVar As String
Dim xPos, yPos As Integer
Dim curPoint As POINTAPI
Dim posRect As RECT
Dim winHandle As Long

cmdStr = Trim(cmdStr)

ParseParams cmdStr, params

xVar = params.Item(1)
yVar = params.Item(2)

GetCursorPos curPoint
winHandle = WindowFromPoint(curPoint.X, curPoint.Y)
GetWindowRect winHandle, posRect
xPos = curPoint.X - posRect.left
yPos = curPoint.Y - posRect.top

SetValue xVar, xPos
SetValue yVar, yPos

End Sub

Public Sub Cmd_Kill(ByVal cmdStr As String)

On Error GoTo killFailed

Dim pathStr As String

cmdStr = Trim(cmdStr)

pathStr = EvalExpression(cmdStr)

Kill pathStr

Exit Sub

killFailed:
    ErrorMsg "Failed to kill file '" & pathStr & "'"

End Sub

Public Sub Cmd_Mid(ByVal cmdStr As String)

On Error Resume Next

Dim params As New ArrayClass
Dim strVar, repStr, orgStr As String
Dim starting, length As Integer

cmdStr = Trim(cmdStr)

ParseParams cmdStr, params

strVar = params.Item(1)
starting = EvalExpression(params.Item(2))

orgStr = EvalExpression(strVar)

If params.itemCount = 3 Then
    repStr = EvalExpression(params.Item(3))
    Mid(orgStr, starting) = repStr
Else
    length = EvalExpression(params.Item(3))
    repStr = EvalExpression(params.Item(4))
    Mid(orgStr, starting, length) = repStr
End If

SetValue strVar, orgStr

End Sub

Public Sub Cmd_SetFont(ByVal cmdStr As String)

Dim params As New ArrayClass
Dim winName, fontName As String
Dim fontWidth, fontHeight As Integer
Dim winDC As Long

cmdStr = Trim(cmdStr)

ParseParams cmdStr, params

winName = EvalExpression(params.Item(1))
fontName = EvalExpression(params.Item(2))
fontWidth = EvalExpression(params.Item(3))
fontHeight = EvalExpression(params.Item(4))

winDC = GetWinDC(winName)

DeleteObject GetCurrentObject(winDC, OBJ_FONT)

SelectObject winDC, CreateFont(fontHeight, fontWidth, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, fontName)

End Sub


Public Sub Cmd_ButtonImg(ByVal cmdStr As String)

Dim winName, picName As String
Dim hPic As Long
Dim n As Integer
Dim params As New ArrayClass
Dim ctlObj As Object

cmdStr = Trim(cmdStr)

ParseParams cmdStr, params

winName = EvalExpression(params.Item(1))
picName = EvalExpression(params.Item(2))

Set ctlObj = GetControlObj(winName)

If ctlObj Is Nothing Then
    ErrorMsg "Control '" & winName & "' does not exist"
    Exit Sub
End If

n = ExistsIn(picName, imgName)

If n = 0 Then
    ErrorMsg "Image '" & nameStr & "' does not exist"
    Exit Sub
Else
    hPic = imgHandle.Item(n)
End If

If ctlObj.ctlType = "picbutton" Then
    SendMessage ctlObj.winHandle, BM_SETIMAGE, 0, ByVal hPic
Else
    ErrorMsg "Control '" & winName & "' needs to be a PICBUTTON"
End If

End Sub


Public Sub Cmd_SetSoundPos(ByVal cmdStr As String)

Dim soundName As String
Dim soundPos As Long
Dim params As New ArrayClass

cmdStr = Trim(cmdStr)

ParseParams cmdStr, params

soundName = EvalExpression(params.Item(1))
soundPos = EvalExpression(params.Item(2))

mciSendString "seek " & soundName & " to " & soundPos, "", 0, 0
mciSendString "play " & soundName, "", 0, 0

End Sub

Public Sub Cmd_SetState(ByVal cmdStr As String)

Dim params As New ArrayClass
Dim winName As String
Dim ctlState As Integer
Dim ctlObj As Object

cmdStr = Trim(cmdStr)

ParseParams cmdStr, params

winName = EvalExpression(params.Item(1))
ctlState = EvalExpression(params.Item(2))

Set ctlObj = GetControlObj(winName)

If ctlObj Is Nothing Then
    ErrorMsg "Control '" & winName & "' does not exist"
    Exit Sub
End If

If ctlObj.ctlType = "radiobutton" Or ctlObj.ctlType = "checkbox" Then
    SendMessage ctlObj.winHandle, BM_SETCHECK, ctlState, 0
Else
    ErrorMsg "Control '" & winName & "' needs to be a RADIOBUTTON or CHECKBOX"
End If


End Sub



Public Sub Cmd_AddFrame(ByVal cmdStr As String)

Dim params As New ArrayClass
Dim winName, nameStr, fileStr As String
Dim n As Integer
Dim winObj As Object

cmdStr = Trim(cmdStr)

ParseParams cmdStr, params

winName = EvalExpression(params.Item(1))
nameStr = EvalExpression(params.Item(2))
fileStr = EvalExpression(params.Item(3))

Set winObj = GetWindowObj(winName)

If winObj Is Nothing Then
    ErrorMsg "Window or control '" & winName & "' does not exist"
    Exit Sub
End If

n = ExistsIn(nameStr, winObj.spriteName)
If n = 0 Then
    ErrorMsg "Sprite '" & nameStr & "' does not exist in window or control '" & winName & "'"
    Exit Sub
End If

winObj.sprites.Item(n).AddFrame fileStr

End Sub


Public Sub Cmd_DelSprite(ByVal cmdStr As String)

Dim params As New ArrayClass
Dim winName, nameStr As String
Dim n As Integer
Dim winObj As Object

cmdStr = Trim(cmdStr)

ParseParams cmdStr, params

winName = EvalExpression(params.Item(1))
nameStr = EvalExpression(params.Item(2))

Set winObj = GetWindowObj(winName)

If winObj Is Nothing Then
    ErrorMsg "Window or control '" & winName & "' does not exist"
    Exit Sub
End If

n = ExistsIn(nameStr, winObj.spriteName)
If n = 0 Then
    ErrorMsg "Sprite '" & nameStr & "' does not exist in window or control '" & winName & "'"
    Exit Sub
End If

winObj.spriteName.Remove n
winObj.sprites.Remove n

End Sub


Public Sub Cmd_DrawSprites(ByVal cmdStr As String)

Dim winName As String
Dim winObj As Object
Dim width, height, n, a, b As Integer
Dim cutWidth, cutHeight, cutLeft, cutTop As Integer
Dim backDC, backBMP As Long
Dim hBrush, bgDC As Long
Dim winRect As RECT
Dim bmpInfo As BITMAP

cmdStr = Trim(cmdStr)

winName = EvalExpression(cmdStr)

Set winObj = GetWindowObj(winName)

If winObj Is Nothing Then
    ErrorMsg "Window or control '" & winName & "' does not exist"
    Exit Sub
End If

GetWindowRect winObj.winHandle, winRect
width = winRect.Right - winRect.left
height = winRect.Bottom - winRect.top

backDC = CreateCompatibleDC(winObj.winDC)
backBMP = CreateCompatibleBitmap(winObj.winDC, width, height)
SelectObject backDC, backBMP

If winObj.spriteBG = 0 Then
    winRect.left = 0: winRect.top = 0
    winRect.Right = width: winRect.Bottom = height
    hBrush = CreateSolidBrush(vbWhite)
    FillRect backDC, winRect, hBrush
    DeleteObject hBrush
Else
    GetObject winObj.spriteBG, Len(bmpInfo), bmpInfo
    bgDC = CreateCompatibleDC(0)
    SelectObject bgDC, winObj.spriteBG
    cutLeft = winObj.spriteBGX Mod bmpInfo.bmWidth
    cutTop = winObj.spriteBGY Mod bmpInfo.bmHeight
    cutWidth = bmpInfo.bmWidth - cutLeft
    cutHeight = bmpInfo.bmHeight - cutTop
    BitBlt backDC, 0, 0, cutWidth, cutHeight, _
            bgDC, cutLeft, cutTop, vbSrcCopy
    For n = 0 To Int(width / bmpInfo.bmWidth)
      BitBlt backDC, (n * bmpInfo.bmWidth) + cutWidth, 0, bmpInfo.bmWidth, _
                cutHeight, bgDC, 0, cutTop, vbSrcCopy
    Next n
    For a = 0 To Int(height / bmpInfo.bmHeight)
      BitBlt backDC, 0, (a * bmpInfo.bmHeight) + cutHeight, cutWidth, _
                bmpInfo.bmHeight, bgDC, cutLeft, 0, vbSrcCopy
      For b = 0 To Int(width / bmpInfo.bmWidth)
        BitBlt backDC, (b * bmpInfo.bmWidth) + cutWidth, (a * bmpInfo.bmHeight) + cutHeight, _
                bmpInfo.bmWidth, bmpInfo.bmHeight, bgDC, 0, 0, vbSrcCopy
      Next b
    Next a
'    For a = 0 To Int(height / bmpInfo.bmHeight)
'        For b = 0 To Int(width / bmpInfo.bmWidth)
'            BitBlt backDC, (b * bmpInfo.bmWidth), (a * bmpInfo.bmHeight), _
'                    bmpInfo.bmWidth, bmpInfo.bmHeight, bgDC, 0, 0, vbSrcCopy
'        Next b
'    Next a
    DeleteDC bgDC
End If

For n = 1 To winObj.sprites.itemCount
    winObj.sprites.Item(n).drawDC = backDC
    winObj.sprites.Item(n).Draw
Next n

BitBlt winObj.winDC, 0, 0, width, height, backDC, 0, 0, vbSrcCopy

DeleteDC backDC
DeleteObject backBMP

End Sub


Public Sub Cmd_SetTooltip(ByVal cmdStr As String)

Dim winName As String
Dim ttText As Variant
Dim winHandle As Long
Dim params As New ArrayClass

cmdStr = Trim(cmdStr)

ParseParams cmdStr, params

winName = EvalExpression(params.Item(1))
ttText = EvalExpression(params.Item(2))

winHandle = GetWinHandle(winName)

If winHandle = 0 Then
    ErrorMsg "Window '" & winName & "' does exist"
    Exit Sub
End If

SetTooltipText winHandle, CStr(ttText)

End Sub

Public Sub Cmd_Sprite(ByVal cmdStr As String)

Dim params As New ArrayClass
Dim winName, nameStr, fileStr As String
Dim left, top, n As Integer
Dim winObj As Object

cmdStr = Trim(cmdStr)

ParseParams cmdStr, params

winName = EvalExpression(params.Item(1))
nameStr = EvalExpression(params.Item(2))
left = EvalExpression(params.Item(3))
top = EvalExpression(params.Item(4))
fileStr = EvalExpression(params.Item(5))

Set winObj = GetWindowObj(winName)

If winObj Is Nothing Then
    ErrorMsg "Window or control '" & winName & "' does not exist"
    Exit Sub
End If

n = ExistsIn(nameStr, winObj.spriteName)
If n Then
    ErrorMsg "Sprite '" & nameStr & "' already exists in window or control '" & winName & "'"
    Exit Sub
End If

winObj.spriteName.Add nameStr
winObj.sprites.Add New SpriteClass

winObj.sprites.Item(winObj.sprites.itemCount).left = left
winObj.sprites.Item(winObj.sprites.itemCount).top = top
winObj.sprites.Item(winObj.sprites.itemCount).AddFrame fileStr

End Sub


Public Sub Cmd_DelFrame(ByVal cmdStr As String)

Dim params As New ArrayClass
Dim winName, nameStr As String
Dim frameIdx, n As Integer
Dim winObj As Object

cmdStr = Trim(cmdStr)

ParseParams cmdStr, params

winName = EvalExpression(params.Item(1))
nameStr = EvalExpression(params.Item(2))
frameIdx = EvalExpression(params.Item(3))

Set winObj = GetWindowObj(winName)

If winObj Is Nothing Then
    ErrorMsg "Window or control '" & winName & "' does not exist"
    Exit Sub
End If

n = ExistsIn(nameStr, winObj.spriteName)
If n = 0 Then
    ErrorMsg "Sprite '" & nameStr & "' does not exist in window or control '" & winName & "'"
    Exit Sub
End If

winObj.sprites.Item(n).RemoveFrame frameIdx

End Sub


Public Sub Cmd_SpriteBGPos(ByVal cmdStr As String)

Dim params As New ArrayClass
Dim winName As String
Dim bgX, bgY As Long
Dim winObj As Object

cmdStr = Trim(cmdStr)

ParseParams cmdStr, params

winName = EvalExpression(params.Item(1))
bgX = EvalExpression(params.Item(2))
bgY = EvalExpression(params.Item(3))

Set winObj = GetWindowObj(winName)

If winObj Is Nothing Then
    ErrorMsg "Window or control '" & winName & "' does not exist"
    Exit Sub
End If

winObj.spriteBGX = bgX
winObj.spriteBGY = bgY

End Sub

Public Sub Cmd_SpritePos(ByVal cmdStr As String)

Dim params As New ArrayClass
Dim winName, nameStr As String
Dim left, top, n As Integer
Dim winObj As Object

cmdStr = Trim(cmdStr)

ParseParams cmdStr, params

winName = EvalExpression(params.Item(1))
nameStr = EvalExpression(params.Item(2))
left = EvalExpression(params.Item(3))
top = EvalExpression(params.Item(4))

Set winObj = GetWindowObj(winName)

If winObj Is Nothing Then
    ErrorMsg "Window or control '" & winName & "' does not exist"
    Exit Sub
End If

n = ExistsIn(nameStr, winObj.spriteName)
If n = 0 Then
    ErrorMsg "Sprite '" & nameStr & "' does not exist in window or control '" & winName & "'"
    Exit Sub
End If

winObj.sprites.Item(n).left = left
winObj.sprites.Item(n).top = top

End Sub


Public Sub Cmd_SpriteSize(ByVal cmdStr As String)

Dim params As New ArrayClass
Dim winName, nameStr As String
Dim width, height, n As Integer
Dim winObj As Object

cmdStr = Trim(cmdStr)

ParseParams cmdStr, params

winName = EvalExpression(params.Item(1))
nameStr = EvalExpression(params.Item(2))
width = EvalExpression(params.Item(3))
height = EvalExpression(params.Item(4))

Set winObj = GetWindowObj(winName)

If winObj Is Nothing Then
    ErrorMsg "Window or control '" & winName & "' does not exist"
    Exit Sub
End If

n = ExistsIn(nameStr, winObj.spriteName)
If n = 0 Then
    ErrorMsg "Sprite '" & nameStr & "' does not exist in window or control '" & winName & "'"
    Exit Sub
End If

winObj.sprites.Item(n).width = width
winObj.sprites.Item(n).height = height

End Sub


Public Sub Cmd_SpriteRate(ByVal cmdStr As String)

Dim params As New ArrayClass
Dim winName, nameStr As String
Dim rate, n As Integer
Dim winObj As Object

cmdStr = Trim(cmdStr)

ParseParams cmdStr, params

winName = EvalExpression(params.Item(1))
nameStr = EvalExpression(params.Item(2))
rate = EvalExpression(params.Item(3))

Set winObj = GetWindowObj(winName)

If winObj Is Nothing Then
    ErrorMsg "Window or control '" & winName & "' does not exist"
    Exit Sub
End If

n = ExistsIn(nameStr, winObj.spriteName)
If n = 0 Then
    ErrorMsg "Sprite '" & nameStr & "' does not exist in window or control '" & winName & "'"
    Exit Sub
End If

winObj.sprites.Item(n).rate = rate

End Sub


Public Sub Cmd_SpriteRotate(ByVal cmdStr As String)

Dim params As New ArrayClass
Dim winName, nameStr, rotation As String
Dim n As Integer
Dim winObj As Object

cmdStr = Trim(cmdStr)

ParseParams cmdStr, params

winName = EvalExpression(params.Item(1))
nameStr = EvalExpression(params.Item(2))
rotation = LCase(EvalExpression(params.Item(3)))

Set winObj = GetWindowObj(winName)

If winObj Is Nothing Then
    ErrorMsg "Window or control '" & winName & "' does not exist"
    Exit Sub
End If

n = ExistsIn(nameStr, winObj.spriteName)
If n = 0 Then
    ErrorMsg "Sprite '" & nameStr & "' does not exist in window or control '" & winName & "'"
    Exit Sub
End If

Select Case rotation
    Case "normal"
        winObj.sprites.Item(n).display = 0
    Case "flip"
        winObj.sprites.Item(n).display = 1
    Case "mirror"
        winObj.sprites.Item(n).display = 2
    Case "rotate180"
        winObj.sprites.Item(n).display = 3
End Select

End Sub



Public Sub Cmd_SpriteHide(ByVal cmdStr As String)

Dim params As New ArrayClass
Dim winName, nameStr As String
Dim n As Integer
Dim winObj As Object

cmdStr = Trim(cmdStr)

ParseParams cmdStr, params

winName = EvalExpression(params.Item(1))
nameStr = EvalExpression(params.Item(2))

Set winObj = GetWindowObj(winName)

If winObj Is Nothing Then
    ErrorMsg "Window or control '" & winName & "' does not exist"
    Exit Sub
End If

n = ExistsIn(nameStr, winObj.spriteName)
If n = 0 Then
    ErrorMsg "Sprite '" & nameStr & "' does not exist in window or control '" & winName & "'"
    Exit Sub
End If

winObj.sprites.Item(n).Visible = False

End Sub


Public Sub Cmd_SpriteShow(ByVal cmdStr As String)

Dim params As New ArrayClass
Dim winName, nameStr As String
Dim n As Integer
Dim winObj As Object

cmdStr = Trim(cmdStr)

ParseParams cmdStr, params

winName = EvalExpression(params.Item(1))
nameStr = EvalExpression(params.Item(2))

Set winObj = GetWindowObj(winName)

If winObj Is Nothing Then
    ErrorMsg "Window or control '" & winName & "' does not exist"
    Exit Sub
End If

n = ExistsIn(nameStr, winObj.spriteName)
If n = 0 Then
    ErrorMsg "Sprite '" & nameStr & "' does not exist in window or control '" & winName & "'"
    Exit Sub
End If

winObj.sprites.Item(n).Visible = True

End Sub


Public Sub Cmd_DrawText(ByVal cmdStr As String)

Dim params As New ArrayClass
Dim winName As String
Dim left, top As Integer
Dim drawText As Variant
Dim winDC As Long

cmdStr = Trim(cmdStr)

ParseParams cmdStr, params

winName = EvalExpression(params.Item(1))
drawText = EvalExpression(params.Item(2))
left = EvalExpression(params.Item(3))
top = EvalExpression(params.Item(4))

winDC = GetWinDC(winName)

If winDC = 0 Then
    ErrorMsg "Window or control '" & winName & "' does not exist"
    Exit Sub
End If

TextOut winDC, left, top, drawText, Len(drawText)

End Sub


Public Sub Cmd_Refresh(ByVal cmdStr As String)

Dim winName As String
Dim winHandle, winDC, redrawDC As Long

cmdStr = Trim(cmdStr)

winName = EvalExpression(cmdStr)

winHandle = GetWinHandle(winName)
If winHandle = 0 Then
    ErrorMsg "Window or control '" & winName & "' does not exist"
    Exit Sub
End If
winDC = GetWinDC(winName)
redrawDC = GetWinRedrawDC(winName)

SendMessage winHandle, WM_ERASEBKGND, winDC, ByVal 0
RedrawWindow winHandle, ByVal 0&, 0&, RDW_INVALIDATE

End Sub


Public Sub Cmd_Clear(ByVal cmdStr As String)

Dim winName As String
Dim winObj As Object

cmdStr = Trim(cmdStr)

winName = EvalExpression(cmdStr)

Set winObj = GetWindowObj(winName)

If winObj Is Nothing Then
    ErrorMsg "Window or control '" & winName & "' does not exist"
    Exit Sub
End If

DeleteObject GetCurrentObject(winObj.redrawDC, OBJ_BITMAP)
DeleteDC winObj.redrawDC
winObj.redrawDC = CreateCompatibleDC(winObj.winDC)
SendMessage winObj.winHandle, WM_ERASEBKGND, winObj.winDC, ByVal 0
RedrawWindow winObj.winHandle, ByVal 0&, 0&, RDW_INVALIDATE

End Sub


Public Sub Cmd_DrawImg(ByVal cmdStr As String)

Dim params As New ArrayClass
Dim winName As String
Dim nameStr As String
Dim left, top, n As Integer
Dim winDC, tempDC As Long
Dim bmpInfo As BITMAP

cmdStr = Trim(cmdStr)

ParseParams cmdStr, params

winName = EvalExpression(params.Item(1))
nameStr = EvalExpression(params.Item(2))
left = EvalExpression(params.Item(3))
top = EvalExpression(params.Item(4))

winDC = GetWinDC(winName)
If winDC = 0 Then
    ErrorMsg "Window or control '" & winName & "' does not exist"
    Exit Sub
End If

n = ExistsIn(nameStr, imgName)
If n = 0 Then
    ErrorMsg "Image '" & nameStr & "' doe snot exist"
    Exit Sub
End If

GetObject imgHandle.Item(n), Len(bmpInfo), bmpInfo
tempDC = CreateCompatibleDC(0)
SelectObject tempDC, imgHandle.Item(n)
BitBlt winDC, left, top, bmpInfo.bmWidth, bmpInfo.bmHeight, tempDC, 0, 0, vbSrcCopy
DeleteDC tempDC

End Sub


Public Sub Cmd_LoadImg(ByVal cmdStr As String)

Dim params As New ArrayClass
Dim nameStr As String
Dim fileStr As String
Dim hImg As Long

cmdStr = Trim(cmdStr)

ParseParams cmdStr, params

nameStr = EvalExpression(params.Item(1))
fileStr = EvalExpression(params.Item(2))

hImg = LoadImage(fileStr)

If hImg = 0 Then
    ErrorMsg "Unable to load bitmap '" & fileStr & "'"
    Exit Sub
End If

imgName.Add nameStr
imgHandle.Add hImg

End Sub


Public Sub Cmd_ForeColor(ByVal cmdStr As String)

Dim params As New ArrayClass
Dim winName As String
Dim color As Long
Dim winDC As Long
Dim pen As LOGPEN

cmdStr = Trim(cmdStr)

ParseParams cmdStr, params

winName = EvalExpression(params.Item(1))
color = EvalExpression(params.Item(2))

winDC = GetWinDC(winName)

If winDC = 0 Then
    ErrorMsg "Window or control '" & winName & "' does not exist"
    Exit Sub
End If

GetObject GetCurrentObject(winDC, OBJ_PEN), Len(pen), pen
DeleteObject SelectObject(winDC, CreatePen(PS_SOLID, pen.lopnWidth.X, color))

End Sub


Public Sub Cmd_UnloadImg(ByVal cmdStr As String)

Dim nameStr As String
Dim n As Integer

cmdStr = Trim(cmdStr)

nameStr = EvalExpression(cmdStr)

n = ExistsIn(nameStr, imgName)

If n = 0 Then
    ErrorMsg "Image '" & nameStr & "' does not exist"
    Exit Sub
End If

DeleteObject imgHandle.Item(n)

imgName.Remove n
imgHandle.Remove n

End Sub


Public Sub Cmd_BackColor(ByVal cmdStr As String)

Dim params As New ArrayClass
Dim winName As String
Dim color As Long
Dim winDC As Long

cmdStr = Trim(cmdStr)

ParseParams cmdStr, params

winName = EvalExpression(params.Item(1))
color = EvalExpression(params.Item(2))

winDC = GetWinDC(winName)

If winDC = 0 Then
    ErrorMsg "Window or control '" & winName & "' does not exist"
    Exit Sub
End If

DeleteObject SelectObject(winDC, CreateSolidBrush(color))
SetBkColor winDC, color

End Sub


Public Sub Cmd_LineSize(ByVal cmdStr As String)

Dim params As New ArrayClass
Dim winName As String
Dim lineSize As Integer
Dim winDC As Long
Dim pen As LOGPEN

cmdStr = Trim(cmdStr)

ParseParams cmdStr, params

winName = EvalExpression(params.Item(1))
lineSize = EvalExpression(params.Item(2))

winDC = GetWinDC(winName)

If winDC = 0 Then
    ErrorMsg "Window or control '" & winName & "' does not exist"
    Exit Sub
End If

GetObject GetCurrentObject(winDC, OBJ_PEN), Len(pen), pen
DeleteObject SelectObject(winDC, CreatePen(PS_SOLID, lineSize, pen.lopnColor))

End Sub

Public Sub Cmd_Box(ByVal cmdStr As String)

Dim params As New ArrayClass
Dim winName As String
Dim left, top, width, height As Integer
Dim Right, Bottom As Integer
Dim winDC As Long

cmdStr = Trim(cmdStr)

ParseParams cmdStr, params

winName = EvalExpression(params.Item(1))
left = EvalExpression(params.Item(2))
top = EvalExpression(params.Item(3))
width = EvalExpression(params.Item(4))
height = EvalExpression(params.Item(5))

Right = left + width
Bottom = top + height

winDC = GetWinDC(winName)

If winDC = 0 Then
    ErrorMsg "Window or control '" & winName & "' does not exist"
    Exit Sub
End If

Rectangle winDC, left, top, Right, Bottom

End Sub


Public Sub Cmd_Circle(ByVal cmdStr As String)

Dim params As New ArrayClass
Dim winName As String
Dim centerX, centerY, radius As Integer
Dim left, top, Right, Bottom As Integer
Dim winDC As Long

cmdStr = Trim(cmdStr)

ParseParams cmdStr, params

winName = EvalExpression(params.Item(1))
centerX = EvalExpression(params.Item(2))
centerY = EvalExpression(params.Item(3))
radius = EvalExpression(params.Item(4))

left = centerX - radius
top = centerY - radius
Right = centerX + radius
Bottom = centerY + radius

winDC = GetWinDC(winName)

If winDC = 0 Then
    ErrorMsg "Window or control '" & winName & "' does not exist"
    Exit Sub
End If

Ellipse winDC, left, top, Right, Bottom

End Sub


Public Sub Cmd_SetSelText(ByVal cmdStr As String)

Dim params As New ArrayClass
Dim winName As String
Dim repStr As String
Dim ctlObj As Object

cmdStr = Trim(cmdStr)

ParseParams cmdStr, params

winName = EvalExpression(params.Item(1))
repStr = EvalExpression(params.Item(2))

Set ctlObj = GetControlObj(winName)

If ctlObj Is Nothing Then
    ErrorMsg "Control '" & winName & "' does not exist"
    Exit Sub
End If

If ctlObj.ctlType = "textbox" Or ctlObj.ctlType = "texteditor" Then
    SendMessage ctlObj.winHandle, EM_REPLACESEL, 1, ByVal repStr
Else
    ErrorMsg "Control '" & winName & "' needs to be a TEXTBOX or TEXTEDITOR"
End If

End Sub


Public Sub Cmd_Line(ByVal cmdStr As String)

Dim params As New ArrayClass
Dim winName As String
Dim startX, startY As Integer
Dim endX, endY As Integer
Dim winDC As Long

cmdStr = Trim(cmdStr)

ParseParams cmdStr, params

winName = EvalExpression(params.Item(1))
startX = EvalExpression(params.Item(2))
startY = EvalExpression(params.Item(3))
endX = EvalExpression(params.Item(4))
endY = EvalExpression(params.Item(5))

winDC = GetWinDC(winName)

If winDC = 0 Then
    ErrorMsg "Window or control '" & winName & "' does not exist"
    Exit Sub
End If

MoveToEx winDC, startX, startY, vbNull
LineTo winDC, endX, endY

End Sub


Public Sub Cmd_GetImg(ByVal cmdStr As String)

Dim params As New ArrayClass
Dim winName, nameStr As String
Dim left, top, width, height As Integer
Dim winDC As Long
Dim tempDC, tempBMP As Long

cmdStr = Trim(cmdStr)

ParseParams cmdStr, params

winName = EvalExpression(params.Item(1))
nameStr = EvalExpression(params.Item(2))
left = EvalExpression(params.Item(3))
top = EvalExpression(params.Item(4))
width = EvalExpression(params.Item(5))
height = EvalExpression(params.Item(6))

winDC = GetWinDC(winName)

If winDC = 0 Then
    ErrorMsg "Window or control '" & winName & "' does not exist"
    Exit Sub
End If

tempDC = CreateCompatibleDC(winDC)
tempBMP = CreateCompatibleBitmap(winDC, width, height)
SelectObject tempDC, tempBMP
BitBlt tempDC, 0, 0, width, height, winDC, left, top, vbSrcCopy
DeleteDC tempDC

imgName.Add nameStr
imgHandle.Add tempBMP

End Sub


Public Function Func_GetItem(ByVal paramStr As String) As Variant

Dim winName, itemText As String
Dim itemIdx As Integer
Dim itemLen As Long
Dim params As New ArrayClass
Dim ctlObj As Object

paramStr = Trim(paramStr)

ParseParams paramStr, params

winName = EvalExpression(params.Item(1))
itemIdx = EvalExpression(params.Item(2))

Set ctlObj = GetControlObj(winName)

If ctlObj Is Nothing Then
    ErrorMsg "Control '" & winName & "' does not exist"
    Exit Function
End If

If ctlObj.ctlType = "listbox" Then
    itemLen = SendMessage(ctlObj.winHandle, LB_GETTEXTLEN, itemIdx - 1, 0)
    itemText = Space(Abs(itemLen))
    SendMessage ctlObj.winHandle, LB_GETTEXT, itemIdx - 1, ByVal itemText
    Func_GetItem = itemText
ElseIf ctlObj.ctlType = "combobox" Then
    itemLen = SendMessage(ctlObj.winHandle, CB_GETLBTEXTLEN, itemIdx - 1, 0)
    itemText = Space(Abs(itemLen))
    SendMessage ctlObj.winHandle, CB_GETLBTEXT, itemIdx - 1, ByVal itemText
    Func_GetItem = itemText
Else
    ErrorMsg "Control '" & winName & "' needs to be a COMBOBOX or LISTBOX"
End If

End Function

Public Sub Cmd_AddItem(ByVal cmdStr As String)

Dim params As New ArrayClass
Dim winName As String
Dim itemText As String
Dim itemIdx As Integer
Dim ctlObj As Object

ParseParams cmdStr, params

winName = EvalExpression(params.Item(1))
itemText = EvalExpression(params.Item(2))
If params.itemCount = 3 Then itemIdx = EvalExpression(params.Item(3))

Set ctlObj = GetControlObj(winName)

If ctlObj Is Nothing Then
    ErrorMsg "Control '" & winName & "' does not exist"
    Exit Sub
End If

If ctlObj.ctlType = "listbox" Then
    SendMessage ctlObj.winHandle, LB_INSERTSTRING, itemIdx - 1, ByVal itemText
ElseIf ctlObj.ctlType = "combobox" Then
    SendMessage ctlObj.winHandle, CB_INSERTSTRING, itemIdx - 1, ByVal itemText
Else
    ErrorMsg "Control '" & winName & "' needs to be a COMBOBOX or LISTBOX"
End If

End Sub


Public Sub Cmd_Menu(ByVal cmdStr As String)

Dim winName, mText As String
Dim subStr, miText As String
Dim n, a, b, C, mCount As Integer
Dim miStyle As Long
Dim miID As Long
Dim params As New ArrayClass

cmdStr = Trim(cmdStr)

ParseParams cmdStr, params

winName = EvalExpression(params.Item(1))
mText = EvalExpression(params.Item(2))

For n = 1 To windows.itemCount
    If winName = windows.Item(n).winName Then
    With windows.Item(n)
        If .hMenu.itemCount = 0 Then
            .hMenuBar = CreateMenu()
            SetMenu .winHandle, .hMenuBar
        End If
        .hMenu.Add CreatePopupMenu()
        .menuItemID.Add New ArrayClass
        .menuItemSubIdx.Add New ArrayClass
        .menuItemSubType.Add New ArrayClass
        AppendMenu .hMenuBar, MF_STRING Or MF_POPUP, .hMenu.Item(.hMenu.itemCount), mText
        DrawMenuBar .winHandle
        If params.itemCount = 2 Then Exit Sub
        mCount = .hMenu.itemCount
        a = 2
        While a < params.itemCount
            a = a + 1
            If params.Item(a) = "|" Then
                miStyle = MF_STRING Or MF_SEPARATOR
            Else
                miText = EvalExpression(params.Item(a))
                subStr = params.Item(a + 1)
                miStyle = MF_STRING
                miID = mCount & .menuItemID.Item(mCount).itemCount + 1
                .menuItemID.Item(mCount).Add miID
                b = ExistsIn(subStr, subName)
                If b Then
                    .menuItemSubIdx.Item(mCount).Add b
                    .menuItemSubType.Item(mCount).Add SP_SUB
                Else
                    C = ExistsIn(subStr, funcName)
                    If C Then
                        .menuItemSubIdx.Item(mCount).Add C
                        .menuItemSubType.Item(mCount).Add SP_FUNC
                    End If
                End If
                a = a + 1
            End If
            AppendMenu .hMenu.Item(mCount), miStyle, miID, miText
            DrawMenuBar .winHandle
        Wend
        Exit Sub
    End With
    End If
Next n

ErrorMsg "Window '" & winName & "' does exist"

End Sub


Public Sub Cmd_Disable(ByVal cmdStr As String)

Dim winName As String
Dim winHandle As Long

cmdStr = Trim(cmdStr)

winName = EvalExpression(cmdStr)

winHandle = GetWinHandle(winName)

If winHandle = 0 Then
    ErrorMsg "Window '" & winName & "' does not exist"
    Exit Sub
End If

EnableWindow winHandle, False

End Sub
Public Sub Cmd_Enable(ByVal cmdStr As String)

Dim winName As String
Dim winHandle As Long

cmdStr = Trim(cmdStr)

winName = EvalExpression(cmdStr)

winHandle = GetWinHandle(winName)

If winHandle = 0 Then
    ErrorMsg "Window '" & winName & "' does not exist"
    Exit Sub
End If

EnableWindow winHandle, True

End Sub
Public Sub Cmd_Hide(ByVal cmdStr As String)

Dim winHandle As Long
Dim winName As String

cmdStr = Trim(cmdStr)

winName = EvalExpression(cmdStr)

winHandle = GetWinHandle(winName)

If winHandle = 0 Then
    ErrorMsg "Window '" & winName & "' does not exist"
    Exit Sub
End If

ShowWindow winHandle, SW_HIDE

End Sub
Public Sub Cmd_SetText(ByVal cmdStr As String)

Dim winName As String
Dim winText As Variant
Dim winHandle As Long
Dim params As New ArrayClass

cmdStr = Trim(cmdStr)

ParseParams cmdStr, params

winName = EvalExpression(params.Item(1))
winText = EvalExpression(params.Item(2))

winHandle = GetWinHandle(winName)

If winHandle = 0 Then
    ErrorMsg "Window '" & winName & "' does exist"
    Exit Sub
End If

SetWindowText winHandle, CStr(winText)

End Sub

Public Sub Cmd_SetSize(ByVal cmdStr As String)

Dim params As New ArrayClass
Dim winName As String
Dim winWidth, winHeight As Integer
Dim winHandle As Long

cmdStr = Trim(cmdStr)

ParseParams cmdStr, params

winName = EvalExpression(params.Item(1))
winWidth = EvalExpression(params.Item(2))
winHeight = EvalExpression(params.Item(3))

winHandle = GetWinHandle(winName)

If winHandle = 0 Then
    ErrorMsg "Window '" & winName & "' does not exist"
    Exit Sub
End If

SetWindowPos winHandle, 0, 0, 0, winWidth, winHeight, SWP_NOMOVE Or SWP_NOZORDER

End Sub

Public Sub Cmd_SetXY(ByVal cmdStr As String)

Dim params As New ArrayClass
Dim winName As String
Dim winLeft, winTop As Integer
Dim winHandle As Long

cmdStr = Trim(cmdStr)

ParseParams cmdStr, params

winName = EvalExpression(params.Item(1))
winLeft = EvalExpression(params.Item(2))
winTop = EvalExpression(params.Item(3))

winHandle = GetWinHandle(winName)

If winHandle = 0 Then
    ErrorMsg "Window '" & winName & "' does not exist"
    Exit Sub
End If

SetWindowPos winHandle, 0, winLeft, winTop, winWidth, winHeight, SWP_NOSIZE Or SWP_NOZORDER

End Sub


Public Sub Cmd_SetPixel(ByVal cmdStr As String)

Dim params As New ArrayClass
Dim winName As String
Dim X, Y As Integer
Dim color As Long
Dim winDC As Long

cmdStr = Trim(cmdStr)

ParseParams cmdStr, params

winName = EvalExpression(params.Item(1))
X = EvalExpression(params.Item(2))
Y = EvalExpression(params.Item(3))
color = EvalExpression(params.Item(4))

winDC = GetWinDC(winName)

If winDC = 0 Then
    ErrorMsg "Window or control '" & winName & "' does not exist"
    Exit Sub
End If

SetPixel winDC, X, Y, color

End Sub


Public Sub Cmd_GetXY(ByVal cmdStr As String)

Dim params As New ArrayClass
Dim winName, leftVar, topVar As String
Dim winHandle As Long
Dim posRect As RECT

cmdStr = Trim(cmdStr)

ParseParams cmdStr, params

winName = EvalExpression(params.Item(1))
leftVar = params.Item(2)
topVar = params.Item(3)

winHandle = GetWinHandle(winName)

If winHandle = 0 Then
    ErrorMsg "Window '" & winName & "' does not exist"
    Exit Sub
End If

GetWindowRect winHandle, posRect

SetValue leftVar, posRect.left
SetValue topVar, posRect.top

End Sub
Public Sub Cmd_GetSize(ByVal cmdStr As String)

Dim params As New ArrayClass
Dim winName, widthVar, heightVar As String
Dim winWidth, winHeight As Integer
Dim winHandle As Long
Dim sizeRect As RECT

cmdStr = Trim(cmdStr)

ParseParams cmdStr, params

winName = EvalExpression(params.Item(1))
widthVar = params.Item(2)
heightVar = params.Item(3)

winHandle = GetWinHandle(winName)

If winHandle = 0 Then
    ErrorMsg "Window '" & winName & "' does not exist"
    Exit Sub
End If

GetWindowRect winHandle, sizeRect
winWidth = sizeRect.Right - sizeRect.left
winHeight = sizeRect.Bottom - sizeRect.top

SetValue widthVar, winWidth
SetValue heightVar, winHeight

End Sub

Public Sub Cmd_Show(ByVal cmdStr As String)

Dim winHandle As Long
Dim winName As String
Dim a, b, n As Integer

cmdStr = Trim(cmdStr)

winName = EvalExpression(cmdStr)

winHandle = GetWinHandle(winName)

If winHandle = 0 Then
    ErrorMsg "Window '" & winName & "' does not exist"
    Exit Sub
End If

ShowWindow winHandle, SW_SHOW

End Sub


Public Function Func_GetText(ByVal paramStr As String) As Variant

Dim winName, winText As String
Dim winHandle, textLen As Long

paramStr = Trim(paramStr)

winName = EvalExpression(paramStr)

winHandle = GetWinHandle(winName)

If winHandle = 0 Then
    ErrorMsg "Window '" & winName & "' does not exist"
    Exit Function
End If

textLen = GetWindowTextLength(winHandle)
winText = Space(textLen)
GetWindowText winHandle, winText, textLen + 1

Func_GetText = winText

End Function

Public Function Func_hDC(ByVal paramStr As String) As Variant

Dim winName As String
Dim winDC As Long

paramStr = Trim(paramStr)

winName = EvalExpression(paramStr)

winDC = GetWinDC(winName)

If winDC = 0 Then
    ErrorMsg "Window '" & winName & "' does not exist"
    Exit Function
End If

Func_hDC = winDC

End Function


Public Function Func_Date() As Variant

Func_Date = Date

End Function


Public Function Func_Replace(ByVal paramStr As String) As Variant

Dim params As New ArrayClass
Dim searchStr, replaceStr, initStr As String

paramStr = Trim(paramStr)

ParseParams paramStr, params

initStr = EvalExpression(params.Item(1))
searchStr = EvalExpression(params.Item(2))
replaceStr = EvalExpression(params.Item(3))

Func_Replace = Replace(initStr, searchStr, replaceStr)

End Function


Public Function Func_RGB(ByVal paramStr As String) As Variant

On Error Resume Next

Dim params As New ArrayClass
Dim red, green, blue As Long

paramStr = Trim(paramStr)

ParseParams paramStr, params

red = EvalExpression(params.Item(1))
green = EvalExpression(params.Item(2))
blue = EvalExpression(params.Item(3))

Func_RGB = RGB(red, green, blue)

End Function

Public Function Func_String(ByVal paramStr As String) As Variant

Dim params As New ArrayClass
Dim retStr, charStr As String
Dim charNum, n As Long

paramStr = Trim(paramStr)

ParseParams paramStr, params

charNum = EvalExpression(params.Item(1))
charStr = EvalExpression(params.Item(2))

For n = 1 To charNum
    retStr = retStr & charStr
Next n

Func_String = retStr

End Function

Public Function Func_Time() As Variant

Func_Time = Time

End Function

Public Function Func_hWnd(ByVal paramStr As String) As Variant

Dim winName As String
Dim winHandle As Long

paramStr = Trim(paramStr)

winName = EvalExpression(paramStr)

winHandle = GetWinHandle(winName)

If winHandle = 0 Then
    ErrorMsg "Window '" & winName & "' does not exist"
    Exit Function
End If

Func_hWnd = winHandle

End Function


Public Sub Cmd_Pause()

If Me Is mainCode Then
    While Not progDone
        DoEvents
        Sleep 1
    Wend
Else
    lineNum = runCode.itemCount + 1
End If

End Sub
Public Sub Cmd_StopTimer(ByVal cmdStr As String)

Dim tmpName As String

'If debugging Then Exit Sub

tmpName = EvalExpression(cmdStr)

For n = 1 To timerName.itemCount
    If timerName.Item(n) = tmpName Then
        KillTimer 0, timerID.Item(n)
        timerName.Remove n
        timerID.Remove n
        timerSubIdx.Remove n
        timerSubType.Remove n
        Exit Sub
    End If
Next n

End Sub
Public Sub Cmd_Timer(ByVal cmdStr As String)

Dim nameStr, subStr, timeStr As String
Dim timeVal As Variant

'If debugging Then Exit Sub

cmdStr = Trim(cmdStr)

nameStr = GetString(1, cmdStr, ",")
timeStr = GetString(Len(nameStr) + 2, cmdStr, ",")
subStr = Trim(Mid(cmdStr, Len(nameStr) + Len(timeStr) + 3))

timerName.Add EvalExpression(nameStr)
timeVal = EvalExpression(timeStr)

For a = 1 To subName.itemCount
    If subStr = subName.Item(a) Then
        timerSubIdx.Add a
        timerSubType.Add SP_SUB
        timerID.Add SetTimer(0, 0, timeVal, AddressOf TimerProc)
        Exit Sub
    End If
Next a

For b = 1 To funcName.itemCount
    If (subStr & "()" = funcName.Item(b) & ")") Or (subStr = left(funcName.Item(b), Len(funcName.Item(b)) - 1)) Then
        timerSubIdx.Add b
        timerSubType.Add SP_FUNC
        timerID.Add SetTimer(0, 0, timeVal, AddressOf TimerProc)
        Exit Sub
    End If
Next b


End Sub
Public Sub Cmd_TextColor(ByVal cmdStr As String)

Dim color As Variant

cmdStr = Trim(cmdStr)

color = EvalExpression(cmdStr)

output.display.ForeColor = color

End Sub
Public Function Func_Word(ByVal paramStr As String) As Variant

Dim params As New ArrayClass
Dim strExp, strDel As String
Dim wordNum As Long
Dim wordList() As String

paramStr = Trim(paramStr)

ParseParams paramStr, params

strDel = " "
strExp = EvalExpression(params.Item(1))
wordNum = EvalExpression(params.Item(2))

If params.itemCount = 3 Then strDel = EvalExpression(params.Item(3))

wordList = Split(strExp, strDel)

If wordNum > 0 And wordNum <= UBound(wordList) + 1 Then
    Func_Word = wordList(wordNum - 1)
End If

End Function

Public Sub LoadDLL(ByVal cmdStr As String)
    
End Sub


Public Function RunBlock(ByVal startLne As Integer, ByVal endLne As Integer) As Boolean

Dim ifNum, whileNum, forNum, selectNum As Integer
Dim n As Integer

RunBlock = True

If LCase(left(runCode.Item(startLne), 3)) = "if " Then
    ifNum = 0
    If LCase(Right(runCode.Item(startLne), 5)) = " then" Then
        For n = startLne To endLne
            If (LCase(Trim(runCode.Item(n))) = "end if" And ifNum = 0) Then
                RunIfBlock startLne, n - 1, False
                n = endLne
            ElseIf (LCase(left(LTrim(runCode.Item(n)), 3)) = "if ") And (n > startLne) Then
                If LCase(Right(runCode.Item(n), 5)) = " then" Then
                    ifNum = ifNum + 1
                End If
            ElseIf LCase(Trim(runCode.Item(n))) = "end if" Then
                ifNum = ifNum - 1
            End If
        Next n
    Else
       RunIfBlock startLne, 0, True
    End If
ElseIf LCase(left(runCode.Item(startLne), 6)) = "while " Then
    whileNum = 0
    For n = startLne To endLne
        If (LCase(Trim(runCode.Item(n))) = "wend" And whileNum = 0) Then
            RunWhileBlock startLne, n - 1
            If progDone Then Exit Function
            n = runCode.itemCount
        ElseIf (LCase(left(LTrim(runCode.Item(n)), 6)) = "while ") And (n > startLne) Then
            whileNum = whileNum + 1
        ElseIf LCase(Trim(runCode.Item(n))) = "wend" Then
            whileNum = whileNum - 1
        End If
    Next n
ElseIf LCase(left(runCode.Item(startLne), 4)) = "for " Then
    forNum = 0
    For n = startLne To endLne
        If (LCase(left(runCode.Item(n), 5)) = "next " And forNum = 0) Then
            RunForBlock startLne, n - 1
            If progDone Then Exit Function
            n = runCode.itemCount
        ElseIf (LCase(left(LTrim(runCode.Item(n)), 4)) = "for ") And (n > startLne) Then
            forNum = forNum + 1
        ElseIf LCase(left(runCode.Item(n), 5)) = "next " Then
            forNum = forNum - 1
        End If
    Next n
ElseIf LCase(left(runCode.Item(startLne), 12)) = "select case " Then
    selectNum = 0
    For n = startLne To endLne
        If (LCase(Trim(runCode.Item(n))) = "end select" And selectNum = 0) Then
            RunSelectBlock startLne, n - 1
            If progDone Then Exit Function
            n = runCode.itemCount
        ElseIf (LCase(left(LTrim(runCode.Item(n)), 12)) = "select case ") And (n > startLne) Then
            selectNum = selectNum + 1
        ElseIf LCase(Trim(runCode.Item(n))) = "end select" Then
            selectNum = selectNum - 1
        End If
    Next n
Else
    RunBlock = False
End If



End Function
Public Sub Cmd_Data(ByVal cmdStr As String)

Dim dataItems As New ArrayClass
Dim a As Integer

cmdStr = Trim(cmdStr)

ParseParams cmdStr, dataItems

For a = dataItems.itemCount To 1 Step -1
    dataList.Add EvalExpression(dataItems.Item(a)), 1
Next a

End Sub
Public Sub Cmd_On(ByVal cmdStr As String)

Dim tmpLabelList As New ArrayClass
Dim valueStr, labelStr, tmpLabel, cmdType As String
Dim valNum As Variant
Dim a, b As Integer

    cmdStr = Trim(cmdStr)

'Get the value if it is an ON...GOTO command
valueStr = GetString(1, LCase(cmdStr), " goto ")
valueStr = left(cmdStr, Len(valueStr))
b = Len(valueStr) + 6
cmdType = "goto"

'If not, then get the value if it is an ON...GOSUB command
If Len(valueStr) = Len(cmdStr) Then
    valueStr = GetString(1, LCase(cmdStr), " gosub ")
    valueStr = left(cmdStr, Len(valueStr))
    b = Len(valueStr) + 7
    cmdType = "gosub"
End If

'Evalute the value
valNum = EvalExpression(valueStr)

'Get list of branch labels
labelStr = Trim(Right(cmdStr, Len(cmdStr) - b))

'Section out each branch label
b = 1
While b <= Len(labelStr)
    tmpLabel = GetString(b, labelStr, ",")
    b = Len(tmpLabel) + b + 1
    tmpLabelList.Add Trim(tmpLabel)
Wend

'Decide which label to jump to
If valNum > 0 And valNum <= tmpLabelList.itemCount Then
    If cmdType = "goto" Then
        Cmd_GoTo tmpLabelList.Item(valNum)
    ElseIf cmdType = "gosub" Then
        Cmd_GoSub tmpLabelList.Item(valNum)
    End If
End If


End Sub
Public Sub Cmd_OnError(ByVal cmdStr As String)

    cmdStr = Trim(cmdStr)

onErrorCmd = cmdStr


End Sub

Public Sub Cmd_Read(ByVal cmdStr As String)

Dim varList As New ArrayClass
Dim a As Integer

cmdStr = Trim(cmdStr)

ParseParams cmdStr, varList

For a = 1 To varList.itemCount
    If readPos > dataList.itemCount Then
        ErrorMsg "Read past end of Data"
        Exit Sub
    End If
    SetValue varList.Item(a), dataList.Item(readPos)
    readPos = readPos + 1
Next a

End Sub

Public Sub Cmd_Restore(ByVal cmdStr As String)

Dim resVal As Integer

    cmdStr = Trim(cmdStr)

If cmdStr = "" Then
    readPos = 1
Else
    resVal = EvalExpression(cmdStr)
    If resVal > 0 And resVal <= dataList.itemCount Then
        readPos = resVal
    Else
        ErrorMsg "Restore beyond Data bounds"
        Exit Sub
    End If
End If
    

End Sub
Public Sub ErrorMsg(msgStr As String)

If onErrorCmd = "" Then
    MsgBox "Something unexpected has happened and I can't go on: " & vbCrLf & _
            vbCrLf & _
            Space(10) & msgStr & vbCrLf & _
            vbCrLf & _
            "Awfully sorry about that. Please don't blame yourself.", _
            vbCritical, "Lithium BASIC Runtime"
    progDone = True
    errorFlag = True
Else
    SetValue "ErrorMsg", msgStr
    RunCmd onErrorCmd
End If


End Sub

Public Sub Cmd_Array(ByVal cmdStr As String)

Dim str As String

  cmdStr = Trim(cmdStr)
  varStr = GetString(1, cmdStr, " ")
  idxStr = GetString(Len(GetString(1, varStr, "(")) + 2, varStr, ")")
  firstIdx = GetString(1, idxStr, ",")
  firstVal = EvalExpression(firstIdx)
  If firstVal < 0 Then ErrorMsg "Runtime error: Illegal index value": Exit Sub
  isMultiDim.Add False
  If Len(firstIdx) < Len(idxStr) Then
      secondIdx = Right(idxStr, Len(idxStr) - (Len(firstIdx) + 1))
      secondVal = EvalExpression(secondIdx)
      If secondVal < 0 Then ErrorMsg "Runtime error: Illegal index value": Exit Sub
      isMultiDim.Item(isMultiDim.itemCount) = True
  End If
  str = Trim(Right(cmdStr, Len(cmdStr) - Len(varStr)))
  If LCase(Trim(Right(str, Len(str) - 3))) = "string" Then
    arrayType.Add DT_STRING
  ElseIf LCase(Trim(Right(str, Len(str) - 3))) = "number" Then
    arrayType.Add DT_NUMBER
  End If
  arrayValue.Add New ArrayClass
  For n = 0 To firstVal
      If isMultiDim.Item(isMultiDim.itemCount) Then
          arrayValue.Item(arrayValue.itemCount).Add New ArrayClass
          For i = 0 To secondVal
            If arrayType.Item(arrayType.itemCount) = DT_STRING Then
                arrayValue.Item(arrayValue.itemCount).Item(n + 1).Add ""
            Else
                arrayValue.Item(arrayValue.itemCount).Item(n + 1).Add 0
            End If
          Next i
      Else
          If arrayType.Item(arrayType.itemCount) = DT_STRING Then
              arrayValue.Item(arrayValue.itemCount).Add ""
          Else
              arrayValue.Item(arrayValue.itemCount).Add 0
          End If
      End If
  Next n
  arrayName.Add left(varStr, Len(GetString(1, varStr, "(")) + 1)

End Sub

Public Sub Cmd_GoSub(ByVal cmdStr As String)

  cmdStr = Trim(cmdStr)
  
  For n = 1 To labelName.itemCount
    If cmdStr = labelName.Item(n) Then
        gosubLine = lineNum
        lineNum = labelLine.Item(n)
    End If
  Next n


End Sub
Public Sub Cmd_BindVar(ByVal cmdStr As String)

  cmdStr = Trim(cmdStr)
  tmpStr = GetString(1, LCase(cmdStr), " to ")
  var1Str = Trim(Mid(tmpStr, 1, Len(tmpStr)))
  var2Str = Trim(Right(cmdStr, Len(cmdStr) - (Len(tmpStr) + 4)))
  For n = 1 To varName.itemCount
    If varName.Item(n) = var2Str Then
        For a = 1 To varName.itemCount
          If varName.Item(a) = var1Str Then
            varBindList.Item(n).Add a
            Exit Sub
          End If
        Next a
    End If
  Next n

End Sub


Public Sub Cmd_Call(ByVal cmdStr As String)

Dim subObj As New SubProgClass
Dim tmpName, tmpParam As String

cmdStr = Trim(cmdStr)

tmpName = GetString(1, cmdStr, " ")

For a = 1 To subName.itemCount
    If tmpName = subName.Item(a) Then
        For b = 1 To subParams.Item(a).itemCount
            'Make the parameter definitions into local sub variables
            subObj.Cmd_Var subParams.Item(a).Item(b)
        Next b
        'Load the lines of code into the sub
        For b = 1 To subRunCode.Item(a).itemCount
            subObj.runCode.Add subRunCode.Item(a).Item(b)
        Next b
        'Tell the sub its name
        subObj.subProgName = tmpName
        'Tell the sub what sub program is calling it
        Set subObj.prevSubProg = Me
    End If
Next a

'Fill the parameter variables with the arguments
n = 1
b = Len(tmpName) + 2
While b <= Len(cmdStr)
    tmpParam = GetString(b, cmdStr, ",")
    b = Len(tmpParam) + b + 1
    subObj.varValue.Item(n) = EvalExpression(tmpParam)
    n = n + 1
Wend

'Start running the sub
subObj.RunProg

End Sub


Public Sub Cmd_ConsolTitle(ByVal cmdStr As String)

  cmdStr = Trim(cmdStr)
  output.Caption = EvalExpression(cmdStr)

End Sub


Public Sub Cmd_GoTo(ByVal cmdStr As String)

  cmdStr = Trim(cmdStr)
  For n = 1 To labelName.itemCount
    If cmdStr = labelName.Item(n) Then lineNum = labelLine.Item(n)
  Next n

End Sub

Public Sub Cmd_Return()

cmdStr = Trim(cmdStr)

If gosubLine = 0 Then
    ErrorMsg "RETURN without GOSUB"
    Exit Sub
Else
    lineNum = gosubLine
    gosubLine = 0
End If

End Sub

Public Sub Cmd_Seek(ByVal cmdStr As String)

Dim handleStr As String
Dim seekVal As Long
Dim a As Integer

cmdStr = Trim(cmdStr)

handleStr = GetString(1, cmdStr, ",")
seekVal = EvalExpression(Mid(cmdStr, Len(handleStr) + 2))
handleStr = Trim(handleStr)

For a = 1 To fileHandle.itemCount
    If fileHandle.Item(a) = handleStr Then
        If seekVal > LOF(FileNumber.Item(a)) Then
            ErrorMsg "Past end of file"
            Exit Sub
        End If
        Seek #FileNumber.Item(a), seekVal
        Exit Sub
    End If
Next a

ErrorMsg "File handle does not exist: " & handleStr


End Sub


Public Sub Cmd_Control(ByVal cmdStr As String)

Dim params As New ArrayClass
Dim tmpParam As String
Dim b, winIdx As Integer
Dim style, exStyle, defStyle As Long
Dim winName, winTitle, winType, parentName As String
Dim winX, winY, winWidth, winHeight As Integer
Dim className As String

cmdStr = Trim(cmdStr)

b = 1
While b <= Len(cmdStr)
    tmpParam = GetString(b, cmdStr, ",")
    b = Len(tmpParam) + b + 1
    params.Add Trim(tmpParam)
Wend

winName = EvalExpression(params.Item(1))
parentName = EvalExpression(params.Item(2))
winTitle = EvalExpression(params.Item(3))
winType = LCase(params.Item(4))
winX = EvalExpression(params.Item(5))
winY = EvalExpression(params.Item(6))
winWidth = EvalExpression(params.Item(7))
winHeight = EvalExpression(params.Item(8))

style = 0
exStyle = WS_EX_CLIENTEDGE
defStyle = WS_VISIBLE Or WS_CHILD

Select Case winType
    Case "button"
        exStyle = 0
        className = "BUTTON"
    Case "statictext"
        exStyle = 0
        className = "STATIC"
    Case "texteditor"
        style = WS_VSCROLL Or WS_HSCROLL Or ES_MULTILINE Or ES_NOHIDESEL
        className = "EDIT"
    Case "textbox"
        style = ES_NOHIDESEL
        className = "EDIT"
    Case "listbox"
        style = LBS_NOTIFY
        className = "LISTBOX"
    Case "combobox"
        style = CBS_DROPDOWN
        className = "COMBOBOX"
    Case "drawbox"
        style = WS_BORDER
        className = "MBGraphWin"
    Case "picbutton"
        exStyle = 0
        style = BS_BITMAP
        className = "BUTTON"
    Case "checkbox"
        exStyle = 0
        style = BS_AUTOCHECKBOX
        className = "BUTTON"
    Case "radiobutton"
        exStyle = 0
        style = BS_AUTORADIOBUTTON
        className = "BUTTON"
    Case "groupbox"
        exStyle = 0
        style = BS_GROUPBOX
        className = "BUTTON"
    Case Else
        Exit Sub
End Select

If windows.itemCount = 0 Then
    ErrorMsg "Window does not exist: '" & parentName & "'"
    Exit Sub
End If

For b = 1 To windows.itemCount
    If parentName = windows.Item(b).winName Then
        winIdx = b
        Exit For
    ElseIf b = windows.itemCount Then
        ErrorMsg "Window does not exist: '" & parentName & "'"
        Exit Sub
    End If
Next b

With windows.Item(winIdx).Controls
    .Add New ControlClass
    .Item(.itemCount).winName = winName
    .Item(.itemCount).ctlType = winType
    .Item(.itemCount).winHandle = CreateWindowEx(exStyle, className, winTitle, _
                                    style Or defStyle, winX, winY, winWidth, winHeight, _
                                    windows.Item(winIdx).winHandle, 0&, App.hInstance, 0&)
    .Item(.itemCount).ctlWndProc = SetWindowLong(.Item(.itemCount).winHandle, GWL_WNDPROC, AddressOf CtlProc)
    .Item(.itemCount).winDC = GetDC(.Item(.itemCount).winHandle)
    .Item(.itemCount).redrawDC = CreateCompatibleDC(.Item(.itemCount).winDC)
    UpdateWindow .Item(.itemCount).winHandle
End With

End Sub

Public Sub Cmd_Input(ByVal cmdStr As String)

Dim varStr, expStr, tmpHandle, tmpVal As String
Dim a, b As Integer

  cmdStr = Trim(cmdStr)
  
If left(cmdStr, 1) = "#" Then
    tmpHandle = GetString(1, cmdStr, ",")
    b = Len(tmpHandle) + 2
    tmpHandle = Trim(tmpHandle)
    For a = 1 To fileHandle.itemCount
      If fileHandle.Item(a) = tmpHandle Then
        Select Case fileType.Item(a)
            Case FT_OUTPUT
                ErrorMsg "File opened in OUTPUT mode cannot be inputted from"
            Case FT_APPEND
                ErrorMsg "File opened in APPEND mode cannot be inputted from"
            Case FT_BINARY
                varStr = Mid(cmdStr, b)
                Input #FileNumber.Item(a), tmpVal
                MsgBox tmpVal
                SetValue varStr, tmpVal
            Case Else
                While b <= Len(cmdStr)
                    varStr = GetString(b, cmdStr, ",")
                    b = b + Len(varStr) + 1
                    Input #FileNumber.Item(a), tmpVal
                    SetValue varStr, tmpVal
                Wend
        End Select
        Exit Sub
      End If
    Next a
    ErrorMsg "File handle does not exist: " & tmpHandle
    Exit Sub
Else
    expStr = GetString(1, cmdStr, ",")
  '*** If there is a prompt in the command ***
    If expStr <> cmdStr Then
      output.display.Text = output.display.Text & EvalExpression(expStr)
      expStr = Mid(cmdStr, Len(expStr) + 2, Len(cmdStr) - (Len(expStr) + 1))
    End If
  '*******************************************
    expStr = Trim(expStr)
    inputting = True
    While inputting And Not progDone
      DoEvents
      Sleep 1
    Wend
    SetValue expStr, userInput
    userInput = ""
End If


End Sub
Public Sub Cmd_Let(ByVal cmdStr As String)

  cmdStr = Trim(cmdStr)
  varStr = GetString(1, cmdStr, "=")
  expStr = Mid(cmdStr, Len(varStr) + 2, Len(cmdStr) - (Len(varStr) + 1))
  varStr = Trim(varStr)
  SetValue varStr, EvalExpression(expStr)

End Sub
Public Sub Cmd_Print(ByVal cmdStr As String)

Dim tmpHandle, tmpExp As String
Dim tmpVal As String
Dim b As Integer
Dim noRet As Boolean

cmdStr = Trim(cmdStr)

If Right(cmdStr, 1) = ";" Then
    noRet = True
    cmdStr = left(cmdStr, Len(cmdStr) - 1)
Else
    noRet = False
End If

If left(cmdStr, 1) = "#" Then
    tmpHandle = GetString(1, cmdStr, ",")
    tmpExp = Right(cmdStr, Len(cmdStr) - (Len(tmpHandle) + 1))
    tmpHandle = Trim(tmpHandle)
    tmpVal = EvalExpression(tmpExp)
    For b = 1 To fileHandle.itemCount
        If fileHandle.Item(b) = tmpHandle Then
            Select Case fileType.Item(b)
                Case FT_INPUT
                    ErrorMsg "File opened in INPUT mode cannot be printed to"
                Case FT_BINARY
                    Put #FileNumber.Item(b), , tmpVal
                Case Else
                    If noRet Then
                        Print #FileNumber.Item(b), tmpVal;
                    Else
                        Print #FileNumber.Item(b), tmpVal
                    End If
            End Select
            Exit Sub
        End If
    Next b
    ErrorMsg "File handle does not exist: " & tmpHandle
Else
    If noRet Then
        output.display.Text = output.display.Text & EvalExpression(cmdStr)
    Else
        output.display.Text = output.display.Text & EvalExpression(cmdStr) & vbCrLf
    End If
End If

End Sub


Public Function Func_Input(ByVal paramStr As String) As Variant

Dim params As New ArrayClass
Dim lenVal As Long
Dim a As Integer

paramStr = Trim(paramStr)

ParseParams paramStr, params

a = ExistsIn(params.Item(1), fileHandle)
lenVal = EvalExpression(params.Item(2))

If a Then
    Select Case fileType.Item(a)
        Case FT_OUTPUT
            ErrorMsg "File opened in OUTPUT mode cannot be inputted from"
        Case FT_APPEND
            ErrorMsg "File opened in APPEND mode cannot be inputted from"
    End Select
    Func_Input = Input(lenVal, FileNumber.Item(a))
Else
    ErrorMsg "File handle does not exist: " & params.Item(1)
End If

End Function


Public Sub Cmd_ReDim(ByVal cmdStr As String)

Dim rdObj As SubProgClass
Dim n, i As Integer

cmdStr = Trim(cmdStr)

If ObjPtr(Me) <> ObjPtr(mainCode) Then
    Set rdObj = Me
    GoSub doReDim
End If

Set rdObj = mainCode
GoSub doReDim

Exit Sub


doReDim:
For n = 1 To rdObj.arrayName.itemCount
  If left(cmdStr, Len(rdObj.arrayName.Item(n))) = rdObj.arrayName.Item(n) And Right(cmdStr, 1) = ")" Then
      idxStr = GetString(Len(GetString(1, cmdStr, "(")) + 2, cmdStr, ")")
      firstIdx = GetString(1, idxStr, ",")
      firstVal = EvalExpression(firstIdx)
      If firstVal < 0 Then ErrorMsg "Runtime error: Illegal index value": Exit Sub
      rdObj.isMultiDim.Item(n) = False
      If Len(firstIdx) < Len(idxStr) Then
          secondIdx = Right(idxStr, Len(idxStr) - (Len(firstIdx) + 1))
          secondVal = EvalExpression(secondIdx)
          If secondVal < 0 Then ErrorMsg "Runtime error: Illegal index value": Exit Sub
          rdObj.isMultiDim.Item(n) = True
      End If
      For i = rdObj.arrayValue.Item(n).itemCount To 1 Step -1
          rdObj.arrayValue.Item(n).Remove i
      Next i
      For i = 0 To firstVal
          If rdObj.isMultiDim.Item(n) Then
              rdObj.arrayValue.Item(n).Add New ArrayClass
              For a = 0 To secondVal
                If rdObj.arrayType.Item(n) = DT_STRING Then
                    rdObj.arrayValue.Item(n).Item(i + 1).Add ""
                Else
                    rdObj.arrayValue.Item(n).Item(i + 1).Add 0
                End If
              Next a
          Else
              If rdObj.arrayType.Item(n) = DT_STRING Then
                  rdObj.arrayValue.Item(n).Add ""
              Else
                  rdObj.arrayValue.Item(n).Add 0
              End If
          End If
      Next i
      Exit Sub
  End If
Next n
Return

End Sub

Public Sub Cmd_UnbindVar(ByVal cmdStr As String)

  cmdStr = Trim(cmdStr)
  tmpStr = GetString(1, LCase(cmdStr), " from ")
  var1Str = Trim(Mid(tmpStr, 1, Len(tmpStr)))
  var2Str = Trim(Right(cmdStr, Len(cmdStr) - (Len(tmpStr) + 6)))
  For n = 1 To varName.itemCount
    If varName.Item(n) = var2Str Then
        For a = 1 To varBindList.Item(n).itemCount
            If varName.Item(varBindList.Item(n).Item(a)) = var1Str Then
                varBindList.Item(n).Remove a
                Exit Sub
            End If
        Next a
        ErrorMsg "Variable cannot be unbound"
        Exit Sub
    End If
  Next n

End Sub
Public Sub Cmd_Var(ByVal cmdStr As String)

Dim tmpVar, varStr, typeStr As String

  cmdStr = Trim(cmdStr)

varStr = GetString(1, LCase(cmdStr), " as ")
varStr = left(cmdStr, Len(varStr))

typeStr = LCase(Trim(Right(cmdStr, Len(cmdStr) - (Len(varStr) + 4))))

b = 1
While b <= Len(varStr)
    tmpVar = GetString(b, varStr, ",")
    b = Len(tmpVar) + b + 1
    If typeStr = "number" Then
        varType.Add DT_NUMBER
        varValue.Add 0
    ElseIf typeStr = "string" Then
        varType.Add DT_STRING
        varValue.Add ""
    End If
    varName.Add Trim(tmpVar)
    varBindList.Add New ArrayClass
Wend

End Sub


Public Sub Cmd_Window(ByVal cmdStr As String)

Dim params As New ArrayClass
Dim tmpParam As String
Dim b As Integer
Dim style, parent As Long
Dim winName, winTitle, winType As String
Dim winX, winY, winWidth, winHeight As Integer

cmdStr = Trim(cmdStr)

b = 1
While b <= Len(cmdStr)
    tmpParam = GetString(b, cmdStr, ",")
    b = Len(tmpParam) + b + 1
    params.Add Trim(tmpParam)
Wend

winName = EvalExpression(params.Item(1))
winTitle = EvalExpression(params.Item(2))
winType = LCase(params.Item(3))
winX = EvalExpression(params.Item(4))
winY = EvalExpression(params.Item(5))
winWidth = EvalExpression(params.Item(6))
winHeight = EvalExpression(params.Item(7))

Select Case winType
    Case "normal"
        style = WS_OVERLAPPEDWINDOW
    Case "dialog"
        style = WS_SYSMENU Or WS_DLGFRAME
    Case "dialog_modal"
        style = WS_SYSMENU Or WS_DLGFRAME Or WS_EX_DLGMODALFRAME
        If windows.itemCount > 0 Then
            parent = windows.Item(windows.itemCount).winHandle
            EnableWindow parent, False
        End If
    Case "popup"
        style = WS_POPUP
End Select

windows.Add New WindowClass

With windows.Item(windows.itemCount)
    .winName = winName
    .winType = winType
    .winHandle = CreateWindowEx(0&, "MicroByteWin", winTitle, _
                            style Or WS_VISIBLE, _
                            winX, winY, winWidth, winHeight, parent, 0&, App.hInstance, 0&)
    .winDC = GetDC(.winHandle)
    .redrawDC = CreateCompatibleDC(.winDC)
    UpdateWindow .winHandle
End With


End Sub


Public Sub Cmd_Stick(ByVal cmdStr As String)

Dim winName As String
Dim winDC, redrawDC, winHandle, tmpBmp As Long
Dim winRect As RECT
Dim width, height As Integer

cmdStr = Trim(cmdStr)

winName = EvalExpression(cmdStr)

winHandle = GetWinHandle(winName)
If winHandle = 0 Then
    ErrorMsg "Window or control '" & winName & "' does not exist"
    Exit Sub
End If
winDC = GetWinDC(winName)
redrawDC = GetWinRedrawDC(winName)

GetWindowRect winHandle, winRect
width = winRect.Right - winRect.left
height = winRect.Bottom - winRect.top

tmpBmp = CreateCompatibleBitmap(winDC, width, height)
DeleteObject SelectObject(redrawDC, tmpBmp)
BitBlt redrawDC, 0, 0, width, height, winDC, 0, 0, vbSrcCopy

End Sub


Public Sub Cmd_CloseWindow(ByVal cmdStr As String)

Dim n As Integer

cmdStr = EvalExpression(Trim(cmdStr))

For n = 1 To windows.itemCount
    If cmdStr = windows.Item(n).winName Then
        DestroyWindow windows.Item(n).winHandle
        Exit Sub
    End If
Next n

ErrorMsg "Window does not exist: '" & cmdStr & "'"


End Sub
Public Sub Cmd_Run(ByVal cmdStr As String)

Dim fileStr, modeStr As String
Dim mode As Integer

cmdStr = Trim(cmdStr)

mode = vbNormalFocus

fileStr = GetString(1, cmdStr, ",")

If Len(fileStr) < Len(cmdStr) Then
    modeStr = Trim(LCase(Mid(cmdStr, Len(fileStr) + 2)))
    Select Case modeStr
        Case "hide"
            mode = vbHide
        Case "minimized"
            mode = vbMinimizedFocus
        Case "maximized"
            mode = vbMaximizedFocus
    End Select
End If

fileStr = EvalExpression(fileStr)

Shell fileStr, mode


End Sub
Public Sub Cmd_Swap(ByVal cmdStr As String)

Dim var1, var2 As String
Dim value1, value2 As Variant
Dim a As Integer

    cmdStr = Trim(cmdStr)

'Seperate the two variables/arrays
var1 = GetString(1, cmdStr, ",")
a = Len(var1) + 1
var2 = Right(cmdStr, Len(cmdStr) - a)

'Trim the spaces from them
var1 = Trim(var1)
var2 = Trim(var2)

'Get the value of each
value1 = EvalExpression(var1)
value2 = EvalExpression(var2)

'Swap the two values
SetValue var1, value2
SetValue var2, value1


End Sub
Public Sub Cmd_Open(ByVal cmdStr As String)

Dim tmpFile, tmpType, tmpHandle As String
Dim a, tmpFileNum As Integer

    cmdStr = Trim(cmdStr)

'Parse out file path
tmpFile = GetString(1, LCase(cmdStr), " for ")
tmpFile = left(cmdStr, Len(tmpFile))
a = Len(tmpFile) + 6

'Parse out file type
tmpType = GetString(a, LCase(cmdStr), " as ")
tmpType = Mid(cmdStr, a, Len(tmpType))
a = a + Len(tmpType) + 3
tmpType = Trim(LCase(tmpType))

'Parse out file handle
tmpHandle = Trim(Right(cmdStr, Len(cmdStr) - a))

'Check to see if handle is already in use
For a = 1 To fileHandle.itemCount
    If fileHandle.Item(a) = tmpHandle Then
        ErrorMsg "File handle already in use: " & tmpHandle
        Exit Sub
    End If
Next a

'Get the next free file number
tmpFileNum = FreeFile

'Add new file handle and file number
fileHandle.Add tmpHandle
FileNumber.Add tmpFileNum

'Evaluate file path string expression
tmpFile = EvalExpression(tmpFile)

'Open file
Select Case tmpType
    Case "input"
        'Check to see if file exists
        If Dir(tmpFile) = "" Then
            ErrorMsg "File does not exists: " & tmpFile
            Exit Sub
        End If
        fileType.Add FT_INPUT
        Open tmpFile For Input As tmpFileNum
    Case "output"
        fileType.Add FT_OUTPUT
        Open tmpFile For Output As tmpFileNum
    Case "append"
        fileType.Add FT_APPEND
        Open tmpFile For Append As tmpFileNum
    Case "binary"
        fileType.Add FT_BINARY
        Open tmpFile For Binary As tmpFileNum
End Select


End Sub

Public Function Func_Asc(ByVal paramStr As String) As Variant

On Error Resume Next

paramStr = Trim(paramStr)

Func_Asc = Asc(EvalExpression(paramStr))

End Function


Public Function Func_Not(ByVal paramStr As String) As Variant

paramStr = Trim(paramStr)

  Func_Not = (Not EvalExpression(paramStr))

End Function

Public Function Func_Len(ByVal paramStr As String) As Variant

paramStr = Trim(paramStr)

  Func_Len = Len(EvalExpression(paramStr))


End Function
Public Function Func_Rnd() As Variant
  
  Randomize
  Func_Rnd = Rnd

End Function
Public Function Func_Val(ByVal paramStr As String) As Variant

paramStr = Trim(paramStr)

  Func_Val = Val(EvalExpression(paramStr))

End Function
Public Function Func_Chr(ByVal paramStr As String) As Variant

paramStr = Trim(paramStr)

Func_Chr = Chr(EvalExpression(paramStr))

End Function


Public Function Func_Collide(ByVal paramStr As String) As Variant

Dim params As New ArrayClass
Dim winName, sprite1, sprite2 As String
Dim a, b As Integer
Dim winObj As Object

ParseParams paramStr, params

winName = EvalExpression(params.Item(1))
sprite1 = EvalExpression(params.Item(2))
sprite2 = EvalExpression(params.Item(3))

Set winObj = GetWindowObj(winName)

If winObj Is Nothing Then
    ErrorMsg "Window or control '" & winName & "' does not exist"
    Exit Function
End If

a = ExistsIn(sprite1, winObj.spriteName)
If a = 0 Then
    ErrorMsg "Sprite '" & nameStr & "' does not exist in window or control '" & winName & "'"
    Exit Function
End If
b = ExistsIn(sprite2, winObj.spriteName)
If b = 0 Then
    ErrorMsg "Sprite '" & nameStr & "' does not exist in window or control '" & winName & "'"
    Exit Function
End If

With winObj.sprites
    If .Item(a).left < .Item(b).left + .Item(b).width And _
       .Item(a).left + .Item(a).width > .Item(b).left And _
       .Item(a).top < .Item(b).top + .Item(b).height And _
       .Item(a).top + .Item(a).height > .Item(b).top Then
          Func_Collide = 1
    End If
End With

End Function


Public Function Func_Str(ByVal paramStr As String) As Variant

paramStr = Trim(paramStr)

  Func_Str = str(EvalExpression(paramStr))

End Function


Public Function Func_Upper(ByVal paramStr As String) As Variant

paramStr = Trim(paramStr)

  Func_Upper = UCase(EvalExpression(paramStr))

End Function
Public Function Func_Lower(ByVal paramStr As String) As Variant

paramStr = Trim(paramStr)

  Func_Lower = LCase(EvalExpression(paramStr))

End Function
Public Function Func_Trim(ByVal paramStr As String) As Variant

paramStr = Trim(paramStr)

  Func_Trim = Trim(EvalExpression(paramStr))

End Function









Public Function Func_Mid(ByVal paramStr As String) As Variant

Dim params As New ArrayClass
Dim stringVal As String
Dim starting, length As Integer

paramStr = Trim(paramStr)

ParseParams paramStr, params

stringVal = EvalExpression(params.Item(1))
starting = EvalExpression(params.Item(2))

If params.itemCount = 3 Then
    length = EvalExpression(params.Item(3))
    Func_Mid = Mid(stringVal, starting, length)
Else
    Func_Mid = Mid(stringVal, starting)
End If

End Function
Public Function Func_Left(ByVal paramStr As String) As Variant

Dim paramList As New ArrayClass

paramStr = Trim(paramStr)

    param = GetString(1, paramStr, ",")
    paramList.Add EvalExpression(param)
    a = Len(param) + 2
    paramList.Add EvalExpression(GetString(a, paramStr, ")"))
    Func_Left = left(paramList.Item(1), paramList.Item(2))

End Function
Public Function Func_Right(ByVal paramStr As String) As Variant

Dim paramList As New ArrayClass

paramStr = Trim(paramStr)

    param = GetString(1, paramStr, ",")
    paramList.Add EvalExpression(param)
    a = Len(param) + 2
    paramList.Add EvalExpression(GetString(a, paramStr, ")"))
    Func_Right = Right(paramList.Item(1), paramList.Item(2))

End Function


Public Function Func_GetState(ByVal paramStr As String)

Dim winName As String
Dim ctlState As Integer
Dim ctlObj As Object

paramStr = Trim(paramStr)

winName = EvalExpression(paramStr)

Set ctlObj = GetControlObj(winName)

If ctlObj Is Nothing Then
    ErrorMsg "Control '" & winName & "' does not exist"
    Exit Function
End If

If ctlObj.ctlType = "radiobutton" Or ctlObj.ctlType = "checkbox" Then
    ctlState = SendMessage(ctlObj.winHandle, BM_GETCHECK, 0, 0)
    Func_GetState = ctlState
Else
    ErrorMsg "Control '" & winName & "' needs to be a RADIOBUTTON or CHECKBOX"
End If

End Function


Public Function Func_InStr(ByVal paramStr As String) As Variant

Dim params As New ArrayClass
Dim string1, string2 As String
Dim starting As Integer

paramStr = Trim(paramStr)

ParseParams paramStr, params

string1 = EvalExpression(params.Item(1))
string2 = EvalExpression(params.Item(2))
If params.itemCount = 3 Then starting = EvalExpression(params.Item(3))

If params.itemCount = 3 Then
    Func_InStr = InStr(starting, string1, string2)
Else
    Func_InStr = InStr(0, string1, string2)
End If

End Function

Public Function Func_Int(ByVal paramStr As String) As Variant

paramStr = Trim(paramStr)

  Func_Int = Int(EvalExpression(paramStr))

End Function
Public Function Func_Abs(ByVal paramStr As String) As Variant

paramStr = Trim(paramStr)

  Func_Abs = Abs(EvalExpression(paramStr))


End Function

Public Sub RunCmd(ByVal cmdStr As String)

Dim tmpCmdStr As String

cmdStr = Trim(cmdStr)

If LCase(left(cmdStr, 6)) = "print " Then
  Cmd_Print Mid(cmdStr, 7)
ElseIf LCase(cmdStr) = "print" Then
  Cmd_Print ""
ElseIf LCase(left(cmdStr, 6)) = "input " Then
  Cmd_Input Mid(cmdStr, 7)
ElseIf LCase(left(cmdStr, 4)) = "let " Then
  Cmd_Let Mid(cmdStr, 5)
ElseIf LCase(left(cmdStr, 4)) = "var " Then
  Cmd_Var Mid(cmdStr, 5)
ElseIf LCase(cmdStr) = "cls" Then
  Cmd_Cls
ElseIf LCase(left(cmdStr, 5)) = "goto " Then
  Cmd_GoTo Mid(cmdStr, 6)
ElseIf LCase(left(cmdStr, 6)) = "gosub " Then
  Cmd_GoSub Mid(cmdStr, 7)
ElseIf LCase(cmdStr) = "return" Then
  Cmd_Return
ElseIf LCase(cmdStr) = "end" Then
  Cmd_End
ElseIf LCase(left(cmdStr, 12)) = "consoltitle " Then
  Cmd_ConsolTitle Mid(cmdStr, 13)
ElseIf LCase(left(cmdStr, 6)) = "array " Then
  Cmd_Array Mid(cmdStr, 7)
ElseIf LCase(left(cmdStr, 6)) = "redim " Then
  Cmd_ReDim Mid(cmdStr, 7)
ElseIf LCase(left(cmdStr, 8)) = "bindvar " Then
  Cmd_BindVar Mid(cmdStr, 9)
ElseIf LCase(left(cmdStr, 10)) = "unbindvar " Then
  Cmd_UnbindVar Mid(cmdStr, 11)
ElseIf LCase(left(cmdStr, 5)) = "open " Then
  Cmd_Open Mid(cmdStr, 6)
ElseIf LCase(left(cmdStr, 6)) = "close " Then
  Cmd_Close Mid(cmdStr, 7)
ElseIf LCase(left(cmdStr, 5)) = "call " Then
  Cmd_Call Mid(cmdStr, 6)
ElseIf LCase(left(cmdStr, 4)) = "dim " Then
  Cmd_Array Mid(cmdStr, 5)
ElseIf LCase(left(cmdStr, 8)) = "onerror " Then
  Cmd_OnError Mid(cmdStr, 9)
ElseIf LCase(cmdStr) = "onerror" Then
  Cmd_OnError ""
ElseIf LCase(left(cmdStr, 5)) = "swap " Then
  Cmd_Swap Mid(cmdStr, 6)
ElseIf LCase(left(cmdStr, 3)) = "on " Then
  Cmd_On Mid(cmdStr, 4)
ElseIf LCase(left(cmdStr, 5)) = "read " Then
  Cmd_Read Mid(cmdStr, 6)
ElseIf LCase(left(cmdStr, 8)) = "restore " Then
  Cmd_Restore Mid(cmdStr, 9)
ElseIf LCase(cmdStr) = "restore" Then
  Cmd_Restore ""
ElseIf LCase(left(cmdStr, 10)) = "textcolor " Then
  Cmd_TextColor Mid(cmdStr, 11)
ElseIf LCase(left(cmdStr, 8)) = "bgcolor " Then
  Cmd_BGColor Mid(cmdStr, 9)
ElseIf LCase(left(cmdStr, 6)) = "timer " Then
  Cmd_Timer Mid(cmdStr, 7)
ElseIf LCase(left(cmdStr, 10)) = "stoptimer " Then
  Cmd_StopTimer Mid(cmdStr, 11)
ElseIf LCase(Trim(cmdStr)) = "pause" Then
  Cmd_Pause
ElseIf LCase(left(cmdStr, 8)) = "message " Then
  Cmd_Message Mid(cmdStr, 9)
ElseIf LCase(left(cmdStr, 9)) = "question " Then
  Cmd_Question Mid(cmdStr, 10)
ElseIf LCase(left(cmdStr, 6)) = "error " Then
  Cmd_Message Mid(cmdStr, 7)
ElseIf LCase(left(cmdStr, 4)) = "run " Then
  Cmd_Run Mid(cmdStr, 5)
ElseIf LCase(left(cmdStr, 5)) = "seek " Then
  Cmd_Seek Mid(cmdStr, 6)
ElseIf LCase(left(cmdStr, 7)) = "window " Then
  Cmd_Window Mid(cmdStr, 8)
ElseIf LCase(left(cmdStr, 12)) = "closewindow " Then
Debug.Print "CloseWindow"
  Cmd_CloseWindow Mid(cmdStr, 13)
ElseIf LCase(left(cmdStr, 6)) = "event " Then
  Cmd_Event Mid(cmdStr, 7)
ElseIf LCase(left(cmdStr, 8)) = "control " Then
  Cmd_Control Mid(cmdStr, 9)
ElseIf LCase(Trim(cmdStr)) = "showconsol" Then
  Cmd_ShowConsol
ElseIf LCase(Trim(cmdStr)) = "hideconsol" Then
  Cmd_HideConsol
ElseIf LCase(left(cmdStr, 7)) = "enable " Then
  Cmd_Enable Mid(cmdStr, 8)
ElseIf LCase(left(cmdStr, 8)) = "disable " Then
  Cmd_Disable Mid(cmdStr, 9)
ElseIf LCase(left(cmdStr, 5)) = "show " Then
  Cmd_Show Mid(cmdStr, 6)
ElseIf LCase(left(cmdStr, 5)) = "hide " Then
  Cmd_Hide Mid(cmdStr, 6)
ElseIf LCase(left(cmdStr, 8)) = "getsize " Then
  Cmd_GetSize Mid(cmdStr, 9)
ElseIf LCase(left(cmdStr, 6)) = "getxy " Then
  Cmd_GetXY Mid(cmdStr, 7)
ElseIf LCase(left(cmdStr, 8)) = "settext " Then
  Cmd_SetText Mid(cmdStr, 9)
ElseIf LCase(left(cmdStr, 8)) = "setsize " Then
  Cmd_SetSize Mid(cmdStr, 9)
ElseIf LCase(left(cmdStr, 6)) = "setxy " Then
  Cmd_SetXY Mid(cmdStr, 7)
ElseIf LCase(left(cmdStr, 5)) = "menu " Then
  Cmd_Menu Mid(cmdStr, 6)
ElseIf LCase(left(cmdStr, 8)) = "additem " Then
  Cmd_AddItem Mid(cmdStr, 9)
ElseIf LCase(left(cmdStr, 8)) = "delitem " Then
  Cmd_DelItem Mid(cmdStr, 9)
ElseIf LCase(left(cmdStr, 10)) = "setselidx " Then
  Cmd_SetSelIdx Mid(cmdStr, 11)
ElseIf LCase(left(cmdStr, 8)) = "setitem " Then
  Cmd_SetItem Mid(cmdStr, 9)
ElseIf LCase(left(cmdStr, 7)) = "getsel " Then
  Cmd_GetSel Mid(cmdStr, 8)
ElseIf LCase(left(cmdStr, 7)) = "setsel " Then
  Cmd_SetSel Mid(cmdStr, 8)
ElseIf LCase(left(cmdStr, 11)) = "setseltext " Then
  Cmd_SetSelText Mid(cmdStr, 12)
ElseIf LCase(left(cmdStr, 17)) = "setclipboardtext " Then
  Cmd_SetClipboardText Mid(cmdStr, 18)
ElseIf LCase(left(cmdStr, 5)) = "line " Then
  Cmd_Line Mid(cmdStr, 6)
ElseIf LCase(left(cmdStr, 4)) = "box " Then
  Cmd_Box Mid(cmdStr, 5)
ElseIf LCase(left(cmdStr, 7)) = "circle " Then
  Cmd_Circle Mid(cmdStr, 8)
ElseIf LCase(left(cmdStr, 9)) = "linesize " Then
  Cmd_LineSize Mid(cmdStr, 10)
ElseIf LCase(left(cmdStr, 8)) = "loadimg " Then
  Cmd_LoadImg Mid(cmdStr, 9)
ElseIf LCase(left(cmdStr, 10)) = "unloadimg " Then
  Cmd_UnloadImg Mid(cmdStr, 11)
ElseIf LCase(left(cmdStr, 8)) = "drawimg " Then
  Cmd_DrawImg Mid(cmdStr, 9)
ElseIf LCase(left(cmdStr, 7)) = "getimg " Then
  Cmd_GetImg Mid(cmdStr, 8)
ElseIf LCase(left(cmdStr, 6)) = "stick " Then
  Cmd_Stick Mid(cmdStr, 7)
ElseIf LCase(left(cmdStr, 8)) = "refresh " Then
  Cmd_Refresh Mid(cmdStr, 9)
ElseIf LCase(left(cmdStr, 6)) = "clear " Then
  Cmd_Clear Mid(cmdStr, 7)
ElseIf LCase(left(cmdStr, 10)) = "backcolor " Then
  Cmd_BackColor Mid(cmdStr, 11)
ElseIf LCase(left(cmdStr, 10)) = "forecolor " Then
  Cmd_ForeColor Mid(cmdStr, 11)
ElseIf LCase(left(cmdStr, 9)) = "setpixel " Then
  Cmd_SetPixel Mid(cmdStr, 10)
ElseIf LCase(left(cmdStr, 9)) = "drawtext " Then
  Cmd_DrawText Mid(cmdStr, 10)
ElseIf LCase(left(cmdStr, 8)) = "setfont " Then
  Cmd_SetFont Mid(cmdStr, 9)
ElseIf LCase(left(cmdStr, 7)) = "sprite " Then
  Cmd_Sprite Mid(cmdStr, 8)
ElseIf LCase(left(cmdStr, 10)) = "delsprite " Then
  Cmd_DelSprite Mid(cmdStr, 11)
ElseIf LCase(left(cmdStr, 12)) = "drawsprites " Then
  Cmd_DrawSprites Mid(cmdStr, 13)
ElseIf LCase(left(cmdStr, 9)) = "addframe " Then
  Cmd_AddFrame Mid(cmdStr, 10)
ElseIf LCase(left(cmdStr, 9)) = "delframe " Then
  Cmd_DelFrame Mid(cmdStr, 10)
ElseIf LCase(left(cmdStr, 10)) = "spritepos " Then
  Cmd_SpritePos Mid(cmdStr, 11)
ElseIf LCase(left(cmdStr, 11)) = "spritesize " Then
  Cmd_SpriteSize Mid(cmdStr, 12)
ElseIf LCase(left(cmdStr, 11)) = "spriterate " Then
  Cmd_SpriteRate Mid(cmdStr, 12)
ElseIf LCase(left(cmdStr, 13)) = "spriterotate " Then
  Cmd_SpriteRotate Mid(cmdStr, 14)
ElseIf LCase(left(cmdStr, 11)) = "spriteshow " Then
  Cmd_SpriteShow Mid(cmdStr, 12)
ElseIf LCase(left(cmdStr, 11)) = "spritehide " Then
  Cmd_SpriteHide Mid(cmdStr, 12)
ElseIf LCase(left(cmdStr, 11)) = "spriteplay " Then
  Cmd_SpritePlay Mid(cmdStr, 12)
ElseIf LCase(left(cmdStr, 12)) = "spritepause " Then
  Cmd_SpritePause Mid(cmdStr, 13)
ElseIf LCase(left(cmdStr, 9)) = "spritebg " Then
  Cmd_SpriteBG Mid(cmdStr, 10)
ElseIf LCase(left(cmdStr, 7)) = "runcmd " Then
  Cmd_RunCmd Mid(cmdStr, 8)
ElseIf LCase(left(cmdStr, 11)) = "closesound " Then
  Cmd_CloseSound Mid(cmdStr, 12)
ElseIf LCase(left(cmdStr, 10)) = "opensound " Then
  Cmd_OpenSound Mid(cmdStr, 11)
ElseIf LCase(left(cmdStr, 11)) = "pausesound " Then
  Cmd_PauseSound Mid(cmdStr, 12)
ElseIf LCase(left(cmdStr, 10)) = "playsound " Then
  Cmd_PlaySound Mid(cmdStr, 11)
ElseIf LCase(left(cmdStr, 10)) = "stopsound " Then
  Cmd_StopSound Mid(cmdStr, 11)
ElseIf LCase(Trim(cmdStr)) = "beep" Then
  Cmd_Beep
ElseIf LCase(left(cmdStr, 9)) = "getfiles " Then
  Cmd_GetFiles Mid(cmdStr, 10)
ElseIf LCase(left(cmdStr, 8)) = "getdirs " Then
  Cmd_GetDirs Mid(cmdStr, 9)
ElseIf LCase(left(cmdStr, 5)) = "name " Then
  Cmd_Name Mid(cmdStr, 6)
ElseIf LCase(left(cmdStr, 9)) = "setstate " Then
  Cmd_SetState Mid(cmdStr, 10)
ElseIf LCase(left(cmdStr, 10)) = "buttonimg " Then
  Cmd_ButtonImg Mid(cmdStr, 11)
ElseIf LCase(left(cmdStr, 6)) = "mkdir " Then
  Cmd_MkDir Mid(cmdStr, 7)
ElseIf LCase(left(cmdStr, 6)) = "rmdir " Then
  Cmd_RmDir Mid(cmdStr, 7)
ElseIf LCase(left(cmdStr, 11)) = "getmousexy " Then
  Cmd_GetMouseXY Mid(cmdStr, 12)
ElseIf LCase(left(cmdStr, 4)) = "mid " Then
  Cmd_Mid Mid(cmdStr, 5)
ElseIf LCase(left(cmdStr, 5)) = "kill " Then
  Cmd_Kill Mid(cmdStr, 6)
ElseIf LCase(left(cmdStr, 12)) = "spritebgpos " Then
  Cmd_SpriteBGPos Mid(cmdStr, 13)
ElseIf LCase(left(cmdStr, 12)) = "setsoundpos " Then
  Cmd_SetSoundPos Mid(cmdStr, 13)
ElseIf LCase(Trim(cmdStr)) = "exit sub" Then
  Cmd_ExitSub
ElseIf LCase(Trim(cmdStr)) = "exit function" Then
  Cmd_ExitFunction
ElseIf LCase(left(cmdStr, 11)) = "settooltip " Then
  Cmd_SetTooltip Mid(cmdStr, 12)
ElseIf LCase(left(cmdStr, 8)) = "dllcall " Then
  Cmd_DLLCall Mid(cmdStr, 9)
ElseIf LCase(left(cmdStr, 8)) = "loaddll " Then
  Cmd_LoadDLL Mid(cmdStr, 9)
ElseIf LCase(left(cmdStr, 10)) = "unloaddll " Then
  Cmd_UnloadDLL Mid(cmdStr, 11)

ElseIf left(cmdStr, 1) = "@" Then
  'NULL
Else
  If Len(GetString(1, cmdStr, "=")) = Len(cmdStr) Then
    ErrorMsg "Bad or unexpected command string: " & UCase(cmdStr)
    Exit Sub
  Else
    Cmd_Let cmdStr
  End If
End If

DoEvents

End Sub


Public Sub Cmd_Beep()

Beep

End Sub

Public Sub Cmd_SpriteBG(ByVal cmdStr As String)

Dim params As New ArrayClass
Dim winName, imgStr As String
Dim n As Integer
Dim winObj As Object

cmdStr = Trim(cmdStr)

ParseParams cmdStr, params

winName = EvalExpression(params.Item(1))
imgStr = EvalExpression(params.Item(2))

Set winObj = GetWindowObj(winName)

If winObj Is Nothing Then
    ErrorMsg "Window or control '" & winName & "' does not exist"
    Exit Sub
End If

If Trim(imgStr) = "" Then
    winObj.spriteBG = 0
    Exit Sub
End If

n = ExistsIn(imgStr, imgName)
If n = 0 Then
    ErrorMsg "Image '" & imgStr & "' does not exist"
    Exit Sub
End If

winObj.spriteBG = imgHandle.Item(n)

End Sub


Public Sub Cmd_ShowConsol()

output.Show

End Sub

Public Sub Cmd_HideConsol()

output.Hide

End Sub

Public Sub Cmd_Close(ByVal cmdStr As String)

Dim a As Integer

cmdStr = Trim(cmdStr)

For a = 1 To fileHandle.itemCount
    If fileHandle.Item(a) = cmdStr Then
        Close FileNumber.Item(a)
        fileHandle.Remove a
        FileNumber.Remove a
        fileType.Remove a
        Exit Sub
    End If
Next a

ErrorMsg "File handle does not exist: " & cmdStr

End Sub

Public Sub Cmd_End()

progDone = True

End Sub
Public Sub Cmd_GetDirs(ByVal cmdStr As String)

Dim params As New ArrayClass
Dim dirList As New ArrayClass
Dim pathName, arrName, fName As String
Dim n As Integer

cmdStr = Trim(cmdStr)

ParseParams cmdStr, params

pathName = EvalExpression(params.Item(1))
arrName = params.Item(2)

If Right(arrName, 1) = ")" Then arrName = Trim(left(arrName, Len(arrName) - 1))

fName = Dir(pathName, vbDirectory)
While fName <> ""
    dirList.Add fName
    fName = Dir
Wend

Cmd_ReDim arrName & dirList.itemCount & ")"

SetValue arrName & "0)", dirList.itemCount

For n = 1 To dirList.itemCount
    SetValue arrName & n & ")", dirList.Item(n)
Next n

End Sub


Public Sub Cmd_GetFiles(ByVal cmdStr As String)

Dim params As New ArrayClass
Dim fileList As New ArrayClass
Dim pathName, arrName, fName As String
Dim n As Integer

cmdStr = Trim(cmdStr)

ParseParams cmdStr, params

pathName = EvalExpression(params.Item(1))
arrName = params.Item(2)

If Right(arrName, 1) = ")" Then arrName = Trim(left(arrName, Len(arrName) - 1))

fName = Dir(pathName, vbNormal)
While fName <> ""
    fileList.Add fName
    fName = Dir
Wend

Cmd_ReDim arrName & fileList.itemCount & ")"

SetValue arrName & "0)", fileList.itemCount

For n = 1 To fileList.itemCount
    SetValue arrName & n & ")", fileList.Item(n)
Next n

End Sub


Public Sub Cmd_Name(ByVal cmdStr As String)

On Error GoTo cmdError

Dim params As New ArrayClass
Dim oldName, newName As String

cmdStr = Trim(cmdStr)

params.Add GetString(1, LCase(cmdStr), " as ")
params.Item(1) = Mid(cmdStr, 1, Len(params.Item(1)))
params.Add Mid(cmdStr, Len(params.Item(1)) + 5)

oldName = EvalExpression(params.Item(1))
newName = EvalExpression(params.Item(2))

Name oldName As newName

Exit Sub
cmdError:
    ErrorMsg "Failed to rename '" & oldName & "' to '" & newName & "'"

End Sub


Public Sub Cmd_MkDir(ByVal cmdStr As String)

On Error GoTo cmdError

Dim dirPath As String

cmdStr = Trim(cmdStr)

dirPath = EvalExpression(cmdStr)

MkDir dirPath

Exit Sub
cmdError:
    ErrorMsg "Failed to create directory '" & dirPath & "'"

End Sub


Public Sub Cmd_RmDir(ByVal cmdStr As String)

On Error GoTo cmdError

Dim dirPath As String

cmdStr = Trim(cmdStr)

dirPath = EvalExpression(cmdStr)

RmDir dirPath

Exit Sub
cmdError:
    ErrorMsg "Failed to remove directory '" & dirPath & "'"

End Sub



Public Sub Cmd_CloseSound(ByVal cmdStr As String)

Dim soundName As String

cmdStr = Trim(cmdStr)

soundName = EvalExpression(cmdStr)

mciSendString "close " & soundName, "", 0, 0

End Sub



Public Sub Cmd_OpenSound(ByVal cmdStr As String)

Dim soundName, soundFile As String
Dim params As New ArrayClass
Dim n As Integer

cmdStr = Trim(cmdStr)

ParseParams cmdStr, params

soundName = EvalExpression(params.Item(1))
soundFile = EvalExpression(params.Item(2))

n = GetShortPathName(soundFile, soundFile, Len(soundFile))
soundFile = left(soundFile, n)

mciSendString "open " & soundFile & " alias " & soundName, "", 0, 0

End Sub



Public Sub Cmd_PauseSound(ByVal cmdStr As String)

Dim soundName As String

cmdStr = Trim(cmdStr)

soundName = EvalExpression(cmdStr)

mciSendString "stop " & soundName, "", 0, 0

End Sub



Public Sub Cmd_PlaySound(ByVal cmdStr As String)

Dim soundName As String

cmdStr = Trim(cmdStr)

soundName = EvalExpression(cmdStr)

mciSendString "play " & soundName, "", 0, 0

End Sub







Public Sub Cmd_StopSound(ByVal cmdStr As String)

Dim soundName As String

cmdStr = Trim(cmdStr)

soundName = EvalExpression(cmdStr)

mciSendString "stop " & soundName, "", 0, 0
mciSendString "seek " & soundName & " to start", "", 0, 0

End Sub



 
Public Sub Cmd_RunCmd(ByVal cmdStr As String)

Dim cmdLine As String

cmdStr = Trim(cmdStr)

cmdLine = EvalExpression(cmdStr)

RunCmd cmdLine

End Sub


Public Sub Cmd_SpritePause(ByVal cmdStr As String)

Dim params As New ArrayClass
Dim winName, nameStr As String
Dim n As Integer
Dim winObj As Object

cmdStr = Trim(cmdStr)

ParseParams cmdStr, params

winName = EvalExpression(params.Item(1))
nameStr = EvalExpression(params.Item(2))

Set winObj = GetWindowObj(winName)

If winObj Is Nothing Then
    ErrorMsg "Window or control '" & winName & "' does not exist"
    Exit Sub
End If

n = ExistsIn(nameStr, winObj.spriteName)
If n = 0 Then
    ErrorMsg "Sprite '" & nameStr & "' does not exist in window or control '" & winName & "'"
    Exit Sub
End If

winObj.sprites.Item(n).isPlaying = False

End Sub


Public Sub Cmd_SpritePlay(ByVal cmdStr As String)

Dim params As New ArrayClass
Dim winName, nameStr As String
Dim n As Integer
Dim winObj As Object

cmdStr = Trim(cmdStr)

ParseParams cmdStr, params

winName = EvalExpression(params.Item(1))
nameStr = EvalExpression(params.Item(2))

Set winObj = GetWindowObj(winName)

If winObj Is Nothing Then
    ErrorMsg "Window or control '" & winName & "' does not exist"
    Exit Sub
End If

n = ExistsIn(nameStr, winObj.spriteName)
If n = 0 Then
    ErrorMsg "Sprite '" & nameStr & "' does not exist in window or control '" & winName & "'"
    Exit Sub
End If

winObj.sprites.Item(n).isPlaying = True

End Sub


Public Sub Cmd_SetClipboardText(ByVal cmdStr As String)

Dim cbText As String

cmdStr = Trim(cmdStr)

cbText = EvalExpression(cmdStr)

Clipboard.SetText cbText

End Sub


Public Function Func_GetClipboardText() As Variant

Func_GetClipboardText = Clipboard.GetText()

End Function

Public Sub Cmd_GetSel(ByVal cmdStr As String)

Dim params As New ArrayClass
Dim winName, startVar, endVar As String
Dim startPos, endPos, selected As Long
Dim ctlObj As Object

cmdStr = Trim(cmdStr)

ParseParams cmdStr, params

winName = EvalExpression(params.Item(1))
startVar = params.Item(2)
endVar = params.Item(3)

Set ctlObj = GetControlObj(winName)

If ctlObj Is Nothing Then
    ErrorMsg "Control '" & winName & "' does not exist"
    Exit Sub
End If

If ctlObj.ctlType = "textbox" Or ctlObj.ctlType = "texteditor" Then
    selected = SendMessage(ctlObj.winHandle, EM_GETSEL, 0, 0)
    startPos = LOWORD(selected) + 1
    endPos = HIWORD(selected) + 1
    SetValue startVar, startPos
    SetValue endVar, endPos
Else
    ErrorMsg "Control '" & winName & "' needs to be a TEXTBOX or TEXTEDITOR"
End If

End Sub


Public Sub Cmd_SetItem(ByVal cmdStr As String)

Dim params As New ArrayClass
Dim winName As String
Dim itemText As String
Dim itemIdx As Integer
Dim ctlObj As Object

ParseParams cmdStr, params

winName = EvalExpression(params.Item(1))
itemIdx = EvalExpression(params.Item(2))
itemText = EvalExpression(params.Item(3))

Set ctlObj = GetControlObj(winName)

If ctlObj Is Nothing Then
    ErrorMsg "Control '" & winName & "' does not exist"
    Exit Sub
End If

If ctlObj.ctlType = "listbox" Then
    SendMessage ctlObj.winHandle, LB_DELETESTRING, itemIdx - 1, 0
    SendMessage ctlObj.winHandle, LB_INSERTSTRING, itemIdx - 1, ByVal itemText
ElseIf ctlObj.ctlType = "combobox" Then
    SendMessage ctlObj.winHandle, CB_DELETESTRING, itemIdx - 1, 0
    SendMessage ctlObj.winHandle, CB_INSERTSTRING, itemIdx - 1, ByVal itemText
Else
    ErrorMsg "Control '" & winName & "' needs to be a COMBOBOX or LISTBOX"
End If

End Sub


Public Sub Cmd_SetSel(ByVal cmdStr As String)

Dim params As New ArrayClass
Dim winName As String
Dim startPos As Long
Dim endPos As Long
Dim ctlObj As Object

cmdStr = Trim(cmdStr)

ParseParams cmdStr, params

winName = EvalExpression(params.Item(1))
startPos = EvalExpression(params.Item(2))
endPos = EvalExpression(params.Item(3))

Set ctlObj = GetControlObj(winName)

If ctlObj Is Nothing Then
    ErrorMsg "Control '" & winName & "' does not exist"
    Exit Sub
End If

If ctlObj.ctlType = "textbox" Or ctlObj.ctlType = "texteditor" Then
    SendMessage ctlObj.winHandle, EM_SETSEL, startPos - 1, ByVal endPos - 1
Else
    ErrorMsg "Control '" & winName & "' needs to be a TEXTBOX or TEXTEDITOR"
End If

End Sub

Public Sub Cmd_DelItem(ByVal cmdStr As String)

Dim params As New ArrayClass
Dim winName As String
Dim itemIdx As Integer
Dim ctlObj As Object

ParseParams cmdStr, params

winName = EvalExpression(params.Item(1))
itemIdx = EvalExpression(params.Item(2))

Set ctlObj = GetControlObj(winName)

If ctlObj Is Nothing Then
    ErrorMsg "Control '" & winName & "' does not exist"
    Exit Sub
End If

If ctlObj.ctlType = "listbox" Then
    SendMessage ctlObj.winHandle, LB_DELETESTRING, itemIdx - 1, 0
ElseIf ctlObj.ctlType = "combobox" Then
    SendMessage ctlObj.winHandle, CB_DELETESTRING, itemIdx - 1, 0
Else
    ErrorMsg "Control '" & winName & "' needs to be a COMBOBOX or LISTBOX"
End If

End Sub


Public Sub Cmd_SetSelIdx(ByVal cmdStr As String)

Dim params As New ArrayClass
Dim winName As String
Dim itemIdx As Integer
Dim ctlObj As Object

ParseParams cmdStr, params

winName = EvalExpression(params.Item(1))
itemIdx = EvalExpression(params.Item(2))

Set ctlObj = GetControlObj(winName)

If ctlObj Is Nothing Then
    ErrorMsg "Control '" & winName & "' does not exist"
    Exit Sub
End If

If ctlObj.ctlType = "listbox" Then
    SendMessage ctlObj.winHandle, LB_SETCURSEL, itemIdx - 1, 0
ElseIf ctlObj.ctlType = "combobox" Then
    SendMessage ctlObj.winHandle, CB_SETCURSEL, itemIdx - 1, 0
Else
    ErrorMsg "Control '" & winName & "' needs to be a COMBOBOX or LISTBOX"
End If

End Sub



Public Sub Cmd_Message(ByVal cmdStr As String)

Dim paramStr, msgStr, titleStr As String

cmdStr = Trim(cmdStr)

paramStr = GetString(1, cmdStr, ",")
msgStr = EvalExpression(paramStr)

paramStr = Mid(cmdStr, Len(paramStr) + 2)
titleStr = EvalExpression(paramStr)

'MessageBox 0, msgStr, titleStr, MB_OK
MsgBox msgStr, vbOKOnly, titleStr

End Sub

Public Sub Cmd_Error(ByVal cmdStr As String)

Dim paramStr, msgStr, titleStr As String

cmdStr = Trim(cmdStr)

paramStr = GetString(1, cmdStr, ",")
msgStr = EvalExpression(paramStr)

paramStr = Mid(cmdStr, Len(paramStr) + 2)
titleStr = EvalExpression(paramStr)

MsgBox msgStr, vbCritical, titleStr


End Sub

Public Sub Cmd_Event(ByVal cmdStr As String)

Dim nameStr, eventStr, subStr As String
Dim a, b, n, i, eventIdx As Integer
Dim winObj As Object

cmdStr = Trim(cmdStr)

nameStr = GetString(1, cmdStr, ",")
b = Len(nameStr) + 2
eventStr = GetString(b, cmdStr, ",")
b = b + Len(eventStr) + 1
subStr = Trim(Mid(cmdStr, b))

nameStr = EvalExpression(nameStr)
eventStr = LCase(EvalExpression(eventStr))

For n = 1 To windows.itemCount
    If nameStr = windows.Item(n).winName Then
        Set winObj = windows.Item(n)
        GoTo addEvent
    End If
Next n

For n = 1 To windows.itemCount
    With windows.Item(n).Controls
    For i = 1 To .itemCount
        If nameStr = .Item(i).winName Then
            Set winObj = .Item(i)
            GoTo addEvent
        End If
    Next i
    End With
Next n

ErrorMsg "Window or control does not exist: '" & nameStr & "'"

Exit Sub


addEvent:
    For a = 1 To subName.itemCount
        If subStr = subName.Item(a) Then
            eventIdx = ExistsIn(eventStr, winObj.eventName)
            If eventIdx Then
                winObj.eventName.Item(eventIdx) = eventStr
                winObj.eventSubIdx.Item(eventIdx) = a
                winObj.eventSubType.Item(eventIdx) = SP_SUB
            Else
                winObj.eventName.Add eventStr
                winObj.eventSubIdx.Add a
                winObj.eventSubType.Add SP_SUB
            End If
            Exit Sub
        End If
    Next a
    For b = 1 To funcName.itemCount
        If (subStr & "()" = funcName.Item(b) & ")") Or (subStr = left(funcName.Item(b), Len(funcName.Item(b)) - 1)) Then
            eventIdx = ExistsIn(eventStr, winObj.eventName)
            If eventIdx Then
                winObj.eventName.Item(eventIdx) = eventStr
                winObj.eventSubIdx.Item(eventIdx) = b
                winObj.eventSubType.Item(eventIdx) = SP_FUNC
            Else
                winObj.eventName.Add eventStr
                winObj.eventSubIdx.Add b
                winObj.eventSubType.Add SP_FUNC
            End If
            Exit Sub
        End If
    Next b


End Sub

Public Sub Cmd_Question(ByVal cmdStr As String)

Dim paramStr, msgStr, titleStr, varStr As String
Dim b, aVal As Integer

cmdStr = Trim(cmdStr)

paramStr = GetString(1, cmdStr, ",")
msgStr = EvalExpression(paramStr)

b = Len(paramStr) + 2

paramStr = GetString(b, cmdStr, ",")
titleStr = EvalExpression(paramStr)

b = b + Len(paramStr) + 1

varStr = Mid(cmdStr, b)

aVal = MsgBox(msgStr, vbYesNo Or vbQuestion, titleStr)
If aVal = vbYes Then
    SetValue varStr, "yes"
Else
    SetValue varStr, "no"
End If


End Sub


Public Sub Cmd_DLLCall(ByVal cmdStr As String)

Dim libName, fName As String
Dim retVar As String
Dim retVal As Long
Dim params As New ArrayClass
Dim dllParams As New ArrayClass
Dim strList As New ArrayClass
Dim pList() As Long
Dim dllObj As New cFuncCall

cmdStr = Trim(cmdStr)

ParseParams cmdStr, params

libName = EvalExpression(params.Item(1))
fName = EvalExpression(params.Item(2))

retVar = Trim(params.Item(params.itemCount))

For n = 3 To params.itemCount - 1
    dllParams.Add EvalExpression(params.Item(n))
Next n

ReDim pList(dllParams.itemCount - 1)

For n = 1 To dllParams.itemCount
    If Not IsNumeric(dllParams.Item(n)) Then
        strList.Add New ByteString
        strList.Item(strList.itemCount).Insert dllParams.Item(n)
        pList(n - 1) = strList.Item(strList.itemCount).StringPtr
    Else
        pList(n - 1) = dllParams.Item(n)
    End If
Next n

dllObj.LibraryName = libName
dllObj.FunctionName = fName
retVal = dllObj.CallFunction(pList)

SetValue retVar, retVal

Set dllObj = Nothing

End Sub
Public Sub Cmd_BGColor(ByVal cmdStr As String)

Dim color As Variant

cmdStr = Trim(cmdStr)

color = EvalExpression(cmdStr)

output.display.BackColor = color

End Sub
Public Sub RunForBlock(ByVal startLne As Integer, ByVal endLne As Integer)

Dim expStr, varStr As String
Dim varVal, val1, val2, stepVal As Integer

varStr = GetString(5, runCode.Item(startLne), "=")

a = Len(varStr) + 6

expStr = GetString(a, LCase(runCode.Item(startLne) & " "), " to ")
expStr = Mid(runCode.Item(startLne), a, Len(expStr))
val1 = EvalExpression(expStr)

a = a + Len(expStr) + 3

expStr = GetString(a, LCase(runCode.Item(startLne) & " "), " step ")
expStr = Mid(runCode.Item(startLne), a, Len(expStr))
val2 = EvalExpression(expStr)

If a + Len(expStr) < Len(runCode.Item(startLne)) Then
    a = a + Len(expStr) + 5
    expStr = Right(runCode.Item(startLne), Len(runCode.Item(startLne)) - a)
    stepVal = EvalExpression(expStr)
Else
    stepVal = 1
End If

For varVal = val1 To val2 Step stepVal
  SetValue varStr, varVal
  If debugging Then debugWin.code.ListIndex = startLne
  If endLne > startLne Then
    For lineNum = startLne + 1 To endLne
        DebugWait
        If Not RunBlock(lineNum, endLne) Then
            RunCmd runCode.Item(lineNum)
        End If
        If progDone Then Exit Sub
        If lineNum < startLne Or lineNum > endLne Then Exit Sub
        If debugging Then debugWin.code.ListIndex = lineNum
    Next lineNum
  End If
  DebugWait
  If debugging Then debugWin.code.ListIndex = startLne - 1
  DebugWait
Next varVal

lineNum = endLne + 1

End Sub

Public Sub RunIfBlock(ByVal startLne As Integer, ByVal endLne As Integer, ByVal oneLine As Boolean)

Dim cmdStr, expStr, tmpLine As String
Dim ifExp As New ArrayClass
Dim ifStart As New ArrayClass
Dim ifEnd As New ArrayClass
Dim ifNum, n As Integer

expStr = GetString(4, LCase(runCode.Item(startLne)) & " ", " then ")
expStr = Mid(runCode.Item(startLne), 4, Len(expStr))

If oneLine Then
    cmdStr = LTrim(Right(runCode.Item(startLne), Len(runCode.Item(startLne)) - (Len(expStr) + 8)))
    If EvalExpression(expStr) Then RunCmd cmdStr
    Exit Sub
Else
  If endLne > startLne Then
    ifExp.Add expStr
    ifStart.Add startLne + 1
    For n = startLne + 1 To endLne
        If LCase(left(runCode.Item(n), 3)) = "if " Then
            If LCase(Right(runCode.Item(n), 5)) = " then" Then
                ifNum = ifNum + 1
            End If
        ElseIf LCase(Trim(runCode.Item(n))) = "end if" Then
            ifNum = ifNum - 1
        ElseIf LCase(left(runCode.Item(n), 7)) = "elseif " And ifNum = 0 Then
            ifEnd.Add n - 1
            expStr = GetString(8, LCase(runCode.Item(n)) & " ", " then ")
            expStr = Mid(runCode.Item(n), 8, Len(expStr))
            ifExp.Add expStr
            ifStart.Add n + 1
        ElseIf LCase(Trim((runCode.Item(n)))) = "else" And ifNum = 0 Then
            ifEnd.Add n - 1
            ifExp.Add "1"
            ifStart.Add n + 1
        End If
    Next n
    ifEnd.Add endLne
    For n = 1 To ifExp.itemCount
        If EvalExpression(ifExp.Item(n)) Then
            If debugging Then debugWin.code.ListIndex = ifStart.Item(n) - 1
            For lineNum = ifStart.Item(n) To ifEnd.Item(n)
                DebugWait
                If Not RunBlock(lineNum, endLne) Then
                    RunCmd runCode.Item(lineNum)
                End If
                If progDone Then Exit Sub
                If lineNum < startLne Or lineNum > endLne Then Exit Sub
                If debugging Then debugWin.code.ListIndex = lineNum
            Next lineNum
            lineNum = endLne + 1
            Exit Sub
        End If
        If debugging Then debugWin.code.ListIndex = ifEnd.Item(n)
        DebugWait
    Next n
    lineNum = endLne + 1
  End If
End If

End Sub


Public Sub RunProg()

Dim tmpLine, str As String
Dim ifNum, whileNum, forNum As Integer
Dim a As Integer

'Define all other variables in the code
For a = runCode.itemCount To 1 Step -1
    If LCase(left(runCode.Item(a), 4)) = "var " Then
        Cmd_Var Mid(runCode.Item(a), 5)
        runCode.Remove a
    End If
Next a

'Read and cut out data commands
For a = runCode.itemCount To 1 Step -1
  If LCase(left(runCode.Item(a), 5)) = "data " Then
    Cmd_Data Mid(runCode.Item(a), 6)
    runCode.Remove a
  End If
Next a

'Read branch labels
For a = 1 To runCode.itemCount
  If left(runCode.Item(a), 1) = "@" Then
    labelLine.Add a
    labelName.Add runCode.Item(a)
  End If
Next a

'If debugging, add code to debugger display
If debugging Then
    'debugCode.Add New ArrayClass, 1
    'debugLneSel.Add debugWin.code.ListIndex, 1
    'debugWin.code.Clear
    'For a = 1 To runCode.itemCount
    '    debugWin.code.AddItem runCode.Item(a)
    '    debugCode.Item(1).Add runCode.Item(a)
    'Next a
    'debugWin.code.AddItem ""
    debugCode.Add Me, 1
    debugLneSel.Add 0, 1
    debugWin.stack.AddItem subProgName, 0
    debugWin.Caption = "Debug - " & subProgName
    DebugUpdateCode Me
    debugWin.code.ListIndex = 0
    DebugUpdateVars Me
End If

gosubLine = 0
onErrorCmd = ""
readPos = 1


'Loop through every line, running each command within the line
For lineNum = 1 To runCode.itemCount
    DebugWait
    If Not RunBlock(lineNum, runCode.itemCount) Then
        RunCmd runCode.Item(lineNum)
    End If
    If progDone Then Exit Sub
    If debugging Then
        debugWin.code.ListIndex = lineNum
        debugLneSel.Item(1) = debugWin.code.ListIndex
    End If
Next lineNum


'If debugging, remove code from debugger display
If debugging Then
    'debugCode.Remove 1
    'debugWin.code.Clear
    'For a = 1 To debugCode.Item(1).itemCount
    '    debugWin.code.AddItem debugCode.Item(1).Item(a)
    'Next a
    'debugWin.code.AddItem ""
    'debugWin.code.ListIndex = debugLneSel.Item(1)
    'debugLneSel.Remove 1
    If ObjPtr(Me.prevSubProg) <> 0 Then
        debugWin.stack.RemoveItem 0
        debugCode.Remove 1
        debugLneSel.Remove 1
    End If
    debugWin.Caption = "Debug - " & debugWin.stack.List(0)
    DebugUpdateCode Me.prevSubProg
    DebugUpdateVars Me.prevSubProg
End If

End Sub


Public Sub RunSelectBlock(ByVal startLne As Integer, ByVal endLne As Integer)

Dim expStr As String
Dim caseExp As New ArrayClass
Dim caseStart As New ArrayClass
Dim caseEnd As New ArrayClass
Dim selectNum, n As Integer
Dim selectVal As Variant

selectVal = EvalExpression(Mid(runCode.Item(startLne), 13))

If endLne > startLne Then
  caseExp.Add "1"
  caseStart.Add startLne + 1
  For n = startLne + 1 To endLne
      If LCase(left(runCode.Item(n), 12)) = "select case " Then
          selectNum = selectNum + 1
      ElseIf LCase(Trim(runCode.Item(n))) = "end select" Then
          selectNum = selectNum - 1
      ElseIf LCase(Trim(runCode.Item(n))) = "case else" And selectNum = 0 Then
          caseEnd.Add n - 1
          caseExp.Add selectVal
          caseStart.Add n + 1
      ElseIf LCase(left(runCode.Item(n), 5)) = "case " And selectNum = 0 Then
          caseEnd.Add n - 1
          caseExp.Add Mid(runCode.Item(n), 6)
          caseStart.Add n + 1
      End If
  Next n
  
  caseEnd.Add endLne
  
  If debugging Then debugWin.code.ListIndex = lineNum
  DebugWait
  
  For n = 2 To caseExp.itemCount
      If EvalExpression(caseExp.Item(n)) = selectVal Then
          If debugging Then debugWin.code.ListIndex = caseStart.Item(n) - 1
          For lineNum = caseStart.Item(n) To caseEnd.Item(n)
              DebugWait
              If Not RunBlock(lineNum, endLne) Then
                  RunCmd runCode.Item(lineNum)
              End If
              If progDone Then Exit Sub
              If lineNum < startLne Or lineNum > endLne Then Exit Sub
              If debugging Then debugWin.code.ListIndex = lineNum
          Next lineNum
          lineNum = endLne + 1
          Exit Sub
      End If
      If debugging Then debugWin.code.ListIndex = caseEnd.Item(n)
      DebugWait
  Next n
End If

lineNum = endLne + 1


End Sub

Private Function EvalExpression(ByVal expStr As String) As Variant

Dim operand As New ArrayClass
Dim operator As New ArrayClass
Dim tmpExp As String
Dim inString As Boolean
Dim i As Integer
Dim retVal As Variant

If Trim(expStr) = "" Then EvalExpression = "": Exit Function

'parse out each operand
For i = 1 To Len(expStr)

  If Mid(expStr, i, 1) = Chr(34) Then
    If inString = False Then inString = True Else inString = False
  End If
  
  If Mid(expStr, i, 1) = "(" And inString = False Then
    temp = GetString(i + 1, expStr, ")")
    tmpExp = tmpExp & "(" & temp & ")"
    i = i + Len(temp) + 1
  
  ElseIf (Mid(expStr, i, 2) = ">=" Or Mid(expStr, i, 2) = "<=" Or Mid(expStr, i, 2) = "<>") _
  And inString = False Then
    GoSub AddType: tmpExp = ""
    operator.Add Mid(expStr, i, 2), 1: i = i + 1
    
  ElseIf (Mid(expStr, i, 1) = "+" Or Mid(expStr, i, 1) = "%" _
  Or Mid(expStr, i, 1) = "*" Or Mid(expStr, i, 1) = "/" Or Mid(expStr, i, 1) = "^" _
  Or Mid(expStr, i, 1) = "=" Or Mid(expStr, i, 1) = "<" Or Mid(expStr, i, 1) = ">" _
  Or Mid(expStr, i, 1) = "&") And inString = False Then
    GoSub AddType: tmpExp = ""
    operator.Add Mid(expStr, i, 1), 1
  
  ElseIf (UCase(Mid(expStr, i, 5)) = " AND " Or UCase(Mid(expStr, i, 5)) = " XOR ") _
  And inString = False Then
    GoSub AddType: tmpExp = ""
    operator.Add UCase(Trim(Mid(expStr, i, 5))), 1: i = i + 4
  
  ElseIf (UCase(Mid(expStr, i, 4)) = " OR ") And inString = False Then
    GoSub AddType: tmpExp = ""
    operator.Add UCase(Trim(Mid(expStr, i, 4))), 1: i = i + 3
  
  ElseIf Mid(expStr, i, 1) = "-" And inString = False Then
    If Len(Trim(tmpExp)) = 0 Then
      tmpExp = tmpExp & "-"
    Else
      GoSub AddType: tmpExp = ""
      operator.Add "-", 1
    End If
        
  Else
    tmpExp = tmpExp & Mid(expStr, i, 1)
  End If

Next i

    GoSub AddType


'Evaluate operator: ^
For a = operator.itemCount To 1 Step -1
  If operator.Item(a) = "^" Then
    operand.Item(a) = operand.Item(a + 1) ^ operand.Item(a)
    operand.Remove (a + 1): operator.Remove (a)
  End If
Next a

'Evaluate operators: *, /, and %
For a = operator.itemCount To 1 Step -1
  If operator.Item(a) = "*" Then
    operand.Item(a) = operand.Item(a + 1) * operand.Item(a)
    operand.Remove (a + 1): operator.Remove (a)
  ElseIf operator.Item(a) = "/" Then
    operand.Item(a) = operand.Item(a + 1) / operand.Item(a)
    operand.Remove (a + 1): operator.Remove (a)
  ElseIf operator.Item(a) = "%" Then
    operand.Item(a) = operand.Item(a + 1) Mod operand.Item(a)
    operand.Remove (a + 1): operator.Remove (a)
  End If
Next a

'Evaluate operators: + and -
For a = operator.itemCount To 1 Step -1
  If operator.Item(a) = "+" Then
    operand.Item(a) = operand.Item(a + 1) + operand.Item(a)
    operand.Remove (a + 1): operator.Remove (a)
  ElseIf operator.Item(a) = "-" Then
    operand.Item(a) = operand.Item(a + 1) - operand.Item(a)
    operand.Remove (a + 1): operator.Remove (a)
  End If
Next a

'Evaluate operator: &
For a = operator.itemCount To 1 Step -1
  If operator.Item(a) = "&" Then
    operand.Item(a) = operand.Item(a + 1) & operand.Item(a)
    operand.Remove (a + 1): operator.Remove (a)
  End If
Next a

'Evaluate operators: =, <, >, <=, >=, and <>
For a = operator.itemCount To 1 Step -1
  If operator.Item(a) = "=" Then
    operand.Item(a) = CDbl(operand.Item(a + 1) = operand.Item(a))
    operand.Remove (a + 1): operator.Remove (a)
  ElseIf operator.Item(a) = "<" Then
    operand.Item(a) = CDbl(operand.Item(a + 1) < operand.Item(a))
    operand.Remove (a + 1): operator.Remove (a)
  ElseIf operator.Item(a) = ">" Then
    operand.Item(a) = CDbl(operand.Item(a + 1) > operand.Item(a))
    operand.Remove (a + 1): operator.Remove (a)
  ElseIf operator.Item(a) = "<=" Then
    operand.Item(a) = CDbl(operand.Item(a + 1) <= operand.Item(a))
    operand.Remove (a + 1): operator.Remove (a)
  ElseIf operator.Item(a) = ">=" Then
    operand.Item(a) = CDbl(operand.Item(a + 1) >= operand.Item(a))
    operand.Remove (a + 1): operator.Remove (a)
  ElseIf operator.Item(a) = "<>" Then
    operand.Item(a) = CDbl(operand.Item(a + 1) <> operand.Item(a))
    operand.Remove (a + 1): operator.Remove (a)
  End If
Next a

'Evaluate operators: AND, OR, and XOR
For a = operator.itemCount To 1 Step -1
  If operator.Item(a) = "AND" Then
    operand.Item(a) = (operand.Item(a + 1) And operand.Item(a))
    operand.Remove (a + 1): operator.Remove (a)
  ElseIf operator.Item(a) = "OR" Then
    operand.Item(a) = (operand.Item(a + 1) Or operand.Item(a))
    operand.Remove (a + 1): operator.Remove (a)
  ElseIf operator.Item(a) = "XOR" Then
    operand.Item(a) = (operand.Item(a + 1) Xor operand.Item(a))
    operand.Remove (a + 1): operator.Remove (a)
  End If
Next a

EvalExpression = operand.Item(1)

Exit Function


'routine to add an operand to the stack
AddType:
    tmpExp = Trim(tmpExp)
    If IsNumeric(tmpExp) Then
      operand.Add CDbl(tmpExp), 1
    ElseIf (left(tmpExp, 1) = Chr(34)) And (Right(tmpExp, 1) = Chr(34)) Then
      operand.Add Mid(tmpExp, 2, Len(tmpExp) - 2), 1
    ElseIf (left(tmpExp, 1) = "(") And (Right(tmpExp, 1) = ")") Then
      operand.Add EvalExpression(Mid(tmpExp, 2, Len(tmpExp) - 2)), 1
    Else
        If ObjPtr(Me) <> ObjPtr(mainCode) Then
            For a = 1 To varName.itemCount
              If tmpExp = varName.Item(a) Then
                  operand.Add varValue.Item(a), 1
                  Return
              End If
            Next a
            For a = 1 To arrayName.itemCount
                If left(tmpExp, Len(arrayName.Item(a))) = arrayName.Item(a) And (Right(tmpExp, 1) = ")") Then
                    idxStr = GetString(Len(GetString(1, tmpExp, "(")) + 2, tmpExp, ")")
                    firstIdx = GetString(1, idxStr, ",")
                    firstVal = EvalExpression(firstIdx)
                    If firstVal < 0 Or (firstVal + 1) > arrayValue.Item(a).itemCount Then
                        ErrorMsg "Illegal index value"
                        Exit Function
                    End If
                    If Len(firstIdx) < Len(idxStr) Then
                        If Not isMultiDim.Item(a) Then
                            ErrorMsg "Array is one dimensional"
                            Exit Function
                        End If
                        secondIdx = Right(idxStr, Len(idxStr) - (Len(firstIdx) + 1))
                        secondVal = EvalExpression(secondIdx)
                        If secondVal < 0 Or (secondVal + 1) > arrayValue.Item(a).Item(1).itemCount Then
                            ErrorMsg "Illegal index value"
                            Exit Function
                        End If
                        If arrayType.Item(a) = DT_NUMBER Then
                            operand.Add arrayValue.Item(a).Item(firstVal + 1).Item(secondVal + 1), 1
                        Else
                            operand.Add arrayValue.Item(a).Item(firstVal + 1).Item(secondVal + 1), 1
                        End If
                    Else
                        If isMultiDim.Item(a) Then
                            ErrorMsg "Array is two dimensional"
                            Exit Function
                        End If
                        If arrayType.Item(a) = DT_NUMBER Then
                            operand.Add arrayValue.Item(a).Item(firstVal + 1), 1
                        Else
                            operand.Add arrayValue.Item(a).Item(firstVal + 1), 1
                        End If
                    End If
                    Return
                End If
            Next a
        End If
        For a = 1 To mainCode.varName.itemCount
          If tmpExp = mainCode.varName.Item(a) Then
              operand.Add mainCode.varValue.Item(a), 1
              Return
          End If
        Next a
        For a = 1 To mainCode.arrayName.itemCount
            If left(tmpExp, Len(mainCode.arrayName.Item(a))) = mainCode.arrayName.Item(a) And (Right(tmpExp, 1) = ")") Then
                idxStr = GetString(Len(GetString(1, tmpExp, "(")) + 2, tmpExp, ")")
                firstIdx = GetString(1, idxStr, ",")
                firstVal = EvalExpression(firstIdx)
                If firstVal < 0 Or (firstVal + 1) > mainCode.arrayValue.Item(a).itemCount Then
                    ErrorMsg "Illegal index value"
                    Exit Function
                End If
                If Len(firstIdx) < Len(idxStr) Then
                    If Not mainCode.isMultiDim.Item(a) Then
                        ErrorMsg "Array is one dimensional"
                        Exit Function
                    End If
                    secondIdx = Right(idxStr, Len(idxStr) - (Len(firstIdx) + 1))
                    secondVal = EvalExpression(secondIdx)
                    If secondVal < 0 Or (secondVal + 1) > mainCode.arrayValue.Item(a).Item(1).itemCount Then
                        ErrorMsg "Illegal index value"
                        Exit Function
                    End If
                    If mainCode.arrayType.Item(a) = DT_NUMBER Then
                        operand.Add mainCode.arrayValue.Item(a).Item(firstVal + 1).Item(secondVal + 1), 1
                    Else
                        operand.Add mainCode.arrayValue.Item(a).Item(firstVal + 1).Item(secondVal + 1), 1
                    End If
                Else
                    If mainCode.isMultiDim.Item(a) Then
                        ErrorMsg "Array is two dimensional"
                        Exit Function
                    End If
                    If mainCode.arrayType.Item(a) = DT_NUMBER Then
                        operand.Add mainCode.arrayValue.Item(a).Item(firstVal + 1), 1
                    Else
                        operand.Add mainCode.arrayValue.Item(a).Item(firstVal + 1), 1
                    End If
                End If
                Return
            End If
        Next a
        'NEW FUNCTION CALL ROUTINE
        If EvalFunction(tmpExp, retVal) Then
            operand.Add retVal
            Return
        End If
        For C = 1 To funcName.itemCount
          If left(tmpExp, Len(funcName.Item(C))) = funcName.Item(C) Then
              operand.Add CallUserFunc(tmpExp), 1
              Return
          End If
        Next C
        'OLD FUNCTION CALL ROUTINE
        'For b = 1 To strFunc.itemCount
        '  If LCase(left(tmpExp, Len(strFunc.Item(b)))) = LCase(strFunc.Item(b)) Then
        '      operand.Add EvalFunction(tmpExp), 1
        '      Return
        '  End If
        'Next b
        'For C = 1 To numFunc.itemCount
        '  If LCase(left(tmpExp, Len(numFunc.Item(C)))) = LCase(numFunc.Item(C)) Then
        '      operand.Add CDbl(EvalFunction(tmpExp)), 1
        '      Return
        '  End If
        'Next C
        'For C = 1 To funcName.itemCount
        '  If left(tmpExp, Len(funcName.Item(C))) = funcName.Item(C) Then
        '      operand.Add CallUserFunc(tmpExp), 1
        '      Return
        '  End If
        'Next C
    End If
Return

End Function

Public Function CallUserFunc(ByVal cmdStr As String) As Variant

Dim funcObj As New SubProgClass
Dim tmpName, tmpParam, paramStr As String

cmdStr = Trim(cmdStr)

tmpName = GetString(1, cmdStr, "(")

For a = 1 To funcName.itemCount
    If tmpName = funcName.Item(a) Then
        'Make the function name a local variable
        funcObj.Cmd_Var tmpName & funcType.Item(a)
        For b = 1 To funcParams.Item(a).itemCount
            'Make the parameter definitions into local function variables
            funcObj.Cmd_Var funcParams.Item(a).Item(b)
        Next b
        'Load the lines of code into the function
        For b = 1 To funcRunCode.Item(a).itemCount
            funcObj.runCode.Add funcRunCode.Item(a).Item(b)
        Next b
        'Tell the function its name
        funcObj.subProgName = tmpName
        'Tell the function what sub program is calling it
        Set funcObj.prevSubProg = Me
    End If
Next a

paramStr = GetString(Len(tmpName) + 2, cmdStr, ")")

'Fill the parameter variables with the arguments
n = 2
b = 1
While b <= Len(paramStr)
    tmpParam = GetString(b, paramStr, ",")
    b = Len(tmpParam) + b + 1
    funcObj.varValue.Item(n) = EvalExpression(tmpParam)
    n = n + 1
Wend

'Start running the function
funcObj.RunProg

'Return the value that was stored in the function name variable
CallUserFunc = funcObj.varValue.Item(1)

'Clean up the sub program object
Set funcObj = Nothing

End Function
Private Function EvalFunction(ByVal funcStr As String, ByRef retVal As Variant) As Boolean

Dim paramStr As String

funcStr = Trim(funcStr)
EvalFunction = True

If LCase(left(funcStr, 4)) = "abs(" Then
    retVal = Func_Abs(GetString(5, funcStr, ")"))
ElseIf LCase(left(funcStr, 4)) = "asc(" Then
    retVal = Func_Asc(GetString(5, funcStr, ")"))
ElseIf LCase(left(funcStr, 4)) = "not(" Then
    retVal = Func_Not(GetString(5, funcStr, ")"))
ElseIf LCase(left(funcStr, 4)) = "int(" Then
    retVal = Func_Int(GetString(5, funcStr, ")"))
ElseIf LCase(left(funcStr, 4)) = "len(" Then
    retVal = Func_Len(GetString(5, funcStr, ")"))
ElseIf LCase(left(funcStr, 4)) = "rnd(" Then
    retVal = Func_Rnd()
ElseIf LCase(left(funcStr, 4)) = "val(" Then
    retVal = Func_Val(GetString(5, funcStr, ")"))
ElseIf LCase(left(funcStr, 4)) = "chr(" Then
    retVal = Func_Chr(GetString(5, funcStr, ")"))
ElseIf LCase(left(funcStr, 4)) = "str(" Then
    retVal = Func_Str(GetString(5, funcStr, ")"))
ElseIf LCase(left(funcStr, 6)) = "upper(" Then
    retVal = Func_Upper(GetString(7, funcStr, ")"))
ElseIf LCase(left(funcStr, 6)) = "lower(" Then
    retVal = Func_Lower(GetString(7, funcStr, ")"))
ElseIf LCase(left(funcStr, 5)) = "trim(" Then
    retVal = Func_Trim(GetString(6, funcStr, ")"))
ElseIf LCase(left(funcStr, 5)) = "left(" Then
    retVal = Func_Left(GetString(6, funcStr, ")"))
ElseIf LCase(left(funcStr, 4)) = "mid(" Then
    retVal = Func_Mid(GetString(5, funcStr, ")"))
ElseIf LCase(left(funcStr, 6)) = "right(" Then
    retVal = Func_Right(GetString(7, funcStr, ")"))
ElseIf LCase(left(funcStr, 6)) = "instr(" Then
    retVal = Func_InStr(GetString(7, funcStr, ")"))
ElseIf LCase(left(funcStr, 4)) = "loc(" Then
    retVal = Func_Loc(GetString(5, funcStr, ")"))
ElseIf LCase(left(funcStr, 8)) = "gettext(" Then
    retVal = Func_GetText(GetString(9, funcStr, ")"))
ElseIf LCase(left(funcStr, 5)) = "hwnd(" Then
    retVal = Func_hWnd(GetString(6, funcStr, ")"))
ElseIf LCase(left(funcStr, 4)) = "hdc(" Then
    retVal = Func_hDC(GetString(5, funcStr, ")"))
ElseIf LCase(left(funcStr, 10)) = "getselidx(" Then
    retVal = Func_GetSelIdx(GetString(11, funcStr, ")"))
ElseIf LCase(left(funcStr, 8)) = "getitem(" Then
    retVal = Func_GetItem(GetString(9, funcStr, ")"))
ElseIf LCase(left(funcStr, 10)) = "itemcount(" Then
    retVal = Func_ItemCount(GetString(11, funcStr, ")"))
ElseIf LCase(left(funcStr, 11)) = "getseltext(" Then
    retVal = Func_GetSelText(GetString(12, funcStr, ")"))
ElseIf LCase(left(funcStr, 10)) = "linecount(" Then
    retVal = Func_LineCount(GetString(11, funcStr, ")"))
ElseIf LCase(left(funcStr, 12)) = "getlinetext(" Then
    retVal = Func_GetLineText(GetString(13, funcStr, ")"))
ElseIf LCase(left(funcStr, 17)) = "getclipboardtext(" Then
    retVal = Func_GetClipboardText()
ElseIf LCase(left(funcStr, 9)) = "inputbox(" Then
    retVal = Func_InputBox(GetString(10, funcStr, ")"))
ElseIf LCase(left(funcStr, 5)) = "date(" Then
    retVal = Func_Date()
ElseIf LCase(left(funcStr, 5)) = "time(" Then
    retVal = Func_Time()
ElseIf LCase(left(funcStr, 9)) = "getstate(" Then
    retVal = Func_GetState(GetString(10, funcStr, ")"))
ElseIf LCase(left(funcStr, 4)) = "min(" Then
    retVal = Func_Min(GetString(5, funcStr, ")"))
ElseIf LCase(left(funcStr, 4)) = "max(" Then
    retVal = Func_Max(GetString(5, funcStr, ")"))
ElseIf LCase(left(funcStr, 4)) = "sqr(" Then
    retVal = Func_Sqr(GetString(5, funcStr, ")"))
ElseIf LCase(left(funcStr, 6)) = "space(" Then
    retVal = Func_Space(GetString(7, funcStr, ")"))
ElseIf LCase(left(funcStr, 4)) = "lof(" Then
    retVal = Func_LOF(GetString(5, funcStr, ")"))
ElseIf LCase(left(funcStr, 4)) = "eof(" Then
    retVal = Func_EOF(GetString(5, funcStr, ")"))
ElseIf LCase(left(funcStr, 5)) = "hbmp(" Then
    retVal = Func_hBmp(GetString(6, funcStr, ")"))
ElseIf LCase(left(funcStr, 9)) = "fileopen(" Then
    retVal = Func_FileOpen(GetString(10, funcStr, ")"))
ElseIf LCase(left(funcStr, 9)) = "filesave(" Then
    retVal = Func_FileSave(GetString(10, funcStr, ")"))
ElseIf LCase(left(funcStr, 8)) = "collide(" Then
    retVal = Func_Collide(GetString(9, funcStr, ")"))
ElseIf LCase(left(funcStr, 6)) = "input(" Then
    retVal = Func_Input(GetString(7, funcStr, ")"))
ElseIf LCase(left(funcStr, 4)) = "rgb(" Then
    retVal = Func_RGB(GetString(5, funcStr, ")"))
ElseIf LCase(left(funcStr, 12)) = "getsoundpos(" Then
    retVal = Func_GetSoundPos(GetString(13, funcStr, ")"))
ElseIf LCase(left(funcStr, 12)) = "getsoundlen(" Then
    retVal = Func_GetSoundLen(GetString(13, funcStr, ")"))
ElseIf LCase(left(funcStr, 8)) = "replace(" Then
    retVal = Func_Replace(GetString(9, funcStr, ")"))
ElseIf LCase(left(funcStr, 7)) = "string(" Then
    retVal = Func_String(GetString(8, funcStr, ")"))
ElseIf LCase(left(funcStr, 5)) = "word(" Then
    retVal = Func_Word(GetString(6, funcStr, ")"))
ElseIf LCase(left(funcStr, 4)) = "sin(" Then
    retVal = Func_Sin(GetString(5, funcStr, ")"))
ElseIf LCase(left(funcStr, 4)) = "cos(" Then
    retVal = Func_Cos(GetString(5, funcStr, ")"))
ElseIf LCase(left(funcStr, 4)) = "tan(" Then
    retVal = Func_Tan(GetString(5, funcStr, ")"))
ElseIf LCase(left(funcStr, 4)) = "log(" Then
    retVal = Func_Log(GetString(5, funcStr, ")"))
ElseIf LCase(left(funcStr, 4)) = "exp(" Then
    retVal = Func_Exp(GetString(5, funcStr, ")"))
ElseIf LCase(left(funcStr, 4)) = "atn(" Then
    retVal = Func_Atn(GetString(5, funcStr, ")"))
ElseIf LCase(left(funcStr, 4)) = "hex(" Then
    retVal = Func_Hex(GetString(5, funcStr, ")"))
ElseIf LCase(left(funcStr, 4)) = "oct(" Then
    retVal = Func_Oct(GetString(5, funcStr, ")"))
ElseIf LCase(left(funcStr, 4)) = "sgn(" Then
    retVal = Func_Sgn(GetString(5, funcStr, ")"))
ElseIf LCase(left(funcStr, 6)) = "round(" Then
    retVal = Func_Round(GetString(7, funcStr, ")"))
Else
    EvalFunction = False
End If

End Function


Public Function Func_Sin(ByVal paramStr As String) As Variant

Dim num As Double

paramStr = Trim(paramStr)

num = EvalExpression(paramStr)

Func_Sin = Sin(num)

End Function


Public Function Func_Cos(ByVal paramStr As String) As Variant

Dim num As Double

paramStr = Trim(paramStr)

num = EvalExpression(paramStr)

Func_Cos = Cos(num)

End Function


Public Function Func_Atn(ByVal paramStr As String) As Variant

Dim num As Double

paramStr = Trim(paramStr)

num = EvalExpression(paramStr)

Func_Atn = Atn(num)

End Function


Public Function Func_Exp(ByVal paramStr As String) As Variant

Dim num As Double

paramStr = Trim(paramStr)

num = EvalExpression(paramStr)

Func_Exp = Exp(num)

End Function


Public Function Func_Log(ByVal paramStr As String) As Variant

Dim num As Double

paramStr = Trim(paramStr)

num = EvalExpression(paramStr)

Func_Log = Log(num)

End Function

Public Function Func_Sgn(ByVal paramStr As String) As Variant

Dim num As Variant

paramStr = Trim(paramStr)

num = EvalExpression(paramStr)

Func_Sgn = Sgn(num)

End Function


Public Function Func_Round(ByVal paramStr As String) As Variant

Dim params As New ArrayClass
Dim num1 As Double
Dim num2 As Long

paramStr = Trim(paramStr)

ParseParams paramStr, params

num1 = EvalExpression(params.Item(1))

If params.itemCount = 2 Then
    num2 = EvalExpression(params.Item(2))
    Func_Round = Round(num1, num2)
Else
    Func_Round = Round(num1)
End If

End Function

Public Function Func_Hex(ByVal paramStr As String) As Variant

Dim num As Variant

paramStr = Trim(paramStr)

num = EvalExpression(paramStr)

Func_Hex = Hex(num)

End Function


Public Function Func_Oct(ByVal paramStr As String) As Variant

Dim num As Variant

paramStr = Trim(paramStr)

num = EvalExpression(paramStr)

Func_Oct = Oct(num)

End Function


Public Function Func_Tan(ByVal paramStr As String) As Variant

Dim num As Double

paramStr = Trim(paramStr)

num = EvalExpression(paramStr)

Func_Tan = Tan(num)

End Function

Public Function Func_GetSoundPos(ByVal paramStr As String) As Variant

Dim soundName As String
Dim musicPos As String

paramStr = Trim(paramStr)

soundName = EvalExpression(paramStr)

musicPos = Space(255)
mciSendString "status " & soundName & " position", musicPos, 255, 0

Func_GetSoundPos = CLng(Trim(musicPos))

End Function


Public Function Func_GetSoundLen(ByVal paramStr As String) As Variant

Dim soundName As String
Dim musicLen As String

paramStr = Trim(paramStr)

soundName = EvalExpression(paramStr)

musicLen = Space(255)
mciSendString "status " & soundName & " length", musicLen, 255, 0

Func_GetSoundLen = CLng(Trim(musicLen))

End Function

Public Function Func_Loc(ByVal paramStr As String) As Variant

Dim a As Integer

paramStr = Trim(paramStr)

a = ExistsIn(paramStr, fileHandle)

If a Then
    Func_Loc = Loc(FileNumber.Item(a))
Else
    ErrorMsg "File handle does not exist: " & paramStr
End If

End Function



Public Function Func_Space(ByVal paramStr As String) As Variant

Dim num As Long

paramStr = Trim(paramStr)

num = EvalExpression(paramStr)

Func_Space = Space(num)

End Function



Public Function Func_EOF(ByVal paramStr As String) As Variant

Dim a As Integer

paramStr = Trim(paramStr)

a = ExistsIn(paramStr, fileHandle)

If a Then
    Func_EOF = Abs(EOF(FileNumber.Item(a)))
Else
    ErrorMsg "File handle does not exist: " & paramStr
End If

End Function



Public Function Func_LOF(ByVal paramStr As String) As Variant

Dim a As Integer

paramStr = Trim(paramStr)

a = ExistsIn(paramStr, fileHandle)

If a Then
    Func_LOF = LOF(FileNumber.Item(a))
Else
    ErrorMsg "File handle does not exist: " & paramStr
End If

End Function


Public Function Func_hBmp(ByVal paramStr As String) As Variant

Dim picName As String
Dim n As Integer

paramStr = Trim(paramStr)

picName = EvalExpression(paramStr)

n = ExistsIn(picName, imgName)

If n Then
    Func_hBmp = imgHandle.Item(n)
Else
    ErrorMsg "Image '" & picName & "' does not exist"
End If

End Function



Public Function Func_FileSave(ByVal paramStr As String) As Variant

Dim titleStr, filterStr, filename As String
Dim params As New ArrayClass

paramStr = Trim(paramStr)

ParseParams paramStr, params

titleStr = EvalExpression(params.Item(1))
filterStr = EvalExpression(params.Item(2))

filename = FileDialog(titleStr, filterStr, 1)

Func_FileSave = Mid(filename, 1, InStr(1, filename, Chr(0)) - 1)

End Function


Public Function Func_FileOpen(ByVal paramStr As String) As Variant

Dim titleStr, filterStr, filename As String
Dim params As New ArrayClass

paramStr = Trim(paramStr)

ParseParams paramStr, params

titleStr = EvalExpression(params.Item(1))
filterStr = EvalExpression(params.Item(2))

filename = FileDialog(titleStr, filterStr, 0)

Func_FileOpen = Mid(filename, 1, InStr(1, filename, Chr(0)) - 1)

End Function



Public Function Func_Sqr(ByVal paramStr As String) As Variant

Dim num As Long

paramStr = Trim(paramStr)

num = EvalExpression(paramStr)

Func_Sqr = Sqr(num)

End Function


Public Function Func_Max(ByVal paramStr As String) As Variant

Dim num1, num2 As Long
Dim params As New ArrayClass

paramStr = Trim(paramStr)

ParseParams paramStr, params

num1 = EvalExpression(params.Item(1))
num2 = EvalExpression(params.Item(2))

Func_Max = Max(num1, num2)

End Function



Public Function Func_Min(ByVal paramStr As String) As Variant

Dim num1, num2 As Long
Dim params As New ArrayClass

paramStr = Trim(paramStr)

ParseParams paramStr, params

num1 = EvalExpression(params.Item(1))
num2 = EvalExpression(params.Item(2))

Func_Min = Min(num1, num2)

End Function



Public Function Func_InputBox(ByVal paramStr As String) As Variant

Dim params As New ArrayClass
Dim promptStr, titleStr As String
Dim defVal As Variant

paramStr = Trim(paramStr)

ParseParams paramStr, params

promptStr = EvalExpression(params.Item(1))
titleStr = EvalExpression(params.Item(2))
If params.itemCount = 3 Then defVal = EvalExpression(params.Item(3))

inputWin.prompt.Caption = promptStr
inputWin.Caption = titleStr
inputWin.inputVal.Text = defVal
inputWin.Show vbModal

Func_InputBox = userInput
userInput = ""

End Function


Public Function Func_GetLineText(ByVal paramStr As String) As Variant

Dim winName, lineText As String
Dim lLen, lNum As Long
Dim params As New ArrayClass
Dim ctlObj As Object

paramStr = Trim(paramStr)

ParseParams paramStr, params

winName = EvalExpression(params.Item(1))
lNum = EvalExpression(params.Item(2))

Set ctlObj = GetControlObj(winName)

If ctlObj Is Nothing Then
    ErrorMsg "Control '" & winName & "' does not exist"
    Exit Function
End If

If ctlObj.ctlType = "textbox" Or ctlObj.ctlType = "texteditor" Then
    lineText = Space(255)
    lLen = SendMessage(ctlObj.winHandle, EM_GETLINE, lNum - 1, ByVal lineText)
    lineText = left(lineText, lLen)
    Func_GetLineText = lineText
Else
    ErrorMsg "Control '" & winName & "' needs to be a TEXTBOX or TEXTEDITOR"
End If

End Function


Public Function Func_LineCount(ByVal paramStr As String) As Variant

Dim winName As String
Dim lNum As Long
Dim ctlObj As Object

paramStr = Trim(paramStr)

winName = EvalExpression(paramStr)

Set ctlObj = GetControlObj(winName)

If ctlObj Is Nothing Then
    ErrorMsg "Control '" & winName & "' does not exist"
    Exit Function
End If

If ctlObj.ctlType = "textbox" Or ctlObj.ctlType = "texteditor" Then
    lNum = SendMessage(ctlObj.winHandle, EM_GETLINECOUNT, 0, 0)
    Func_LineCount = lNum
Else
    ErrorMsg "Control '" & winName & "' needs to be a TEXTBOX or TEXTEDITOR"
End If

End Function


Public Function Func_ItemCount(ByVal paramStr As String) As Variant

Dim winName As String
Dim itemNum As Integer
Dim ctlObj As Object

paramStr = Trim(paramStr)

winName = EvalExpression(paramStr)

Set ctlObj = GetControlObj(winName)

If ctlObj Is Nothing Then
    ErrorMsg "Control '" & winName & "' does not exist"
    Exit Function
End If
        
If ctlObj.ctlType = "listbox" Then
    itemNum = SendMessage(ctlObj.winHandle, LB_GETCOUNT, 0, 0)
    Func_ItemCount = itemNum
ElseIf ctlObj.ctlType = "combobox" Then
    itemNum = SendMessage(ctlObj.winHandle, CB_GETCOUNT, 0, 0)
    Func_ItemCount = itemNum
Else
    ErrorMsg "Control '" & winName & "' needs to be a COMBOBOX or LISTBOX"
End If

End Function

Public Function Func_GetSelIdx(ByVal paramStr As String) As Variant

Dim winName As String
Dim itemIdx As Integer
Dim ctlObj As Object

paramStr = Trim(paramStr)

winName = EvalExpression(paramStr)

Set ctlObj = GetControlObj(winName)

If ctlObj Is Nothing Then
    ErrorMsg "Control '" & winName & "' does not exist"
    Exit Function
End If

If ctlObj.ctlType = "listbox" Then
    itemIdx = SendMessage(ctlObj.winHandle, LB_GETCURSEL, 0, 0)
    Func_GetSelIdx = itemIdx + 1
ElseIf ctlObj.ctlType = "combobox" Then
    itemIdx = SendMessage(ctlObj.winHandle, CB_GETCURSEL, 0, 0)
    Func_GetSelIdx = itemIdx + 1
Else
    ErrorMsg "Control '" & winName & "' needs to be a COMBOBOX or LISTBOX"
End If

End Function


Public Function Func_GetSelText(ByVal paramStr As String) As Variant

Dim winName, selText As String
Dim winText As String
Dim startPos, endPos As Integer
Dim textLen, selected As Long
Dim ctlObj As Object

paramStr = Trim(paramStr)

winName = EvalExpression(paramStr)

Set ctlObj = GetControlObj(winName)

If ctlObj Is Nothing Then
    ErrorMsg "Control '" & winName & "' does not exist"
    Exit Function
End If

If ctlObj.ctlType = "textbox" Or ctlObj.ctlType = "texteditor" Then
    textLen = GetWindowTextLength(ctlObj.winHandle)
    winText = Space(textLen + 1)
    GetWindowText ctlObj.winHandle, winText, textLen + 1
    selected = SendMessage(ctlObj.winHandle, EM_GETSEL, 0, 0)
    startPos = LOWORD(selected) + 1
    endPos = HIWORD(selected) + 1
    selText = Mid(winText, startPos, endPos - startPos)
    Func_GetSelText = selText
Else
    ErrorMsg "Control '" & winName & "' needs to be a TEXTBOX or TEXTEDITOR"
End If

End Function

Public Sub RunWhileBlock(ByVal startLne As Integer, ByVal endLne As Integer)

Dim str, expStr, tmpLine As String

expStr = Right(runCode.Item(startLne), Len(runCode.Item(startLne)) - 6)

While EvalExpression(expStr)
  If debugging Then debugWin.code.ListIndex = startLne
  If endLne > startLne Then
    For lineNum = startLne + 1 To endLne
        DebugWait
        If Not RunBlock(lineNum, endLne) Then
            RunCmd runCode.Item(lineNum)
        End If
        If progDone Then Exit Sub
        If lineNum < startLne Or lineNum > endLne Then Exit Sub
        If debugging Then debugWin.code.ListIndex = lineNum
    Next lineNum
  End If
  DebugWait
  If debugging Then debugWin.code.ListIndex = startLne - 1
  DebugWait
Wend

lineNum = endLne + 1


End Sub

Public Sub SetValue(ByVal varStr As String, ByVal value As Variant)

Dim svObj As SubProgClass

varStr = Trim(varStr)

If ObjPtr(Me) <> ObjPtr(mainCode) Then
    Set svObj = Me
    GoSub doSetVal
End If

Set svObj = mainCode
GoSub doSetVal

Exit Sub


doSetVal:
For n = 1 To svObj.varName.itemCount
    If svObj.varName.Item(n) = varStr Then
        If svObj.varType.Item(n) = DT_NUMBER Then
            svObj.varValue.Item(n) = Val(value)
            For a = 1 To svObj.varBindList.Item(n).itemCount
                svObj.varValue.Item(svObj.varBindList.Item(n).Item(a)) = Val(value)
            Next a
        Else
            svObj.varValue.Item(n) = value
            For a = 1 To svObj.varBindList.Item(n).itemCount
                svObj.varValue.Item(svObj.varBindList.Item(n).Item(a)) = value
            Next a
        End If
        If debugging Then DebugUpdateVars svObj
        Exit Sub
    End If
Next n
For n = 1 To svObj.arrayName.itemCount
    If left(varStr, Len(svObj.arrayName.Item(n))) = svObj.arrayName.Item(n) And (Right(varStr, 1) = ")") Then
        idxStr = GetString(Len(GetString(1, varStr, "(")) + 2, varStr, ")")
        firstIdx = GetString(1, idxStr, ",")
        firstVal = EvalExpression(firstIdx)
        If firstVal < 0 Or (firstVal + 1) > svObj.arrayValue.Item(n).itemCount Then
            ErrorMsg "Illegal index value"
            Exit Sub
        End If
        If Len(firstIdx) < Len(idxStr) Then
            If Not svObj.isMultiDim.Item(n) Then
                ErrorMsg "Array is one dimensional"
                Exit Sub
            End If
            secondIdx = Right(idxStr, Len(idxStr) - (Len(firstIdx) + 1))
            secondVal = EvalExpression(secondIdx)
            If secondVal < 0 Or (secondVal + 1) > svObj.arrayValue.Item(n).Item(1).itemCount Then
                ErrorMsg "Illegal index value"
                Exit Sub
            End If
            If svObj.arrayType.Item(n) = DT_NUMBER Then
                svObj.arrayValue.Item(n).Item(firstVal + 1).Item(secondVal + 1) = Val(value)
            Else
                svObj.arrayValue.Item(n).Item(firstVal + 1).Item(secondVal + 1) = value
            End If
        Else
            If svObj.isMultiDim.Item(n) Then
                ErrorMsg "Array is two dimensional"
                Exit Sub
            End If
            If svObj.arrayType.Item(n) = DT_NUMBER Then
                svObj.arrayValue.Item(n).Item(firstVal + 1) = Val(value)
            Else
                svObj.arrayValue.Item(n).Item(firstVal + 1) = value
            End If
        End If
        Exit Sub
    End If
Next n
Return

End Sub



Public Sub UnloadDLL(ByVal cmdStr As String)
    
End Sub


