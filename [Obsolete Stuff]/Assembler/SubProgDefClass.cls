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

'Branch label line #s
Public labelLineList As New ArrayClass

'Variable and array definitions
Public varNameList As New ArrayClass
Public varTypeList As New ArrayClass
Public arrayNameList As New ArrayClass
Public arrayTypeList As New ArrayClass
Public arrayDimNumList As New ArrayClass
Public arrayDimValList As New ArrayClass '(multi-dim)

'Bytecode text
Public codeText As String
