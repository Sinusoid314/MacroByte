#define _WIN32_IE 0x0300 //For commctrl.h
#include <cstdlib>
#include <sstream>
#include <string>
#include <vector>
#include <deque>
#include <windows.h>
#include <commctrl.h>
#include "..\..\..\[Libraries]\String Extension\stringExt.h"
#include "..\..\..\[Libraries]\File IO\FileIO.h"
#include "..\basic_tags.h"
#include "..\basic_def.h"
#include "compiler_main.h"
#include "compiler_display.h"
#include "compiler_cmd.h"
#include "assembler_main.h"

using namespace std;

string sourceFile;
string resultFile;

string rawSourceCodeStr;

CSubProgDef* currDefPtr;
int currDefIdx;
int currCodeLine;

HANDLE asyncExitFlag;
bool errorFlag;
std::string errorMsg;
std::string debugStr;
int resultVal;
string resultStr;

HANDLE hCompThread;
DWORD idCompThread;


CDataRefInfo::CDataRefInfo(void)
//
{
    drID = 0;
    drIdx = 0;
    drType = 0;
    drSPDefPtr = NULL;
}

CDataRefInfo::~CDataRefInfo(void)
//
{
    
}

int WINAPI WinMain (HINSTANCE hThisInstance, HINSTANCE hPrevInstance, LPSTR lpszArgument, int dispFlag)
//Main program entry point
{
    MSG messages;            /* Here messages to the application are saved */

    //Load main program data
    if(!WinSetup()) return 0;
    
    //Launch main compiler thread
    hCompThread = CreateThread(NULL, 0, CompilerMain, (LPVOID) 0, 0, &idCompThread);

    //Main message loop
    while (GetMessage (&messages, NULL, 0, 0) > 0)
    {
        TranslateMessage(&messages);
        DispatchMessage(&messages);
    }
    
    //Unload main program data
    WinCleanup();
    
    return messages.wParam;
}

bool WinSetup(void)
//Load main program data
{
    //Create display window
    if(!DisplaySetup()) return false;
    
    //Create compile-completion flag
    asyncExitFlag = CreateEvent(NULL, TRUE, FALSE, NULL);
    
    return true;
}

void WinCleanup(void)
//Unload main program data
{    
    //Delete compile-completion flag
    CloseHandle(asyncExitFlag);
    
    //Destroy display window
    DisplayCleanup();
}

DWORD WINAPI CompilerMain(LPVOID rttParam)
//
{
	CFile outFile;
    
    //Load compiler data
    CompilerSetup();

    try
    {
        Compile();
    }
    catch (int throwVal)
    {
    }

    //Unload compiler data
    CompilerCleanup();

    //Result is considered 'canceled' if asyncExitFlag is set
    if(WaitForSingleObject(asyncExitFlag, 0) == WAIT_OBJECT_0)
    {
	    resultStr = "Compile canceled.";
	}
    else
    {
	    //If compile was not canceled, and there
        //was no error, then result is 'successful'
	    if(!errorFlag)
        {
            resultStr = "Compile successful";
        }
    }
    
    //Write result to file
    if(outFile.OpenFile(resultFile.c_str(), 1, FT_OUTPUT))
    {
        outFile.Print( static_cast<ostringstream*>(&(ostringstream() << resultVal))->str() );
        outFile.Print("\r\n", 2);
        outFile.Print(resultStr);
        outFile.Print("\r\n", 2);
        outFile.CloseFile();
    }
    
    //Signal the display window that this thread is done
    PostMessage(hDispWin, MBWM_COMPILE_THREAD_DONE, 0, 0);
    
    return (DWORD)1;
}

void CompilerSetup(void)
//Load compiler data
{
	CFile inFile;

    //Initialize main compiler variables
    errorFlag = false;
    errorMsg = "";
    debugStr = "";
    resultVal = 0;
    resultStr = "";
    ParseCommandLine();
    
    //Read in source code
    if(inFile.OpenFile(sourceFile.c_str(), 1, FT_INPUT))
    {
        inFile.InputBytes(rawSourceCodeStr, inFile.GetFileLength());
        inFile.CloseFile();
    }
}

void CompilerCleanup(void)
//Unload compiler data
{
    //Delete literals
    LiteralList.clear();
    
    //Delete subprog definitions
    for(int n=0; n<spDefList.size(); n++)
    {
        delete spDefList[n];
    }
    spDefList.clear();
}

void CompileError(int daLine)
//Sets the result as an error on the current
//code line, then jumps back to CompilerMain()
//by throwing an exception
{
    if(daLine < 0)
    {
        daLine = currDefPtr->rawCodeIndexList[currCodeLine];
    }
    
    resultVal = daLine;
    resultStr = "Compile error on line " + NumToStr(daLine+1) + ": " + errorMsg;
    
    errorFlag = true;
    
    throw 0;
}

void ParseCommandLine(void)
//Parse out the command-line arguments and
//put them in the appropriate variables
{
    string cmdLineStr;
    vector<string> clArgList;
    
    cmdLineStr = GetCommandLineA();
    cmdLineStr = cmdLineStr.substr(cmdLineStr.find("\"",1) + 1);

    //Seperate command line into a list of arguments
    ParseParams(cmdLineStr, clArgList, "|");
    
    //Check argument count
    if(clArgList.size() != 5)
    {
        MessageBoxA(NULL, "Wrong number of compiler arguments", "Macrobyte Compiler", MB_OK | MB_ICONERROR | MB_SETFOREGROUND);
        ExitProcess(0);
    }
    
    //Set rtMode
    clArgList[0] = LCaseStr(clArgList[0]);
    if(clArgList[0] == "run")
        rtMode = RTMODE_RUN;
    else if(clArgList[0] == "debug")
	    rtMode = RTMODE_DEBUG;
    else if(clArgList[0] == "deploy")
	    rtMode = RTMODE_DEPLOY;
    else
    {
	    MessageBoxA(NULL, (string("Runtime mode:\r\n\r\n'") + clArgList[0] + string("'\r\n\r\nis not understood")).c_str(),
                   "Macrobyte Compiler", MB_OK | MB_ICONERROR | MB_SETFOREGROUND);
        ExitProcess(0);
	}

    //Set workingDir
    workingDir = clArgList[1];
    if(!DirectoryExists(workingDir))
    {
        MessageBoxA(NULL, (string("Woring directory:\r\n\r\n'") + clArgList[1] + string("'\r\n\r\ndoes not exist")).c_str(),
                   "Macrobyte Compiler", MB_OK | MB_ICONERROR | MB_SETFOREGROUND);
        ExitProcess(0);
    }

    //Set sourceFile
    sourceFile = clArgList[2];
    if(!FileExists(sourceFile))
    {
        MessageBoxA(NULL, (string("Source code file:\r\n\r\n'") + clArgList[2] + string("'\r\n\r\ndoes not exist")).c_str(),
                   "Macrobyte Compiler", MB_OK | MB_ICONERROR | MB_SETFOREGROUND);
        ExitProcess(0);
    }

    //Set rtExeFileName
    rtExeFileName = clArgList[3];
    if(!FileExists(rtExeFileName))
    {
        MessageBoxA(NULL, (string("Runtime executable file:\r\n\r\n'") + clArgList[3] + string("'\r\n\r\ndoes not exist")).c_str(),
                   "Macrobyte Compiler", MB_OK | MB_ICONERROR | MB_SETFOREGROUND);
        ExitProcess(0);
    }

    //Set resultFile
    resultFile = clArgList[4];
}

void Compile(void)
//
{
	//Initialize progress bar
    SendMessage(hDispProgress, PBM_SETRANGE, 0, MAKELPARAM(0, spDefList.size()));
    
    //Parse raw source code into seperate sub programs
    SetWindowTextA(hDispStatus, "Parsing source code...");
    CreateSubProgs();
    
    //Compile sub program definitions
    SendMessage(hDispProgress, PBM_SETPOS, 0, 0);
    SetWindowTextA(hDispStatus, "Compiling program definitions...");
    for(currDefIdx=0; currDefIdx < spDefList.size(); currDefIdx++)
    {
        currDefPtr = spDefList[currDefIdx];
        CompileSubProgDef();
        SendMessage(hDispProgress, PBM_SETPOS, currDefIdx, 0);
        if(WaitForSingleObject(asyncExitFlag, 0) == WAIT_OBJECT_0) throw 0;
    }
    
    //Compile sub program code
    SendMessage(hDispProgress, PBM_SETPOS, 0, 0);
    SetWindowTextA(hDispStatus, "Compiling program code...");
    for(currDefIdx=0; currDefIdx < spDefList.size(); currDefIdx++)
    {
        currDefPtr = spDefList[currDefIdx];
        CompileSubProgCode();
        SendMessage(hDispProgress, PBM_SETPOS, currDefIdx, 0);
        if(WaitForSingleObject(asyncExitFlag, 0) == WAIT_OBJECT_0) throw 0;
    }

    //Assemble compiled definitions into runtime file
    SetWindowTextA(hDispStatus, "Assembling program file...");
    AssembleFile();

/* Test code
    //Initialize hDispProgress
    SendMessage(hDispProgress, PBM_SETRANGE, 0, MAKELPARAM(0, 20));
    SendMessage(hDispProgress, PBM_SETPOS, 0, 0);
    for(int n=1; n<=20; n++)
    {
	    Sleep(500);
        //Update hDispProgress
        SendMessage(hDispProgress, PBM_SETPOS, n, 0);
        if(WaitForSingleObject(asyncExitFlag, 0) == WAIT_OBJECT_0) throw 0;
    }
*/
}

void CreateSubProgs(void)
//
{
    string lineStr;
    string cmdStr;
    bool inQuotes = false;
    bool inComment = false;
    bool inSub = false;
    bool inFunc = false;
    
    spDefList.push_back(new CSubProgDef);
    spDefList[0]->isFunc = false;
    spDefList[0]->subProgName = "<main>";
    
    for(int n=0; n < rawSourceCodeStr.length(); n++)
    {
        if(MidStr(rawSourceCodeStr, n, 2) == "\r\n")
        {
            cmdStr = TrimStr(cmdStr);
            if(RightStr(cmdStr, 1) == "_" && (!inComment))
            {
                cmdStr = LeftStr(cmdStr, cmdStr.length()-1);
            }
            else
            {
	            AddSubProgCmd(inSub, inFunc, cmdStr);
	        }
	        rawSourceCodeList.push_back(lineStr);
	        lineStr = "";
            inComment = false;
	        n++;
        }
        else
        {
	        if(!inComment)
            {
                if((MidStr(rawSourceCodeStr, n, 1) == ":") && (!inQuotes))
                {
	                AddSubProgCmd(inSub, inFunc, cmdStr);
                }
                else if((MidStr(rawSourceCodeStr, n, 1) == "'") && (!inQuotes))
                {
	                inComment = true;
	            }
                else
                {
	                if(MidStr(rawSourceCodeStr, n, 1) == "\"")
                    {
                        inQuotes = !inQuotes;
                    }
                    cmdStr += MidStr(rawSourceCodeStr, n, 1);
                }
            }
            lineStr += MidStr(rawSourceCodeStr, n, 1);
        }
    }
    
    AddSubProgCmd(inSub, inFunc, cmdStr);
    rawSourceCodeList.push_back(lineStr);
    lineStr = "";
}

void AddSubProgCmd(bool& inSub, bool& inFunc, string& cmdStr)
//
{
    cmdStr = TrimStr(cmdStr);
    if(cmdStr != "") return;
    
    if(inSub)
    {
	    if(LCaseStr(LeftStr(cmdStr, 4)) == "sub ")
        {
	        errorMsg = "Cannot have a SUB within another SUB.";
	        CompileError(rawSourceCodeList.size());
        }
        else if(LCaseStr(LeftStr(cmdStr, 9)) == "function ")
        {
	        errorMsg = "Cannot have a FUNCTION within a SUB.";
	        CompileError(rawSourceCodeList.size());
        }
        else if(LCaseStr(cmdStr) == "end sub")
        {
	        inSub = false;
        }
        else if(LCaseStr(cmdStr) == "end function")
        {
	        errorMsg = "END FUNCTION without FUNCTION.";
	        CompileError(rawSourceCodeList.size());
        }
        else
        {
	        spDefList.back()->sourceCodeList.push_back(cmdStr);
            spDefList.back()->rawCodeIndexList.push_back(rawSourceCodeList.size());
        }
    }
    else if(inFunc)
    {
	    if(LCaseStr(LeftStr(cmdStr, 4)) == "sub ")
        {
	        errorMsg = "Cannot have a SUB wihtin a FUNCTION.";
	        CompileError(rawSourceCodeList.size());
        }
        else if(LCaseStr(LeftStr(cmdStr, 9)) == "function ")
        {
	        errorMsg = "Cannot have a FUNCION within another FUNCTION.";
	        CompileError(rawSourceCodeList.size());
        }
        else if(LCaseStr(cmdStr) == "end sub")
        {
	        errorMsg = "END SUB without SUB";
	        CompileError(rawSourceCodeList.size());
        }
        else if(LCaseStr(cmdStr) == "end function")
        {
	        inFunc = false;
        }
        else
        {
	        spDefList.back()->sourceCodeList.push_back(cmdStr);
            spDefList.back()->rawCodeIndexList.push_back(rawSourceCodeList.size());
        }
    }
    else
    {
	    if(LCaseStr(LeftStr(cmdStr, 4)) == "sub ")
        {
	        spDefList.push_back(new CSubProgDef);
            spDefList.back()->isFunc = false;
            spDefList.back()->sourceCodeList.push_back(cmdStr);
            spDefList.back()->rawCodeIndexList.push_back(rawSourceCodeList.size());
            inSub = true;
        }
        else if(LCaseStr(LeftStr(cmdStr, 9)) == "function ")
        {
	        spDefList.push_back(new CSubProgDef);
            spDefList.back()->isFunc = true;
            spDefList.back()->sourceCodeList.push_back(cmdStr);
            spDefList.back()->rawCodeIndexList.push_back(rawSourceCodeList.size());
            inFunc = true;
        }
        else if(LCaseStr(cmdStr) == "end sub")
        {
	        errorMsg = "END SUB without SUB.";
	        CompileError(rawSourceCodeList.size());
        }
        else if(LCaseStr(cmdStr) == "end function")
        {
	        errorMsg = "END FUNCTION without FUNCTION.";
	        CompileError(rawSourceCodeList.size());
        }
        else
        {
	        spDefList[0]->sourceCodeList.push_back(cmdStr);
            spDefList[0]->rawCodeIndexList.push_back(rawSourceCodeList.size());
        }
    }
    
    cmdStr = "";
}

void CompileSubProgDef(void)
//
{
	vector<string> paramList;
    vector<string> spParamList;
    vector<int> tmpIdxList;
    string tmpName;
    string tmpParams;
    string tmpType;
    
    //Process sub/function definition/params (if not main subprog)
    if(currDefIdx > 0)
    {
	    currCodeLine = 0;
        
        //Parse out subprog name, parameters, and return type
        static const char* delimList[2] ={"(", ")"};
        ParseParamsEx(currDefPtr->sourceCodeList[0], paramList, delimList, 2);
        if( (paramList.size() < 2) || (paramList.size() > 3) )
        {
	        errorMsg = "Syntax error";
            CompileError();
        }
        
        //Add parameter variables
        ParseParams(paramList[1], spParamList, ",");
        currDefPtr->paramNum = spParamList.size();
        for(int n=0; n < spParamList.size(); n++)
        {
            Cmd_Var(spParamList[n]);
        }
    
        //Add return variable
        if(currDefPtr->isFunc)
        {
            if(paramList.size() != 3)
            {
                errorMsg = "Must specify a return type for this function.";
                CompileError(currDefPtr->rawCodeIndexList[0]);
            }
            paramList[0] = TrimStr(MidStr(paramList[0], 8));
            Cmd_Var(paramList[0] + " " + paramList[2]);
        }
        else
        {
            paramList[0] = TrimStr(MidStr(paramList[0], 3));
        }
        currDefPtr->subProgName = paramList[0];
        currDefPtr->sourceCodeList.erase(currDefPtr->sourceCodeList.begin());
        currDefPtr->rawCodeIndexList.erase(currDefPtr->rawCodeIndexList.begin());
    }
    
    //Compile variable/array definitions, and store each line number for removal
    for(currCodeLine = 0; currCodeLine < currDefPtr->sourceCodeList.size(); currCodeLine++)
    {
        if(LCaseStr(LeftStr(currDefPtr->sourceCodeList[currCodeLine], 4)) == "var ")
        {
            Cmd_Var(MidStr(currDefPtr->sourceCodeList[currCodeLine], 4));
            tmpIdxList.push_back(currCodeLine);
        }
        else if(LCaseStr(LeftStr(currDefPtr->sourceCodeList[currCodeLine], 6)) == "array ")
        {
            Cmd_Array(MidStr(currDefPtr->sourceCodeList[currCodeLine], 6));
            tmpIdxList.push_back(currCodeLine);
        }
        else if(LCaseStr(LeftStr(currDefPtr->sourceCodeList[currCodeLine], 4)) == "dim " )
        {
            Cmd_Array(MidStr(currDefPtr->sourceCodeList[currCodeLine], 4));
            tmpIdxList.push_back(currCodeLine);
        }
        if(WaitForSingleObject(asyncExitFlag, 0) == WAIT_OBJECT_0) throw 0;
    }
    
    //Remove variable/array definition lines
    for(int n = tmpIdxList.size()-1; n >= 0; n--)
    {
        currDefPtr->sourceCodeList.erase(currDefPtr->sourceCodeList.begin() + tmpIdxList[n]);
        currDefPtr->rawCodeIndexList.erase(currDefPtr->rawCodeIndexList.begin() + tmpIdxList[n]);
    }
    
    //Add branch label names
    for(int n=0; n < currDefPtr->sourceCodeList.size(); n++)
    {
        if(LeftStr(currDefPtr->sourceCodeList[n], 1) == "@")
        {
            currDefPtr->labelNameList.push_back(TrimStr(currDefPtr->sourceCodeList[n]));
        }
    }
}

void CompileSubProgCode(void)
//
{
    int tmpIdx;
    
    //Compile the current subprog's commands
    for(currCodeLine=0; currCodeLine < currDefPtr->sourceCodeList.size(); currCodeLine++)
    {
	    CompileCmd(currDefPtr->sourceCodeList[currCodeLine]);
        if(WaitForSingleObject(asyncExitFlag, 0) == WAIT_OBJECT_0) throw 0;
	}
    
    //Replace index reference with line number reference
    //in all GOTO and GOSUB byte-code commands
    for(int n=0; n < currDefPtr->byteCodeList.size(); n++)
    {
        if((currDefPtr->byteCodeList[n]->argList[0] == IDC_GOTO) ||
           (currDefPtr->byteCodeList[n]->argList[0] == IDC_GOSUB))
        {
            tmpIdx = currDefPtr->byteCodeList[n]->argList[1];
            currDefPtr->byteCodeList[n]->argList[1] = currDefPtr->labelLocList[tmpIdx];
        }
    }
}

string GetString(int startPos, const string& inStr, const char* delimStr)
//Section out a substring from within inStr, starting at
//startPos and ending when delimStr is found within inStr,
//not counting matches found within quotes or parenthesis.
{
    bool inQuotes = false;
    int parenCount = 0;
    string outStr = "";
    
    for(int n=startPos; n < inStr.length(); n++)
    {
        if(MidStr(inStr, n, char_traits<char>::length(delimStr)) == delimStr)
        {
            if((parenCount == 0) && (!inQuotes))
                break;
        }
        
        if(MidStr(inStr, n, 1) == "\"")
        {
            inQuotes = !inQuotes;
        }
        
        if((MidStr(inStr, n, 1) == "(") && (!inQuotes))
        {
            parenCount++;
        }
        else if((MidStr(inStr, n, 1) == ")") && (!inQuotes))
        {
            if(parenCount > 0)
                parenCount--;
        }
        
        outStr += inStr.substr(n, 1);
	}
    
    return outStr;
}

void ParseParams(const string& paramStr, vector<string>& paramList, const char* delimStr)
//
{
    int n;
    string tmpStr;
    
    n = 0;
    while(n < paramStr.length())
    {
        tmpStr = GetString(n, paramStr, delimStr);
        n = n + tmpStr.length() + char_traits<char>::length(delimStr);
        paramList.push_back(TrimStr(tmpStr));
    }
}

void ParseParamsEx(const string& paramStr, vector<string>& paramList, const char* delimList[], int delimCount)
//
{
    int b = 0;
    string tmpStr;
    
    //Loop through each delimiter
    for(int a=0; a < delimCount; a++)
    {
        tmpStr = GetString(b, LCaseStr(paramStr), delimList[a]);
        tmpStr = MidStr(paramStr, b, tmpStr.length());
        paramList.push_back(TrimStr(tmpStr));
        b = b + tmpStr.length() + char_traits<char>::length(delimList[a]);
        if(b >= paramStr.length()) return;
	}
    
    //Add remaining bit of paramStr
    paramList.push_back(TrimStr(MidStr(paramStr, b)));
}

bool NameCheck(string nameStr)
//
{
    return false;
}

void EvalExpression(string expStr, CDataRefInfo& retDataRef, bool isBoolExp)
//
{
    vector<CDataRefInfo> operandRefList;
    string operandStr;
    vector<int> operatorList;
    deque<int> operatorStack;
    int operatorID;
    int charIdx;
    bool inQuotes = false;
    string tmpStr;
    
    expStr = TrimStr(expStr);
    if(expStr == "") return;
    
    //***************( PARSE OPERANDS )***************
    for(charIdx = 0; charIdx < expStr.length(); charIdx++)
    {
        if(MidStr(expStr, charIdx, 1) == "\"")
        {
            inQuotes = !inQuotes;
        }
        
        if(!inQuotes)
        {
            if(MidStr(expStr, charIdx, 1) == "(")
            {
	            charIdx++;
                tmpStr = GetString(charIdx, expStr, ")");
                charIdx += tmpStr.length();
                if(charIdx == expStr.length()) 
                {
	                errorMsg = "Syntax error";
                    CompileError();
                }
                operandStr = operandStr + "(" + tmpStr + ")";
            }
            else if(CheckForOperator(expStr, charIdx, operatorID, isBoolExp))
            {
                if(operatorID == IDC_SUB)
                {
                    if(TrimStr(operandStr).length() > 0)
                    {
                        operandRefList.push_back(CDataRefInfo());
                        EvalOperand(operandStr, operandRefList.back(), isBoolExp);
                        EvalOperator(IDC_SUB, operatorStack);
                        operatorList.push_back(IDC_SUB);
                    }
                    else
                    {
                        operandStr += "-";
                    }
                }
                else
                {
                    operandRefList.push_back(CDataRefInfo());
                    EvalOperand(operandStr, operandRefList.back(), isBoolExp);
                    EvalOperator(operatorID, operatorStack);
                    operatorList.push_back(operatorID);
                }
            }
            else
            {
                operandStr += MidStr(expStr, charIdx, 1);
            }
        }
        else
        {
            operandStr += MidStr(expStr, charIdx, 1);
        }
    }
    
    operandRefList.push_back(CDataRefInfo());
    EvalOperand(operandStr, operandRefList.back(), isBoolExp);
    
    while(operatorStack.size() > 0)
    {
        currDefPtr->byteCodeList.push_back(new CCommand(operatorStack[0]));
        operatorStack.pop_front();
    }
    //************************************************
    
    //***************( TYPE CHECK )*******************
    for(int n = operatorList.size()-1; n >= 0; n--)
    {
        if(operatorList[n] == IDC_STRCON)
        {
            if(!((operandRefList[n].drType == DT_STRING) && (operandRefList[n+1].drType == DT_STRING)))
            {
	            errorMsg = "Type mismatch";
                CompileError();
            }
            retDataRef.drType = DT_STRING;
        }
        else if(operatorList[n] == IDC_ADD)
        {
            if(operandRefList[n].drType != operandRefList[n+1].drType)
            {
	            errorMsg = "Type mismatch";
                CompileError();
            }
            retDataRef.drType = operandRefList[n].drType;
        }
        else if((operatorList[n] >= IDC_EQUAL) && (operatorList[n] <= IDC_NOTEQUAL))
        {
            if(operandRefList[n].drType != operandRefList[n+1].drType)
            {
	            errorMsg = "Type mismatch";
                CompileError();
            }
            retDataRef.drType = DT_NUMBER;
        }
        else
        {
            if(!((operandRefList[n].drType == DT_NUMBER) && (operandRefList[n+1].drType == DT_NUMBER)))
            {
                errorMsg = "Type mismatch";
                CompileError();
            }
            retDataRef.drType = DT_NUMBER;
        }
    }
    
    if(operatorList.size() == 0)
    {
        retDataRef.drType = operandRefList[0].drType;
    }
    //**********************************************
    
    //End result of expression evaluation
    retDataRef.drID = DATAREF_DATASTACK;
    retDataRef.drIdx = 0;
    
    if(WaitForSingleObject(asyncExitFlag, 0) == WAIT_OBJECT_0) throw 0;
}

void EvalOperand(string& operandStr, CDataRefInfo& retDataRef, bool isBoolExp)
//Call the appropriate operand-evaluation
//function, and return its DataRef object.
{
    operandStr = TrimStr(operandStr);
    
    if((LeftStr(operandStr, 1) == "(") && (RightStr(operandStr, 1) == ")"))
    {
        operandStr = MidStr(operandStr, 1, operandStr.length() - 2);
        EvalExpression(operandStr, retDataRef, isBoolExp);
    }
    else if(EvalLitRef(operandStr, retDataRef))
    {
	    //Write bytecode
        currDefPtr->byteCodeList.push_back(new CCommand(IDC_ADDDATA, 3));
        currDefPtr->byteCodeList.back()->argList[1] = retDataRef.drID;
        currDefPtr->byteCodeList.back()->argList[2] = retDataRef.drIdx;
	}
    else if(EvalFunction(operandStr, retDataRef))
    {
        if(!(RightStr(operandStr, 1) == ")"))
        {
	        errorMsg = "Syntax error";
            CompileError();
        }
    }
    else if(EvalUserFunc(operandStr, retDataRef))
    {
        if(!(RightStr(operandStr, 1) == ")"))
        {
	        errorMsg = "Syntax error";
            CompileError();
        }
    }
    else
    {
        //Get variable/array reference
        EvalSubProgDataRef(operandStr, retDataRef);
    
        //Write bytecode
        currDefPtr->byteCodeList.push_back(new CCommand(IDC_ADDDATA, 3));
        currDefPtr->byteCodeList.back()->argList[1] = retDataRef.drID;
        currDefPtr->byteCodeList.back()->argList[2] = retDataRef.drIdx;
    }
    
    if(WaitForSingleObject(asyncExitFlag, 0) == WAIT_OBJECT_0) throw 0;
    
    operandStr = "";
}

void EvalOperator(int operatorID, deque<int>& operatorStack)
//Write bytecode command for, and pop, each top item in
//operatorStack while the stack is not empty and the top
//item's precedence is greater than or equal to the precedence
//of operatorID. Once done, push operatorID onto operatorStack.
{
    while(operatorStack.size() > 0)
    {
        if(GetOperatorPrecedence(operatorStack[0]) < GetOperatorPrecedence(operatorID)) break;
        currDefPtr->byteCodeList.push_back(new CCommand(operatorStack[0]));
        operatorStack.pop_front();
    }
    
    operatorStack.push_front(operatorID);
}

bool CheckForOperator(const string& expStr, int& charIdx, int& operatorID, bool isBoolExp)
//Check to see if the characters in expStr, starting at charIdx, indicate an operator.
//If so, set operatorID to the corresponding operator command ID, increment charIdx
//(if applicable), and return True. If not, return False.
{
    if(MidStr(expStr, charIdx, 1) == "+")
    {
        operatorID = IDC_ADD;
    }
    else if(MidStr(expStr, charIdx, 1) == "-")
    {
        operatorID = IDC_SUB;
    }
    else if(MidStr(expStr, charIdx, 1) == "%")
    {
        operatorID = IDC_MOD;
    }
    else if(MidStr(expStr, charIdx, 1) == "*")
    {
        operatorID = IDC_MUL;
    }
    else if(MidStr(expStr, charIdx, 1) == "/")
    {
        operatorID = IDC_DIV;
    }
    else if(MidStr(expStr, charIdx, 1) == "^")
    {
        operatorID = IDC_EXP;
    }
    else if(MidStr(expStr, charIdx, 2) == ">=")
    {
        operatorID = IDC_GREATEROREQUAL;
        charIdx += 1;
    }
    else if(MidStr(expStr, charIdx, 2) == "<=")
    {
        operatorID = IDC_LESSOREQUAL;
        charIdx += 1;
    }
    else if(MidStr(expStr, charIdx, 2) == "<>")
    {
        operatorID = IDC_NOTEQUAL;
        charIdx += 1;
    }
    else if(MidStr(expStr, charIdx, 1) == "=")
    {
        operatorID = IDC_EQUAL;
    }
    else if(MidStr(expStr, charIdx, 1) == "<")
    {
        operatorID = IDC_LESS;
    }
    else if(MidStr(expStr, charIdx, 1) == ">")
    {
        operatorID = IDC_GREATER;
    }
    else if(MidStr(expStr, charIdx, 1) == "&")
    {
        operatorID = IDC_STRCON;
    }
    else if(UCaseStr(MidStr(expStr, charIdx, 5)) == " AND ")
    {
        operatorID = isBoolExp ? IDC_LAND : IDC_BAND;
        charIdx += 4;
    }
    else if(UCaseStr(MidStr(expStr, charIdx, 5)) == " XOR ")
    {
        operatorID = isBoolExp ? IDC_LXOR : IDC_BXOR;
        charIdx += 4;
    }
    else if(UCaseStr(MidStr(expStr, charIdx, 4)) == " OR ")
    {
        operatorID = isBoolExp ? IDC_LOR : IDC_BOR;
        charIdx += 3;
    }
    else
    {
        return false;
    }
    
    return true;
}

int GetOperatorPrecedence(int operatorID)
//Return the precedence number of operatorID.
{
    if(operatorID == IDC_EXP)
        return 6;
    else if((operatorID == IDC_MUL) || (operatorID == IDC_DIV) || (operatorID == IDC_MOD))
        return 5;
    else if((operatorID == IDC_ADD) || (operatorID == IDC_SUB))
        return 4;
    else if(operatorID == IDC_STRCON)
        return 3;
    else if((operatorID == IDC_EQUAL) || (operatorID == IDC_LESS) || (operatorID == IDC_GREATER) ||
            (operatorID == IDC_LESSOREQUAL) || (operatorID == IDC_GREATEROREQUAL) || (operatorID == IDC_NOTEQUAL))
        return 2;
    else if((operatorID == IDC_LAND) || (operatorID == IDC_LOR) || (operatorID == IDC_LXOR) ||
            (operatorID == IDC_BAND) || (operatorID == IDC_BOR) || (operatorID == IDC_BXOR))
        return 1;
    else
        return 0;
}

bool EvalSubProgCall(string spNameStr, string spArgStr, bool isFuncCall, int& spDefIdx)
//
{
	vector<string> argStrList;
    vector<CDataRefInfo> argRefList;
    
    for(int a=0; a < spDefList.size(); a++)
    {
        if(LCaseStr(spNameStr) == LCaseStr(spDefList[a]->subProgName))
        {
            if(isFuncCall == spDefList[a]->isFunc)
            {
                //Seperate arguments
                ParseParams(spArgStr, argStrList, ",");
                
                //Check argument # against parameter #
                if(argStrList.size() != spDefList[a]->paramNum)
                {
                    errorMsg = "Wrong number of arguments for call to " + spDefList[a]->subProgName;
                    CompileError();
                }
                
                //Evaluate each argument
                argRefList.resize(argStrList.size());
                for(int b = argStrList.size()-1; b >= 0; b--)
                {
                    EvalExpression(argStrList[b], argRefList[b]);
                }
                
                //Check argument types against parameter types
                for(int b=0; b < argRefList.size(); b++)
                {
                    if(argRefList[b].drType != spDefList[a]->varTypeList[b])
                    {
	                    errorMsg = "Type mismatch in argument " + NumToStr(b+1) + " of call to " + spDefList[a]->subProgName;
                        CompileError();
                    }
                }
                
                //Write bytecode for function call
                currDefPtr->byteCodeList.push_back(new CCommand(IDC_CALLSUBPROG, 2));
                currDefPtr->byteCodeList.back()->argList[1] = a;
                
                //Return index of the sub program definition
                spDefIdx = a;
                return true;
            }
        }
    }
    
    //Sub prog not found
    return false;
}

bool EvalUserFunc(string funcStr, CDataRefInfo& retDataRef)
//
{
    string funcNameStr;
    string funcArgStr;
    int spDefIdx = -1;
    
    funcStr = TrimStr(funcStr);
    
    //Get function name
    funcNameStr = LeftStr(funcStr, funcStr.find_first_of("("));
    
    //Get argument string
    funcArgStr = GetString(funcNameStr.length() + 1, funcStr, ")");
    
    //Evaluate the call's arguments
    if(EvalSubProgCall(funcNameStr, funcArgStr, true, spDefIdx))
    {
        //Fill out return reference and exit
        retDataRef.drID = DATAREF_DATASTACK;
        retDataRef.drIdx = 0;
        retDataRef.drType = spDefList[spDefIdx]->varTypeList[spDefList[spDefIdx]->paramNum];
        
        return true;
    }
    else
    {
	    return false;
	}
}

bool EvalLitRef(string litStr, CDataRefInfo& retDataRef)
//
{
    CLiteral litObj;
    
    //Check if litStr is a string literal, number literal, or neither
    if(IsNumericStr(litStr))
    {
        retDataRef.drType = DT_NUMBER;
    }
    else if((LeftStr(litStr, 1) == "\"") && (RightStr(litStr, 1) == "\""))
    {
        retDataRef.drType = DT_STRING;
    }
    else
    {
	    return false;
    }
    
    retDataRef.drID = DATAREF_LITERAL;
    
    //Literal already exists?
    for(int n=0; n < LiteralList.size(); n++)
    {
        if((LiteralList[n].litStr == litStr) && (LiteralList[n].litType == retDataRef.drType))
        {
            retDataRef.drIdx = n;
            return true;
        }
    }
    
    //Add new literal
    LiteralList.push_back(CLiteral(litStr, retDataRef.drType));
    retDataRef.drIdx = LiteralList.size() - 1;
    return true;
}

void EvalSubProgDataRef(string dataNameStr, CDataRefInfo& retDataRef)
//
{
    string arrayNameStr;
    string arrayArgStr;

    dataNameStr = TrimStr(dataNameStr);

    //Get variable/array reference
    if(dataNameStr.find_first_of("(") != string::npos)
    {
        if(RightStr(dataNameStr, 1) == ")")
        {
            arrayNameStr = LeftStr(dataNameStr, dataNameStr.find_first_of("("));
            arrayArgStr = GetString(arrayNameStr.length() + 1, dataNameStr, ")");
            EvalArrayRef(arrayNameStr, retDataRef);
            
            //Write bytecode for array index expression(s)
            EvalArrayArgs(arrayArgStr, retDataRef);
        }
        else
        {
	        errorMsg = "Syntax error";
            CompileError();
        }
    }
    else
    {
        EvalVarRef(dataNameStr, retDataRef);
    }
}

void EvalVarRef(string varNameStr, CDataRefInfo& retDataRef)
//
{
    varNameStr = TrimStr(varNameStr);
    
    //Check in local variables
    if(currDefIdx > 0)
    {
        for(int n=0; n < currDefPtr->varNameList.size(); n++)
        {
            if(LCaseStr(varNameStr) == LCaseStr(currDefPtr->varNameList[n]))
            {
                retDataRef.drID = DATAREF_LOCALVAR;
                retDataRef.drIdx = n;
                retDataRef.drType = currDefPtr->varTypeList[n];
                retDataRef.drSPDefPtr = currDefPtr;
                return;
            }
        }
    }
    
    //Check in global variables
    for(int n=0; n < spDefList[0]->varNameList.size(); n++)
    {
        if(LCaseStr(varNameStr) == LCaseStr(spDefList[0]->varNameList[n]))
        {
            retDataRef.drID = DATAREF_GLOBALVAR;
            retDataRef.drIdx = n;
            retDataRef.drType = spDefList[0]->varTypeList[n];
            retDataRef.drSPDefPtr = spDefList[0];
            return;
        }
    }
    
    errorMsg = "Variable '" + varNameStr + "' has not been declared.";
    CompileError();
}

void EvalArrayRef(string arrayNameStr, CDataRefInfo& retDataRef)
//
{
    arrayNameStr = TrimStr(arrayNameStr);
    
    //Check in local arrays
    if(currDefIdx > 0)
    {
        for(int n=0; n < currDefPtr->arrayDefList.size(); n++)
        {
            if(LCaseStr(arrayNameStr) == LCaseStr(currDefPtr->arrayDefList[n]->arrayName))
            {
                //Fill out return reference and exit
                retDataRef.drID = DATAREF_LOCALARRAYITEM;
                retDataRef.drIdx = n;
                retDataRef.drType = currDefPtr->arrayDefList[n]->arrayType;
                retDataRef.drSPDefPtr = currDefPtr;
                return;
            }
        }
    }
    
    //Check in global arrays
    for(int n=0; n < spDefList[0]->arrayDefList.size(); n++)
    {
        if(LCaseStr(arrayNameStr) == LCaseStr(spDefList[0]->arrayDefList[n]->arrayName))
        {
            //Fill out return reference and exit
            retDataRef.drID = DATAREF_GLOBALARRAYITEM;
            retDataRef.drIdx = n;
            retDataRef.drType = spDefList[0]->arrayDefList[n]->arrayType;
            retDataRef.drSPDefPtr = spDefList[0];
            return;
        }
    }
    
    errorMsg = "Array '" + arrayNameStr + "()' has not been declared.";
    CompileError();
}

void EvalArrayArgs(string arrayArgStr, const CDataRefInfo& arrayDataRef)
//
{
    vector<string> paramStrList;
    vector<CDataRefInfo> paramRefList;
    CArrayDef* arrayDefPtr;
    
    //Get array definition pointer
    arrayDefPtr = arrayDataRef.drSPDefPtr->arrayDefList[arrayDataRef.drIdx];
    
    //Get index arguments
    ParseParams(arrayArgStr, paramStrList, ",");
    
    //Check argument # against dimension #
    if(paramStrList.size() != arrayDefPtr->dimSizeList.size())
    {
	    errorMsg = "Wrong number of dimensions for array " + arrayDefPtr->arrayName + "()";
        CompileError();
    }
    
    //Evaluate each index argument
    paramRefList.resize(paramStrList.size());
    for(int n = paramStrList.size()-1; n >= 0; n--)
    {
        EvalExpression(paramStrList[n], paramRefList[n]);
    }
    
    //Check argument types
    for(int n=0; n < paramRefList.size(); n++)
    {
        if(paramRefList[n].drType != DT_NUMBER)
        {
	        errorMsg = "Type mismatch in dimension " + NumToStr(n+1) + " of array " + arrayDefPtr->arrayName + "()";
            CompileError();
        }
    }
    
    //Write bytecode for index stacking
    currDefPtr->byteCodeList.push_back(new CCommand(IDC_ARRAYIDX, 2));
    currDefPtr->byteCodeList.back()->argList[1] = paramRefList.size();
}


