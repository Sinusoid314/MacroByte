#include <cstdlib>
#include <limits.h>
#include <time.h>
#include <string>
#include <vector>
#include <deque>
#include <windows.h>
#include "..\..\..\[Libraries]\File IO\FileIO.h"
#include "..\basic_tags.h"
#include "..\basic_def.h"
#include "runtime_main.h"
#include "runtime_loader.h"
#include "runtime_data.h"
#include "runtime_cmd.h"
#include "runtime_cui.h"
#include "runtime_debug.h"
#include "runtime_fileIO.h"

using namespace std;

HANDLE asyncExitFlag;
bool errorFlag;
string errorMsg;
int errorSubProgIdx;

HANDLE hRtThread;
DWORD idRtThread;


int WINAPI WinMain (HINSTANCE hThisInstance, HINSTANCE hPrevInstance, LPSTR lpszArgument, int dispFlag)
//Main program entry point
{
    MSG messages;            /* Here messages to the application are saved */

    //Load main program data
    if(!WinSetup()) return 0;

    //Launch main runtime thread
    hRtThread = CreateThread(NULL, 0, RuntimeMain, (LPVOID) 0, 0, &idRtThread);

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
  #ifdef _COMPONENT_DEBUGGER
    //Create debug window
    if(!DebugSetup()) return false;
  #endif

    //Create console window
    if(!ConsoleSetup()) return false;

    //Create runtime-completion flag
    asyncExitFlag = CreateEvent(NULL, TRUE, FALSE, NULL);

    return true;
}

void WinCleanup(void)
//Unload main program data
{
    //Delete runtime-completion flag
    CloseHandle(asyncExitFlag);

    //Destroy console window
    ConsoleCleanup();

  #ifdef _COMPONENT_DEBUGGER
    //Destroy debug window
    DebugCleanup();
  #endif
}

DWORD WINAPI RuntimeMain(LPVOID rttParam)
//Setup and execute runtime code
{
    //Load runtime data
    RuntimeSetup();

    //Run main subprogram
    LoadSubProg(0);

    spList.front()->RunProg();

  #ifdef _COMPONENT_DEBUGGER
    //Make sure the selected item of hDebugCodeView is
    //the current breakpoint line of the main subprog
    PostMessage( hDebugCodeView, LB_SETCURSEL, (WPARAM)spList.front()->debugCurrBreakpointLine, 0 );
  #endif

    UnloadSubProg();

    //Unload runtime data
    RuntimeCleanup();

  #ifdef _COMPONENT_DEBUGGER
    //Signal the Debug window that program execution has finished
    PostMessage(hDebugWin, MBWM_RUN_THREAD_DONE, 0, 0);
  #else
    //Signal the Console window that program execution has finished
    PostMessage(hConsoleWin, MBWM_RUN_THREAD_DONE, 0, 0);
  #endif

    return (DWORD)1;
}

void RuntimeSetup(void)
//Load runtime data
{
    //Set up runtime-error variables
    errorFlag = false;
    errorMsg = "";
    errorSubProgIdx = 0;

    //Load the runtime file code/subprog defs/memory allocs/resources
    LoadRunFile();
}

void RuntimeCleanup(void)
//Unload runtime data
{
    for(int n=0; n<spList.size(); n++)
    {
        delete spList[n];
    }
    spList.clear();

    for(int n=0; n<fileList.size(); n++)
    {
        delete fileList[n];
    }
    fileList.clear();

    for(int n=0; n<LiteralList.size(); n++)
    {
        delete LiteralList[n];
    }
    LiteralList.clear();

    for(int n=0; n<spDefList.size(); n++)
    {
        delete spDefList[n];
    }
    spDefList.clear();

    ArrayIdxStack.clear();

    for(int n=0; n<DataStack.size(); n++)
    {
        delete DataStack[n];
    }
    DataStack.clear();
}

void RuntimeError(void)
//Display the given error message or, if
//errorSubProgIdx is not zero, call the
//subroutine with the error message as an argument.
//Then end the runtime process.
{
    string msgStr;

    //The error handler had an error (D'OH!)
    if(errorFlag)
    {
        MessageBoxA(NULL, "The error subroutine failed to run correctly.", "MacroByteRT", MB_OK | MB_ICONERROR | MB_SETFOREGROUND);
        ExitProcess(0);
    }

    errorFlag = true;

    if(errorSubProgIdx > 0)
    {
        //Load errorMsg onto DataStack
        if(spDefList[errorSubProgIdx]->paramNum == 1)
        {
            PushDataCell(new CDataCell(DT_STRING, (void*)errorMsg.c_str(), errorMsg.length()+1));
        }
        //Run error subprog
        LoadSubProg(errorSubProgIdx);
        spList.back()->RunProg();
        UnloadSubProg();
    }
    else
    {
        //Compose proper error message
        msgStr = errorMsg;
        errorMsg = "Something unexpected has happened and I can't go on:";
        errorMsg += "\r\n\r\n";
        errorMsg += "    "; errorMsg += msgStr;
        errorMsg += "\r\n\r\n";
        errorMsg += "Awfully sorry about that. Please don't blame yourself.";

        MessageBoxA(NULL, errorMsg.c_str(), "MacroByteRT", MB_OK | MB_ICONERROR | MB_SETFOREGROUND);
    }

    //GET THE HELL OOT OF HERE!!!
    ExitProcess(0);
}

unsigned time_seed()
{
  time_t now = time ( 0 );
  unsigned char *p = (unsigned char *)&now;
  unsigned seed = 0;
  size_t i;

  for ( i = 0; i < sizeof now; i++ )
    {seed = seed * ( UCHAR_MAX + 2U ) + p[i];}

  return seed;
}


