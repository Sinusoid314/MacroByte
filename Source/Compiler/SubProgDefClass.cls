VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "SubProgDefClass"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
'Subprog identifier
Public subProgName As String

'Number of parameters
Public paramNum As Long

'Function flag
Public isFunc As Integer

'Branch label names & byte-code locations
Public labelNameList As New ArrayClass
Public labelLocList As New ArrayClass

'Counters for code blocks
Public forBlockNum As Long
Public whileBlockNum As Long

'Variable and array definitions
Public varNameList As New ArrayClass
Public varTypeList As New ArrayClass
Public arrayNameList As New ArrayClass
Public arrayTypeList As New ArrayClass
Public arrayDimNumList As New ArrayClass
Public arrayDimValList As New ArrayClass '(multi-dim)

'Raw (BASIC) code list (Pre-Compile)
Public sourceCodeList As New ArrayClass

'Textbox line numbers for each sourceCodeList item
Public rawCodeIndexList As New ArrayClass

'Bytecode-formated list (Post-Compile)
Public byteCodeList As New ArrayClass  '(multi-dim)

Private Sub Class_Initialize()

forBlockNum = 0
whileBlockNum = 0

End Sub


