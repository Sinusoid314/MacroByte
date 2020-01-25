#ifndef _RUNTIME_CMD_H
#define _RUNTIME_CMD_H

class CSubProg
{
      public:
             CSubProgDef* spDefPtr;
             std::vector<CDataCell*> varList;
             std::vector<CArray*> arrayList;
             std::deque<int> blockStack;
             long currCodeLine;
             long debugCurrBreakpointLine;
             CSubProg(void);
             ~CSubProg(void);
             void Initialize(CSubProgDef*);
             void AddCodeBlock(int);
             void RemoveCodeBlock(void);
             bool SetBlockToExit(int);
             bool RunCodeBlock(int,int,int,bool);
             void RunProg(void);
             void Cmd_AddData(void);
             void Cmd_RemoveData(void);
             void Cmd_ClearDataStack(void);
             void Cmd_CopyData(void);
             void Cmd_CallSubProg(void);
             void Cmd_ADD(void);
             void Cmd_SUB(void);
             void Cmd_DIV(void);
             void Cmd_MUL(void);
             void Cmd_MOD(void);
             void Cmd_EXP(void);
             void Cmd_STRCON(void);
             void Cmd_EQUAL(void);
             void Cmd_LESS(void);
             void Cmd_GREATER(void);
             void Cmd_LESSOREQUAL(void);
             void Cmd_GREATEROREQUAL(void);
             void Cmd_NOTEQUAL(void);
             void Cmd_LAND(void);
             void Cmd_LOR(void);
             void Cmd_LXOR(void);
             void Cmd_BAND(void);
             void Cmd_BOR(void);
             void Cmd_BXOR(void);
             void Cmd_Label(void);
             void Cmd_ArrayIdx(void);
             void Cmd_Goto(void);
             void Cmd_Gosub(void);
             void Cmd_Return(void);
             void Cmd_If(void);
             void Cmd_PrintToConsol(void);
             void Cmd_InputFromConsol(void);
             void Cmd_ShowConsol(void);
             void Cmd_HideConsol(void);
             void Cmd_PrintBlank(void);
             void Cmd_For(void);
             void Cmd_ClearConsol(void);
             void Cmd_InputEvents(void);
             void Cmd_FlushEvents(void);
             void Cmd_Pause(void);
             void Cmd_End(void);
             void Cmd_Message(void);
             void Cmd_OpenFile(void);
             void Cmd_CloseFile(void);
             void Cmd_PrintToFile(void);
             void Cmd_InputFieldFromFile(void);
             void Cmd_InputLineFromFile(void);
             void Cmd_InputBytesFromFile(void);
             void Cmd_SetFilePos(void);
             void Cmd_GetFilePos(void);
             void Cmd_FileLength(void);
             void Cmd_EndOfFile(void);
             
             void Cmd_Str(void);
             void Cmd_Int(void);
             void Cmd_Rnd(void);
             void Cmd_Val(void);
             void Cmd_Chr(void);
             void Cmd_Asc(void);
             void Cmd_Abs(void);
             void Cmd_Not(void);
             void Cmd_Len(void);
             void Cmd_Upper(void);
             void Cmd_Lower(void);
             void Cmd_LTrim(void);
             void Cmd_RTrim(void);
             void Cmd_Trim(void);
             void Cmd_Left(void);
             void Cmd_Mid(void);
             void Cmd_Right(void);
             
             void Cmd_OnError(void);
             void Cmd_Redim(void);
             void Cmd_ConsolTitle(void);
             void Cmd_RedimAdd(void);
             void Cmd_RedimRemove(void);
             void Cmd_While(void);
             void Cmd_ExitFor(void);
             void Cmd_ExitWhile(void);
             void Cmd_ExitSubProg(void);
             void Cmd_DebugBreakpoint(void);
};

//Array of pointers to Command functions
extern void (CSubProg::*cmdPtrList[])();

extern std::vector<CSubProg*> spList;

void LoadSubProg(int);
void UnloadSubProg(void);

#endif
