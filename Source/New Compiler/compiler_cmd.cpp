#include <cstdlib>
#include <string>
#include <vector>
#include <deque>
#include <windows.h>
#include "..\..\..\[Libraries]\String Extension\stringExt.h"
#include "..\basic_tags.h"
#include "..\basic_def.h"
#include "compiler_main.h"
#include "compiler_cmd.h"

using namespace std;

void CompileCmd(string cmdStr)
//
{

}

bool EvalFunction(string funcStr, CDataRefInfo& retDataRef)
//
{

}

void Cmd_Array(string cmdStr)
//
{
    vector<string> paramList;
    vector<string> arrayStrList;
    string nameStr;
    string indexStr;
    vector<string> indexStrList;

    cmdStr = TrimStr(cmdStr);

    //Parse parameters
    static const char* delimList[1] = {" as "};
    ParseParamsEx(cmdStr, paramList, delimList, 1);
    if(paramList.size() != 2)
    {
        errorMsg = "Syntax error.";
        CompileError();
    }

    //Parse array declarations
    ParseParams(paramList[0], arrayStrList, ",");

    //Process each array declarations
    for(int a = 0; a < arrayStrList.size(); a++)
    {
        //Parse name
        nameStr = LeftStr(arrayStrList[a], arrayStrList[a].find_first_of("("));
        if( (nameStr.length() == arrayStrList[a].length()) || ((nameStr.length() + 1) == arrayStrList[a].length()) )
        {
            errorMsg = "Syntax error.";
            CompileError();
        }
        nameStr = TrimStr(nameStr);

        //Parse dimensions
        indexStr = GetString(nameStr.length() + 1, arrayStrList[a], ")");
        if( (nameStr.length() + indexStr.length() + 1) == (arrayStrList[a].length()) )
        {
            errorMsg = "Syntax error.";
            CompileError();
        }
        ParseParams(indexStr, indexStrList, ",");

        //Check for a valid array name
        if(NameCheck(nameStr))
        {
            errorMsg = "Illegal array name: '" + nameStr + "'";
            CompileError();
        }

        //Check name against existing arrays (in current subprog)
        for(int b = 0; b < currDefPtr->arrayDefList.size(); b++)
        {
            if(LCaseStr(nameStr) == LCaseStr(currDefPtr->arrayDefList[b]->arrayName))
            {
                errorMsg = "Array '" + nameStr + "' already declared.";
                CompileError();
            }
        }

        //Check for valid dimensions
        if(indexStrList.size() == 0)
        {
            errorMsg = "Array '" + nameStr + "' needs at least one dimension.";
            CompileError();
        }
        for(int b = 0; b < indexStrList.size(); b++)
        {
            indexStrList[b] = TrimStr(indexStrList[b]);
            if(!IsNumericStr(indexStrList[b]))
            {
                errorMsg = "Size of dimension " + NumToStr(b) + " in array '" + nameStr + "' must be an integer number.";
                CompileError();
            }
            if(StrToNum(indexStrList[b]) <= 0)
            {
                errorMsg = "Size of dimension " + NumToStr(b) + " in array '" + nameStr + "' must be greater than zero.";
                CompileError();
            }
        }

        //Add new array definition
        currDefPtr->arrayDefList.push_back(nameStr);

        //Set array name
        currDefPtr->arrayDefList.back()->arrayName = nameStr;

        //Set array dimensions
        for(int b = 0; b < indexStrList.size(); b++)
        {
            currDefPtr->arrayDefList.back()->dimSizeList.push_back(int(StrToNum(indexStrList[b])));
        }

        //Set array type
        if(LCaseStr(paramList[1]) == "string")
        {
            currDefPtr->arrayDefList.back()->arrayType = DT_STRING;
        }
        else if(LCaseStr(paramList[1]) == "number")
        {
            currDefPtr->arrayDefList.back()->arrayType = DT_NUMBER;
        }
        else
        {
            errorMsg = "Type '" + paramsList[1] + "' does not exist.";
            CompileError();
        }

        //Cleanup for next array declaration
        nameStr = "";
        indexStr = "";
        indexStrList.clear();
    }
}

void Cmd_Call(string cmdStr)
//
{
    string subNameStr;
    string subArgStr;
    int spDefIdx = -1;

    cmdStr = TrimStr(cmdStr);

    //Get sub name
    subNameStr = LeftStr(cmdStr, cmdStr.find_first_of(" "));

    //Get argument string
    subArgStr = MidStr(cmdStr, subNameStr.length() + 1);

    //Evaluate the call's arguments
    if(!EvalSubProgCall(subNameStr, subArgStr, false, spDefIdx))
    {
        errorMsg = "Undefined sub '" + subNameStr + "'";
        CompileError();
    }
}

void Cmd_Close(string cmdStr)
//
{
    vector<string> paramStrList;
    vector<CDataRefInfo> paramRefList;

    cmdStr = TrimStr(cmdStr);

    //Get arguments
    ParseParams(cmdStr, paramStrList, ",");

    //Check argument # against parameter #
    if(paramStrList.size() != 1)
    {
        errorMsg = "Wrong number of arguments for command Close.";
        CompileError();
    }

    //cHOP OFF #
    if(LeftStr(paramStrList[0], 1) == "#")
    {
        paramStrList[0] = RightStr(paramStrList[0], paramStrList[0].length() - 1)
    }

    //Evaluate argument
    paramRefList.resize(1);
    EvalExpression(paramStrList[0], paramRefList[0]);

    //Check argument type against parameter type
    if(paramRefList[0].drType != DT_NUMBER)
    {
        errorMsg = "Type mismatch in argument 1 of command Close.";
        CompileError();
    }

    //Write bytecode for function call
    currDefPtr->byteCodeList.push_back(new CCommand(IDC_CloseFile));
}

void Cmd_ConsoleTitle(string cmdStr)
//
{
    vector<string> paramStrList;
    vector<CDataRefInfo> paramRefList;

    cmdStr = TrimStr(cmdStr);

    //Get arguments
    ParseParams(cmdStr, paramStrList, ",");

    //Check argument # against parameter #
    if(paramStrList.size() != 1)
    {
        errorMsg = "Wrong number of arguments for command ConsoleTitle.";
        CompileError();
    }

    //Evaluate argument
    paramRefList.resize(1);
    EvalExpression(paramStrList[0], paramRefList[0]);

    //Check argument type against parameter type
    if(paramRefList[0].drType <> DT_STRING)
    {
        errorMsg = "Console title should be a String.";
        CompileError();
    }

    //Write bytecode for function call
    currDefPtr->byteCodeList.push_back(new CCommand(IDC_ConsoleTitle));
}

void Cmd_ExitFor(string cmdStr)
//
{
    if(currDefPtr->forBlockNum > 0)
    {
        currDefPtr->byteCodeList.push_back(new CCommand(IDC_ExitFor));
    }
    else
    {
        errorMsg = "Exit For outside of For block.";
        CompileError();
    }
}

void Cmd_ExitFunction(string cmdStr)
//
{
    if((currDefIdx == 0) || !(currDefPtr->isFunc))
    {
        errorMsg = "Exit Function outside of Function";
        CompileError();
    }
    currDefPtr->byteCodeList.push_back(new CCommand(IDC_ExitSubProg));
}

void Cmd_ExitSub(string cmdStr)
//
{
    if((currDefIdx == 0) || (currDefPtr->isFunc))
    {
        errorMsg = "Exit Sub outside of Sub";
        CompileError();
    }
    currDefPtr->byteCodeList.push_back(new CCommand(IDC_ExitSubProg));
}

void Cmd_ExitWhile(string cmdStr)
//
{
    if(currDefPtr->whileBlockNum > 0)
    {
        currDefPtr->byteCodeList.push_back(new CCommand(IDC_ExitWhile));
    }
    else
    {
        errorMsg = "Exit While outside of While block.";
        CompileError();
    }
}

void Cmd_For(string cmdStr)
//
{

}

void Cmd_Gosub(string cmdStr)
//
{

}

void Cmd_Goto(string cmdStr)
//
{

}

void Cmd_If(string cmdStr)
//
{

}

void Cmd_Input(string cmdStr)
//
{

}

void Cmd_Label(string cmdStr)
//
{
    //Add location of next byte-code command to labelLocList
    currDefPtr->labelLocList.push_back(currDefPtr->byteCodeList.size());
}

void Cmd_Let(string cmdStr)
//
{
    vector<string> paramList;
    CDataRefInfo destRef;
    CDataRefInfo srcRef;

    cmdStr = TrimStr(cmdStr);

    //Parse out both the variable/array name and the expression string
    static const char* delimList[1] = {"="};
    ParseParamsEx(cmdStr, paramList, delimList, 1);
    if(paramList.size() != 2)
    {
	    errorMsg = "Syntax error";
        CompileError();
    }
    else if(paramList[0] == "")
    {
	    errorMsg = "Missing expression.";
        CompileError();
    }

    //Get variable/array reference
    EvalSubProgDataRef(paramList[0], destRef);

    //Get expression reference
    EvalExpression(paramList[1], srcRef);

    //Type check
    if(srcRef.drType != destRef.drType)
    {
        errorMsg = "Type mismatch: Expression type and variable/array type do not match";
        CompileError();
    }

    //Write bytecode
    currDefPtr->byteCodeList.push_back(new CCommand(IDC_COPYDATA, 3));
    currDefPtr->byteCodeList.back()->argList[1] = destRef.drID;
    currDefPtr->byteCodeList.back()->argList[2] = destRef.drIdx;
}

void Cmd_LineInput(string cmdStr)
//
{

}

void Cmd_Message(string cmdStr)
//
{
    vector<string> paramStrList;
    vector<CDataRefInfo> paramRefList;

    cmdStr = TrimStr(cmdStr);

    //Get arguments
    ParseParams(cmdStr, paramStrList, ",");

    //Check argument # against parameter #
    if(paramStrList.size() != 2)
    {
        errorMsg = "Wrong number of arguments for command Message.";
        CompileError();
    }

    //Evaluate each argument
    paramRefList.resize(paramStrList.size());
    for(int a = paramStrList.size()-1; a >= 0; a--)
    {
        EvalExpression(paramStrList[a], paramRefList[a]);
    }

    //Check argument types against parameter types
    for(int a=0; a < paramRefList.size(); a++)
    {
        if(paramRefList[a].drType != DT_STRING)
        {
            errorMsg = "Type mismatch in argument " + NumToStr(a) + " of command Message.";
            CompileError();
        }
    }

    //Write bytecode for function call
    currDefPtr->byteCodeList.push_back(new CCommand(IDC_Message));
}

void Cmd_OnError(string cmdStr)
//
{

}

void Cmd_Open(string cmdStr)
//
{

}

void Cmd_Pause(string cmdStr)
//
{
    vector<string> paramStrList;
    vector<CDataRefInfo> paramRefList;

    cmdStr = TrimStr(cmdStr);

    //Get arguments
    ParseParams(cmdStr, paramStrList, ",");

    //Check argument # against parameter #
    if(paramStrList.size() != 1)
    {
        errorMsg = "Wrong number of arguments for command Pause.";
        CompileError();
    }

    //Evaluate argument
    paramRefList.resize(1);
    EvalExpression(paramStrList[0], paramRefList[0]);

    //Check argument type against parameter type
    if(paramRefList[0].drType != DT_NUMBER)
    {
        errorMsg = "Type mismatch in argument 1 of command Pause.";
        CompileError();
    }

    //Write bytecode for function call
    currDefPtr->byteCodeList.push_back(new CCommand(IDC_Pause));
}

void Cmd_Print(string cmdStr)
//
{

}

void Cmd_Redim(string cmdStr)
//
{

}

void Cmd_RedimAdd(string cmdStr)
//
{

}

void Cmd_RedimRemove(string cmdStr)
//
{

}

void Cmd_Seek(string cmdStr)
//
{
    vector<string> paramStrList;
    vector<CDataRefInfo> paramRefList;

    cmdStr = TrimStr(cmdStr);

    //Get arguments
    ParseParams(cmdStr, paramStrList, ",");

    //Check argument # against parameter #
    if(paramStrList.size() != 2)
    {
        errorMsg = "Wrong number of arguments for command Seek.";
        CompileError();
    }

    //cHOP OFF #
    if(LeftStr(paramStrList[0], 1) == "#")
    {
        paramStrList[0] = RightStr(paramStrList[0], paramStrList[0].length() - 1);
    }

    //Evaluate arguments
    paramRefList.resize(paramStrList.size());
    for(int a = paramStrList.size()-1; a >= 0; a--)
    {
        EvalExpression(paramStrList[a], paramRefList[a]);
    }

    //Check argument type against parameter type
    for(int a=0; a < paramRefList.size(); a++)
    {
        if(paramRefList[a].drType != DT_NUMBER)
        {
            errorMsg = "Type mismatch in argument " + NumToStr(a) + " of command Seek.";
            CompileError();
        }
    }

    //Write bytecode for function call
    currDefPtr->byteCodeList.push_back(new CCommand(IDC_SetFilePos));
}

void Cmd_Var(string cmdStr)
//
{
    vector<string> paramList;
    vector<string> varNameList;

    cmdStr = TrimStr(cmdStr);

    //Parse parameters
    static const char* delimList[1] = {" as "};
    ParseParamsEx(cmdStr, paramList, delimList, 1);
    if(paramList.size() != 2)
    {
        errorMsg = "Syntax error.";
        CompileError();
    }

    //Parse variable names
    ParseParams(paramList[0], varNameList, ",");

    //Process each variable
    for(int a = 0; a < varNameList.size(); a++)
    {
        //Check for valid variable name
        if(NameCheck(varNameList[a]))
        {
            errorMsg = "Illegal variable name: '" + varNameList[a] + "'.";
            CompileError();
        }

        //Check name against existing variables (in current subprog)
        for(int b = 0; b < currDefPtr.varNameList.size(); b++)
        {
            if(LCaseStr(varNameList[a]) == LCaseStr(currDefPtr.varNameList[b]))
            {
                errorMsg = "Variable '" + varNameList[a] + "' already declared.";
                CompileError();
            }
        }

        //Add variable name
        currDefPtr.varNameList.push_back(varNameList[a]);

        //Add variable type
        if(LCaseStr(paramList[1]) == "string")
        {
            currDefPtr.varTypeList.push_back(DT_STRING);
        }
        else if(LCaseStr(paramList[1]) == "number")
        {
            currDefPtr.varTypeList.push_back(DT_NUMBER);
        }
        else
        {
            errorStr = "Type '" + paramList[1] + "' does not exist.";
            CompileError();
        }
    }
}

void Cmd_While(string cmdStr)
//
{

}

void Func_Abs(string cmdStr, CDataRefInfo& retDataRef)
//
{
    vector<string> paramStrList;
    vector<CDataRefInfo> paramRefList;

    cmdStr = TrimStr(cmdStr);

    //Get arguments
    ParseParams(cmdStr, paramStrList, ",");

    //Check argument # against parameter #
    if(paramStrList.size() != 1)
    {
        errorMsg = "Wrong number of arguments for function ABS().";
        CompileError();
    }

    //Evaluate argument
    paramRefList.resize(1);
    EvalExpression(paramStrList[0], paramRefList[0]);

    //Check argument type against parameter type
    if(paramRefList[0].drType != DT_NUMBER)
    {
        errorMsg = "Type mismatch in argument 1 of function ABS().";
        CompileError();
    }

    //Write bytecode for function call
    currDefPtr->byteCodeList.push_back(new CCommand(IDC_Abs));

    //Fill out return reference and exit
    retDataRef.drID = DATAREF_DATASTACK;
    retDataRef.drIdx = 0;
    retDataRef.drType = DT_NUMBER;
}

void Func_Asc(string cmdStr, CDataRefInfo& retDataRef)
//
{
    vector<string> paramStrList;
    vector<CDataRefInfo> paramRefList;

    cmdStr = TrimStr(cmdStr);

    //Get arguments
    ParseParams(cmdStr, paramStrList, ",");

    //Check argument # against parameter #
    if(paramStrList.size() != 1)
    {
        errorMsg = "Wrong number of arguments for function ASC().";
        CompileError();
    }

    //Evaluate argument
    paramRefList.resize(1);
    EvalExpression(paramStrList[0], paramRefList[0]);

    //Check argument type against parameter type
    if(paramRefList[0].drType != DT_STRING)
    {
        errorMsg = "Type mismatch in argument 1 of function ASC().";
        CompileError();
    }

    //Write bytecode for function call
    currDefPtr->byteCodeList.push_back(new CCommand(IDC_Asc));

    //Fill out return reference and exit
    retDataRef.drID = DATAREF_DATASTACK;
    retDataRef.drIdx = 0;
    retDataRef.drType = DT_NUMBER;
}

void Func_Chr(string cmdStr, CDataRefInfo& retDataRef)
//
{
    vector<string> paramStrList;
    vector<CDataRefInfo> paramRefList;

    cmdStr = TrimStr(cmdStr);

    //Get arguments
    ParseParams(cmdStr, paramStrList, ",");

    //Check argument # against parameter #
    if(paramStrList.size() != 1)
    {
        errorMsg = "Wrong number of arguments for function CHR().";
        CompileError();
    }

    //Evaluate argument
    paramRefList.resize(1);
    EvalExpression(paramStrList[0], paramRefList[0]);

    //Check argument type against parameter type
    if(paramRefList[0].drType != DT_NUMBER)
    {
        errorMsg = "Type mismatch in argument 1 of function CHR().";
        CompileError();
    }

    //Write bytecode for function call
    currDefPtr->byteCodeList.push_back(new CCommand(IDC_Chr));

    //Fill out return reference and exit
    retDataRef.drID = DATAREF_DATASTACK;
    retDataRef.drIdx = 0;
    retDataRef.drType = DT_STRING;
}

void Func_EOF(string cmdStr, CDataRefInfo& retDataRef)
//
{
    vector<string> paramStrList;
    vector<CDataRefInfo> paramRefList;

    cmdStr = TrimStr(cmdStr);

    //Get arguments
    ParseParams(cmdStr, paramStrList, ",");

    //Check argument # against parameter #
    if(paramStrList.size() != 1)
    {
        errorMsg = "Wrong number of arguments for function EOF().";
        CompileError();
    }

    //Evaluate argument
    paramRefList.resize(1);
    EvalExpression(paramStrList[0], paramRefList[0]);

    //Check argument type against parameter type
    if(paramRefList[0].drType != DT_NUMBER)
    {
        errorMsg = "Type mismatch in argument 1 of function EOF().";
        CompileError();
    }

    //Write bytecode for function call
    currDefPtr->byteCodeList.push_back(new CCommand(IDC_EndOfFile));

    //Fill out return reference and exit
    retDataRef.drID = DATAREF_DATASTACK;
    retDataRef.drIdx = 0;
    retDataRef.drType = DT_NUMBER;
}

void Func_Input(string cmdStr, CDataRefInfo& retDataRef)
//
{
    vector<string> paramStrList;
    vector<CDataRefInfo> paramRefList;

    cmdStr = TrimStr(cmdStr);

    //Get arguments
    ParseParams(cmdStr, paramStrList, ",");

    //Check argument # against parameter #
    if(paramStrList.size() != 2)
    {
        errorMsg = "Wrong number of arguments for function INPUT().";
        CompileError();
    }

    //Evaluate each argument
    paramRefList.resize(paramStrList.size());
    for(int a = paramStrList.size()-1; a >= 0; a--)
    {
        EvalExpression(paramStrList[a], paramRefList[a]);
    }

    //Check argument types against parameter types
    for(int a=0; a < paramRefList.size(); a++)
    {
        if(paramRefList[a].drType != DT_NUMBER)
        {
            errorMsg = "Type mismatch in argument " + NumToStr(a) + " of function INPUT().";
            CompileError();
        }
    }

    //Write bytecode for function call
    currDefPtr->byteCodeList.push_back(new CCommand(IDC_InputBytesFromFile));

    //Fill out return reference and exit
    retDataRef.drID = DATAREF_DATASTACK;
    retDataRef.drIdx = 0;
    retDataRef.drType = DT_STRING;
}

void Func_Int(string cmdStr, CDataRefInfo& retDataRef)
//
{
    vector<string> paramStrList;
    vector<CDataRefInfo> paramRefList;

    cmdStr = TrimStr(cmdStr);

    //Get arguments
    ParseParams(cmdStr, paramStrList, ",");

    //Check argument # against parameter #
    if(paramStrList.size() != 1)
    {
        errorMsg = "Wrong number of arguments for function INT().";
        CompileError();
    }

    //Evaluate argument
    paramRefList.resize(1);
    EvalExpression(paramStrList[0], paramRefList[0]);

    //Check argument type against parameter type
    if(paramRefList[0].drType != DT_NUMBER)
    {
        errorMsg = "Type mismatch in argument 1 of function INT().";
        CompileError();
    }

    //Write bytecode for function call
    currDefPtr->byteCodeList.push_back(new CCommand(IDC_Int));

    //Fill out return reference and exit
    retDataRef.drID = DATAREF_DATASTACK;
    retDataRef.drIdx = 0;
    retDataRef.drType = DT_NUMBER;
}

void Func_Left(string cmdStr, CDataRefInfo& retDataRef)
//
{
    vector<string> paramStrList;
    vector<CDataRefInfo> paramRefList;

    cmdStr = TrimStr(cmdStr);

    //Get arguments
    ParseParams(cmdStr, paramStrList, ",");

    //Check argument # against parameter #
    if(paramStrList.size() != 2)
    {
        errorMsg = "Wrong number of arguments for function LEFT().";
        CompileError();
    }

    //Evaluate each argument
    paramRefList.resize(paramStrList.size());
    for(int a = paramStrList.size()-1; a >= 0; a--)
    {
        EvalExpression(paramStrList[a], paramRefList[a]);
    }

    //Check argument types against parameter types
    if(paramRefList[0].drType != DT_STRING)
    {
        errorMsg = "Type mismatch in argument 1 of function LEFT().";
        CompileError();
    }
    if(paramRefList[1].drType != DT_NUMBER)
    {
        errorMsg = "Type mismatch in argument 2 of function LEFT().";
        CompileError();
    }

    //Write bytecode for function call
    currDefPtr->byteCodeList.push_back(new CCommand(IDC_Left));

    //Fill out return reference and exit
    retDataRef.drID = DATAREF_DATASTACK;
    retDataRef.drIdx = 0;
    retDataRef.drType = DT_STRING;
}

void Func_Len(string cmdStr, CDataRefInfo& retDataRef)
//
{
    vector<string> paramStrList;
    vector<CDataRefInfo> paramRefList;

    cmdStr = TrimStr(cmdStr);

    //Get arguments
    ParseParams(cmdStr, paramStrList, ",");

    //Check argument # against parameter #
    if(paramStrList.size() != 1)
    {
        errorMsg = "Wrong number of arguments for function LEN().";
        CompileError();
    }

    //Evaluate argument
    paramRefList.resize(1);
    EvalExpression(paramStrList[0], paramRefList[0]);

    //Check argument type against parameter type
    if(paramRefList[0].drType != DT_STRING)
    {
        errorMsg = "Type mismatch in argument 1 of function LEN().";
        CompileError();
    }

    //Write bytecode for function call
    currDefPtr->byteCodeList.push_back(new CCommand(IDC_Len));

    //Fill out return reference and exit
    retDataRef.drID = DATAREF_DATASTACK;
    retDataRef.drIdx = 0;
    retDataRef.drType = DT_NUMBER;
}

void Func_Loc(string cmdStr, CDataRefInfo& retDataRef)
//
{
    vector<string> paramStrList;
    vector<CDataRefInfo> paramRefList;

    cmdStr = TrimStr(cmdStr);

    //Get arguments
    ParseParams(cmdStr, paramStrList, ",");

    //Check argument # against parameter #
    if(paramStrList.size() != 1)
    {
        errorMsg = "Wrong number of arguments for function LOC().";
        CompileError();
    }

    //Evaluate argument
    paramRefList.resize(1);
    EvalExpression(paramStrList[0], paramRefList[0]);

    //Check argument type against parameter type
    if(paramRefList[0].drType != DT_NUMBER)
    {
        errorMsg = "Type mismatch in argument 1 of function LOC().";
        CompileError();
    }

    //Write bytecode for function call
    currDefPtr->byteCodeList.push_back(new CCommand(IDC_GetFilePos));

    //Fill out return reference and exit
    retDataRef.drID = DATAREF_DATASTACK;
    retDataRef.drIdx = 0;
    retDataRef.drType = DT_NUMBER;
}

void Func_LOF(string cmdStr, CDataRefInfo& retDataRef)
//
{
    vector<string> paramStrList;
    vector<CDataRefInfo> paramRefList;

    cmdStr = TrimStr(cmdStr);

    //Get arguments
    ParseParams(cmdStr, paramStrList, ",");

    //Check argument # against parameter #
    if(paramStrList.size() != 1)
    {
        errorMsg = "Wrong number of arguments for function LOF().";
        CompileError();
    }

    //Evaluate argument
    paramRefList.resize(1);
    EvalExpression(paramStrList[0], paramRefList[0]);

    //Check argument type against parameter type
    if(paramRefList[0].drType != DT_NUMBER)
    {
        errorMsg = "Type mismatch in argument 1 of function LOF().";
        CompileError();
    }

    //Write bytecode for function call
    currDefPtr->byteCodeList.push_back(new CCommand(IDC_FileLength));

    //Fill out return reference and exit
    retDataRef.drID = DATAREF_DATASTACK;
    retDataRef.drIdx = 0;
    retDataRef.drType = DT_NUMBER;
}

void Func_Lower(string cmdStr, CDataRefInfo& retDataRef)
//
{
    vector<string> paramStrList;
    vector<CDataRefInfo> paramRefList;

    cmdStr = TrimStr(cmdStr);

    //Get arguments
    ParseParams(cmdStr, paramStrList, ",");

    //Check argument # against parameter #
    if(paramStrList.size() != 1)
    {
        errorMsg = "Wrong number of arguments for function LOWER().";
        CompileError();
    }

    //Evaluate argument
    paramRefList.resize(1);
    EvalExpression(paramStrList[0], paramRefList[0]);

    //Check argument type against parameter type
    if(paramRefList[0].drType != DT_STRING)
    {
        errorMsg = "Type mismatch in argument 1 of function LOWER().";
        CompileError();
    }

    //Write bytecode for function call
    currDefPtr->byteCodeList.push_back(new CCommand(IDC_Lower));

    //Fill out return reference and exit
    retDataRef.drID = DATAREF_DATASTACK;
    retDataRef.drIdx = 0;
    retDataRef.drType = DT_STRING;
}

void Func_LTrim(string cmdStr, CDataRefInfo& retDataRef)
//
{
    vector<string> paramStrList;
    vector<CDataRefInfo> paramRefList;

    cmdStr = TrimStr(cmdStr);

    //Get arguments
    ParseParams(cmdStr, paramStrList, ",");

    //Check argument # against parameter #
    if(paramStrList.size() != 1)
    {
        errorMsg = "Wrong number of arguments for function LTRIM().";
        CompileError();
    }

    //Evaluate argument
    paramRefList.resize(1);
    EvalExpression(paramStrList[0], paramRefList[0]);

    //Check argument type against parameter type
    if(paramRefList[0].drType != DT_STRING)
    {
        errorMsg = "Type mismatch in argument 1 of function LTRIM().";
        CompileError();
    }

    //Write bytecode for function call
    currDefPtr->byteCodeList.push_back(new CCommand(IDC_LTrim));

    //Fill out return reference and exit
    retDataRef.drID = DATAREF_DATASTACK;
    retDataRef.drIdx = 0;
    retDataRef.drType = DT_STRING;
}

void Func_Mid(string cmdStr, CDataRefInfo& retDataRef)
//
{
    vector<string> paramStrList;
    vector<CDataRefInfo> paramRefList;

    cmdStr = TrimStr(cmdStr);

    //Get arguments
    ParseParams(cmdStr, paramStrList, ",");

    //Check argument # against parameter #
    if((paramStrList.size() < 2) || (paramStrList.size() > 3))
    {
        errorMsg = "Wrong number of arguments for function MID().";
        CompileError();
    }

    //Evaluate each argument
    paramRefList.resize(paramStrList.size());
    for(int a = paramStrList.size()-1; a >= 0; a--)
    {
        EvalExpression(paramStrList[a], paramRefList[a]);
    }

    //Check argument types against parameter types
    if(paramRefList[0].drType != DT_STRING)
    {
        errorMsg = "Type mismatch in argument 1 of function MID().";
        CompileError();
    }
    for(int a=1; a < paramRefList.size(); a++)
    {
        if(paramRefList[a].drType != DT_NUMBER)
        {
            errorMsg = "Type mismatch in argument " + NumToStr(a+1) + " of function MID().";
            CompileError();
        }
    }

    //Write bytecode for function call
    currDefPtr->byteCodeList.push_back(new CCommand(IDC_Mid));

    //Fill out return reference and exit
    retDataRef.drID = DATAREF_DATASTACK;
    retDataRef.drIdx = 0;
    retDataRef.drType = DT_STRING;
}

void Func_Not(string cmdStr, CDataRefInfo& retDataRef)
//
{
    vector<string> paramStrList;
    vector<CDataRefInfo> paramRefList;

    cmdStr = TrimStr(cmdStr);

    //Get arguments
    ParseParams(cmdStr, paramStrList, ",");

    //Check argument # against parameter #
    if(paramStrList.size() != 1)
    {
        errorMsg = "Wrong number of arguments for function NOT().";
        CompileError();
    }

    //Evaluate argument
    paramRefList.resize(1);
    EvalExpression(paramStrList[0], paramRefList[0]);

    //Check argument type against parameter type
    if(paramRefList[0].drType != DT_NUMBER)
    {
        errorMsg = "Type mismatch in argument 1 of function NOT().";
        CompileError();
    }

    //Write bytecode for function call
    currDefPtr->byteCodeList.push_back(new CCommand(IDC_Not));

    //Fill out return reference and exit
    retDataRef.drID = DATAREF_DATASTACK;
    retDataRef.drIdx = 0;
    retDataRef.drType = DT_NUMBER;
}

void Func_Right(string cmdStr, CDataRefInfo& retDataRef)
//
{
    vector<string> paramStrList;
    vector<CDataRefInfo> paramRefList;

    cmdStr = TrimStr(cmdStr);

    //Get arguments
    ParseParams(cmdStr, paramStrList, ",");

    //Check argument # against parameter #
    if(paramStrList.size() != 2)
    {
        errorMsg = "Wrong number of arguments for function RIGHT().";
        CompileError();
    }

    //Evaluate each argument
    paramRefList.resize(paramStrList.size());
    for(int a = paramStrList.size()-1; a >= 0; a--)
    {
        EvalExpression(paramStrList[a], paramRefList[a]);
    }

    //Check argument types against parameter types
    if(paramRefList[0].drType != DT_STRING)
    {
        errorMsg = "Type mismatch in argument 1 of function RIGHT().";
        CompileError();
    }
    if(paramRefList[1].drType != DT_NUMBER)
    {
        errorMsg = "Type mismatch in argument 2 of function RIGHT().";
        CompileError();
    }

    //Write bytecode for function call
    currDefPtr->byteCodeList.push_back(new CCommand(IDC_Right));

    //Fill out return reference and exit
    retDataRef.drID = DATAREF_DATASTACK;
    retDataRef.drIdx = 0;
    retDataRef.drType = DT_STRING;
}

void Func_Rnd(string cmdStr, CDataRefInfo& retDataRef)
//
{
    vector<string> paramStrList;
    vector<CDataRefInfo> paramRefList;

    cmdStr = TrimStr(cmdStr);

    //Get arguments
    ParseParams(cmdStr, paramStrList, ",");

    //Check argument # against parameter #
    if(paramStrList.size() > 0)
    {
        errorMsg = "Wrong number of arguments for function RND().";
        CompileError();
    }

    //Write bytecode for function call
    currDefPtr->byteCodeList.push_back(new CCommand(IDC_Rnd));

    //Fill out return reference and exit
    retDataRef.drID = DATAREF_DATASTACK;
    retDataRef.drIdx = 0;
    retDataRef.drType = DT_NUMBER;
}

void Func_RTrim(string cmdStr, CDataRefInfo& retDataRef)
//
{
    vector<string> paramStrList;
    vector<CDataRefInfo> paramRefList;

    cmdStr = TrimStr(cmdStr);

    //Get arguments
    ParseParams(cmdStr, paramStrList, ",");

    //Check argument # against parameter #
    if(paramStrList.size() != 1)
    {
        errorMsg = "Wrong number of arguments for function RTRIM().";
        CompileError();
    }

    //Evaluate argument
    paramRefList.resize(1);
    EvalExpression(paramStrList[0], paramRefList[0]);

    //Check argument type against parameter type
    if(paramRefList[0].drType != DT_STRING)
    {
        errorMsg = "Type mismatch in argument 1 of function RTRIM().";
        CompileError();
    }

    //Write bytecode for function call
    currDefPtr->byteCodeList.push_back(new CCommand(IDC_RTrim));

    //Fill out return reference and exit
    retDataRef.drID = DATAREF_DATASTACK;
    retDataRef.drIdx = 0;
    retDataRef.drType = DT_STRING;
}

void Func_Str(string cmdStr, CDataRefInfo& retDataRef)
//
{
    vector<string> paramStrList;
    vector<CDataRefInfo> paramRefList;

    cmdStr = TrimStr(cmdStr);

    //Get arguments
    ParseParams(cmdStr, paramStrList, ",");

    //Check argument # against parameter #
    if(paramStrList.size() != 1)
    {
        errorMsg = "Wrong number of arguments for function STR().";
        CompileError();
    }

    //Evaluate argument
    paramRefList.resize(1);
    EvalExpression(paramStrList[0], paramRefList[0]);

    //Check argument type against parameter type
    if(paramRefList[0].drType != DT_NUMBER)
    {
        errorMsg = "Type mismatch in argument 1 of function STR().";
        CompileError();
    }

    //Write bytecode for function call
    currDefPtr->byteCodeList.push_back(new CCommand(IDC_Str));

    //Fill out return reference and exit
    retDataRef.drID = DATAREF_DATASTACK;
    retDataRef.drIdx = 0;
    retDataRef.drType = DT_STRING;
}

void Func_Trim(string cmdStr, CDataRefInfo& retDataRef)
//
{
    vector<string> paramStrList;
    vector<CDataRefInfo> paramRefList;

    cmdStr = TrimStr(cmdStr);

    //Get arguments
    ParseParams(cmdStr, paramStrList, ",");

    //Check argument # against parameter #
    if(paramStrList.size() != 1)
    {
        errorMsg = "Wrong number of arguments for function TRIM().";
        CompileError();
    }

    //Evaluate argument
    paramRefList.resize(1);
    EvalExpression(paramStrList[0], paramRefList[0]);

    //Check argument type against parameter type
    if(paramRefList[0].drType != DT_STRING)
    {
        errorMsg = "Type mismatch in argument 1 of function TRIM().";
        CompileError();
    }

    //Write bytecode for function call
    currDefPtr->byteCodeList.push_back(new CCommand(IDC_Trim));

    //Fill out return reference and exit
    retDataRef.drID = DATAREF_DATASTACK;
    retDataRef.drIdx = 0;
    retDataRef.drType = DT_STRING;
}

void Func_Upper(string cmdStr, CDataRefInfo& retDataRef)
//
{
    vector<string> paramStrList;
    vector<CDataRefInfo> paramRefList;

    cmdStr = TrimStr(cmdStr);

    //Get arguments
    ParseParams(cmdStr, paramStrList, ",");

    //Check argument # against parameter #
    if(paramStrList.size() != 1)
    {
        errorMsg = "Wrong number of arguments for function UPPER().";
        CompileError();
    }

    //Evaluate argument
    paramRefList.resize(1);
    EvalExpression(paramStrList[0], paramRefList[0]);

    //Check argument type against parameter type
    if(paramRefList[0].drType != DT_STRING)
    {
        errorMsg = "Type mismatch in argument 1 of function UPPER().";
        CompileError();
    }

    //Write bytecode for function call
    currDefPtr->byteCodeList.push_back(new CCommand(IDC_Upper));

    //Fill out return reference and exit
    retDataRef.drID = DATAREF_DATASTACK;
    retDataRef.drIdx = 0;
    retDataRef.drType = DT_STRING;
}

void Func_Val(string cmdStr, CDataRefInfo& retDataRef)
//
{
    vector<string> paramStrList;
    vector<CDataRefInfo> paramRefList;

    cmdStr = TrimStr(cmdStr);

    //Get arguments
    ParseParams(cmdStr, paramStrList, ",");

    //Check argument # against parameter #
    if(paramStrList.size() != 1)
    {
        errorMsg = "Wrong number of arguments for function VAL().";
        CompileError();
    }

    //Evaluate argument
    paramRefList.resize(1);
    EvalExpression(paramStrList[0], paramRefList[0]);

    //Check argument type against parameter type
    if(paramRefList[0].drType != DT_STRING)
    {
        errorMsg = "Type mismatch in argument 1 of function VAL().";
        CompileError();
    }

    //Write bytecode for function call
    currDefPtr->byteCodeList.push_back(new CCommand(IDC_Val));

    //Fill out return reference and exit
    retDataRef.drID = DATAREF_DATASTACK;
    retDataRef.drIdx = 0;
    retDataRef.drType = DT_NUMBER;
}


