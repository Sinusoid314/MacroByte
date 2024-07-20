//USER INTERFACE FUNCTIONS



#define WinGUI_InvokeMethod \
       case IDMETH_WinGUI_GetHWND:\
           Meth_GetHWND();\
           break;\
       \
       case IDMETH_WinGUI_SetText:\
           Meth_SetText();\
           break;\
       \
       case IDMETH_WinGUI_GetText:\
           Meth_GetText();\
           break;\
       

bool InitWin(void)
//Create Window and DrawBox classes
{
    HINSTANCE hThisInstance = (HINSTANCE) GetModuleHandle(NULL);
    WNDCLASSEX* wincl;

    wincl = new WNDCLASSEX;
    wincl->hInstance = hThisInstance;
    wincl->lpszClassName = "MBWindow";
    wincl->lpfnWndProc = WinProc;
    wincl->style = CS_DBLCLKS;
    wincl->cbSize = sizeof (WNDCLASSEX);
    wincl->hIcon = LoadIcon (NULL, IDI_APPLICATION);
    wincl->hIconSm = LoadIcon (NULL, IDI_APPLICATION);
    wincl->hCursor = LoadCursor (NULL, IDC_ARROW);
    wincl->lpszMenuName = NULL;
    wincl->cbClsExtra = 0;
    wincl->cbWndExtra = 0;
    wincl->hbrBackground = (HBRUSH) COLOR_BACKGROUND;
    if (!RegisterClassEx (wincl))
        return false;
    delete wincl;
    
    wincl = new WNDCLASSEX;
    wincl->hInstance = hThisInstance;
    wincl->lpszClassName = "MBDrawBox";
    wincl->lpfnWndProc = DrawBoxProc;
    wincl->style = CS_DBLCLKS | CS_OWNDC;
    wincl->cbSize = sizeof (WNDCLASSEX);
    wincl->hIcon = LoadIcon (NULL, IDI_APPLICATION);
    wincl->hIconSm = LoadIcon (NULL, IDI_APPLICATION);
    wincl->hCursor = LoadCursor (NULL, IDC_ARROW);
    wincl->lpszMenuName = NULL;
    wincl->cbClsExtra = 0;
    wincl->cbWndExtra = 0;
    wincl->hbrBackground = (HBRUSH) COLOR_BACKGROUND;
    if (!RegisterClassEx (wincl))
        return false;
    delete wincl;

    return true;
}

bool CallWinEventSubProg(CWinGUI* wguiObjPtr, UINT wguiEvent)
//Search for an event entry within the WinGUI object's
//event list that matches the given message
{
    double tmpID;
    
    for(int n=1; n<=(wguiObjPtr->winEventCount); n++)
    {
        if(wguiObjPtr->winEventList[n]->winMessage == wguiEvent)
        {
            if(wguiObjPtr->winEventList[n]->spdIdx > 0)
            {
                //Put objectID from event entry on top of data stack
                if(spDefList[wguiObjPtr->winEventList[n]->spdIdx]->paramNum == 1)
                {
                    tmpID = (double) wguiObjPtr->objectID;
                    DataStack->AddData(DT_NUMBER, 0, &tmpID, sizeof(double), 1);
                }
                
                //Load, run, and unload subprog given in event entry
                LoadSubProg(wguiObjPtr->winEventList[n]->spdIdx);
                spList[spCount]->RunProg();
                UnloadSubProg();
                
                return true;
            }
        }
    }
    
    return false;
}

LRESULT CALLBACK WinProc(HWND hwnd, UINT message, WPARAM wParam, LPARAM lParam)
{
    CWinGUI* guiObjPtr;
    HWND tmpHwnd = 0;
    UINT tmpMsg = 0;
    
    //Get window handle and message
    if(message == WM_COMMAND)
    {
        tmpHwnd = (HWND)lParam;
        tmpMsg = (UINT)HIWORD(wParam);
    }
    else
    {
        tmpHwnd = hwnd;
        tmpMsg = message;
    }
    
    //Get pointer to WinGUI object linked
    //with the given window's handle
    guiObjPtr = (CWinGUI*) GetWindowLong(tmpHwnd, GWL_USERDATA);
    if(guiObjPtr == NULL) {goto defProc;}
    
    //Process event
    if(CallWinEventSubProg(guiObjPtr, tmpMsg)) {return 0;}
    
    defProc:
        if(tmpMsg == WM_CLOSE) {return 0;}
        return DefWindowProc (hwnd, message, wParam, lParam);
}

LRESULT CALLBACK DrawBoxProc(HWND hwnd, UINT message, WPARAM wParam, LPARAM lParam)
{
    CWinGUI* guiObjPtr;
    HWND tmpHwnd = 0;
    UINT tmpMsg = 0;
    HDC paintDC;
    PAINTSTRUCT ps;
    
    //Get window handle and message
    if(message == WM_COMMAND)
    {
        tmpHwnd = (HWND)lParam;
        tmpMsg = (UINT)HIWORD(wParam);
    }
    else
    {
        tmpHwnd = hwnd;
        tmpMsg = message;
    }
    
    //Get pointer to WinGUI object linked
    //with the given window's handle
    guiObjPtr = (CWinGUI*) GetWindowLong(tmpHwnd, GWL_USERDATA);
    if(guiObjPtr == NULL) {goto defProc;}
    
    switch (tmpMsg)
    {            
        case WM_PAINT:
            //Redraw DrawBox
            paintDC = BeginPaint(tmpHwnd, &ps);
            BitBlt(paintDC, ps.rcPaint.left, ps.rcPaint.top,
                   ps.rcPaint.right - ps.rcPaint.left, 
                   ps.rcPaint.bottom - ps.rcPaint.top,
                   ((CObjDrawBox*)guiObjPtr)->redrawDC,
                   ps.rcPaint.left, ps.rcPaint.top, SRCCOPY);
            EndPaint(tmpHwnd, &ps);
            
              CallWinEventSubProg(guiObjPtr, tmpMsg);
              
            return 0;
            
        case WM_SIZE:
            //Update redraw dimensions
            ((CObjDrawBox*)guiObjPtr)->UpdateRedrawData();
            
              CallWinEventSubProg(guiObjPtr, tmpMsg);
            
            return 0;
            
        default:
            //Process event
            if(CallWinEventSubProg(guiObjPtr, tmpMsg)) {return 0;}
    }
    
    defProc:
        if(tmpMsg == WM_CLOSE) {return 0;}
        return DefWindowProc (hwnd, message, wParam, lParam);
}

LRESULT CALLBACK CtlProc(HWND hwnd, UINT message, WPARAM wParam, LPARAM lParam)
{
    CWinGUI* guiObjPtr;
    HWND tmpHwnd = 0;
    UINT tmpMsg = 0;
    
    //Get window handle and message
    if(message == WM_COMMAND)
    {
        tmpHwnd = (HWND)lParam;
        tmpMsg = (UINT)HIWORD(wParam);
    }
    else
    {
        tmpHwnd = hwnd;
        tmpMsg = message;
    }
    
    //Get pointer to WinGUI object linked
    //with the given window's handle
    guiObjPtr = (CWinGUI*) GetWindowLong(tmpHwnd, GWL_USERDATA);
    if(guiObjPtr == NULL)
    {
        MessageBox(NULL, "WinGUI-object pointer is not valid", "MacroByteRT", MB_OK | MB_ICONERROR);
        ExitProcess(0);
        //return 0;
    }
    
    //Process event
    CallWinEventSubProg(guiObjPtr, tmpMsg);
    
    return CallWindowProc(guiObjPtr->oldCtlProc, hwnd, message, wParam, lParam);
}
    



//CObject Methods *****************************************************

CObject::CObject(void)
{
    objectID = nextObjID;
    nextObjID++;
    
    parentObjectID = 0;
    
    childObjCount = 0;
    childObjIDList = new int[1];
    
    isGuiObj = false;
    
    debugBlockCount[10]++;
    
    return;
}

CObject::~CObject(void)
{
    int tmpIdx;
    CObject* tmpObjPtr;
    
    //Delete child objects and their objList references
    for(int n=1; n<=childObjCount; n++)
    {
        tmpIdx = GetObjectIdx(childObjIDList[n]);
        if(tmpIdx > 0)
        {
            tmpObjPtr = RemoveObjectRef(tmpIdx);
            delete tmpObjPtr;
        }
    }
    
    delete [] childObjIDList;
    
    debugBlockCount[10]--;
}

void CObject::AddChildObj(int newObjID)
{
    int* tmpList = new int[childObjCount+2];
    
    for(int n=1; n<=childObjCount; n++)
    {
        tmpList[n] = childObjIDList[n];
    }
    tmpList[childObjCount+1] = newObjID;
    delete [] childObjIDList;
    childObjIDList = tmpList;
    childObjCount++;
}

void CObject::RemoveChildObj(int childID)
{
    int childIdx = 0;
    int* tmpList = new int[childObjCount];
    
    for(int n=1; n<=childObjCount; n++)
    {
        childIdx ++;
        if(childID == childObjIDList[n])
            {break;}
        else
            {tmpList[n] = childObjIDList[n];}
    }
    
    for(int n=(childIdx+1); n<=childObjCount; n++)
    {
        tmpList[n-1] = childObjIDList[n];
    }
    
    delete [] childObjIDList;
    childObjIDList = tmpList;
    childObjCount--;
}

//*********************************************************************


//CWinGUI Methods *****************************************************

CWinGUI::CWinGUI(void)
{
    isGuiObj = true;
    oldCtlProc = NULL;
    winHandle = 0;
    winDC = 0;
    winEventCount = 0;
    winEventList = new CWinEvent*[1];
}

CWinGUI::~CWinGUI(void)
{    
    //Destroy window
    DestroyWindow(winHandle);
    
    //Delete window events
    for(int n=1; n<=winEventCount; n++)
    {
        delete winEventList[n];
    }
    delete [] winEventList;
    winEventCount = 0;
}

void CWinGUI::AddWinEvent(CWinEvent* newEventObj)
{
    int winEventIdx = 0;
    CWinEvent** tmpList = new CWinEvent*[winEventCount+2];
    
    //Check if winEventList already has this entry
    for(int n=1; n<=winEventCount; n++)
    {
        if(winEventList[n]->winMessage == newEventObj->winMessage)
        {
            winEventIdx = n;
            break;
        }
    }
    
    if(winEventIdx == 0)
    {
        if(newEventObj->spdIdx == 0) return;
        
        //Add entry to winEventList
        for(int n=1; n<=winEventCount; n++)
        {
            tmpList[n] = winEventList[n];
        }
        tmpList[winEventCount+1] = newEventObj;
        delete [] winEventList;
        winEventList = tmpList;
        winEventCount++;
    }
    else
    {
        //Update event entry
        winEventList[winEventIdx]->spdIdx = newEventObj->spdIdx;
        
        if((newEventObj->spdIdx == 0)
           && (newEventObj->allowRemove))
        {
            RemoveWinEvent(winEventIdx);
        }
        delete newEventObj;
    }
    
}


void CWinGUI::RemoveWinEvent(int winEventIdx)
//Removes the given event object from winEventList
{
     
    CWinEvent** tmpList = new CWinEvent*[winEventCount];
    
    for(int n=1; n<winEventIdx; n++)
    {
        tmpList[n] = winEventList[n];
    }
    
    delete winEventList[winEventIdx];
    
    for(int n=(winEventIdx+1); n<=winEventCount; n++)
    {
        tmpList[n-1] = winEventList[n];
    }
    
    delete [] winEventList;
    winEventList = tmpList;
    winEventCount--;
}

void CWinGUI::Meth_GetHWND(void)
{
    double numRes = (double)(int)winHandle;
    DataStack->AddData(DT_NUMBER, 0, &numRes, sizeof(double), 1);
}


void CWinGUI::Meth_SetText(void)
{
    int tmpTextLen;
    char* tmpText;
    
    //Get new window text from data stack
    tmpTextLen = DataStack->itemPtr[1]->dataSize;
    tmpText = new char[tmpTextLen];
    DataStack->itemPtr[1]->GetData(tmpText);
    DataStack->RemoveData(1);
    
    //Set new window text
    SetWindowText(winHandle, tmpText);
    
    delete tmpText;
}


void CWinGUI::Meth_GetText(void)
{
    int tmpTextLen;
    char* tmpText;
    
    //Get window text
    tmpTextLen = GetWindowTextLength(winHandle);
    tmpText = new char[tmpTextLen];
    tmpTextLen = GetWindowText(winHandle, tmpText, tmpTextLen);
    
    //Add window text to data stack
    DataStack->AddData(DT_STRING, 0, (void*)tmpText, tmpTextLen + 1, 1);
    
    delete tmpText;
}

//*********************************************************************


//CObjWindow Methods **************************************************

CObjWindow::CObjWindow(void)
{
    string winText = "";
    string winType = "";
    int winX = 0;
    int winY = 0;
    int winWidth = 0;
    int winHeight = 0;
    DWORD winStyle = 0;
    string tmpStr = "";
    
    //Get arguments off the data stack
    winText = (const char*) DataStack->itemPtr[1]->dataPtr;
      DataStack->RemoveData(1);
    winType = (const char*) DataStack->itemPtr[1]->dataPtr;
      DataStack->RemoveData(1);
    winX = (int) *((double*)(DataStack->itemPtr[1]->dataPtr));
      DataStack->RemoveData(1);
    winY = (int) *((double*)(DataStack->itemPtr[1]->dataPtr));
      DataStack->RemoveData(1);
    winWidth = (int) *((double*)(DataStack->itemPtr[1]->dataPtr));
      DataStack->RemoveData(1);
    winHeight = (int) *((double*)(DataStack->itemPtr[1]->dataPtr));
      DataStack->RemoveData(1);
    
    //Set correct window style
    for(int n=0; n<winType.length(); n++)
        {tmpStr += tolower(winType[n]);}
    winType = tmpStr;
    if(winType.compare("normal") == 0)
    {
        winStyle = WS_OVERLAPPEDWINDOW | WS_VISIBLE | WS_CLIPCHILDREN;
    }
    
    winHandle = CreateWindowEx(0, "MBWindow", winText.c_str(), winStyle,
                               winX, winY, winWidth, winHeight, HWND_DESKTOP,
                               NULL, (HINSTANCE) GetModuleHandle(NULL), NULL);
    
    //Link window handle with object pointer
    SetLastError(0);
    if((SetWindowLong(winHandle, GWL_USERDATA, (LONG) this) == 0)
       && (GetLastError() != 0))
    {
        MessageBox(NULL, "Failed to link Window handle with object pointer", "MacroByteRT", MB_OK | MB_ICONERROR);
        ExitProcess(0);
    }
    
    return;
}

CObjWindow::~CObjWindow(void)
{
}

void CObjWindow::InvokeMethod(int methodIdx)
{
   switch(methodIdx)
   {
       WinGUI_InvokeMethod
       
       case IDMETH_WinGUI_Window_OnClose:
           Meth_OnClose();
           break;
   }
   return;
}

void CObjWindow::Meth_OnClose(void)
{
    int spdIdx = spList[spCount]->spDefPtr->codeList[spList[spCount]->lineNum].argList[3];
    CWinEvent* winEventObj = new CWinEvent;
    
    //Fill out event object
    winEventObj->winMessage = WM_CLOSE;
    winEventObj->spdIdx = spdIdx;
    
    //Add event to list
    AddWinEvent(winEventObj);
}

//*********************************************************************


//CObjButton Methods **************************************************

CObjButton::CObjButton(void)
{
    string winText = "";
    int winX = 0;
    int winY = 0;
    int winWidth = 0;
    int winHeight = 0;
    int parentObjIdx = 0;
    HWND parentHwnd = 0;
    CWinGUI* parentObjPtr;
    
    //Get arguments off the data stack
    parentObjectID = (int) *((double*)(DataStack->itemPtr[1]->dataPtr));
      DataStack->RemoveData(1);
    winText = (const char*) DataStack->itemPtr[1]->dataPtr;
      DataStack->RemoveData(1);
    winX = (int) *((double*)(DataStack->itemPtr[1]->dataPtr));
      DataStack->RemoveData(1);
    winY = (int) *((double*)(DataStack->itemPtr[1]->dataPtr));
      DataStack->RemoveData(1);
    winWidth = (int) *((double*)(DataStack->itemPtr[1]->dataPtr));
      DataStack->RemoveData(1);
    winHeight = (int) *((double*)(DataStack->itemPtr[1]->dataPtr));
      DataStack->RemoveData(1);
      
    //Set correct parent window handle
    parentObjIdx = GetObjectIdx(parentObjectID);
    if(parentObjIdx == 0)
    {
        //ERROR
        return;
    }
    if(!(objList[parentObjIdx]->isGuiObj))
    {
        //ERROR
        return;
    }
    parentObjPtr = (CWinGUI*)objList[parentObjIdx];
    parentHwnd = parentObjPtr->winHandle;

    //Add button object ID to parent's child-object list
    objList[parentObjIdx]->AddChildObj(objectID);
    
    winHandle = CreateWindowEx(0, "BUTTON", winText.c_str(),
                               WS_VISIBLE | WS_CHILD |WS_CLIPCHILDREN,
                               winX, winY, winWidth, winHeight, parentHwnd,
                               NULL, (HINSTANCE) GetModuleHandle(NULL), NULL);
    
    //Link window handle with object pointer
    SetLastError(0);
    if((SetWindowLong(winHandle, GWL_USERDATA, (LONG) this) == 0)
       && (GetLastError() != 0))
    {
        MessageBox(NULL, "Failed to link Button handle with object pointer", "MacroByteRT", MB_OK | MB_ICONERROR);
        ExitProcess(0);
    }
    
    //Subclass control
    oldCtlProc = (WNDPROC) SetWindowLong(winHandle, GWL_WNDPROC, (LONG) CtlProc);
    
    return;
}

CObjButton::~CObjButton(void)
{
}

void CObjButton::InvokeMethod(int methodIdx)
{
     
    switch(methodIdx)
    {
        WinGUI_InvokeMethod
        
       case IDMETH_WinGUI_Button_OnClick:
           Meth_OnClick();
           break;
    }
    return;
}

void CObjButton::Meth_OnClick(void)
{
    int spdIdx = spList[spCount]->spDefPtr->codeList[spList[spCount]->lineNum].argList[3];
    CWinEvent* winEventObj = new CWinEvent;
    
    //Fill out event object
    winEventObj->winMessage = BN_CLICKED;
    winEventObj->spdIdx = spdIdx;
    
    //Add event to list
    AddWinEvent(winEventObj);
}

//*********************************************************************


//CObjStaticText Methods **************************************************

CObjStaticText::CObjStaticText(void)
{
    int parentObjID = 0;
    string winText = "";
    int winX = 0;
    int winY = 0;
    int winWidth = 0;
    int winHeight = 0;
    int parentObjIdx = 0;
    HWND parentHwnd = 0;
    CWinGUI* parentObjPtr;
    
    //Get arguments off the data stack
    parentObjID = (int) *((double*)(DataStack->itemPtr[1]->dataPtr));
      DataStack->RemoveData(1);
    winText = (const char*) DataStack->itemPtr[1]->dataPtr;
      DataStack->RemoveData(1);
    winX = (int) *((double*)(DataStack->itemPtr[1]->dataPtr));
      DataStack->RemoveData(1);
    winY = (int) *((double*)(DataStack->itemPtr[1]->dataPtr));
      DataStack->RemoveData(1);
    winWidth = (int) *((double*)(DataStack->itemPtr[1]->dataPtr));
      DataStack->RemoveData(1);
    winHeight = (int) *((double*)(DataStack->itemPtr[1]->dataPtr));
      DataStack->RemoveData(1);
      
    //Set correct parent window handle
    parentObjIdx = GetObjectIdx(parentObjID);
    if(parentObjIdx == 0)
    {
        //ERROR
        return;
    }
    if(!(objList[parentObjIdx]->isGuiObj))
    {
        //ERROR
        return;
    }
    parentObjPtr = (CWinGUI*)objList[parentObjIdx];
    parentHwnd = parentObjPtr->winHandle;

    //Add button object ID to parent's child-object list
    objList[parentObjIdx]->AddChildObj(objectID);
    
    winHandle = CreateWindowEx(0, "STATIC", winText.c_str(),
                               WS_VISIBLE | WS_CHILD |WS_CLIPCHILDREN,
                               winX, winY, winWidth, winHeight, parentHwnd,
                               NULL, (HINSTANCE) GetModuleHandle(NULL), NULL);
    
    //Link window handle with object pointer
    SetWindowLong(winHandle, GWL_USERDATA, (LONG) this);
    
    //Subclass control
    oldCtlProc = (WNDPROC) SetWindowLong(winHandle, GWL_WNDPROC, (LONG) CtlProc);
    
    return;
}

CObjStaticText::~CObjStaticText(void)
{
}

void CObjStaticText::InvokeMethod(int methodIdx)
{
     
    switch(methodIdx)
    {
        WinGUI_InvokeMethod
    }
    return;
}

//*********************************************************************


//CObjDrawBox Methods **************************************************

CObjDrawBox::CObjDrawBox(void)
{
    int parentObjID = 0;
    int winX = 0;
    int winY = 0;
    int winWidth = 0;
    int winHeight = 0;
    int parentObjIdx = 0;
    HWND parentHwnd = 0;
    CWinGUI* parentObjPtr;
    
    //Get arguments off the data stack
    parentObjID = (int) *((double*)(DataStack->itemPtr[1]->dataPtr));
      DataStack->RemoveData(1);
    winX = (int) *((double*)(DataStack->itemPtr[1]->dataPtr));
      DataStack->RemoveData(1);
    winY = (int) *((double*)(DataStack->itemPtr[1]->dataPtr));
      DataStack->RemoveData(1);
    winWidth = (int) *((double*)(DataStack->itemPtr[1]->dataPtr));
      DataStack->RemoveData(1);
    winHeight = (int) *((double*)(DataStack->itemPtr[1]->dataPtr));
      DataStack->RemoveData(1);
      
    //Set correct parent window handle
    parentObjIdx = GetObjectIdx(parentObjID);
    if(parentObjIdx == 0)
    {
        //ERROR
        return;
    }
    if(!(objList[parentObjIdx]->isGuiObj))
    {
        //ERROR
        return;
    }
    parentObjPtr = (CWinGUI*)objList[parentObjIdx];
    parentHwnd = parentObjPtr->winHandle;

    //Add button object ID to parent's child-object list
    objList[parentObjIdx]->AddChildObj(objectID);
    
    //Create DrawBox window
    winHandle = CreateWindowEx(0, "MBDrawBox", "", 
                               WS_VISIBLE | WS_CHILD |WS_CLIPCHILDREN | WS_BORDER,
                               winX, winY, winWidth, winHeight, parentHwnd,
                               NULL, (HINSTANCE) GetModuleHandle(NULL), NULL);
    
    //Link window handle with object pointer
    SetWindowLong(winHandle, GWL_USERDATA, (LONG) this);
    
    //Save window DC handle
    winDC = GetDC(winHandle);
    
    //Create redraw data
    redrawDC = CreateCompatibleDC(winDC);
    redrawBMP = CreateCompatibleBitmap(winDC, winWidth, winHeight);
    redrawDefBMP = (HBITMAP) SelectObject(redrawDC, redrawBMP);
    redrawWidth = winWidth;
    redrawHeight = winHeight;
    
    //Initialize DrawOp behavior
    autoRedraw = false;
    autoStick = false;
    
    return;
}

CObjDrawBox::~CObjDrawBox(void)
{
    //Delete redraw data
    SelectObject(redrawDC, redrawDefBMP);
    DeleteDC(redrawDC);
    DeleteObject(redrawBMP);
}

void CObjDrawBox::InvokeMethod(int methodIdx)
{
     
    switch(methodIdx)
    {
        WinGUI_InvokeMethod
        
       case IDMETH_WinGUI_DrawBox_Redraw:
           Meth_Redraw();
           break;
           
       case IDMETH_WinGUI_DrawBox_Stick:
           Meth_Stick();
           break;
           
       case IDMETH_WinGUI_DrawBox_CopyTo:
           Meth_CopyTo();
           break;
           
       case IDMETH_WinGUI_DrawBox_Line:
           Meth_Line();
           break;
           
       case IDMETH_WinGUI_DrawBox_Box:
           Meth_Box();
           break;
           
       case IDMETH_WinGUI_DrawBox_Circle:
           Meth_Circle();
           break;
    }
    return;
}

void CObjDrawBox::UpdateRedrawData(void)
//Update the redraw data if the DrawBox's size
//is larger than that of the current redraw size
{
    RECT winRect;
    int winWidth;
    int winHeight;
    HDC newDC;
    HBITMAP newBMP;
    HBITMAP newDefBMP;
    int newWidth;
    int newHeight;
    
    //Get DrawBox's client-area size
    GetClientRect(winHandle, &winRect);
    winWidth = winRect.right - winRect.left;
    winHeight = winRect.bottom - winRect.top;
    
    //Don't update if DrawBox size
    //isn't larger than redraw size
    if((winWidth <= redrawWidth) && (winHeight <= redrawHeight))
        return;
        
    //Set new redraw size
    if(winWidth > redrawWidth)
        newWidth = winWidth;
    else
        newWidth = redrawWidth;
    if(winHeight > redrawHeight)
        newHeight = winHeight;
    else
        newHeight = redrawHeight;
    
    //Create new redraw DC and BMP
    newDC = CreateCompatibleDC(winDC);
    newBMP = CreateCompatibleBitmap(winDC, newWidth, newHeight);
    newDefBMP = (HBITMAP) SelectObject(newDC, newBMP);
    
    //Transfer redraw image from old DC to new DC
    BitBlt(newDC, 0, 0, redrawWidth, redrawHeight, redrawDC, 0, 0, SRCCOPY);
    
    //Delete old redraw data
    SelectObject(redrawDC, redrawDefBMP);
    DeleteDC(redrawDC);
    DeleteObject(redrawBMP);
    
    //Update all redraw data
    redrawDC = newDC;
    redrawBMP = newBMP;
    redrawDefBMP = newDefBMP;
    redrawWidth = newWidth;
    redrawHeight = newHeight;
}

HDC CObjDrawBox::BeginDrawOp(void)
//Return either winDC or redrawDC, depending
//on the state of autoStick
{
    if(autoStick)
        return redrawDC;
    else
        return winDC;
}

void CObjDrawBox::EndDrawOp(void)
//Redraw DrawBox if autoRedraw is TRUE
{
    if((autoRedraw) && (IsWindowVisible(winHandle)))
        Meth_Redraw();
}

void CObjDrawBox::Meth_Redraw(void)
//Repaint DrawBox winDC using redrawDC
{
    RECT winRect;
    int winWidth;
    int winHeight;
    
    GetWindowRect(winHandle, &winRect);
    winWidth = winRect.right - winRect.left;
    winHeight = winRect.bottom - winRect.top;
    
    BitBlt(winDC, 0, 0, winWidth, winHeight, redrawDC, 0, 0, SRCCOPY);
}

void CObjDrawBox::Meth_Stick(void)
//Transfer DrawBox image from winDC to redrawDC
{
    RECT winRect;
    int winWidth;
    int winHeight;
    
    GetWindowRect(winHandle, &winRect);
    winWidth = winRect.right - winRect.left;
    winHeight = winRect.bottom - winRect.top;
    
    BitBlt(redrawDC, 0, 0, winWidth, winHeight, winDC, 0, 0, SRCCOPY);
}

void CObjDrawBox::Meth_CopyTo(void)
//Copy DrawBox image to another DrawBox
{
    int toObjID = 0;
    int toLeft; int toTop;
    int fromLeft; int fromTop;
    int width; int height;
    int toObjIdx = 0;
    CObjDrawBox* toObjPtr;
    HDC fromDC;
    HDC toDC;
    
    //Get arguments off the DataStack
    toObjID = (int) *((double*)(DataStack->itemPtr[1]->dataPtr));
      DataStack->RemoveData(1);
    toLeft = (int) *((double*)(DataStack->itemPtr[1]->dataPtr));
      DataStack->RemoveData(1);
    toTop = (int) *((double*)(DataStack->itemPtr[1]->dataPtr));
      DataStack->RemoveData(1);
    fromLeft = (int) *((double*)(DataStack->itemPtr[1]->dataPtr));
      DataStack->RemoveData(1);
    fromTop = (int) *((double*)(DataStack->itemPtr[1]->dataPtr));
      DataStack->RemoveData(1);
    width = (int) *((double*)(DataStack->itemPtr[1]->dataPtr));
      DataStack->RemoveData(1);
    height = (int) *((double*)(DataStack->itemPtr[1]->dataPtr));
      DataStack->RemoveData(1);
    
    //Get toObjPtr
    toObjIdx = GetObjectIdx(toObjID);
    if(toObjIdx == 0)
    {
        //ERROR
        return;
    }
    if(objList[toObjIdx]->classID != IDCLS_DrawBox)
    {
        //ERROR
        return;
    }
    toObjPtr = (CObjDrawBox*)objList[toObjIdx];
    
    //Start copy operation
    fromDC = BeginDrawOp();
    toDC = toObjPtr->BeginDrawOp();
    
    //Copy image
    BitBlt(toDC, toLeft, toTop, width, height, fromDC, fromLeft, fromTop, SRCCOPY);
    
    //End copy operation
    toObjPtr->EndDrawOp();
}

void CObjDrawBox::Meth_Line(void)
//DRAW ZEE LINE!
{
    HDC drawDC;
    int startX; int startY;
    int endX; int endY;
    
    //Get arguments off the DataStack
    startX = (int) *((double*)(DataStack->itemPtr[1]->dataPtr));
      DataStack->RemoveData(1);
    startY = (int) *((double*)(DataStack->itemPtr[1]->dataPtr));
      DataStack->RemoveData(1);
    endX = (int) *((double*)(DataStack->itemPtr[1]->dataPtr));
      DataStack->RemoveData(1);
    endY = (int) *((double*)(DataStack->itemPtr[1]->dataPtr));
      DataStack->RemoveData(1);
    
    drawDC = BeginDrawOp();
    
      MoveToEx(drawDC, startX, startY, NULL);
      LineTo(drawDC, endX, endY);
    
    EndDrawOp();
}

void CObjDrawBox::Meth_Box(void)
//DRAW ZEE BOX!
{
    HDC drawDC;
    int left; int top;
    int width; int height;
    
    //Get arguments off the DataStack
    left = (int) *((double*)(DataStack->itemPtr[1]->dataPtr));
      DataStack->RemoveData(1);
    top = (int) *((double*)(DataStack->itemPtr[1]->dataPtr));
      DataStack->RemoveData(1);
    width = (int) *((double*)(DataStack->itemPtr[1]->dataPtr));
      DataStack->RemoveData(1);
    height = (int) *((double*)(DataStack->itemPtr[1]->dataPtr));
      DataStack->RemoveData(1);
    
    drawDC = BeginDrawOp();
    
      Rectangle(drawDC, left, top, (left + width), (top + height));
    
    EndDrawOp();
}

void CObjDrawBox::Meth_Circle(void)
//CIRCLE!!!!
{
    HDC drawDC;
    int centerX;
    int centerY;
    int radius;
    
    //Get arguments off the DataStack
    centerX = (int) *((double*)(DataStack->itemPtr[1]->dataPtr));
      DataStack->RemoveData(1);
    centerY = (int) *((double*)(DataStack->itemPtr[1]->dataPtr));
      DataStack->RemoveData(1);
    radius = (int) *((double*)(DataStack->itemPtr[1]->dataPtr));
      DataStack->RemoveData(1);
      
    drawDC = BeginDrawOp();
    
      Ellipse(drawDC, (centerX - radius), (centerY - radius), 
              (centerX + radius), (centerY + radius));
    
    EndDrawOp();
}

//*********************************************************************


//CObjTextBox Methods **************************************************

CObjTextBox::CObjTextBox(void)
{
}

CObjTextBox::~CObjTextBox(void)
{
}

void CObjTextBox::InvokeMethod(int methodIdx)
{
     
    switch(methodIdx)
    {
        WinGUI_InvokeMethod
    }
    return;
}

//*********************************************************************


//CObjListBox Methods **************************************************

CObjListBox::CObjListBox(void)
{
}

CObjListBox::~CObjListBox(void)
{
}

void CObjListBox::InvokeMethod(int methodIdx)
{
     
    switch(methodIdx)
    {
        WinGUI_InvokeMethod
    }
    return;
}

//*********************************************************************


//CObjComboBox Methods **************************************************

CObjComboBox::CObjComboBox(void)
{
}

CObjComboBox::~CObjComboBox(void)
{
}

void CObjComboBox::InvokeMethod(int methodIdx)
{
     
    switch(methodIdx)
    {
        WinGUI_InvokeMethod
    }
    return;
}

//*********************************************************************


//CObjScrollBar Methods **************************************************

CObjScrollBar::CObjScrollBar(void)
{
}

CObjScrollBar::~CObjScrollBar(void)
{
}

void CObjScrollBar::InvokeMethod(int methodIdx)
{
     
    switch(methodIdx)
    {
        WinGUI_InvokeMethod
    }
    return;
}

//*********************************************************************


//CObjImage Methods **************************************************

CObjImage::CObjImage(void)
{
}

CObjImage::~CObjImage(void)
{
}

void CObjImage::InvokeMethod(int methodIdx)
{
     
    switch(methodIdx)
    {
        
    }
    return;
}

//*********************************************************************


//CObjSprite Methods **************************************************

CObjSprite::CObjSprite(void)
{
}

CObjSprite::~CObjSprite(void)
{
}

void CObjSprite::InvokeMethod(int methodIdx)
{
     
    switch(methodIdx)
    {
        
    }
    return;
}

//*********************************************************************


//CObjDLL Methods **************************************************

CObjDLL::CObjDLL(void)
{
}

CObjDLL::~CObjDLL(void)
{
}

void CObjDLL::InvokeMethod(int methodIdx)
{
     
    switch(methodIdx)
    {
        
    }
    return;
}

//*********************************************************************




