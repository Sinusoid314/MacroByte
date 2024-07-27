Attribute VB_Name = "TagDefinitions"
Public Const versionStr = "1.0"

'Runtime Mode Tags
'---------------------
Public Const RTMODE_RUN = 1
Public Const RTMODE_DEBUG = 2
Public Const RTMODE_DEPLOY = 3

'Data Type Tags
'--------------------
Public Const DT_VOID = 0
Public Const DT_NUMBER = 1
Public Const DT_STRING = 2

'File Type Tags
'-----------------------------
Public Const FT_INPUT = 1
Public Const FT_OUTPUT = 2
Public Const FT_APPEND = 3
Public Const FT_BINARY = 4

'Data Reference Tags
'-----------------------------
Public Const IDD_DATLST = 1
Public Const IDD_LITLST = 2
Public Const IDD_GVARLST = 3
Public Const IDD_GARRAYLST = 4
Public Const IDD_LVARLST = 5
Public Const IDD_LARRAYLST = 6

'Code Block Tags
'-----------------------------
Public Const IDBLOCK_VOID = 0
Public Const IDBLOCK_ROOT = 1
Public Const IDBLOCK_GOSUB = 2
Public Const IDBLOCK_IF = 3
Public Const IDBLOCK_FOR = 4
Public Const IDBLOCK_WHILE = 5

'Command/Function Tags
'----------------------------------------
Public Const IDC_ADDDATA = 1
Public Const IDC_REMOVEDATA = 2
Public Const IDC_CLEARDATASTACK = 3
Public Const IDC_COPYDATA = 4
Public Const IDC_CALLSUBPROG = 5
Public Const IDC_ADD = 6
Public Const IDC_SUB = 7
Public Const IDC_DIV = 8
Public Const IDC_MUL = 9
Public Const IDC_MOD = 10
Public Const IDC_EXP = 11
Public Const IDC_STRCON = 12
Public Const IDC_EQUAL = 13
Public Const IDC_LESS = 14
Public Const IDC_GREATER = 15
Public Const IDC_LESSOREQUAL = 16
Public Const IDC_GREATEROREQUAL = 17
Public Const IDC_NOTEQUAL = 18
Public Const IDC_LAND = 19
Public Const IDC_LOR = 20
Public Const IDC_LXOR = 21
Public Const IDC_BAND = 22
Public Const IDC_BOR = 23
Public Const IDC_BXOR = 24
Public Const IDC_LABEL = 25
Public Const IDC_ARRAYIDX = 26
Public Const IDC_GOTO = 27
Public Const IDC_GOSUB = 28
Public Const IDC_RETURN = 29
Public Const IDC_IF = 30
Public Const IDC_PrintToConsole = 31
Public Const IDC_InputFromConsole = 32
Public Const IDC_ShowConsole = 33
Public Const IDC_HideConsole = 34
Public Const IDC_PrintBlank = 35
Public Const IDC_FOR = 36
Public Const IDC_ClearConsole = 37
Public Const IDC_InputEvents = 38
Public Const IDC_FlushEvents = 39
Public Const IDC_Pause = 40
Public Const IDC_End = 41
Public Const IDC_Message = 42
Public Const IDC_OpenFile = 43
Public Const IDC_CloseFile = 44
Public Const IDC_PrintToFile = 45
Public Const IDC_InputFieldFromFile = 46
Public Const IDC_InputLineFromFile = 47
Public Const IDC_InputBytesFromFile = 48
Public Const IDC_SetFilePos = 49
Public Const IDC_GetFilePos = 50
Public Const IDC_FileLength = 51
Public Const IDC_EndOfFile = 52
Public Const IDC_Str = 53
Public Const IDC_Int = 54
Public Const IDC_Rnd = 55
Public Const IDC_Val = 56
Public Const IDC_Chr = 57
Public Const IDC_Asc = 58
Public Const IDC_Abs = 59
Public Const IDC_Not = 60
Public Const IDC_Len = 61
Public Const IDC_Upper = 62
Public Const IDC_Lower = 63
Public Const IDC_LTrim = 64
Public Const IDC_RTrim = 65
Public Const IDC_Trim = 66
Public Const IDC_Left = 67
Public Const IDC_Mid = 68
Public Const IDC_Right = 69
Public Const IDC_OnError = 70
Public Const IDC_Redim = 71
Public Const IDC_ConsoleTitle = 72
Public Const IDC_RedimAdd = 73
Public Const IDC_RedimRemove = 74
Public Const IDC_While = 75
Public Const IDC_ExitFor = 76
Public Const IDC_ExitWhile = 77
Public Const IDC_ExitSubProg = 78
Public Const IDC_DebugBreakpoint = 79

