#ifndef _COMPILER_DISPLAY_H
#define _COMPILER_DISPLAY_H

extern const char* dispWndClassName;

extern HWND hDispWin;
extern HWND hDispCancelBtn;
extern HWND hDispStatus;
extern HWND hDispProgress;

bool DisplaySetup(void);
void DisplayCleanup(void);
LRESULT CALLBACK DisplayWinProc(HWND,UINT,WPARAM,LPARAM);

#endif
