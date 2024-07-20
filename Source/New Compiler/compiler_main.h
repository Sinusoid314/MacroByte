#ifndef _COMPILER_MAIN_H
#define _COMPILER_MAIN_H

#define MBWM_COMPILE_THREAD_DONE WM_APP+420

class CDataRefInfo
{
      public:
             int drID;
		     int drIdx;
		     int drType;
		     CSubProgDef* drSPDefPtr;
             CDataRefInfo(void);
             ~CDataRefInfo(void);
};

extern std::string sourceFile;
extern std::string resultFile;

extern std::string rawSourceCodeStr;

extern CSubProgDef* currDefPtr;
extern int currDefIdx;
extern int currCodeLine;

extern HANDLE asyncExitFlag;
extern bool errorFlag;
extern std::string errorMsg;
extern std::string debugStr;
extern int resultVal;
extern std::string resultStr;

extern HANDLE hCompThread;
extern DWORD idCompThread;

int WINAPI WinMain (HINSTANCE, HINSTANCE, LPSTR, int);
bool WinSetup(void);
void WinCleanup(void);
DWORD WINAPI CompilerMain(LPVOID);
void CompilerSetup(void);
void CompilerCleanup(void);
void CompileError(int daLine = -1);
void ParseCommandLine(void);
void Compile(void);
void CreateSubProgs(void);
void AddSubProgCmd(bool&, bool&, std::string&);
void CompileSubProgDef(void);
void CompileSubProgCode(void);
std::string GetString(int,const std::string&,const char*);
void ParseParams(const std::string&, std::vector<std::string>&, const char*);
void ParseParamsEx(const std::string&, std::vector<std::string>&, const char**, int);
bool NameCheck(std::string);
void EvalExpression(std::string, CDataRefInfo&, bool isBoolExp = false);
void EvalOperand(std::string&, CDataRefInfo&, bool);
void EvalOperator(int, std::deque<int>&);
bool CheckForOperator(const std::string&, int&, int&, bool);
int GetOperatorPrecedence(int);
bool EvalSubProgCall(std::string, std::string, bool, int&);
bool EvalUserFunc(std::string, CDataRefInfo&);
bool EvalLitRef(std::string, CDataRefInfo&);
void EvalSubProgDataRef(std::string, CDataRefInfo&);
void EvalVarRef(std::string, CDataRefInfo&);
void EvalArrayRef(std::string, CDataRefInfo&);
void EvalArrayArgs(std::string, const CDataRefInfo&);
#endif
