#ifndef _BASIC_TAGS_H
#define _BASIC_TAGS_H

//Main Runtime Tags
#define versionStr "1.0"

//Runtime Mode Tags
//--------------------
#define RTMODE_RUN 1
#define RTMODE_DEBUG 2
#define RTMODE_DEPLOY 3

//Data Type Tags
//--------------------
#define DT_VOID   0
#define DT_NUMBER 1
#define DT_STRING 2

//Data Reference Tags
//-----------------------------
#define DATAREF_DATASTACK 1
#define DATAREF_LITERAL 2
#define DATAREF_GLOBALVAR 3
#define DATAREF_GLOBALARRAYITEM 4
#define DATAREF_LOCALVAR 5
#define DATAREF_LOCALARRAYITEM 6

//Code Block Tags
//-----------------------------
#define IDBLOCK_VOID 0
#define IDBLOCK_ROOT 1
#define IDBLOCK_GOSUB 2
#define IDBLOCK_IF 3
#define IDBLOCK_FOR 4
#define IDBLOCK_WHILE 5

//Command/Function Tags
//----------------------------------------
#define IDC_ADDDATA 1
#define IDC_REMOVEDATA 2
#define IDC_CLEARDATASTACK 3
#define IDC_COPYDATA 4
#define IDC_CALLSUBPROG 5
#define IDC_ADD 6
#define IDC_SUB 7
#define IDC_DIV 8
#define IDC_MUL 9
#define IDC_MOD 10
#define IDC_EXP 11
#define IDC_STRCON 12
#define IDC_EQUAL 13
#define IDC_LESS 14
#define IDC_GREATER 15
#define IDC_LESSOREQUAL 16
#define IDC_GREATEROREQUAL 17
#define IDC_NOTEQUAL 18
#define IDC_LAND 19
#define IDC_LOR 20
#define IDC_LXOR 21
#define IDC_BAND 22
#define IDC_BOR 23
#define IDC_BXOR 24
#define IDC_LABEL 25
#define IDC_ARRAYIDX 26
#define IDC_GOTO 27
#define IDC_GOSUB 28
#define IDC_RETURN 29
#define IDC_IF 30
#define IDC_PrintToConsole 31
#define IDC_InputFromConsole 32
#define IDC_ShowConsole 33
#define IDC_HideConsole 34
#define IDC_PrintBlank 35
#define IDC_FOR 36
#define IDC_ClearConsole 37
#define IDC_InputEvents 38
#define IDC_FlushEvents 39
#define IDC_Pause 40
#define IDC_End 41
#define IDC_Message 42
#define IDC_OpenFile 43
#define IDC_CloseFile 44
#define IDC_PrintToFile 45
#define IDC_InputFieldFromFile 46
#define IDC_InputLineFromFile 47
#define IDC_InputBytesFromFile 48
#define IDC_SetFilePos 49
#define IDC_GetFilePos 50
#define IDC_FileLength 51
#define IDC_EndOfFile 52
#define IDC_Str 53
#define IDC_Int 54
#define IDC_Rnd 55
#define IDC_Val 56
#define IDC_Chr 57
#define IDC_Asc 58
#define IDC_Abs 59
#define IDC_Not 60
#define IDC_Len 61
#define IDC_Upper 62
#define IDC_Lower 63
#define IDC_LTrim 64
#define IDC_RTrim 65
#define IDC_Trim 66
#define IDC_Left 67
#define IDC_Mid 68
#define IDC_Right 69
#define IDC_OnError 70
#define IDC_Redim 71
#define IDC_ConsoleTitle 72
#define IDC_RedimAdd 73
#define IDC_RedimRemove 74
#define IDC_While 75
#define IDC_ExitFor 76
#define IDC_ExitWhile 77
#define IDC_ExitSubProg 78
#define IDC_DebugBreakpoint 79

#endif
