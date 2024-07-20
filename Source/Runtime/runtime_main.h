#ifndef _RUNTIME_MAIN_H
#define _RUNTIME_MAIN_H

#define MBWM_RUN_THREAD_DONE WM_APP+420

extern HANDLE asyncExitFlag;
extern bool errorFlag;
extern std::string errorMsg;
extern int errorSubProgIdx;

extern HANDLE hRtThread;
extern DWORD idRtThread;

int WINAPI WinMain(HINSTANCE, HINSTANCE, LPSTR, int);
bool WinSetup(void);
void WinCleanup(void);
DWORD WINAPI RuntimeMain(LPVOID);
void RuntimeSetup(void);
void RuntimeCleanup(void);
void RuntimeError(void);

unsigned time_seed(void);

#endif
