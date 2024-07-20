#ifndef _RUNTIME_CUI_H
#define _RUNTIME_CUI_H

extern const char* consolWinClassName;

extern std::string userInput;
extern HANDLE inputting;
extern HWND hConsolWin;
extern HWND hConsolDisplay;
extern WNDPROC oldDisplayProc;
extern HFONT dispFont;
extern COLORREF dispBackColor;
extern COLORREF dispTextColor;

bool ConsolSetup(void);
void ConsolCleanup(void);
LRESULT CALLBACK ConsolWinProc(HWND,UINT,WPARAM,LPARAM);
LRESULT CALLBACK ConsolDisplayProc(HWND,UINT,WPARAM,LPARAM);


#endif
