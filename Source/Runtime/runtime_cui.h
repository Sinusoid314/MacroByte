#ifndef _RUNTIME_CUI_H
#define _RUNTIME_CUI_H

extern const char* consoleWinClassName;

extern std::string userInput;
extern HANDLE inputting;
extern HWND hConsoleWin;
extern HWND hConsoleDisplay;
extern WNDPROC oldDisplayProc;
extern HFONT dispFont;
extern COLORREF dispBackColor;
extern COLORREF dispTextColor;

bool ConsoleSetup(void);
void ConsoleCleanup(void);
LRESULT CALLBACK ConsoleWinProc(HWND,UINT,WPARAM,LPARAM);
LRESULT CALLBACK ConsoleDisplayProc(HWND,UINT,WPARAM,LPARAM);


#endif
