#ifndef _COMPILER_CMD_H
#define _COMPILER_CMD_H

void CompileCmd(std::string);
bool EvalFunction(std::string, CDataRefInfo&);

void Cmd_Array(std::string);
void Cmd_Call(std::string);
void Cmd_Close(std::string);
void Cmd_ConsoleTitle(std::string);
void Cmd_ExitFor(std::string);
void Cmd_ExitFunction(std::string);
void Cmd_ExitSub(std::string);
void Cmd_ExitWhile(std::string);
void Cmd_For(std::string);
void Cmd_Gosub(std::string);
void Cmd_Goto(std::string);
void Cmd_If(std::string);
void Cmd_Input(std::string);
void Cmd_Label(std::string);
void Cmd_Let(std::string);
void Cmd_LineInput(std::string);
void Cmd_Message(std::string);
void Cmd_OnError(std::string);
void Cmd_Open(std::string);
void Cmd_Pause(std::string);
void Cmd_Print(std::string);
void Cmd_Redim(std::string);
void Cmd_RedimAdd(std::string);
void Cmd_RedimRemove(std::string);
void Cmd_Seek(std::string);
void Cmd_Var(std::string);
void Cmd_While(std::string);
void Func_Abs(std::string, CDataRefInfo&);
void Func_Asc(std::string, CDataRefInfo&);
void Func_Chr(std::string, CDataRefInfo&);
void Func_EOF(std::string, CDataRefInfo&);
void Func_Input(std::string, CDataRefInfo&);
void Func_Int(std::string, CDataRefInfo&);
void Func_Left(std::string, CDataRefInfo&);
void Func_Len(std::string, CDataRefInfo&);
void Func_Loc(std::string, CDataRefInfo&);
void Func_LOF(std::string, CDataRefInfo&);
void Func_Lower(std::string, CDataRefInfo&);
void Func_LTrim(std::string, CDataRefInfo&);
void Func_Mid(std::string, CDataRefInfo&);
void Func_Not(std::string, CDataRefInfo&);
void Func_Right(std::string, CDataRefInfo&);
void Func_Rnd(std::string, CDataRefInfo&);
void Func_RTrim(std::string, CDataRefInfo&);
void Func_Str(std::string, CDataRefInfo&);
void Func_Trim(std::string, CDataRefInfo&);
void Func_Upper(std::string, CDataRefInfo&);
void Func_Val(std::string, CDataRefInfo&);

#endif
