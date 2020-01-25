#include <cstdlib>
#include <string>
#include <vector>
#include <windows.h>
#include "..\basic_tags.h"
#include "runtime_main.h"
#include "runtime_cui.h"

using namespace std;

const char* consolWinClassName = "MacroByteConsol";

string userInput;
HANDLE inputting;
HWND hConsolWin;
HWND hConsolDisplay;
WNDPROC oldDisplayProc;
HFONT dispFont;
COLORREF dispBackColor;
COLORREF dispTextColor;


bool ConsolSetup(void)
//Create consol window class, create & display
//consol window
{
    HINSTANCE hThisInstance = (HINSTANCE) GetModuleHandle(NULL);
    WNDCLASSEX wincl;
    int tmpWidth = int(GetSystemMetrics(SM_CXSCREEN) / 1.9);
    int tmpHeight = int(GetSystemMetrics(SM_CYSCREEN) / 1.6);
    int tmpX = (GetSystemMetrics(SM_CXSCREEN) - tmpWidth) / 2;
    int tmpY = (GetSystemMetrics(SM_CYSCREEN) - tmpHeight) / 2;

    /* The Window structure */
    wincl.hInstance = hThisInstance;
    wincl.lpszClassName = consolWinClassName;
    wincl.lpfnWndProc = ConsolWinProc;      /* This function is called by windows */
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
    
    //Initialize consol input variables    
    userInput = "";
    inputting = CreateEvent(NULL, TRUE, FALSE, NULL);

    //Create the consol window
    hConsolWin = CreateWindowEx(0,consolWinClassName, "MacroByte Runtime Consol", WS_OVERLAPPEDWINDOW | WS_CLIPCHILDREN,
                                tmpX, tmpY, tmpWidth, tmpHeight, HWND_DESKTOP, NULL,
                                hThisInstance, NULL);

    return true;
}

void ConsolCleanup(void)
//Destroy consol window and unregister
//its window class
{
    //Destroy consol window
    DestroyWindow(hConsolWin);
    
    //Close the inputting flag
    CloseHandle(inputting);
    
    //Unregister window class
    UnregisterClass(consolWinClassName,(HINSTANCE)GetModuleHandle(NULL));   
}

LRESULT CALLBACK ConsolWinProc(HWND hwnd, UINT message, WPARAM wParam, LPARAM lParam)
{
    MSG tmpMsg;
    RECT dispRect;

    switch (message)
    {
        case WM_ACTIVATE:
            if(LOWORD(wParam) != 0)
            {
                SetFocus(hConsolDisplay);
            }
            break;
            
        case WM_CTLCOLORSTATIC:
            SetBkColor((HDC)wParam, dispBackColor);
	        SetTextColor((HDC)wParam, dispTextColor);
            return (LRESULT)GetStockObject(BLACK_BRUSH);

        case WM_SIZE:
            MoveWindow(hConsolDisplay, 0, 0, LOWORD(lParam), HIWORD(lParam), TRUE);
            return TRUE;

        case WM_CREATE:
            hConsolDisplay = CreateWindowEx(0, "EDIT", "",
                                            WS_VISIBLE|WS_CHILD|WS_BORDER|
                                            WS_VSCROLL|WS_HSCROLL|ES_READONLY|
                                            ES_MULTILINE|ES_WANTRETURN|
                                            ES_AUTOHSCROLL|ES_AUTOVSCROLL|WS_CLIPCHILDREN,
                                            1, 1, 535, 347, hwnd, NULL,
                                            (HINSTANCE) GetModuleHandle(NULL),
                                            NULL);
            dispBackColor = RGB(0,0,0);
            dispTextColor = RGB(255,255,255);
            dispFont = CreateFont(13,0,0,0,0,0,0,0,0,0,0,0,0,"Lucida Console");
            SendMessage(hConsolDisplay, WM_SETFONT, (WPARAM)dispFont, MAKELPARAM(TRUE, 0));

            //Set display window procedure
            oldDisplayProc = (WNDPROC) SetWindowLong(hConsolDisplay, GWL_WNDPROC, (LONG)ConsolDisplayProc);

            break;

        case WM_CLOSE:
            //Set asyncExitFlag to TRUE
            SetEvent(asyncExitFlag);
            
            //Wait for hRtThread to finish running with WaitForSingleObject()
            while(WaitForSingleObject(hRtThread, 0) != WAIT_OBJECT_0)
            {                
                Sleep(1);
            }
            
            #ifdef _COMPONENT_DEBUGGER
              //Hide consol window
              ShowWindow(hwnd, SW_HIDE);
            #else
              //Signal main message loop to exit
              PostQuitMessage(0);
            #endif

            break;
        
        case MBWM_RUN_THREAD_DONE:
            //If hConsolWin is NOT visible, close it
            if(IsWindowVisible(hwnd) == 0)
            {
                //Send WM_CLOSE message
                PostMessage(hwnd, WM_CLOSE, 0, 0);
            }
            break;
        
        default:                      /* for messages that we don't deal with */
            return DefWindowProc (hwnd, message, wParam, lParam);
    }

    return 0;
}

LRESULT CALLBACK ConsolDisplayProc(HWND hwnd, UINT message, WPARAM wParam, LPARAM lParam)
{

    int dispTextLen;
    char* outText;

    switch (message)
    {
        case WM_CHAR:
            //Exit if inputting is FALSE
            if(WaitForSingleObject(inputting, 0) != WAIT_OBJECT_0)
                {return CallWindowProc (oldDisplayProc, hwnd, message, wParam, lParam);}
            
            switch(wParam)
            {
                case 8:
                      dispTextLen = GetWindowTextLength(hConsolDisplay);
                      if((dispTextLen > 0) && (userInput.length() > 0))
                      {
                        //Remove last character from display
                          SendMessage( hConsolDisplay, EM_SETSEL, (WPARAM)dispTextLen-1, (LPARAM)dispTextLen );
                          SendMessage( hConsolDisplay, EM_REPLACESEL, 0, (LPARAM) ((LPSTR) "") );
                        //Remove last character from userInput
                          userInput.erase(userInput.length()-1);
                      }
                    break;
                case 13:
                    //Add new line characters (Cr-Lf) to display
                      outText = new char[3];
                      outText[0] = (char)13;
                      outText[1] = (char)10;
                      outText[2] = '\0';
                      dispTextLen = GetWindowTextLength( hConsolDisplay );
                      SendMessage( hConsolDisplay, EM_SETSEL, (WPARAM)dispTextLen, (LPARAM)dispTextLen );
                      SendMessage( hConsolDisplay, EM_REPLACESEL, 0, (LPARAM) ((LPSTR) outText) );
                    //Set inputting to FALSE
                      ResetEvent(inputting);
                    //Cleanup
                      delete [] outText;
                    break;

                default:
                    //Add user-entered character to display  
                      outText = new char[2];
                      outText[0] = (char)wParam;
                      outText[1] = '\0';
                      dispTextLen = GetWindowTextLength( hConsolDisplay );
                      SendMessage( hConsolDisplay, EM_SETSEL, (WPARAM)dispTextLen, (LPARAM)dispTextLen );
                      SendMessage( hConsolDisplay, EM_REPLACESEL, 0, (LPARAM) ((LPSTR) outText) );
                    //Add character to userInput
                      userInput += (char)wParam;
                    //Cleanup
                      delete [] outText;
            }
            
            //SendMessage(hConsolDisplay, EM_SETSEL, dispTextLen, dispTextLen);
            //SendMessage(hConsolDisplay, EM_SCROLLCARET, 0, 0);
            //delete [] dispText;
            
            break;
    }

    return CallWindowProc (oldDisplayProc, hwnd, message, wParam, lParam);
}
