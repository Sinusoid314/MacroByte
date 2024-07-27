#include <cstdlib>
#include <sstream>
#include <string>
#include <vector>
#include <deque>
#include <math.h>
#include <windows.h>
#include "..\..\..\[Libraries]\String Extension\stringExt.h"
#include "..\..\..\[Libraries]\File IO\FileIO.h"
#include "..\basic_tags.h"
#include "..\basic_def.h"
#include "runtime_main.h"
#include "runtime_data.h"
#include "runtime_cmd.h"
#include "runtime_cui.h"
#include "runtime_debug.h"
#include "runtime_fileIO.h"

using namespace std;

//Initialize array of pointers to Command functions
void (CSubProg::*cmdPtrList[80])() = {NULL,
                                      &CSubProg::Cmd_AddData,
                                      &CSubProg::Cmd_RemoveData,
                                      &CSubProg::Cmd_ClearDataStack,
                                      &CSubProg::Cmd_CopyData,
                                      &CSubProg::Cmd_CallSubProg,
                                      &CSubProg::Cmd_ADD,
                                      &CSubProg::Cmd_SUB,
                                      &CSubProg::Cmd_DIV,
                                      &CSubProg::Cmd_MUL,
                                      &CSubProg::Cmd_MOD,
                                      &CSubProg::Cmd_EXP,
                                      &CSubProg::Cmd_STRCON,
                                      &CSubProg::Cmd_EQUAL,
                                      &CSubProg::Cmd_LESS,
                                      &CSubProg::Cmd_GREATER,
                                      &CSubProg::Cmd_LESSOREQUAL,
                                      &CSubProg::Cmd_GREATEROREQUAL,
                                      &CSubProg::Cmd_NOTEQUAL,
                                      &CSubProg::Cmd_LAND,
                                      &CSubProg::Cmd_LOR,
                                      &CSubProg::Cmd_LXOR,
                                      &CSubProg::Cmd_BAND,
                                      &CSubProg::Cmd_BOR,
                                      &CSubProg::Cmd_BXOR,
                                      &CSubProg::Cmd_Label,
                                      &CSubProg::Cmd_ArrayIdx,
                                      &CSubProg::Cmd_Goto,
                                      &CSubProg::Cmd_Gosub,
                                      &CSubProg::Cmd_Return,
                                      &CSubProg::Cmd_If,
                                      &CSubProg::Cmd_PrintToConsole,
                                      &CSubProg::Cmd_InputFromConsole,
                                      &CSubProg::Cmd_ShowConsole,
                                      &CSubProg::Cmd_HideConsole,
                                      &CSubProg::Cmd_PrintBlank,
                                      &CSubProg::Cmd_For,
                                      &CSubProg::Cmd_ClearConsole,
                                      &CSubProg::Cmd_InputEvents,
                                      &CSubProg::Cmd_FlushEvents,
                                      &CSubProg::Cmd_Pause,
                                      &CSubProg::Cmd_End,
                                      &CSubProg::Cmd_Message,
                                      &CSubProg::Cmd_OpenFile,
                                      &CSubProg::Cmd_CloseFile,
                                      &CSubProg::Cmd_PrintToFile,
                                      &CSubProg::Cmd_InputFieldFromFile,
                                      &CSubProg::Cmd_InputLineFromFile,
                                      &CSubProg::Cmd_InputBytesFromFile,
                                      &CSubProg::Cmd_SetFilePos,
                                      &CSubProg::Cmd_GetFilePos,
                                      &CSubProg::Cmd_FileLength,
                                      &CSubProg::Cmd_EndOfFile,
                                      &CSubProg::Cmd_Str,
                                      &CSubProg::Cmd_Int,
                                      &CSubProg::Cmd_Rnd,
                                      &CSubProg::Cmd_Val,
                                      &CSubProg::Cmd_Chr,
                                      &CSubProg::Cmd_Asc,
                                      &CSubProg::Cmd_Abs,
                                      &CSubProg::Cmd_Not,
                                      &CSubProg::Cmd_Len,
                                      &CSubProg::Cmd_Upper,
                                      &CSubProg::Cmd_Lower,
                                      &CSubProg::Cmd_LTrim,
                                      &CSubProg::Cmd_RTrim,
                                      &CSubProg::Cmd_Trim,
                                      &CSubProg::Cmd_Left,
                                      &CSubProg::Cmd_Mid,
                                      &CSubProg::Cmd_Right,
                                      &CSubProg::Cmd_OnError,
                                      &CSubProg::Cmd_Redim,
                                      &CSubProg::Cmd_ConsoleTitle,
                                      &CSubProg::Cmd_RedimAdd,
                                      &CSubProg::Cmd_RedimRemove,
                                      &CSubProg::Cmd_While,
                                      &CSubProg::Cmd_ExitFor,
                                      &CSubProg::Cmd_ExitWhile,
                                      &CSubProg::Cmd_ExitSubProg,
                                      &CSubProg::Cmd_DebugBreakpoint
};

vector<CSubProg*> spList;

void LoadSubProg(int spdIdx)
//Load a subprogram definition onto the top of spList
{
    spList.push_back(new CSubProg);
	spList.back()->Initialize( spDefList[spdIdx] );
}

void UnloadSubProg(void)
//Remove subprog reference from top of spList
//and delete subprog object
{
    delete spList.back();
    spList.pop_back();
}

CSubProg::CSubProg(void)
//
{
    spDefPtr = NULL;
    currCodeLine = 0;
    debugCurrBreakpointLine = 0;
}

CSubProg::~CSubProg(void)
//Unload all subprog data
{
    for(int n=0; n < varList.size(); n++)
    {
        delete varList[n];
    }
    varList.clear();

    for(int n=0; n < arrayList.size(); n++)
    {
        delete arrayList[n];
    }
    arrayList.clear();

    blockStack.clear();
}

void CSubProg::Initialize(CSubProgDef* spdObj)
//Load all subprog data
{
    //Set subprog's definition pointer
    spDefPtr = spdObj;

    //Load (non-parameter) variables
    varList.resize(spDefPtr->varTypeList.size());
    for(int n = spDefPtr->paramNum; n < spDefPtr->varTypeList.size(); n++)
    {
        varList[n] = new CDataCell(spDefPtr->varTypeList[n], NULL, 0);
    }

    //Load arrays
    arrayList.resize(spDefPtr->arrayDefList.size());
    for(int n=0; n < spDefPtr->arrayDefList.size(); n++)
    {
        arrayList[n] = new CArray;
        arrayList[n]->Initialize( spDefPtr->arrayDefList[n] );
    }

    //Load parameter values from the stack into variable list
    for(int n=0; n < spDefPtr->paramNum; n++)
    {
        varList[n] = PopDataCell();
    }
}

void CSubProg::AddCodeBlock(int blockID)
//Add blockID to top of blockStack
{
    blockStack.insert(blockStack.begin(), blockID);
}

void CSubProg::RemoveCodeBlock(void)
//Remove top item of blockStack
{
    blockStack.erase(blockStack.begin());
}

bool CSubProg::SetBlockToExit(int blockID)
//Set entries of blockStack to IDBLOCK_VOID up
//to and including the first occurence of blockID
//and returns FALSE if not found
{
    int tmpID;

    for(int n=0; n < blockStack.size(); n++)
    {
        tmpID = blockStack[n];
        blockStack[n] = IDBLOCK_VOID;
        if(tmpID == blockID) {return true;}
    }

    return false;
}

bool CSubProg::RunCodeBlock(int startLine, int endLine, int resetLine, bool exitOnGoto)
//Run the section of code starting from startLine
//to endLine, then reset currCodeLine to resetLine and
//return TRUE if code block was run without exiting early
{
    bool isComplete;

    //Assume loop will complete without exiting early
    isComplete = true;

    //Run selected code block
    for(currCodeLine=startLine; currCodeLine <= endLine; currCodeLine++)
    {
        //Run bytecode command at currCodeLine
        (this->*cmdPtrList[spDefPtr->byteCodeList[currCodeLine]->argList[0]])();

        //Check early exit conditions
        if(WaitForSingleObject(asyncExitFlag, 0) == WAIT_OBJECT_0)
            {isComplete = false; break;}
        if(blockStack[0] == IDBLOCK_VOID)
            {isComplete = false; break;}
        if(exitOnGoto)
        {
            if((currCodeLine < (startLine - 1)) || (currCodeLine > endLine))
            {
                resetLine = currCodeLine;
                isComplete = false;
                break;
            }
        }
    }

    //Reset currCodeLine
    if(resetLine > 0)
        {currCodeLine = resetLine;}

    return isComplete;
}



void CSubProg::RunProg(void)
//Start execution of subprogram code
{
    //Add block entry
    AddCodeBlock(IDBLOCK_ROOT);

    //Run subprogram bytecode
    RunCodeBlock(0, spDefPtr->byteCodeList.size() - 1, 0, false);

    //Remove block entry
    RemoveCodeBlock();

    //Place return value on data stack (if function)
    if(spDefPtr->isFunc)
    {
        PushDataCell(varList[spDefPtr->paramNum]);
        varList[spDefPtr->paramNum] = NULL;
    }
}

void CSubProg::Cmd_AddData(void)
//
{
    CDataRef srcDatRef;

    srcDatRef.Initialize(spDefPtr->byteCodeList[currCodeLine]->argList[1],
                         spDefPtr->byteCodeList[currCodeLine]->argList[2]);

    PushDataCell(new CDataCell(srcDatRef.dataCellPtr->dataType,
                               srcDatRef.dataCellPtr->dataPtr,
                               srcDatRef.dataCellPtr->dataSize));
}

void CSubProg::Cmd_RemoveData(void)
//
{
    delete PopDataCell();
}

void CSubProg::Cmd_ClearDataStack(void)
//
{
    for(int n=0; n<DataStack.size(); n++)
    {
        delete DataStack[n];
    }
    DataStack.clear();
}

void CSubProg::Cmd_CopyData(void)
//Copy raw data from the data stack to the specified data-cell
{
    CDataRef destDatRef;
    CDataCell* srcDatPtr;

    destDatRef.Initialize(spDefPtr->byteCodeList[currCodeLine]->argList[1],
                          spDefPtr->byteCodeList[currCodeLine]->argList[2]);
    srcDatPtr = DataStack[0];

    destDatRef.SetCellData(srcDatPtr->dataType,
                           srcDatPtr->dataPtr,
                           srcDatPtr->dataSize);

    delete PopDataCell();
}

void CSubProg::Cmd_CallSubProg(void)
//
{
    LoadSubProg(spDefPtr->byteCodeList[currCodeLine]->argList[1]);
    spList.back()->RunProg();
    UnloadSubProg();
}

void CSubProg::Cmd_ADD(void)
//
{
    if(DataStack.size() < 2)
    {
        //ERROR
        errorMsg = "Not enough operands on the data stack for ADD.";
		RuntimeError();
    }
    DataStack[1]->Op_Add(DataStack[0], DataStack[1]);
    delete PopDataCell();
}

void CSubProg::Cmd_SUB(void)
//
{
    if(DataStack.size() < 2)
    {
        //ERROR
        errorMsg = "Not enough operands on the data stack for SUB.";
		RuntimeError();
    }
    DataStack[1]->Op_Subtract(DataStack[0], DataStack[1]);
    delete PopDataCell();
}

void CSubProg::Cmd_DIV(void)
//
{
    if(DataStack.size() < 2)
    {
        //ERROR
        errorMsg = "Not enough operands on the data stack for DIV.";
		RuntimeError();
    }
    DataStack[1]->Op_Divide(DataStack[0], DataStack[1]);
    delete PopDataCell();
}

void CSubProg::Cmd_MUL(void)
//
{
    if(DataStack.size() < 2)
    {
        //ERROR
        errorMsg = "Not enough operands on the data stack for MUL.";
		RuntimeError();
    }
    DataStack[1]->Op_Multiply(DataStack[0], DataStack[1]);
    delete PopDataCell();
}

void CSubProg::Cmd_MOD(void)
//
{
    if(DataStack.size() < 2)
    {
        //ERROR
        errorMsg = "Not enough operands on the data stack for MOD.";
		RuntimeError();
    }
    DataStack[1]->Op_Mod(DataStack[0], DataStack[1]);
    delete PopDataCell();
}

void CSubProg::Cmd_EXP(void)
//
{
    if(DataStack.size() < 2)
    {
        //ERROR
        errorMsg = "Not enough operands on the data stack for EXP.";
		RuntimeError();
    }
    DataStack[1]->Op_Exp(DataStack[0], DataStack[1]);
    delete PopDataCell();
}

void CSubProg::Cmd_STRCON(void)
//
{
    if(DataStack.size() < 2)
    {
        //ERROR
        errorMsg = "Not enough operands on the data stack for STRCON.";
		RuntimeError();
    }
    DataStack[1]->Op_Add(DataStack[0], DataStack[1]);
    delete PopDataCell();
}

void CSubProg::Cmd_EQUAL(void)
//
{
    if(DataStack.size() < 2)
    {
        //ERROR
        errorMsg = "Not enough operands on the data stack for EQUAL.";
		RuntimeError();
    }
    DataStack[1]->Op_Equal(DataStack[0], DataStack[1]);
    delete PopDataCell();
}

void CSubProg::Cmd_LESS(void)
//
{
    if(DataStack.size() < 2)
    {
        //ERROR
        errorMsg = "Not enough operands on the data stack for LESS.";
		RuntimeError();
    }
    DataStack[1]->Op_Less(DataStack[0], DataStack[1]);
    delete PopDataCell();
}

void CSubProg::Cmd_GREATER(void)
//
{
    if(DataStack.size() < 2)
    {
        //ERROR
        errorMsg = "Not enough operands on the data stack for GREATER.";
		RuntimeError();
    }
    DataStack[1]->Op_Greater(DataStack[0], DataStack[1]);
    delete PopDataCell();
}

void CSubProg::Cmd_LESSOREQUAL(void)
//
{
    if(DataStack.size() < 2)
    {
        //ERROR
        errorMsg = "Not enough operands on the data stack for LESSOREQUAL.";
		RuntimeError();
    }
    DataStack[1]->Op_LessOrEqual(DataStack[0], DataStack[1]);
    delete PopDataCell();
}

void CSubProg::Cmd_GREATEROREQUAL(void)
//
{
    if(DataStack.size() < 2)
    {
        //ERROR
        errorMsg = "Not enough operands on the data stack for GREATEROREQUAL.";
		RuntimeError();
    }
    DataStack[1]->Op_GreaterOrEqual(DataStack[0], DataStack[1]);
    delete PopDataCell();
}

void CSubProg::Cmd_NOTEQUAL(void)
//
{
    if(DataStack.size() < 2)
    {
        //ERROR
        errorMsg = "Not enough operands on the data stack for NOTEQUAL.";
		RuntimeError();
    }
    DataStack[1]->Op_NotEqual(DataStack[0], DataStack[1]);
    delete PopDataCell();
}

void CSubProg::Cmd_LAND(void)
//
{
    if(DataStack.size() < 2)
    {
        //ERROR
        errorMsg = "Not enough operands on the data stack for LAND.";
		RuntimeError();
    }
    DataStack[1]->Op_LogicalAND(DataStack[0], DataStack[1]);
    delete PopDataCell();
}

void CSubProg::Cmd_LOR(void)
//
{
    if(DataStack.size() < 2)
    {
        //ERROR
        errorMsg = "Not enough operands on the data stack for LOR.";
		RuntimeError();
    }
    DataStack[1]->Op_LogicalOR(DataStack[0], DataStack[1]);
    delete PopDataCell();
}

void CSubProg::Cmd_LXOR(void)
//
{
    if(DataStack.size() < 2)
    {
        //ERROR
        errorMsg = "Not enough operands on the data stack for LXOR.";
		RuntimeError();
    }
    DataStack[1]->Op_LogicalXOR(DataStack[0], DataStack[1]);
    delete PopDataCell();
}

void CSubProg::Cmd_BAND(void)
//
{
    if(DataStack.size() < 2)
    {
        //ERROR
        errorMsg = "Not enough operands on the data stack for BAND.";
		RuntimeError();
    }
    DataStack[1]->Op_BitwiseAND(DataStack[0], DataStack[1]);
    delete PopDataCell();
}

void CSubProg::Cmd_BOR(void)
//
{
    if(DataStack.size() < 2)
    {
        //ERROR
        errorMsg = "Not enough operands on the data stack for BOR.";
		RuntimeError();
    }
    DataStack[1]->Op_BitwiseOR(DataStack[0], DataStack[1]);
    delete PopDataCell();
}

void CSubProg::Cmd_BXOR(void)
//
{
    if(DataStack.size() < 2)
    {
        //ERROR
        errorMsg = "Not enough operands on the data stack for BXOR.";
		RuntimeError();
    }
    DataStack[1]->Op_BitwiseXOR(DataStack[0], DataStack[1]);
    delete PopDataCell();
}

void CSubProg::Cmd_Label(void)
//
{
    //NOOP
}

void CSubProg::Cmd_ArrayIdx(void)
//
{
    int indexVal;
    int indexCount;

    indexCount = spDefPtr->byteCodeList[currCodeLine]->argList[1];

    ArrayIdxStack.insert(ArrayIdxStack.begin(), indexCount, 0);

    for(int n=0; n<indexCount; n++)
    {
        indexVal = int(*((double*)DataStack[0]->dataPtr));
        delete PopDataCell();
        ArrayIdxStack[n] = indexVal;
    }
}

void CSubProg::Cmd_Goto(void)
//
{
    currCodeLine = (spDefPtr->byteCodeList[currCodeLine]->argList[1]) - 1;
}

void CSubProg::Cmd_Gosub(void)
//Run code starting at the given line number
{
    //Add code block entry
    AddCodeBlock(IDBLOCK_GOSUB);

    //Run bytecode starting at given line number
    RunCodeBlock(spDefPtr->byteCodeList[currCodeLine]->argList[1], spDefPtr->byteCodeList.size() - 1, currCodeLine, false);

    //Remove block entry
    RemoveCodeBlock();
}

void CSubProg::Cmd_Return(void)
//Exit most recent Gosub block
{
    if(!SetBlockToExit(IDBLOCK_GOSUB))
    {
        //ERROR
        errorMsg = "Return without GoSub.";
        RuntimeError();
    }
}

void CSubProg::Cmd_If(void)
//
{
    bool testRes;
    int trueBLen;
    int falseBLen;
    int ifLine;

    //Load condition and block data
    testRes = (bool)(*( (double*)(DataStack[0]->dataPtr) ));
    delete PopDataCell();
    trueBLen = spDefPtr->byteCodeList[currCodeLine]->argList[1];
    falseBLen = spDefPtr->byteCodeList[currCodeLine]->argList[2];
    ifLine = currCodeLine;

    //Add block entry
    AddCodeBlock(IDBLOCK_IF);

    //Test condition
    if( testRes )
    {
        //Run TRUE block
        RunCodeBlock(ifLine + 1, ifLine + trueBLen,
                     ifLine + trueBLen + falseBLen, true);
    }
    else
    {
        //Run FALSE block
        RunCodeBlock(ifLine + trueBLen + 1, ifLine + trueBLen + falseBLen,
                     ifLine + trueBLen + falseBLen, true);
    }

    //Remove block entry
    RemoveCodeBlock();
}

void CSubProg::Cmd_PrintToConsole(void)
//
{
    int dispTextLen;
    string outputStr;
    double tmpNum;

    if(DataStack[0]->dataType == DT_STRING)
    {
      //Get output text from top of DataStack as STRING
        outputStr = (char*)DataStack[0]->dataPtr;
    }
    else if(DataStack[0]->dataType == DT_NUMBER)
    {
      //Get output text from top of DataStack as NUMBER
        tmpNum = *((double*)(DataStack[0]->dataPtr));
        outputStr = static_cast<ostringstream*>(&(ostringstream() << tmpNum))->str();
    }
    delete PopDataCell();

  //Add outText to display
    dispTextLen = GetWindowTextLength( hConsoleDisplay );
    SendMessage( hConsoleDisplay, EM_SETSEL, (WPARAM)dispTextLen, (LPARAM)dispTextLen );
    SendMessage( hConsoleDisplay, EM_REPLACESEL, 0, (LPARAM) ((LPSTR) outputStr.c_str()) );
}

void CSubProg::Cmd_InputFromConsole(void)
//
{
    CDataRef destDatRef;
    MSG message;
    double tmpNum;

    userInput = "";
    destDatRef.Initialize(spDefPtr->byteCodeList[currCodeLine]->argList[1],
                          spDefPtr->byteCodeList[currCodeLine]->argList[2]);

    //Set inputting to TRUE
    SetEvent(inputting);

    //DoEvents message pump
    while( (WaitForSingleObject(inputting, 0) == WAIT_OBJECT_0)
           && (WaitForSingleObject(asyncExitFlag, 0) != WAIT_OBJECT_0) )
    {
        while(PeekMessage(&message, NULL, 0, 0, PM_REMOVE))
        {
            TranslateMessage(&message);
            DispatchMessage(&message);
        }
        Sleep(1);
    }

    ResetEvent(inputting);
    if(WaitForSingleObject(asyncExitFlag, 0) == WAIT_OBJECT_0)
        {return;}

    if(destDatRef.dataCellPtr->dataType == DT_STRING)
    {
        //Add userInput to destDat as STRING
        destDatRef.SetCellData(DT_STRING, (void*)userInput.c_str(), userInput.length()+1);
    }
    else if(destDatRef.dataCellPtr->dataType == DT_NUMBER)
    {
        //Add userInput to destDat as NUMBER
        tmpNum = StrToNum(userInput);
        destDatRef.SetCellData(DT_NUMBER, &tmpNum, sizeof(double));
    }
}

void CSubProg::Cmd_ShowConsole(void)
//
{
    ShowWindow(hConsoleWin, SW_SHOW);
    SetForegroundWindow(hConsoleWin);
}

void CSubProg::Cmd_HideConsole(void)
//
{
    ShowWindow(hConsoleWin, SW_HIDE);
}

void CSubProg::Cmd_PrintBlank(void)
//
{
    char outText[3] = {(char)13, (char)10, '\0'};
    int dispTextLen;

  //Add outText to display
    dispTextLen = GetWindowTextLength( hConsoleDisplay );
    SendMessage( hConsoleDisplay, EM_SETSEL, (WPARAM)dispTextLen, (LPARAM)dispTextLen );
    SendMessage( hConsoleDisplay, EM_REPLACESEL, 0, (LPARAM) ((LPSTR) outText) );

    //SendMessage(hConsoleDisplay, EM_SETSEL, dispTextLen-1, dispTextLen-1);
    //SendMessage(hConsoleDisplay, EM_SCROLLCARET, 0, 0);

    //delete [] dispText;
}

void CSubProg::Cmd_For(void)
//
{
    double counter = 0;
    CDataRef counterDatRef;
    double fromVal;
    double toVal;
    double stepVal;
    int codeBLen;
    int forLine;
    int startLine;
    int endLine;
    int resetLine;

    //Load loop and block data
    fromVal = *( (double*)(DataStack[0]->dataPtr) );
      delete PopDataCell();
    toVal = *( (double*)(DataStack[0]->dataPtr) );
      delete PopDataCell();
    stepVal = *( (double*)(DataStack[0]->dataPtr) );
      delete PopDataCell();
    counterDatRef.Initialize(spDefPtr->byteCodeList[currCodeLine]->argList[1],
                             spDefPtr->byteCodeList[currCodeLine]->argList[2]);
    codeBLen = spDefPtr->byteCodeList[currCodeLine]->argList[3];
    forLine = currCodeLine;
    startLine = forLine + 1;
    endLine = forLine + codeBLen;
    resetLine = forLine + codeBLen;

    //Initialize counter to fromVal
    counter = fromVal;
    counterDatRef.SetCellData(DT_NUMBER, &counter, sizeof(double));

    //Add code block entry
    AddCodeBlock(IDBLOCK_FOR);


  loopStart:

    //Check counter against toDat
    if( stepVal < 0 )
    //Decreasing counter
    {
        if( counter <  toVal )
            {goto loopEnd;}
    }
    else
    //Increasing counter
    {
        if( counter >  toVal )
            {goto loopEnd;}
    }

    //Run loop code block
    if(!RunCodeBlock(startLine, endLine, resetLine, true))
    {
        //Code block exited without completing
        goto loopEnd;
    }

    //Add stepDat to counter
    counter = counter + stepVal;
    counterDatRef.SetCellData(DT_NUMBER, &counter, sizeof(double));

    //Jump back to loop beginning
    goto loopStart;

  loopEnd:

    //Remove code block entry
    RemoveCodeBlock();

    //Reset currCodeLine
    currCodeLine = resetLine;

    return;
}

void CSubProg::Cmd_ClearConsole(void)
//Clear text of console display
{
    SetWindowTextA(hConsoleDisplay, "");

    SendMessage(hConsoleDisplay, EM_SETSEL, 0, 0);
    SendMessage(hConsoleDisplay, EM_SCROLLCARET, 0, 0);
}

void CSubProg::Cmd_InputEvents(void)
//Process all pending messages until
//asyncExitFlag is set to TRUE
{
    MSG message;

    while(WaitForSingleObject(asyncExitFlag, 0) != WAIT_OBJECT_0)
    {
        while(PeekMessage(&message, NULL, 0, 0, PM_REMOVE))
        {
            TranslateMessage(&message);
            DispatchMessage(&message);
        }
        Sleep(1);
    }
}

void CSubProg::Cmd_FlushEvents(void)
//Process all pending messages
{
    MSG message;

    while(PeekMessage(&message, NULL, 0, 0, PM_REMOVE))
    {
        TranslateMessage(&message);
        DispatchMessage(&message);
    }
}

void CSubProg::Cmd_Pause(void)
//
{
    int pauseLen;

    //Get pause length from top of data stack
    pauseLen = (int) *((double*)(DataStack[0]->dataPtr));
    delete PopDataCell();

    //Pause for given time length
    Sleep(pauseLen);
}


void CSubProg::Cmd_End(void)
//Set asyncExitFlag to TRUE
{
    SetEvent(asyncExitFlag);
}

void CSubProg::Cmd_Message(void)
//Display a message box with given title and message
{
    string tmpMessage;
    string tmpTitle;

    tmpMessage = (char*)DataStack[0]->dataPtr;
    delete PopDataCell();
    tmpTitle = (char*)DataStack[0]->dataPtr;
    delete PopDataCell();

    MessageBoxA(NULL, tmpMessage.c_str(), tmpTitle.c_str(), MB_OK | MB_SETFOREGROUND);
}

void CSubProg::Cmd_OpenFile(void)
//Open new file with given name, type and handle
{
    //Declare variables
    string tmpName = "";
    int tmpID;
    int tmpType;

    //Get name & ID from DataStack
    tmpName = (char*)DataStack[0]->dataPtr;
    delete PopDataCell();
    tmpID = int(*((double*)DataStack[0]->dataPtr));
    delete PopDataCell();

    //Get file type from command argument #2
    tmpType = spDefPtr->byteCodeList[currCodeLine]->argList[1];

    //Open new file
    AddFile(tmpName, tmpID, tmpType);
}

void CSubProg::Cmd_CloseFile(void)
//Close file
{
    //Declare variables
    int tmpID;

    //Get file ID from DataStack
    tmpID = int(*((double*)DataStack[0]->dataPtr));
    delete PopDataCell();

    //Close file
    RemoveFile(tmpID);
}

void CSubProg::Cmd_PrintToFile(void)
//Print output string to file
{
    int fileID;
    int fileIdx;
    bool hasCR;
    string outputStr;
    double tmpNum;

    //Get boolean indicating whether or not output string should
    //be printed with it's return characters
    hasCR = (bool) spDefPtr->byteCodeList[currCodeLine]->argList[1];

    //Get file ID
    fileID = (int)*((double*)(DataStack[0]->dataPtr));
    delete PopDataCell();

    //Get output data
    if(DataStack[0]->dataType == DT_STRING)
    {
      //Get output text from top of DataStack as STRING
        outputStr = (char*)DataStack[0]->dataPtr;
    }
    else if(DataStack[0]->dataType == DT_NUMBER)
    {
      //Get output text from top of DataStack as NUMBER
        tmpNum = *((double*)(DataStack[0]->dataPtr));
        outputStr = static_cast<ostringstream*>(&(ostringstream() << tmpNum))->str();
    }
    delete PopDataCell();

    //Add line end
    if(hasCR) outputStr += "\r\n";

    //Get file object's index from ID
    if(!GetFileIndex(fileID, fileIdx))
    {
        //ERROR
        errorMsg = "File handle #" + NumToStr(fileID) + " not found.";
        RuntimeError();
    }

    //Print output string to file
    if( !(fileList[fileIdx]->Print(outputStr)) )
    {
        //ERROR
        errorMsg = fileList[fileIdx]->fileErrorStr;
        RuntimeError();
    }
}

void CSubProg::Cmd_InputFieldFromFile(void)
//Read in a field of bytes from a file
{
    int fileID;
    int fileIdx;
    CDataRef destDatRef;
    string inputStr = "";
    double tmpNum;

    //Get file ID from DataStack
    fileID = (int)*((double*)(DataStack[0]->dataPtr));
    delete PopDataCell();

    //Get destination data-cell reference from bytecode
    destDatRef.Initialize(spDefPtr->byteCodeList[currCodeLine]->argList[1],
                          spDefPtr->byteCodeList[currCodeLine]->argList[2]);

    //Get file index from ID
    if(!GetFileIndex(fileID, fileIdx))
    {
        //ERROR
        errorMsg = "File handle #" + NumToStr(fileID) + " not found.";
        RuntimeError();
    }

    //Get the next data field from file
    if( !(fileList[fileIdx]->InputField(inputStr)) )
    {
        //ERROR
        errorMsg = fileList[fileIdx]->fileErrorStr;
        RuntimeError();
    }

    if(destDatRef.dataCellPtr->dataType == DT_STRING)
    {
        //Add inputStr to destDat as STRING
        destDatRef.SetCellData(DT_STRING, (void*)inputStr.c_str(), inputStr.length()+1);
    }
    else if(destDatRef.dataCellPtr->dataType == DT_NUMBER)
    {
        //Add inputStr to destDat as NUMBER
        tmpNum = StrToNum(inputStr);
        destDatRef.SetCellData(DT_NUMBER, &tmpNum, sizeof(double));
    }
}

void CSubProg::Cmd_InputLineFromFile(void)
//Read in a line of bytes from a file
{
    int fileID;
    int fileIdx;
    CDataRef destDatRef;
    string inputStr = "";
    double tmpNum;

    //Get file handle from DataStack
    fileID = (int)*((double*)(DataStack[0]->dataPtr));
    delete PopDataCell();

    //Get destination data-cell reference from bytecode
    destDatRef.Initialize(spDefPtr->byteCodeList[currCodeLine]->argList[1],
                             spDefPtr->byteCodeList[currCodeLine]->argList[2]);

    //Get file index from handle
    if(!GetFileIndex(fileID, fileIdx))
    {
        //ERROR
        errorMsg = "File handle #" + NumToStr(fileID) + " not found.";
        RuntimeError();
    }

    //Get the next data line from file
    if( !(fileList[fileIdx]->InputLine(inputStr)) )
    {
        //ERROR
        errorMsg = fileList[fileIdx]->fileErrorStr;
        RuntimeError();
    }

    if(destDatRef.dataCellPtr->dataType == DT_STRING)
    {
        //Add inputStr to destDat as STRING
        destDatRef.SetCellData(DT_STRING, (void*)inputStr.c_str(), inputStr.length()+1);
    }
    else if(destDatRef.dataCellPtr->dataType == DT_NUMBER)
    {
        //Add inputStr to destDat as NUMBER
        tmpNum = StrToNum(inputStr);
        destDatRef.SetCellData( DT_NUMBER, &tmpNum, sizeof(double));
    }
}

void CSubProg::Cmd_InputBytesFromFile(void)
//Read in a specified number of bytes from a file
{
    int fileID;
    int fileIdx;
    int byteLen;
    string inputStr = "";

    //Get file handle from DataStack
    fileID = (int)*((double*)(DataStack[0]->dataPtr));
    delete PopDataCell();

    //Get byte length from DataStack
    byteLen = (int)*((double*)(DataStack[0]->dataPtr));
    delete PopDataCell();

    //Get file index from handle
    if(!GetFileIndex(fileID, fileIdx))
    {
        //ERROR
        errorMsg = "File handle #" + NumToStr(fileID) + " not found.";
        RuntimeError();
    }

    //Read in bytes from file
    if( !(fileList[fileIdx]->InputBytes(inputStr, byteLen)) )
    {
        //ERROR
        errorMsg = fileList[fileIdx]->fileErrorStr;
        RuntimeError();
    }

    //Add inputStr to DataStack
    PushDataCell(new CDataCell(DT_STRING, (void*)inputStr.c_str(), inputStr.length()+1));
}

void CSubProg::Cmd_SetFilePos(void)
//Set the position of a file's read/write pointer
{
    int fileID;
    int fileIdx;
    int filePos;

    //Get file handle from DataStack
    fileID = (int)*((double*)(DataStack[0]->dataPtr));
    delete PopDataCell();

    //Get new read/write position from DataStack
    filePos = (int)*((double*)(DataStack[0]->dataPtr));
    delete PopDataCell();

    //Get file index from handle
    if(!GetFileIndex(fileID, fileIdx))
    {
        //ERROR
        errorMsg = "File handle #" + NumToStr(fileID) + " not found.";
        RuntimeError();
    }

    //Set read/write position
    fileList[fileIdx]->SetFilePos(filePos);
}

void CSubProg::Cmd_GetFilePos(void)
//Get the position of a file's read/write pointer
{
    int fileID;
    int fileIdx;
    double filePos;

    //Get file handle from DataStack
    fileID = (int)*((double*)(DataStack[0]->dataPtr));
    delete PopDataCell();

    //Get file index from handle
    if(!GetFileIndex(fileID, fileIdx))
    {
        //ERROR
        errorMsg = "File handle #" + NumToStr(fileID) + " not found.";
        RuntimeError();
    }

    //Get read/write position
    filePos = (double)fileList[fileIdx]->GetFilePos();

    //Add read/write position to DataStack
    PushDataCell(new CDataCell(DT_NUMBER, &filePos, sizeof(double)));
}

void CSubProg::Cmd_FileLength(void)
//Get the number of bytes in a file
{
    int fileID;
    int fileIdx;
    double fileLen;

    //Get file handle from DataStack
    fileID = (int)*((double*)(DataStack[0]->dataPtr));
    delete PopDataCell();

    //Get file index from handle
    if(!GetFileIndex(fileID, fileIdx))
    {
        //ERROR
        errorMsg = "File handle #" + NumToStr(fileID) + " not found.";
        RuntimeError();
    }

    //Get file length
    fileLen = (double)fileList[fileIdx]->GetFileLength();

    //Add file length to DataStack
    PushDataCell(new CDataCell(DT_NUMBER, &fileLen, sizeof(double)));
}

void CSubProg::Cmd_EndOfFile(void)
//Return TRUE if a file's read/write pointer is
//at the end of the file, FALSE if not
{
    int fileID;
    int fileIdx;
    double isAtEnd;

    //Get file handle from DataStack
    fileID = (int)*((double*)(DataStack[0]->dataPtr));
    delete PopDataCell();

    //Get file index from handle
    if(!GetFileIndex(fileID, fileIdx))
    {
        //ERROR
        errorMsg = "File handle #" + NumToStr(fileID) + " not found.";
        RuntimeError();
    }

    //Get end-of-file flag
    isAtEnd = (double)fileList[fileIdx]->EndOfFile();

    //Add end-of-file flag to DataStack
    PushDataCell(new CDataCell(DT_NUMBER, &isAtEnd, sizeof(double)));
}

void CSubProg::Cmd_Str(void)
//
{
    double tmpNum;
    string strRes;

    tmpNum = *((double*)(DataStack[0]->dataPtr));
    delete PopDataCell();

    strRes = static_cast<ostringstream*>(&(ostringstream() << tmpNum))->str();

    PushDataCell(new CDataCell(DT_STRING, (void*)strRes.c_str(), strRes.length()+1));
}

void CSubProg::Cmd_Int(void)
//
{
    double numRes;
    numRes = (int)*((double*)(DataStack[0]->dataPtr));
    delete PopDataCell();
    PushDataCell(new CDataCell(DT_NUMBER, &numRes, sizeof(double)));
}

void CSubProg::Cmd_Rnd(void)
//
{
    double numRes;
    srand ( time_seed() );
    numRes = ((double)rand() / ((double)(RAND_MAX)+(double)(1)));
    PushDataCell(new CDataCell(DT_NUMBER, &numRes, sizeof(double)));
}

void CSubProg::Cmd_Val(void)
//
{
    double numRes = 0;
    string tmpStr = "";

    tmpStr = (char*)DataStack[0]->dataPtr;
    numRes = StrToNum(tmpStr);

    delete PopDataCell();
    PushDataCell(new CDataCell(DT_NUMBER, &numRes, sizeof(double)));
}

void CSubProg::Cmd_Chr(void)
//
{
    char strRes[2];
    strRes[0] = char(int(*((double*)DataStack[0]->dataPtr)));
    strRes[1] = '\0';
    delete PopDataCell();
    PushDataCell(new CDataCell(DT_STRING, &strRes, 2));
}

void CSubProg::Cmd_Asc(void)
//
{
    double numRes;
    numRes = int( ((char*)DataStack[0]->dataPtr)[0] );
    delete PopDataCell();
    PushDataCell(new CDataCell(DT_NUMBER, &numRes, sizeof(double)));
}

void CSubProg::Cmd_Abs(void)
//Return absolute value of the given number
{
    double numRes;
    numRes = fabs( *((double*)(DataStack[0]->dataPtr)) );
    delete PopDataCell();
    PushDataCell(new CDataCell(DT_NUMBER, &numRes, sizeof(double)));
}

void CSubProg::Cmd_Not(void)
//Return 1 if the given number is 0, and 0 otherwise
{
    double numRes;
    numRes = *((double*)DataStack[0]->dataPtr);

    if(numRes == 0)
        { numRes = 1; }
    else
        { numRes = 0; }

    delete PopDataCell();
    PushDataCell(new CDataCell(DT_NUMBER, &numRes, sizeof(double)));
}

void CSubProg::Cmd_Len(void)
//
{
    double numRes;
    numRes = double( DataStack[0]->dataSize - 1 );
    delete PopDataCell();
    PushDataCell(new CDataCell(DT_NUMBER, &numRes, sizeof(double)));
}

void CSubProg::Cmd_Upper(void)
//
{
    string inStr;
    string outStr;

    inStr = (char*)DataStack[0]->dataPtr;
    delete PopDataCell();

    outStr = UCaseStr(inStr);

    PushDataCell(new CDataCell(DT_STRING, (char*)outStr.c_str(), outStr.length()+1));
}

void CSubProg::Cmd_Lower(void)
//
{
    string inStr;
    string outStr;

    inStr = (char*)DataStack[0]->dataPtr;
    delete PopDataCell();

    outStr = LCaseStr(inStr);

    PushDataCell(new CDataCell(DT_STRING, (char*)outStr.c_str(), outStr.length()+1));
}

void CSubProg::Cmd_LTrim(void)
//
{
    string inStr;
    string outStr;

    inStr = (char*)DataStack[0]->dataPtr;
    delete PopDataCell();

    outStr = LTrimStr(inStr);

    PushDataCell(new CDataCell(DT_STRING, (char*)outStr.c_str(), outStr.length()+1));
}

void CSubProg::Cmd_RTrim(void)
//
{
    string inStr;
    string outStr;

    inStr = (char*)DataStack[0]->dataPtr;
    delete PopDataCell();

    outStr = RTrimStr(inStr);

    PushDataCell(new CDataCell(DT_STRING, (char*)outStr.c_str(), outStr.length()+1));
}

void CSubProg::Cmd_Trim(void)
//
{
    string inStr;
    string outStr;

    inStr = (char*)DataStack[0]->dataPtr;
    delete PopDataCell();

    outStr = TrimStr(inStr);

    PushDataCell(new CDataCell(DT_STRING, (char*)outStr.c_str(), outStr.length()+1));
}

void CSubProg::Cmd_Left(void)
//
{
    string inStr;
    string outStr;
    unsigned int cutLen;

    inStr = (char*)DataStack[0]->dataPtr;
      delete PopDataCell();
    cutLen = (unsigned int)*((double*)DataStack[0]->dataPtr);
      delete PopDataCell();

    outStr = LeftStr(inStr, cutLen);

    PushDataCell(new CDataCell(DT_STRING, (char*)outStr.c_str(), outStr.length()+1));
}

void CSubProg::Cmd_Mid(void)
//
{
    string inStr;
    string outStr;
    unsigned int cutPos;
    unsigned int cutLen;

    inStr = (char*)DataStack[0]->dataPtr;
      delete PopDataCell();
    cutPos = (unsigned int)*((double*)DataStack[0]->dataPtr);
      delete PopDataCell();
    cutLen = (unsigned int)*((double*)DataStack[0]->dataPtr);
      delete PopDataCell();

    outStr = MidStr(inStr, cutPos-1, cutLen);

    PushDataCell(new CDataCell(DT_STRING, (char*)outStr.c_str(), outStr.length()+1));
}

void CSubProg::Cmd_Right(void)
//
{
    string inStr;
    string outStr;
    unsigned int cutLen;

    inStr = (char*)DataStack[0]->dataPtr;
      delete PopDataCell();
    cutLen = (unsigned int)*((double*)DataStack[0]->dataPtr);
      delete PopDataCell();

    outStr = RightStr(inStr, cutLen);

    PushDataCell(new CDataCell(DT_STRING, (char*)outStr.c_str(), outStr.length()+1));
}

void CSubProg::Cmd_OnError(void)
//Set errorSubProgIdx to the given subprog index
{
    errorSubProgIdx = spDefPtr->byteCodeList[currCodeLine]->argList[1];
}

void CSubProg::Cmd_Redim(void)
//Resize the given array
{
    CArray* arrayPtr;
    vector<int> newDimList;

    //Get pointer to the array
    switch(spDefPtr->byteCodeList[currCodeLine]->argList[1])
    {
        case DATAREF_GLOBALARRAYITEM:
            arrayPtr = spList.front()->arrayList[spDefPtr->byteCodeList[currCodeLine]->argList[2]];
            break;
        case DATAREF_LOCALARRAYITEM:
            arrayPtr = arrayList[spDefPtr->byteCodeList[currCodeLine]->argList[2]];
            break;
        default:
            //ERROR
            errorMsg = "Unrecognized DATAREF value.";
            RuntimeError();
            break;
    }

    //Get new dimension sizes from the DataStack
    for(int n=0; n < arrayPtr->arrayDefPtr->dimSizeList.size(); n++)
    {
        newDimList.push_back( (int)*((double*)DataStack[0]->dataPtr) );
        delete PopDataCell();
    }

    //Re-dimension the array
    arrayPtr->ReDim(newDimList);

    //Cleanup
    newDimList.clear();
}

void CSubProg::Cmd_ConsoleTitle(void)
//Change the caption of the console window
{
    SetWindowTextA(hConsoleWin, (char*)DataStack[0]->dataPtr);
    delete PopDataCell();
}

void CSubProg::Cmd_RedimAdd(void)
//Add an element to the given array
{
    CArray* arrayPtr;
    CDataCell* newItemPtr;
    int beforeIdx;

    //Get pointer to the array
    switch(spDefPtr->byteCodeList[currCodeLine]->argList[1])
    {
        case DATAREF_GLOBALARRAYITEM:
            arrayPtr = spList.front()->arrayList[spDefPtr->byteCodeList[currCodeLine]->argList[2]];
            break;
        case DATAREF_LOCALARRAYITEM:
            arrayPtr = arrayList[spDefPtr->byteCodeList[currCodeLine]->argList[2]];
            break;
        default:
            //ERROR
            errorMsg = "Unrecognized DATAREF value.";
            RuntimeError();
            break;
    }

    //Get new item pointer from DataStack
    newItemPtr = PopDataCell();

    //Get beforeIdx from DataStack
    beforeIdx = (int)*((double*)DataStack[0]->dataPtr);
    delete PopDataCell();

    //Add new item to array
    arrayPtr->ReDimAdd(newItemPtr, beforeIdx);
}

void CSubProg::Cmd_RedimRemove(void)
//Remove an element from the given array
{
    CArray* arrayPtr;
    int itemIdx;

    //Get pointer to the array
    switch(spDefPtr->byteCodeList[currCodeLine]->argList[1])
    {
        case DATAREF_GLOBALARRAYITEM:
            arrayPtr = spList.front()->arrayList[spDefPtr->byteCodeList[currCodeLine]->argList[2]];
            break;
        case DATAREF_LOCALARRAYITEM:
            arrayPtr = arrayList[spDefPtr->byteCodeList[currCodeLine]->argList[2]];
            break;
        default:
            //ERROR
            errorMsg = "Unrecognized DATAREF value.";
            RuntimeError();
            break;
    }

    //Get itemIdx from DataStack
    itemIdx = (int)*((double*)DataStack[0]->dataPtr);
    delete PopDataCell();

    //Remove item from array
    arrayPtr->ReDimRemove(itemIdx);
}

void CSubProg::Cmd_While(void)
//Execute the specified section of bytecode until
//result of test expression is zero
{
    bool testRes;
    int testBLen;
    int codeBLen;
    int whileLine;
    int testStartLine;
    int testEndLine;
    int codeStartLine;
    int codeEndLine;
    int resetLine;

    testBLen = spDefPtr->byteCodeList[currCodeLine]->argList[1];
    codeBLen = spDefPtr->byteCodeList[currCodeLine]->argList[2];
    whileLine = currCodeLine;
    testStartLine = whileLine + 1;
    testEndLine = whileLine + testBLen;
    codeStartLine = whileLine + testBLen + 1;
    codeEndLine = whileLine + testBLen + codeBLen;
    resetLine = codeEndLine;

    //Add code block entry
    AddCodeBlock(IDBLOCK_WHILE);

  whileTest:

    //Run testBlock bytecode
    if(!RunCodeBlock(testStartLine, testEndLine, resetLine, false))
    {
        //Code block exited without completing
        goto whileDone;
    }

    //Extract test result value from top of DataStack
    testRes = (bool)*((double*)DataStack[0]->dataPtr);
    delete PopDataCell();

    //If test result is zero, GoTo WhileDone
    if(!testRes) goto whileDone;

    //Run codeBlock bytecode
    if(!RunCodeBlock(codeStartLine, codeEndLine, resetLine, true))
    {
        //Code block exited without completing
        goto whileDone;
    }

    goto whileTest;

  whileDone:

    //Remove code block entry
    RemoveCodeBlock();

    //Reset currCodeLine
    currCodeLine = resetLine;

    return;
}

void CSubProg::Cmd_ExitFor()
//Exit most recent For block
{
    if(!SetBlockToExit(IDBLOCK_FOR))
    {
        //ERROR
        errorMsg = "Exit For outside of For loop.";
        RuntimeError();
    }
}

void CSubProg::Cmd_ExitWhile()
//Exit most recent While block
{
    if(!SetBlockToExit(IDBLOCK_WHILE))
    {
        //ERROR
        errorMsg = "Exit While outside of While loop.";
        RuntimeError();
    }
}

void CSubProg::Cmd_ExitSubProg()
//Exit current subprogram
{
    SetBlockToExit(IDBLOCK_ROOT);
}

void CSubProg::Cmd_DebugBreakpoint(void)
//Update debugger window and wait
//for breakpoint flag to be unsignaled
{
#ifdef _COMPONENT_DEBUGGER
    MSG message;
    int sourceLineIdx;

    //Get debug source-code line number
    sourceLineIdx = spDefPtr->byteCodeList[currCodeLine]->argList[1];

    //Update debugger window displays
    SendMessage( hDebugCodeView, LB_SETCURSEL, (WPARAM)sourceLineIdx, 0 );

    //Set the current subprog's debug breakpoint line to sourceLineIdx.
    debugCurrBreakpointLine = sourceLineIdx;

    //Set debugInBreakpoint to TRUE
    SetEvent(debugInBreakpoint);

    //Wait for either debugInBreakPoint to be FALSE, or asyncExitFlag to be TRUE
    while( (WaitForSingleObject(debugInBreakpoint, 0) == WAIT_OBJECT_0)
           && (WaitForSingleObject(asyncExitFlag, 0) != WAIT_OBJECT_0) )
    {
        while(PeekMessage(&message, NULL, 0, 0, PM_REMOVE))
        {
            TranslateMessage(&message);
            DispatchMessage(&message);
        }
        Sleep(1);
    }

    //Set debugInBreakPoint to FALSE
    ResetEvent(debugInBreakpoint);
#endif
}




