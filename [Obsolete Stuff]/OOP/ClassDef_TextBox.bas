Attribute VB_Name = "ClassDef_TextBox"
Public Sub InitObject(ByRef varRef As DataRefClass, ByRef paramList As ArrayClass)



End Sub


Public Function MethodCall(ByRef mcObj As MethodCallClass) As Boolean

MethodCall = True

Select Case LCase(mcObj.methodName)

'    Case "*"
'        ClassDef_TextBox.Meth_* mcObj
'        Exit Function

End Select

MethodCall = False

End Function

