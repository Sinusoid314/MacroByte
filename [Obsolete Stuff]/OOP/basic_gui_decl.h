//BASIC_GUI

bool InitWin(void);
bool CallWinEventSubProg(CWinGUI*, UINT);
LRESULT CALLBACK WinProc(HWND,UINT,WPARAM,LPARAM);
LRESULT CALLBACK DrawBoxProc(HWND,UINT,WPARAM,LPARAM);
LRESULT CALLBACK CtlProc(HWND,UINT,WPARAM,LPARAM);


class CWinEvent
{
    public:
           UINT winMessage;
           int spdIdx;
           bool allowRemove;
           CWinEvent(void);
};


class CObject
{
    public:
           int classID;
           int objectID;
           int parentObjectID;
           int childObjCount;
           int* childObjIDList;
           bool isGuiObj;
           CObject(void);
           virtual ~CObject(void);
           virtual void InvokeMethod(int methodIdx)
               {return;}
           void AddChildObj(int);
           void RemoveChildObj(int);
};

class CWinGUI: public CObject
{
    public:
           HWND winHandle;
           WNDPROC oldCtlProc;
           HDC winDC;
           int winEventCount;
           CWinEvent** winEventList;
           CWinGUI(void);
           ~CWinGUI(void);
           void AddWinEvent(CWinEvent*);
           void RemoveWinEvent(int);
           void Meth_GetHWND(void);
           void Meth_SetText(void);
           void Meth_GetText(void);
};

class CObjWindow: public CWinGUI
{
    public:
           CObjWindow(void);
           ~CObjWindow(void);
           void InvokeMethod(int);
           void Meth_OnClose(void);
};

class CObjButton: public CWinGUI
{
    public:
           CObjButton(void);
           ~CObjButton(void);
           void InvokeMethod(int);
           void Meth_OnClick(void);
};


class CObjStaticText: public CWinGUI
{
    public:
           CObjStaticText(void);
           ~CObjStaticText(void);
           void InvokeMethod(int);
};


class CObjDrawBox: public CWinGUI
{
    public:
           HDC redrawDC;
           HBITMAP redrawBMP;
           HBITMAP redrawDefBMP;
           int redrawWidth;
           int redrawHeight;
           bool autoRedraw;
           bool autoStick;
           CObjDrawBox(void);
           ~CObjDrawBox(void);
           void InvokeMethod(int);
           void UpdateRedrawData(void);
           HDC BeginDrawOp(void);
           void EndDrawOp(void);
           void Meth_Redraw(void);
           void Meth_Stick(void);
           void Meth_CopyTo(void);
           void Meth_Line(void);
           void Meth_Box(void);
           void Meth_Circle(void);           
};

class CObjTextBox: public CWinGUI
{
    public:
           CObjTextBox(void);
           ~CObjTextBox(void);
           void InvokeMethod(int);
};

class CObjListBox: public CWinGUI
{
    public:
           CObjListBox(void);
           ~CObjListBox(void);
           void InvokeMethod(int);
};

class CObjComboBox: public CWinGUI
{
    public:
           CObjComboBox(void);
           ~CObjComboBox(void);
           void InvokeMethod(int);
};

class CObjScrollBar: public CWinGUI
{
    public:
           CObjScrollBar(void);
           ~CObjScrollBar(void);
           void InvokeMethod(int);
};

class CObjImage: public CObject
{
    public:
           CObjImage(void);
           ~CObjImage(void);
           void InvokeMethod(int);
};

class CObjSprite: public CObject
{
    public:
           CObjSprite(void);
           ~CObjSprite(void);
           void InvokeMethod(int);
};

class CObjDLL: public CObject
{
    public:
           CObjDLL(void);
           ~CObjDLL(void);
           void InvokeMethod(int);
};

