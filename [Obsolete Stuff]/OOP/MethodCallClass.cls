VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "MethodCallClass"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Public expStr As String
Public methodName As String
Public paramList As New ArrayClass
Public retRef As DataRefClass
Public isFuncCall As Boolean

