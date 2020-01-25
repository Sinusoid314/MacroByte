#include <cstdlib>
#include <string>
#include <vector>
#include <deque>
#include "basic_def.h"

using namespace std;

const char* fileFooterID = "MACROBYTE-RUNTIME";

int rtMode;
string workingDir;

vector<string> rawSourceCodeList;
vector<CSubProgDef*> spDefList;


CArrayDef::CArrayDef(void)
//
{
}

CArrayDef::~CArrayDef(void)
//Unload array definition data
{
    arrayName = "";
    
    dimSizeList.clear();
}

CCommand::CCommand(void)
//
{
}

CCommand::CCommand(int initArg, int argCount)
//
{
	argList.resize(argCount);
    argList[0] = initArg;
}

CCommand::~CCommand(void)
//Delete argument list
{
    argList.clear();
}

CSubProgDef::CSubProgDef(void)
//
{
}

CSubProgDef::~CSubProgDef(void)
//Delete subprog definition data
{    
    subProgName = "";
    
    varNameList.clear();
    varTypeList.clear();
    
    for(int n=0; n<arrayDefList.size(); n++)
    {
        delete arrayDefList[n];
    }
    arrayDefList.clear();
    
    for(int n=0; n<byteCodeList.size(); n++)
    {
        delete byteCodeList[n];
    }
    byteCodeList.clear();
}


