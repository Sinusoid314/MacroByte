VERSION 5.00
Object = "{831FDD16-0C5C-11D2-A9FC-0000F8754DA1}#2.0#0"; "MSCOMCTL.OCX"
Begin VB.MDIForm mainWin 
   AutoShowChildren=   0   'False
   BackColor       =   &H8000000C&
   Caption         =   "MacroByte v1.0"
   ClientHeight    =   9195
   ClientLeft      =   165
   ClientTop       =   450
   ClientWidth     =   12900
   Icon            =   "mainWin.frx":0000
   LinkTopic       =   "MDIForm1"
   OLEDropMode     =   1  'Manual
   ScrollBars      =   0   'False
   StartUpPosition =   2  'CenterScreen
   Begin VB.Timer Timer1 
      Enabled         =   0   'False
      Left            =   4890
      Top             =   2970
   End
   Begin MSComctlLib.ImageList img1 
      Left            =   4890
      Top             =   1740
      _ExtentX        =   1005
      _ExtentY        =   1005
      BackColor       =   -2147483643
      ImageWidth      =   16
      ImageHeight     =   16
      MaskColor       =   12632256
      _Version        =   393216
      BeginProperty Images {2C247F25-8591-11D1-B16A-00C0F0283628} 
         NumListImages   =   10
         BeginProperty ListImage1 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "mainWin.frx":0442
            Key             =   "new"
         EndProperty
         BeginProperty ListImage2 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "mainWin.frx":07DC
            Key             =   "open"
         EndProperty
         BeginProperty ListImage3 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "mainWin.frx":0B76
            Key             =   "save"
         EndProperty
         BeginProperty ListImage4 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "mainWin.frx":0F10
            Key             =   "cut"
         EndProperty
         BeginProperty ListImage5 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "mainWin.frx":12AA
            Key             =   "copy"
         EndProperty
         BeginProperty ListImage6 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "mainWin.frx":1644
            Key             =   "paste"
         EndProperty
         BeginProperty ListImage7 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "mainWin.frx":19DE
            Key             =   "run"
         EndProperty
         BeginProperty ListImage8 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "mainWin.frx":1D78
            Key             =   "debug"
         EndProperty
         BeginProperty ListImage9 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "mainWin.frx":2112
            Key             =   "tools"
         EndProperty
         BeginProperty ListImage10 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "mainWin.frx":24AC
            Key             =   "help"
         EndProperty
      EndProperty
   End
   Begin MSComctlLib.StatusBar statusbar 
      Align           =   2  'Align Bottom
      Height          =   270
      Left            =   0
      TabIndex        =   1
      Top             =   8925
      Width           =   12900
      _ExtentX        =   22754
      _ExtentY        =   476
      Style           =   1
      SimpleText      =   "Ready."
      _Version        =   393216
      BeginProperty Panels {8E3867A5-8586-11D1-B16A-00C0F0283628} 
         NumPanels       =   1
         BeginProperty Panel1 {8E3867AB-8586-11D1-B16A-00C0F0283628} 
         EndProperty
      EndProperty
   End
   Begin MSComctlLib.Toolbar toolbar1 
      Align           =   1  'Align Top
      Height          =   420
      Left            =   0
      TabIndex        =   0
      Top             =   0
      Width           =   12900
      _ExtentX        =   22754
      _ExtentY        =   741
      ButtonWidth     =   609
      ButtonHeight    =   582
      AllowCustomize  =   0   'False
      Wrappable       =   0   'False
      Appearance      =   1
      ImageList       =   "img1"
      _Version        =   393216
      BeginProperty Buttons {66833FE8-8583-11D1-B16A-00C0F0283628} 
         NumButtons      =   14
         BeginProperty Button1 {66833FEA-8583-11D1-B16A-00C0F0283628} 
            Key             =   "new"
            Object.ToolTipText     =   "New"
            ImageIndex      =   1
         EndProperty
         BeginProperty Button2 {66833FEA-8583-11D1-B16A-00C0F0283628} 
            Key             =   "open"
            Object.ToolTipText     =   "Open"
            ImageIndex      =   2
         EndProperty
         BeginProperty Button3 {66833FEA-8583-11D1-B16A-00C0F0283628} 
            Key             =   "save"
            Object.ToolTipText     =   "Save"
            ImageIndex      =   3
         EndProperty
         BeginProperty Button4 {66833FEA-8583-11D1-B16A-00C0F0283628} 
            Style           =   3
         EndProperty
         BeginProperty Button5 {66833FEA-8583-11D1-B16A-00C0F0283628} 
            Key             =   "cut"
            Object.ToolTipText     =   "Cut"
            ImageIndex      =   4
         EndProperty
         BeginProperty Button6 {66833FEA-8583-11D1-B16A-00C0F0283628} 
            Key             =   "copy"
            Object.ToolTipText     =   "Copy"
            ImageIndex      =   5
         EndProperty
         BeginProperty Button7 {66833FEA-8583-11D1-B16A-00C0F0283628} 
            Key             =   "paste"
            Object.ToolTipText     =   "Paste"
            ImageIndex      =   6
         EndProperty
         BeginProperty Button8 {66833FEA-8583-11D1-B16A-00C0F0283628} 
            Style           =   3
         EndProperty
         BeginProperty Button9 {66833FEA-8583-11D1-B16A-00C0F0283628} 
            Key             =   "run"
            Object.ToolTipText     =   "Run Program"
            ImageIndex      =   7
         EndProperty
         BeginProperty Button10 {66833FEA-8583-11D1-B16A-00C0F0283628} 
            Key             =   "debug"
            Object.ToolTipText     =   "Debug Program"
            ImageIndex      =   8
         EndProperty
         BeginProperty Button11 {66833FEA-8583-11D1-B16A-00C0F0283628} 
            Style           =   3
         EndProperty
         BeginProperty Button12 {66833FEA-8583-11D1-B16A-00C0F0283628} 
            Enabled         =   0   'False
            Key             =   "edittools"
            Object.ToolTipText     =   "Edit Tools"
            ImageIndex      =   9
         EndProperty
         BeginProperty Button13 {66833FEA-8583-11D1-B16A-00C0F0283628} 
            Style           =   3
         EndProperty
         BeginProperty Button14 {66833FEA-8583-11D1-B16A-00C0F0283628} 
            Key             =   "about"
            Object.ToolTipText     =   "About MicroByte"
            ImageIndex      =   10
         EndProperty
      EndProperty
      Begin VB.ComboBox tools 
         Height          =   315
         Left            =   5460
         Style           =   2  'Dropdown List
         TabIndex        =   3
         TabStop         =   0   'False
         Top             =   30
         Width           =   3480
      End
      Begin VB.PictureBox Picture1 
         BorderStyle     =   0  'None
         Height          =   315
         Left            =   4785
         ScaleHeight     =   315
         ScaleWidth      =   660
         TabIndex        =   4
         TabStop         =   0   'False
         Top             =   30
         Width           =   660
         Begin VB.Label Label1 
            Caption         =   "Tools:"
            BeginProperty Font 
               Name            =   "Times New Roman"
               Size            =   8.25
               Charset         =   0
               Weight          =   400
               Underline       =   0   'False
               Italic          =   0   'False
               Strikethrough   =   0   'False
            EndProperty
            Height          =   210
            Left            =   45
            TabIndex        =   2
            Top             =   45
            Width           =   480
         End
      End
   End
   Begin VB.Menu mnuFile 
      Caption         =   "&File"
      Begin VB.Menu mnuFileNew 
         Caption         =   "&New"
      End
      Begin VB.Menu mnuFileOpen 
         Caption         =   "&Open"
      End
      Begin VB.Menu mnuFileSave 
         Caption         =   "&Save"
      End
      Begin VB.Menu mnuFileSaveAs 
         Caption         =   "Save &As..."
      End
      Begin VB.Menu mnuFilePrint 
         Caption         =   "&Print"
      End
      Begin VB.Menu mnuFileSep1 
         Caption         =   "-"
      End
      Begin VB.Menu mnuFileRecent 
         Caption         =   "No File"
         Enabled         =   0   'False
         Index           =   0
      End
      Begin VB.Menu mnuFileRecent 
         Caption         =   "No File"
         Enabled         =   0   'False
         Index           =   1
      End
      Begin VB.Menu mnuFileRecent 
         Caption         =   "No File"
         Enabled         =   0   'False
         Index           =   2
      End
      Begin VB.Menu mnuFileRecent 
         Caption         =   "No File"
         Enabled         =   0   'False
         Index           =   3
      End
      Begin VB.Menu mnuFileRecent 
         Caption         =   "No File"
         Enabled         =   0   'False
         Index           =   4
      End
      Begin VB.Menu mnuFileSep2 
         Caption         =   "-"
      End
      Begin VB.Menu mnuFileExit 
         Caption         =   "E&xit"
      End
   End
   Begin VB.Menu mnuEdit 
      Caption         =   "&Edit"
      Begin VB.Menu mnuEditUndo 
         Caption         =   "&Undo"
      End
      Begin VB.Menu mnuEditSep1 
         Caption         =   "-"
      End
      Begin VB.Menu mnuEditCut 
         Caption         =   "Cu&t"
      End
      Begin VB.Menu mnuEditCopy 
         Caption         =   "&Copy"
      End
      Begin VB.Menu mnuEditPaste 
         Caption         =   "&Paste"
      End
      Begin VB.Menu mnuEditSep2 
         Caption         =   "-"
      End
      Begin VB.Menu mnuEditSelAll 
         Caption         =   "&Select All"
      End
      Begin VB.Menu mnuEditSep3 
         Caption         =   "-"
      End
      Begin VB.Menu mnuEditFind 
         Caption         =   "&Find..."
      End
   End
   Begin VB.Menu mnuProgram 
      Caption         =   "&Program"
      Begin VB.Menu mnuProgramRun 
         Caption         =   "&Run Code"
      End
      Begin VB.Menu mnuProgramDebug 
         Caption         =   "&Debug Code"
      End
      Begin VB.Menu mnuProgramSep1 
         Caption         =   "-"
      End
      Begin VB.Menu mnuProgramCreate 
         Caption         =   "&Create Runtime File"
      End
   End
   Begin VB.Menu mnuTools 
      Caption         =   "&Tools"
      Begin VB.Menu mnuToolsEdit 
         Caption         =   "&Edit Tools"
      End
      Begin VB.Menu mnuToolsProgs 
         Caption         =   "&Startup Programs"
      End
      Begin VB.Menu mnuToolsSep1 
         Caption         =   "-"
      End
      Begin VB.Menu mnuToolsReg 
         Caption         =   "Register Lithium BASIC"
      End
      Begin VB.Menu mnuToolsSep2 
         Caption         =   "-"
         Visible         =   0   'False
      End
      Begin VB.Menu mnuToolsOptions 
         Caption         =   "&Options"
         Visible         =   0   'False
      End
   End
   Begin VB.Menu mnuWindow 
      Caption         =   "&Window"
      WindowList      =   -1  'True
   End
   Begin VB.Menu mnuHelp 
      Caption         =   "&Help"
      Begin VB.Menu mnuHelpContents 
         Caption         =   "&Contents..."
      End
      Begin VB.Menu mnuHelpFeatures 
         Caption         =   "Lithium BASIC 1.02 &Features"
      End
      Begin VB.Menu mnuHelpSep1 
         Caption         =   "-"
      End
      Begin VB.Menu mnuHelpSite 
         Caption         =   "Visit the Lithium BASIC Web Site..."
      End
      Begin VB.Menu mnuHelpSep2 
         Caption         =   "-"
      End
      Begin VB.Menu mnuHelpAbout 
         Caption         =   "&About Lithium BASIC"
      End
   End
End
Attribute VB_Name = "mainWin"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Declare Function SendMessage Lib "user32" Alias "SendMessageA" (ByVal hwnd As Long, ByVal wMsg As Long, ByVal wParam As Long, lParam As Any) As Long
Private Declare Function ShellExecute Lib "shell32.dll" Alias "ShellExecuteA" (ByVal hwnd As Long, ByVal lpOperation As String, ByVal lpFile As String, ByVal lpParameters As String, ByVal lpDirectory As String, ByVal nShowCmd As Long) As Long
Private Const WM_USER As Long = &H400
Private Const EM_SETTARGETDEVICE As Long = WM_USER + 72
Private Const EM_UNDO = &HC7

Private Declare Function GetTickCount Lib "kernel32" () As Long
Private Declare Function OpenProcess Lib "kernel32" (ByVal dwDesiredAccess As Long, ByVal bInheritHandle As Long, ByVal dwProcessId As Long) As Long
Private Declare Function WaitForSingleObject Lib "kernel32" (ByVal hHandle As Long, ByVal dwMilliseconds As Long) As Long
Private Declare Function CloseHandle Lib "kernel32" (ByVal hObject As Long) As Long
Private Declare Sub Sleep Lib "kernel32" (ByVal dwMilliseconds As Long)
Private Const WAIT_OBJECT_0 = 0
Const SYNCHRONIZE = &H100000

Private Declare Function ShellExecuteEx Lib "shell32.dll" (SEI As SHELLEXECUTEINFO) As Long
Private Const SEE_MASK_NOCLOSEPROCESS = &H40
Private Const SW_NORMAL = 1
Private Type SHELLEXECUTEINFO
    cbSize As Long
    fMask As Long
    hwnd As Long
    lpVerb As String
    lpFile As String
    lpParameters As String
    lpDirectory As String
    nShow As Long
    hInstApp As Long
    lpIDList As Long
    lpClass As String
    hkeyClass As Long
    dwHotKey As Long
    hIcon As Long
    hProcess As Long
End Type

Private RecentFiles(0 To 4) As String


Private Function CompileCode(ByVal rtMode As String, ByVal workingDir As String, ByVal sourceFile As String, ByVal rtExeFile As String, ByVal resultFile As String) As Boolean

Dim cmdStr As String
Dim resultVal As Long
Dim resultStr As String
Dim tmpStr As String
Dim pID As Long
Dim pHnd As Long

CompileCode = True

cmdStr = rtMode & "|" & _
        workingDir & "|" & _
        sourceFile & "|" & _
        rtExeFile & "|" & _
        resultFile

'Run compiler
pHnd = ShellProg(App.Path & "\..\Compiler\Compiler.exe", cmdStr)
'pID = Shell(App.Path & "\..\Compiler\Compiler.exe " & cmdStr, vbNormalFocus)
    If pHnd = 0 Then
        MsgBox "Could not run compiler", vbCritical, "MBEdit Error"
        CompileCode = False
        statusbar.SimpleText = "Compile error!"
        Exit Function
    End If

'pHnd = OpenProcess(SYNCHRONIZE, 0, pID)
'    If pHnd = 0 Then
'        MsgBox "Could not run compiler", vbcritial, "MBEdit Error"
'        CompileCode = False
'        Exit Function
'    End If

'Wait for compiler to finish
While WaitForSingleObject(pHnd, 0) <> WAIT_OBJECT_0
    DoEvents
    Sleep 1
Wend

CloseHandle (pHnd)

'Get compiler results
Open resultFile For Input As #1
    Input #1, tmpStr
    resultVal = CLng(tmpStr)
    Input #1, resultStr
Close #1

If resultVal > 0 Then
    SelectLine mainWin.ActiveForm.editor, resultVal
    statusbar.SimpleText = "Compile error!"
    MsgBox resultStr
    CompileCode = False
ElseIf resultVal < 0 Then
    statusbar.SimpleText = resultStr
    CompileCode = False
End If

End Function


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

Private Sub SelectLine(txtControl As Object, ByVal theLine As Integer)

'This sub selects the given line from a VB textbox control

Dim lneCount As Integer
Dim lneTxt As String

lneCount = 0

For a = 1 To Len(txtControl.Text)
    If Mid(txtControl.Text, a, 2) = vbCrLf Then
        lneCount = lneCount + 1
        If lneCount = theLine Then
            txtControl.SelStart = (a - 1) - Len(lneTxt)
            txtControl.SelLength = Len(lneTxt)
            Exit Sub
        Else
            a = a + 1
            lneTxt = ""
        End If
    Else
        lneTxt = lneTxt & Mid(txtControl.Text, a, 1)
    End If
    If a = Len(txtControl.Text) Then
        lneCount = lneCount + 1
        If lneCount = theLine Then
            txtControl.SelStart = a - Len(lneTxt)
            txtControl.SelLength = Len(lneTxt)
            Exit Sub
        End If
    End If
Next a

End Sub
Private Sub AddRecentFile(ByVal fName As String)

'Check if the new filename is already there
For n = 0 To 4
    If fName = RecentFiles(n) Then Exit Sub
Next n

'Add new filename
For n = 4 To 1 Step -1
    RecentFiles(n) = RecentFiles(n - 1)
Next n
RecentFiles(0) = fName
  
'Reload menu items with filename data
For n = 0 To 4
  If RecentFiles(n) = "" Then
    mnuFileRecent(n).Caption = "No File"
    mnuFileRecent(n).Enabled = False
  Else
    mnuFileRecent(n).Caption = "&" & (n + 1) & ". " & RecentFiles(n)
    mnuFileRecent(n).Enabled = True
  End If
Next n

If Dir(App.Path & "\recent.dat") = "" Then Exit Sub

Open App.Path & "\recent.dat" For Output As #1
    For n = 0 To 4
        Print #1, RecentFiles(n)
    Next n
Close #1

End Sub

Private Sub LoadFile(ByVal fName As String)

Dim newWin As Form
Dim tmpTxt As String

Open fName For Input As #1
  tmpTxt = Input(LOF(1), 1)
Close #1

Set newWin = New editorWin

newWin.editor.Text = tmpTxt
newWin.hasChanged = False
newWin.filename = fName
newWin.Show

newWin.Caption = fName
statusbar.SimpleText = "Ready."

AddRecentFile fName

End Sub


Private Sub LoadRecentFiles()

If Dir(App.Path & "\recent.dat") = "" Then Exit Sub

Dim tmpFile As String

Open App.Path & "\recent.dat" For Input As #1
    If EOF(1) Then
        Close #1
        Exit Sub
    End If
    For n = 0 To 4
        Input #1, tmpFile
        RecentFiles(n) = Trim(tmpFile)
        If Trim(tmpFile) = "" Then
            mnuFileRecent(n).Caption = "No File"
        Else
            mnuFileRecent(n).Caption = "&" & (n + 1) & ". " & tmpFile
            mnuFileRecent(n).Enabled = True
        End If
    Next n
Close #1

End Sub


Private Sub LoadTools()

If Dir(App.Path & "\tools.dat") = "" Then Exit Sub

Dim num As Integer
Dim tName, tProg, tCmdOpt, tStartOpt As String
Dim hPic As Long

Open App.Path & "\tools.dat" For Input As #1
    Input #1, num
    If num = 0 Then
        Close #1
        Exit Sub
    End If
    For n = 1 To num
        Input #1, tName
        Input #1, tProg
        Input #1, tStartOpt
        Input #1, tCmdOpt
        tools.AddItem tName
        ToolName.Add tName
        ToolProg.Add tProg
        ToolStartOpt.Add CInt(tStartOpt)
        ToolCmdOpt.Add tCmdOpt
    Next n
Close #1

For n = 1 To num
    If ToolStartOpt.Item(n) Then
        RunToolProg n
    End If
Next n

End Sub


Private Sub RemoveRecentFile(ByVal mnuIdx As Integer)

'Check if mnuIdx is in bounds
If mnuIdx < 0 Or mnuIdx > 4 Then Exit Sub

'Remove filename
For n = mnuIdx To 3
    RecentFiles(n) = RecentFiles(n + 1)
Next n
RecentFiles(4) = ""

'Reload menu items with filename data
For n = 0 To 4
  If RecentFiles(n) = "" Then
    mnuFileRecent(n).Caption = "No File"
    mnuFileRecent(n).Enabled = False
  Else
    mnuFileRecent(n).Caption = "&" & (n + 1) & ". " & RecentFiles(n)
    mnuFileRecent(n).Enabled = True
  End If
Next n

If Dir(App.Path & "\recent.dat") = "" Then Exit Sub

Open App.Path & "\recent.dat" For Output As #1
    For n = 0 To 4
        Print #1, RecentFiles(n)
    Next n
Close #1

End Sub

Private Sub RunToolProg(ByVal progIdx As Long)

Dim coList() As String
Dim tmpCL As String

'If Dir(ToolProg.Item(progIdx)) = "" Then Exit Sub

'coList = Split(ToolCmdOpt.Item(progIdx), ",")

'If CInt(coList(0)) Then tmpCL = str(mainWin.hwnd)

'Shell ToolProg.Item(progIdx) & " " & tmpCL, vbNormalFocus

End Sub


Private Function ShellProg(ByVal progFile As String, ByVal cmdStr As String) As Long

Dim SEI As SHELLEXECUTEINFO

With SEI
    .cbSize = Len(SEI)
    .fMask = SEE_MASK_NOCLOSEPROCESS
    .hwnd = 0
    .lpVerb = vbNullChar
    .lpFile = progFile
    .lpParameters = cmdStr
    .lpDirectory = ParseFilePath(progFile)
    .nShow = SW_NORMAL
    .hInstApp = 0
    .lpIDList = 0
End With

ShellExecuteEx SEI

ShellProg = SEI.hProcess

End Function

Private Sub MDIForm_Load()

'LoadOptions
LoadRecentFiles
'LoadMbr

'startup.Show vbModal

'If Not isMbr Then mnuProgramCreate.Enabled = False

LoadTools

If Trim(Command$) <> "" Then
  LoadFile Mid(Command$, 2, Len(Command$) - 2)
End If

End Sub


Private Sub MDIForm_OLEDragDrop(Data As DataObject, Effect As Long, Button As Integer, Shift As Integer, X As Single, Y As Single)

For n = 1 To Data.Files.Count
    If Right(Data.Files(n), 4) = ".bas" Then LoadFile Data.Files(n)
Next n

End Sub


Private Sub MDIForm_Unload(Cancel As Integer)

'If Not isMbr Then startup.Show

End Sub


Private Sub mnuEditCopy_Click()

If mainWin.ActiveForm Is Nothing Then Exit Sub
Clipboard.SetText mainWin.ActiveForm.editor.SelText

End Sub

Private Sub mnuEditCut_Click()

If mainWin.ActiveForm Is Nothing Then Exit Sub
Clipboard.SetText mainWin.ActiveForm.editor.SelText
mainWin.ActiveForm.editor.SelText = ""

End Sub

Private Sub mnuEditFind_Click()

If mainWin.ActiveForm Is Nothing Then Exit Sub
findDlg.Show 0, Me

End Sub

Private Sub mnuEditPaste_Click()

If mainWin.ActiveForm Is Nothing Then Exit Sub
mainWin.ActiveForm.editor.SelText = Clipboard.GetText

End Sub

Private Sub mnuEditSelAll_Click()

If mainWin.ActiveForm Is Nothing Then Exit Sub
mainWin.ActiveForm.editor.SelStart = 0
mainWin.ActiveForm.editor.SelLength = Len(mainWin.ActiveForm.editor.Text)

End Sub

Private Sub mnuEditUndo_Click()

If mainWin.ActiveForm Is Nothing Then Exit Sub
SendMessage mainWin.ActiveForm.editor.hwnd, EM_UNDO, 0, 0

End Sub

Private Sub mnuFileExit_Click()

Unload Me

End Sub

Private Sub mnuFileNew_Click()
  
Dim newWin As Form

Set newWin = New editorWin
newWin.Show

statusbar.SimpleText = "Ready."

End Sub

Private Sub mnuFileOpen_Click()

Dim tmpFile As String

tmpFile = FileDialog("Open...", "BASIC Source File (*.bas)" & Chr(0) & "*.bas" & Chr(0), 0)
If tmpFile = "" Then Exit Sub

LoadFile tmpFile
  
End Sub

Private Sub mnuFilePrint_Click()

On Error Resume Next

Dim aWin As Form

If mainWin.ActiveForm Is Nothing Then Exit Sub
Set aWin = mainWin.ActiveForm

'dialog.DialogTitle = "Print Code..."
'dialog.CancelError = True
'dialog.flags = cdlPDReturnDC + cdlPDNoPageNums
'If aWin.editor.SelLength = 0 Then
'    dialog.flags = dialog.flags + cdlPDAllPages
'Else
'    dialog.flags = dialog.flags + cdlPDSelection
'End If
'dialog.ShowPrinter
'If Err <> cdlCancel Then
'    aWin.editor.SelPrint dialog.hDC
'End If

End Sub

Private Sub mnuFileRecent_Click(Index As Integer)

On Error GoTo openError

If Dir(RecentFiles(Index)) = "" Then GoTo openError
LoadFile RecentFiles(Index)

Exit Sub

openError:
    MsgBox "File not found", vbCritical, "Lithium BASIC Error"
    RemoveRecentFile Index

End Sub
Public Sub mnuFileSave_Click()

Dim aWin As Form
Dim tmpFile As String

If mainWin.ActiveForm Is Nothing Then Exit Sub
Set aWin = mainWin.ActiveForm

If aWin.filename = "" Then
    tmpFile = FileDialog("Save As...", "BASIC Source File (*.bas)" & Chr(0) & "*.bas" & Chr(0), 1)
    If tmpFile = "" Then Exit Sub
    aWin.filename = tmpFile
    Open aWin.filename For Output As #1
        Print #1, aWin.editor.Text;
    Close #1
    aWin.Caption = aWin.filename
    aWin.hasChanged = False
    AddRecentFile aWin.filename
Else
    Open aWin.filename For Output As #1
        Print #1, aWin.editor.Text;
    Close #1
    aWin.hasChanged = False
End If

End Sub


Private Sub mnuFileSaveAs_Click()

Dim aWin As Form
Dim tmpFile As String

If mainWin.ActiveForm Is Nothing Then Exit Sub
Set aWin = mainWin.ActiveForm

tmpFile = FileDialog("Save As...", "BASIC Source File (*.bas)" & Chr(0) & "*.bas" & Chr(0), 1)
If tmpFile = "" Then Exit Sub

Open tmpFile For Output As #1
    Print #1, aWin.editor.Text;
Close #1

AddRecentFile tmpFile

End Sub


Private Sub mnuHelpAbout_Click()

about.Show vbModal

End Sub



Private Sub mnuHelpContents_Click()

ShellExecute 0, "open", App.Path & "\Help\Macrobyte v1.0 Help.chm", "", "", 1

End Sub

Private Sub mnuHelpFeatures_Click()

Shell "notepad " & App.Path & "\version 1.02.txt"

End Sub

Private Sub mnuHelpSite_Click()

ShellExecute 0, "open", "http://sircodezalot.britcoms.com/", "", "", 1

End Sub



Private Sub mnuProgramDebug_Click()

Dim rtMode As String
Dim workingDir As String
Dim sourceFile As String
Dim rtExeFile As String
Dim resultFile As String

If mainWin.ActiveForm Is Nothing Then Exit Sub
If Trim(mainWin.ActiveForm.editor.Text) = "" Then Exit Sub

mnuProgram.Enabled = False
toolbar1.Buttons(9).Enabled = False
toolbar1.Buttons(10).Enabled = False

statusbar.SimpleText = "Compiling..."


rtMode = "Debug"
rtExeFile = App.Path & "\..\Runtime\Debug.exe"
resultFile = App.Path & "\mbcRes.txt"

'Write source file
sourceFile = App.Path & "\tmpSrc.bas"
Open sourceFile For Output As #1
    Print #1, mainWin.ActiveForm.editor.Text;
Close #1

If mainWin.ActiveForm.filename = "" Then
'Set to compile from Editor's directory
    workingDir = App.Path
Else
'Set to compile from current source file's directory
    workingDir = ParseFilePath(mainWin.ActiveForm.filename)
End If

'Compile source code
If CompileCode(rtMode, workingDir, sourceFile, rtExeFile, resultFile) Then
    statusbar.SimpleText = "Launching runtime engine..."
    ShellProg rtExeFile, ""
    'Shell rtExeFile, vbNormalFocus
    statusbar.SimpleText = "Compile successful"
End If


mnuProgram.Enabled = True
toolbar1.Buttons(9).Enabled = True
toolbar1.Buttons(10).Enabled = True

End Sub

Private Sub mnuProgramRun_Click()

Dim rtMode As String
Dim workingDir As String
Dim sourceFile As String
Dim rtExeFile As String
Dim resultFile As String

If mainWin.ActiveForm Is Nothing Then Exit Sub
If Trim(mainWin.ActiveForm.editor.Text) = "" Then Exit Sub

mnuProgram.Enabled = False
toolbar1.Buttons(9).Enabled = False
toolbar1.Buttons(10).Enabled = False

statusbar.SimpleText = "Compiling..."


rtMode = "Run"
rtExeFile = App.Path & "\..\Runtime\Run.exe"
resultFile = App.Path & "\mbcRes.txt"

'Write source file
sourceFile = App.Path & "\tmpSrc.bas"
Open sourceFile For Output As #1
    Print #1, mainWin.ActiveForm.editor.Text;
Close #1

If mainWin.ActiveForm.filename = "" Then
'Set to compile from Editor's directory
    workingDir = App.Path
Else
'Set to compile from current source file's directory
    workingDir = ParseFilePath(mainWin.ActiveForm.filename)
End If

'Compile source code & launch runtime engine
If CompileCode(rtMode, workingDir, sourceFile, rtExeFile, resultFile) Then
    statusbar.SimpleText = "Launching runtime engine..."
    ShellProg rtExeFile, ""
    statusbar.SimpleText = "Compile successful"
End If


mnuProgram.Enabled = True
toolbar1.Buttons(9).Enabled = True
toolbar1.Buttons(10).Enabled = True

End Sub



Private Sub mnuToolsEdit_Click()

editTools.Show vbModal

End Sub

Private Sub mnuToolsOptions_Click()

Options.Show vbModal

End Sub

Private Sub mnuToolsReg_Click()

Load regWin
regWin.Show vbModal

End Sub

Private Sub toolbar1_ButtonClick(ByVal Button As MSComctlLib.Button)

Select Case Button.Key
  Case "new"
    Call mnuFileNew_Click
  Case "open"
    Call mnuFileOpen_Click
  Case "save"
    Call mnuFileSave_Click
  Case "cut"
    Call mnuEditCut_Click
  Case "copy"
    Call mnuEditCopy_Click
  Case "paste"
    Call mnuEditPaste_Click
  Case "run"
    Call mnuProgramRun_Click
  Case "debug"
    Call mnuProgramDebug_Click
  Case "tools"
    Call mnuToolsEdit_Click
  Case "help"
    Call mnuHelpAbout_Click
End Select

End Sub


Private Sub tools_Click()

RunToolProg tools.ListIndex + 1

End Sub


