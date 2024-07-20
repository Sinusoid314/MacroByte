#ifdef _COMPONENT_DEBUGGER

#include <cstdlib>
#include <string>
#include <vector>
#include <windows.h>
#include "..\basic_tags.h"
#include "runtime_main.h"
#include "runtime_debug.h"

using namespace std;

HANDLE debugInBreakpoint;
HWND hDebugWin;
HWND hDebugCodeView;
HWND hDebugStepBtn;

bool DebugSetup(void)
//Create debugging window class, create & display
//debugging window
{
    char szClassName[ ] = "MacroByteDebugConsol";
    HINSTANCE hThisInstance = (HINSTANCE) GetModuleHandle(NULL);
    WNDCLASSEX wincl;
    int tmpWidth = int(GetSystemMetrics(SM_CXSCREEN) / 1.9);
    int tmpHeight = int(GetSystemMetrics(SM_CYSCREEN) / 1.6);
    int tmpX = int((GetSystemMetrics(SM_CXSCREEN) - tmpWidth) / 2.5);
    int tmpY = int((GetSystemMetrics(SM_CYSCREEN) - tmpHeight) / 2.5);

    /* The Window structure */
    wincl.hInstance = hThisInstance;
    wincl.lpszClassName = szClassName;
    wincl.lpfnWndProc = DebugWinProc;      /* This function is called by windows */
    wincl.style = CS_DBLCLKS;                 /* Catch double-clicks */
    wincl.cbSize = sizeof (WNDCLASSEX);

    /* Use default icon and mouse-pointer */
    wincl.hIcon = LoadIcon (NULL, IDI_APPLICATION);
    wincl.hIconSm = LoadIcon (NULL, IDI_APPLICATION);
    wincl.hCursor = LoadCursor (NULL, IDC_ARROW);
    wincl.lpszMenuName = NULL;                 /* No menu */
    wincl.cbClsExtra = 0;                      /* No extra bytes after the window class */
    wincl.cbWndExtra = 0;                      /* structure or the window instance */
    /* Use Windows's default color as the background of the window */
    wincl.hbrBackground = (HBRUSH) COLOR_BACKGROUND;



    /* Register the window class, and if it fails quit the program */
    if (!RegisterClassEx (&wincl))
        return false;

    /* The class is registered, let's create the program*/
    hDebugWin = CreateWindowEx (0, szClassName, "MacroByte Debugging Consol",
                                WS_OVERLAPPEDWINDOW | WS_CLIPCHILDREN,
                                tmpX, tmpY, tmpWidth, tmpHeight, HWND_DESKTOP,
                                NULL, hThisInstance, NULL);
              
    //Create breakpoint flag
    debugInBreakpoint = CreateEvent(NULL, TRUE, FALSE, NULL);



    /* Make the window visible on the screen */
    ShowWindow (hDebugWin, SW_SHOWNORMAL);

    return true;
}

void DebugCleanup(void)
//Destroy debug window and unregister
//its window class
{
    //Delete breakpoint flag
    CloseHandle(debugInBreakpoint);
    
    //Destroy debug window
    DestroyWindow(hDebugWin);
    
    //Unregister window class
    UnregisterClass("MacroByteDebugConsol",(HINSTANCE)GetModuleHandle(NULL));
}

LRESULT CALLBACK DebugWinProc(HWND hwnd, UINT message, WPARAM wParam, LPARAM lParam)
{
    MSG tmpMsg;
    RECT dispRect;
    LRESULT retVal;

    switch (message)
    {
        case WM_SIZE:
            MoveWindow(hDebugCodeView, 0, 0, LOWORD(lParam), HIWORD(lParam)-50, TRUE);
            MoveWindow(hDebugStepBtn, 10, HIWORD(lParam)-45, 75, 35, TRUE);
            retVal = TRUE;
            break;

        case WM_CREATE:
            hDebugCodeView = CreateWindowEx(0, "LISTBOX", "",
                                            WS_VISIBLE|WS_CHILD|WS_BORDER|
                                            WS_VSCROLL|WS_HSCROLL,
                                            0, 0, 0, 0, hwnd, NULL,
                                            (HINSTANCE) GetModuleHandle(NULL), NULL);
            hDebugStepBtn = CreateWindowEx(0, "BUTTON", "Step",
                                            WS_VISIBLE|WS_CHILD,
                                            0, 0, 0, 0, hwnd, NULL,
                                            (HINSTANCE) GetModuleHandle(NULL), NULL);
            retVal = 0;
            break;
            
        case WM_COMMAND:
            if((HWND)lParam == hDebugStepBtn)
            {
                //MessageBox(NULL, "Step to next command", "Debug", MB_OK | MB_SETFOREGROUND);
                ResetEvent(debugInBreakpoint);
                retVal = 0;
            }
            else
            {
                retVal = DefWindowProc (hwnd, message, wParam, lParam);
            }
            break;

        case WM_CLOSE:
            //Set asyncExitFlag to TRUE
            SetEvent(asyncExitFlag);
            
            //Wait for hRtThread to finish running with WaitForSingleObject()
            while(WaitForSingleObject(hRtThread, 0) != WAIT_OBJECT_0)
            {                
                Sleep(1);
            }
            
            //Signal main message loop to exit
            PostQuitMessage(0);

            retVal = 0;
            break;
            
        case MBWM_RUN_THREAD_DONE:
            SetWindowText(hDebugWin, "Execution Complete - MacroByte Debugger");
            retVal = 0;
            break;
            
        default:
            retVal = DefWindowProc (hwnd, message, wParam, lParam);
            break;
    }

    return retVal;
}

#endif
