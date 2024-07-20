#include <cstdlib>
#include <sstream>
#include <string>
#include <vector>
#include <deque>
#include <windows.h>
#include "..\..\..\[Libraries]\String Extension\stringExt.h"
#include "..\..\..\[Libraries]\File IO\FileIO.h"
#include "..\basic_tags.h"
#include "..\basic_def.h"
#include "runtime_data.h"
#include "runtime_loader.h"
#include "runtime_debug.h"

using namespace std;

string rtFilePath;
string rtFileName;

void LoadRunFile(void)
//
{
    string dat;
    
    vector<string> lineList;
    int listPos = 0;
    
    int tmpCount1;
    int tmpCount2;
    int tmpCount3;
    string tmpStr = "";
    double tmpVal;
    double tmpLitVal;
    char tmpPath[_MAX_PATH];
    char tmpName[_MAX_FNAME];
    
    //Get program EXE file path & name
    GetModuleFileNameA(NULL, tmpPath, _MAX_PATH);
    _splitpath(tmpPath, NULL, NULL, tmpName, NULL);
    rtFilePath = tmpPath;
    rtFileName = tmpName;
    
    //Extract runtime data
    ExtractRunData(dat);
    
    //Decrypt data
    DTask(dat);
    
    //Split data into lines
    SplitLines(dat, lineList);
    
    //Skip past number of lines (no longer used)
    listPos++;
    
    //Load version string
    tmpStr = lineList[listPos];
    listPos++;
    if(tmpStr != versionStr)
    {
        //ERROR
        MessageBoxA(NULL, (string("Wrong version number: '") + tmpStr + "' should be '" + versionStr + "'").c_str(), "MacroByteRT", MB_OK | MB_ICONERROR);
        ExitProcess(0);
    }
    
    //Load runtime mode
    rtMode = StrToNum(lineList[listPos]);
    listPos++;
    
    //Check runtime mode against compile mode
    #ifdef _COMPONENT_RUN
    if(rtMode != RTMODE_RUN)
    #endif
    #ifdef _COMPONENT_DEBUGGER
    if(rtMode != RTMODE_DEBUG)
    #endif
    #ifdef _COMPONENT_DEPLOY
    if(rtMode != RTMODE_DEPLOY)
    #endif
    {
        //ERROR
        MessageBoxA(NULL, "Incorrect runtime mode.", "MacroByteRT", MB_OK | MB_ICONERROR);
        ExitProcess(0);
    }
    
    //Load working directory
    workingDir = lineList[listPos].c_str();
    listPos++;
    if(workingDir.length() != 0)
    {
        SetCurrentDirectoryA(workingDir.c_str());
    }
    
    //Load source code for Debug mode
    #ifdef _COMPONENT_DEBUGGER
    tmpCount1 = StrToNum(lineList[listPos]);
    listPos++;
    for(int a=0; a < tmpCount1; a++)
    {
        SendMessage( hDebugCodeView, LB_ADDSTRING, 0, (LPARAM) ((LPSTR)lineList[listPos].c_str()) );
        listPos++;
    }
    #endif
    
    //Load literals
    tmpCount1 = StrToNum(lineList[listPos]);
    listPos++;
    LiteralList.resize(tmpCount1);
    for(int a=0; a<tmpCount1; a++)
    {
        tmpVal = StrToNum(lineList[listPos]);
        listPos++;
        switch(int(tmpVal))
        {
            case DT_NUMBER:
                tmpLitVal = StrToNum(lineList[listPos]);
                LiteralList[a] = new CDataCell(DT_NUMBER, &tmpLitVal, sizeof(double));
                break;
            case DT_STRING:
                LiteralList[a] = new CDataCell(DT_STRING, (void*)lineList[listPos].c_str(), lineList[listPos].length() + 1);
                break;
        }
        listPos++;
    }
    
    //Load subProg definitions into spDefList objects
    tmpCount1 = StrToNum(lineList[listPos]);
    listPos++;
    spDefList.resize(tmpCount1);
    for(int a=0; a<tmpCount1; a++)
    {        
        //Create new SubProgDef object
        spDefList[a] = new CSubProgDef;
        
        //Load SubProg name
        #ifdef _COMPONENT_DEBUGGER
        spDefList[a]->subProgName = lineList[listPos];
        listPos++;
        #endif
        
        //Load isFunc flag
        spDefList[a]->isFunc = (bool)StrToNum(lineList[listPos]);
        listPos++;
        
        //Load number of parameters
        spDefList[a]->paramNum = StrToNum(lineList[listPos]);
        listPos++;
        
        //Load varable definitions
        tmpCount2 = StrToNum(lineList[listPos]);
        listPos++;
        spDefList[a]->varNameList.resize(tmpCount2);
        spDefList[a]->varTypeList.resize(tmpCount2);
        for(int b=0; b<tmpCount2; b++)
        {
            #ifdef _COMPONENT_DEBUGGER
            spDefList[a]->varNameList[b] = lineList[listPos];
            listPos++;
            #endif
            spDefList[a]->varTypeList[b] = StrToNum(lineList[listPos]);
            listPos++;
        }
        
        //Load array definitions
        tmpCount2 = StrToNum(lineList[listPos]);     
        listPos++;
        spDefList[a]->arrayDefList.resize(tmpCount2);
        for(int b=0; b<tmpCount2; b++)
        {
            spDefList[a]->arrayDefList[b] = new CArrayDef;
            
            #ifdef _COMPONENT_DEBUGGER
            spDefList[a]->arrayDefList[b]->arrayName = lineList[listPos];
            listPos++;
            #endif
            spDefList[a]->arrayDefList[b]->arrayType = StrToNum(lineList[listPos]);
            listPos++;
            tmpCount3 = StrToNum(lineList[listPos]);
            listPos++;
            spDefList[a]->arrayDefList[b]->dimSizeList.resize(tmpCount3);
            for(int c=0; c<tmpCount3; c++)
            {
                spDefList[a]->arrayDefList[b]->dimSizeList[c] = StrToNum(lineList[listPos]);
                listPos++;
            }
        }

        //Load code list
        tmpCount2 = StrToNum(lineList[listPos]);
        listPos++;
        spDefList[a]->byteCodeList.resize(tmpCount2);
        for(int b=0; b<tmpCount2; b++)
        {
            spDefList[a]->byteCodeList[b] = new CCommand;
            
            tmpCount3 = StrToNum(lineList[listPos]);
            listPos++;
            spDefList[a]->byteCodeList[b]->argList.resize(tmpCount3);
            for(int c=0; c<tmpCount3; c++)
            {
                spDefList[a]->byteCodeList[b]->argList[c] = StrToNum(lineList[listPos]);
                listPos++;
            }
        }
    }
    
    dat = "";
    lineList.clear();
}

void ExtractRunData(string& dataBuffer)
{
    CFile rtFile;
    long rtFileSize;
    long dataSize;
    long dataPos;
    long nextReadPos;
    string tmpStr;
    
#ifndef _COMPONENT_DEPLOY
    //Open file
    if (rtFile.OpenFile("mbcDat.mbr", 1, FT_BINARY))
    {
        //Get file size
        rtFileSize = rtFile.GetFileLength();
        
        //Read in file data
        rtFile.InputBytes(dataBuffer, rtFileSize);
        
        //Close file
        rtFile.CloseFile();
    }
    else 
    {
        MessageBoxA(NULL, "Failed to open debug file.", "MacroByteRT", MB_OK | MB_ICONERROR);
        ExitProcess(0);
    }
#endif
    
#ifdef _COMPONENT_DEPLOY
    if (rtFile.OpenFile(rtFilePath.c_str(), 1, FT_BINARY))
    {
        //Get file size
        rtFileSize = rtFile.GetFileLength();
        
        //Get footerID
        nextReadPos = rtFileSize - strlen(fileFooterID);
        rtFile.SetFilePos(nextReadPos);
        rtFile.InputBytes(tmpStr, strlen(fileFooterID));
        
        if(tmpStr.compare(fileFooterID) == 0)
        {
            //Get data position
            nextReadPos = nextReadPos - sizeof(dataPos);
            rtFile.SetFilePos(nextReadPos);
            rtFile.InputBytes((char*)&dataPos, sizeof(dataPos));
            dataPos--; //TODO - For data written from VB
            
            //Get data size
            nextReadPos = nextReadPos - sizeof(dataSize);
            rtFile.SetFilePos(nextReadPos);
            rtFile.InputBytes((char*)&dataSize, sizeof(dataSize));
            
            //Read in data
            rtFile.SetFilePos(dataPos);
            rtFile.InputBytes(dataBuffer, dataSize);
            
            //Close file
            rtFile.CloseFile();
        }
        else
        {
            MessageBox(NULL, "Failed to read runtime data.", "MacroByteRT", MB_OK | MB_ICONERROR);
            ExitProcess(0);
        }
    }
    else 
    {
        MessageBox(NULL, "Failed to open runtime file.", "MacroByteRT", MB_OK | MB_ICONERROR);
        ExitProcess(0);
    }
#endif
}

void DTask(string& dataStr)
//
{
    char dKey;
    
    //Retrieve key
    dKey = dataStr[10];
    
    //Remove head and tail padding
    dataStr.erase(0, 19);
    dataStr.erase(dataStr.length()-10, 10);
    
    //Decrypt data
    for(int n=0; n < dataStr.length(); n++)
    {
        dataStr[n] = char( int(dataStr[n]) - int(dKey) + ((n%2) ? 0 : 3) );
    }
}

void SplitLines(string& datStr, vector<string>& lineList)
//
{
    string tmpStr = "";

    //Fill line list
    for(int n=0; n < datStr.length(); n++)
    {
        if(datStr[n] == '\n')
        {
            lineList.push_back( tmpStr );
            tmpStr ="";
        }
        else
        {
            tmpStr += datStr[n];
        }
    }
}

