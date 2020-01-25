VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "DataRefClass"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Public drID As Integer
Public drIdx As Long
Public drType As Integer
Public drSPDefRef As SubProgDefClass

Private Sub Class_Initialize()
    drID = 0
    drIdx = 0
    drType = 0
    Set drSPDefRef = Nothing
End Sub


Private Sub Class_Terminate()
    Set drSPDefRef = Nothing
End Sub


