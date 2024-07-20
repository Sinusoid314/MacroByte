#include <cstdlib>
#include <iostream>

using namespace std;

const int IDMETH_Window_GetHandle = 1;
const int IDMETH_Window_SetText = 2;
const int IDMETH_Window_GetText = 3;

class CObject
{
    public:
           int objectID;
           virtual void InvokeMethod(int methodIdx)
               {return;}
           CObject(void);
           virtual ~CObject(void);
};

class CWinGUI: public CObject
{
    public:
           long winHandle;
           long oldWinProc;
           void GetHandle(void);
           void SetText(void);
           void GetText(void);
};

class CObjWindow: public CWinGUI
{
    public:
           CObjWindow(void);
           ~CObjWindow(void);
           void InvokeMethod(int);
};


class CObjButton: public CWinGUI
{
    public:
           CObjButton(void);
           ~CObjButton(void);
           void InvokeMethod(int);
};


int objCount = 0;
CObject** objList;
int nextObjID = 1;


#define WinGUI_InvokeMethod \
       case IDMETH_Window_GetHandle:\
           GetHandle();\
           break;\
       \
       case IDMETH_Window_SetText:\
           SetText();\
           break;\
       \
       case IDMETH_Window_GetText:\
           GetText();\
           break;\



//CObject Methods *****************************************************

CObject::CObject(void)
{
    objectID = nextObjID;
    nextObjID++;
    cout << "CObject: " << objectID << endl;
    return;
}

CObject::~CObject(void)
{
    cout << "Deleted CObject: " << objectID << endl;
    return;
}

//*********************************************************************


//CWinGUI Methods *****************************************************

void CWinGUI::GetHandle(void)
{
   cout << "GetHandle: " << objectID << endl;
}


void CWinGUI::SetText(void)
{
   cout << "SetText: " << objectID << endl;
}


void CWinGUI::GetText(void)
{
   cout << "GetText: " << objectID << endl;
}

//*********************************************************************


//CObjWindow Methods **************************************************

CObjWindow::CObjWindow(void)
{
   cout << "Created: CObjWindow " << objectID << endl;
   return;
}

CObjWindow::~CObjWindow(void)
{
   cout << "Destroyed: CObjWindow " << objectID << endl;
   return;
}

void CObjWindow::InvokeMethod(int methodIdx)
{
   switch(methodIdx)
   {
      WinGUI_InvokeMethod
   }
   return;
}

//*********************************************************************


//CObjButton Methods **************************************************

CObjButton::CObjButton(void)
{
    cout << "Created: CObjButton " << objectID << endl;
    return;
}

CObjButton::~CObjButton(void)
{
    cout << "Destroyed: CObjButton " << objectID << endl;
    return;
}

void CObjButton::InvokeMethod(int methodIdx)
{
     
    switch(methodIdx)
    {
        WinGUI_InvokeMethod
    }
    return;
}

//*********************************************************************




int main(int argc, char *argv[])
{
    objCount = 3;
    objList = new CObject*[objCount];
    
    objList[0] = new CObjWindow;
    objList[1] = new CObjButton;
    objList[2] = new CObjButton;

    objList[0]->InvokeMethod(3);
    objList[1]->InvokeMethod(2);
    objList[2]->InvokeMethod(1);
    
    for(int n=0; n < objCount; n++)
        {delete objList[n];}
    delete [] objList;
    
    system("PAUSE");
    return EXIT_SUCCESS;
}
