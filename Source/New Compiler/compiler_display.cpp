#define _WIN32_IE 0x0300 //For commctrl.h
#include <cstdlib>
#include <string>
#include <vector>
#include <deque>
#include <windows.h>
#include <commctrl.h>
#include "..\basic_tags.h"
#include "..\basic_def.h"
#include "compiler_main.h"
#include "compiler_display.h"

using namespace std;

const char* dispWndClassName = "MacroByteCompilerDisplay";

HWND hDispWin;
HWND hDispCancelBtn;
HWND hDispStatus;
HWND hDispProgress;


bool DisplaySetup(void)
//Create display window class, create & show
//display window
{
    HINSTANCE hThisInstance = (HINSTANCE) GetModuleHandle(NULL);
    WNDCLASSEXA wincl;
    int tmpWidth = int(GetSystemMetrics(SM_CXSCREEN) / 2.5);
    int tmpHeight = int(GetSystemMetrics(SM_CYSCREEN) / 3.5);
    int tmpX = (GetSystemMetrics(SM_CXSCREEN) - tmpWidth) / 2;
    int tmpY = (GetSystemMetrics(SM_CYSCREEN) - tmpHeight) / 2;
    INITCOMMONCONTROLSEX InitCtrlEx;

    /* The Window structure */
    wincl.hInstance = hThisInstance;
    wincl.lpszClassName = dispWndClassName;
    wincl.lpfnWndProc = DisplayWinProc;      /* This function is called by windows */
    wincl.style = CS_DBLCLKS;                 /* Catch double-clicks */
    wincl.cbSize = sizeof (WNDCLASSEX);

    /* Use default icon and mouse-pointer */
    wincl.hIcon = LoadIcon (NULL, IDI_APPLICATION);
    wincl.hIconSm = LoadIcon (NULL, IDI_APPLICATION);
    wincl.hCursor = LoadCursor (NULL, IDC_ARROW);
    wincl.lpszMenuName = NULL;                 /* No menu */
    wincl.cbClsExtra = 0;                      /* No extra bytes after the window class */
    wincl.cbWndExtra = 0;                      /* structure or the window instance */
    wincl.hbrBackground = (HBRUSH) COLOR_WINDOWFRAME;

    //Initialize common controls
    InitCtrlEx.dwSize = sizeof(INITCOMMONCONTROLSEX);
	InitCtrlEx.dwICC  = ICC_PROGRESS_CLASS;
	InitCommonControlsEx(&InitCtrlEx);

    /* Register the window class, and if it fails quit the program */
    if (!RegisterClassExA(&wincl))
        return false;

    //Create the display window
    hDispWin = CreateWindowExA(0,dispWndClassName, "Compile Prograss",
                                WS_OVERLAPPED | WS_CAPTION | WS_SYSMENU | WS_DLGFRAME | WS_MINIMIZEBOX| WS_VISIBLE,
                                tmpX, tmpY, tmpWidth, tmpHeight, HWND_DESKTOP, NULL, hThisInstance, NULL);

    return true;
}

void DisplayCleanup(void)
//Destroy display window and unregister
//its window class
{
    //Destroy display window
    DestroyWindow(hDispWin);
    
    //Unregister window class
    UnregisterClassA(dispWndClassName,(HINSTANCE)GetModuleHandle(NULL));   
}

LRESULT CALLBACK DisplayWinProc(HWND hwnd, UINT message, WPARAM wParam, LPARAM lParam)
{
    int parentWidth;
    int parentHeight;
    
    switch (message)
    {
        case WM_CREATE:
            //Create status label, progress bar, and cancel button
            hDispCancelBtn = CreateWindowExA(0, "BUTTON", "Cancel", WS_VISIBLE|WS_CHILD,
                                            1, 1, 1, 1, hwnd, NULL,
                                            (HINSTANCE) GetModuleHandle(NULL), NULL);
            hDispStatus = CreateWindowExA(0, "STATIC", "Compiling some stuff...", WS_VISIBLE|WS_CHILD|SS_CENTER,
                                            1, 1, 1, 1, hwnd, NULL,
                                            (HINSTANCE) GetModuleHandle(NULL), NULL);
            hDispProgress = CreateWindowExA(0, (LPCSTR)PROGRESS_CLASS, "", WS_VISIBLE|WS_CHILD|PBS_SMOOTH,
                                            1, 1, 1, 1, hwnd, NULL,
                                            (HINSTANCE) GetModuleHandle(NULL), NULL);
            break;
        
        case WM_SIZE:
            parentWidth = LOWORD(lParam);
            parentHeight = HIWORD(lParam);
            MoveWindow(hDispCancelBtn, 0.4*parentWidth, 0.71*parentHeight, 0.2*parentWidth, 0.21*parentHeight, TRUE);
            MoveWindow(hDispStatus, 0.03*parentWidth, 0.11*parentHeight, 0.94*parentWidth, 0.21*parentHeight, TRUE);
            MoveWindow(hDispProgress, 0.03*parentWidth, 0.46*parentHeight, 0.94*parentWidth, 0.18*parentHeight, TRUE);
            break;
            
        case WM_COMMAND:
            //Handle cancel button click by sending WM_CLOSE
            if(HIWORD(wParam) == BN_CLICKED)
            {
                if((HWND)lParam == hDispCancelBtn)
                {
                    EnableWindow(hDispCancelBtn, FALSE);
                    SendMessage(hDispWin, WM_CLOSE, 0, 0);
                }
            }
            break;

        case WM_CLOSE:
            //Set asyncExitFlag to TRUE
            SetEvent(asyncExitFlag);
            break;
        
        case MBWM_COMPILE_THREAD_DONE:
            //Make sure the compiler thread has finished
            //before quitting the program
            while(WaitForSingleObject(hCompThread, 0) != WAIT_OBJECT_0)
            {                
                Sleep(1);
            }
            PostQuitMessage(0);
            break;
        
        default:                      /* for messages that we don't deal with */
            return DefWindowProc (hwnd, message, wParam, lParam);
    }

    return 0;
}
