#ifdef _COMPONENT_DEBUGGER

#ifndef _RUNTIME_DEBUG_H
#define _RUNTIME_DEBUG_H

extern HANDLE debugInBreakpoint;
extern HWND hDebugWin;
extern HWND hDebugCodeView;
extern HWND hDebugStepBtn;

bool DebugSetup(void);
void DebugCleanup(void);
LRESULT CALLBACK DebugWinProc(HWND,UINT,WPARAM,LPARAM);

#endif

#endif
