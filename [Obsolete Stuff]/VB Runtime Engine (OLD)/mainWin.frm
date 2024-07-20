VERSION 5.00
Begin VB.Form mainWin 
   BorderStyle     =   1  'Fixed Single
   Caption         =   "MacroByte Assembler"
   ClientHeight    =   2100
   ClientLeft      =   45
   ClientTop       =   330
   ClientWidth     =   7125
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   ScaleHeight     =   140
   ScaleMode       =   3  'Pixel
   ScaleWidth      =   475
   StartUpPosition =   3  'Windows Default
   Begin VB.TextBox srcFile 
      Height          =   315
      Left            =   660
      Locked          =   -1  'True
      TabIndex        =   4
      Top             =   315
      Width           =   5100
   End
   Begin VB.CommandButton Command2 
      Caption         =   "Convert"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   9.75
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   570
      Left            =   2595
      TabIndex        =   2
      Top             =   915
      Width           =   2100
   End
   Begin VB.CommandButton Command1 
      Caption         =   "Browse"
      Height          =   435
      Left            =   5850
      TabIndex        =   1
      Top             =   255
      Width           =   1125
   End
   Begin VB.Label status 
      BorderStyle     =   1  'Fixed Single
      Height          =   300
      Left            =   0
      TabIndex        =   3
      Top             =   1800
      Width           =   7125
   End
   Begin VB.Label Label1 
      Caption         =   "Source:"
      Height          =   240
      Left            =   60
      TabIndex        =   0
      Top             =   360
      Width           =   585
   End
End
Attribute VB_Name = "mainWin"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Function ETask(ByVal dat As String) As String

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
Private Sub Command1_Click()

Dim tmpFile As String

tmpFile = FileDialog("Choose Source File", "All files" & Chr(0) & "*.*" & Chr(0), 0)

If Trim(tmpFile) = "" Then Exit Sub

srcFile.Text = tmpFile
srcFile.SelStart = Len(srcFile.Text)

End Sub

Private Sub Command2_Click()

Dim tmpDat As String
Dim eDat As String

If Trim(srcFile.Text) = "" Then Exit Sub

status.Caption = "Reading source file..."
Open srcFile.Text For Binary As #1
    tmpDat = Input(LOF(1), 1)
Close #1

status.Caption = "Encrypting source data..."
eDat = ETask(tmpDat)

status.Caption = "Writing ecrypted bytecode file..."
Open App.Path & "\Runtime.mbr" For Output As #1
    Print #1, eDat;
Close #1

status.Caption = "Done."

End Sub


