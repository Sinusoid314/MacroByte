#include <cstdlib>
#include <ctime>
#include <sstream>
#include <string>
#include <vector>
#include <windows.h>
#include "..\[Libraries]\File IO\FileIO.h"
#include "..\basic_tags.h"
#include "..\basic_def.h"
#include "assembler_main.h"

using namespace std;

string rawData;
string rtExeFileName;

vector<CLiteral> LiteralList;


CLiteral::CLiteral(void)
//
{
    litType = DT_STRING;
}

CLiteral::CLiteral(const string& initStr, int initType)
//
{
    litStr = initStr;
    litType = initType;
}

void AssembleFile(void)
//
{
    CFile rtFile;
    
    //Write version number
    WriteRawData(string(versionStr));
    
    //Write runtime mode
    WriteRawData(rtMode);
    
    //Write working directory
    if(rtMode != RTMODE_DEPLOY)
    {
        WriteRawData(workingDir);
    }
    else
    {
        WriteRawData(string(""));
    }
    
    //Write source code for Debug mode
    if(rtMode == RTMODE_DEBUG)
    {
        WriteRawData(rawSourceCodeList.size());
        for(int n=0; n < rawSourceCodeList.size(); n++)
        {
            WriteRawData(rawSourceCodeList[n]);
        }
    }
    
    //Write literals    
    WriteRawData(LiteralList.size());
    for(int n=0; n < LiteralList.size(); n++)
    {
        WriteRawData(LiteralList[n]->litType);
        WriteRawData(LiteralList[n]->litStr);
    }
    
    //Write subprog data
    WriteRawData(spDefList.size());
    for(int n=0; n < spDefList.size(); n++)
    {
        AssembleSubProg(n);
    }

    //Write unencrypted MBR file
    //Open App.Path & "\MBRData.txt" For Output As #1
    //    Print #1, rawData;
    //Close #1

    //Encrypt raw data
    ETask(rawData);

    //Write final program data
    if(rtMode == RTMODE_DEPLOY)
    {
        AppendToFile(rtExeFileName, rawData);
    }
    else
    {
        if(rtFile.OpenFile(ParseFilePath(rtExeFileName).append("\\mbcDat.mbr").c_str(), 1, FT_OUTPUT))
        {
            rtFile.Print(rawData);
            rtFile.CloseFile();
        }
    }
    
    rawData = "";
}

void AssembleSubProg(int spIdx)
//
{
    CSubProgDef* spDefPtr;
    int b;
    int c;
    
    spDefPtr = spDefList[spIdx];
    
    //Write subprog name
    if(rtMode == RTMODE_DEBUG)
    {
        WriteRawData(spDefPtr->subProgName);
    }
    
    //Write function flag
    WriteRawData(spDefPtr->isFunc);
    
    //Write parameter count
    WriteRawData(spDefPtr->paramNum);
    
    //Write variable definitions
    WriteRawData(spDefPtr->varTypeList.size());
    for(b = 0; b < spDefPtr->varTypeList.size(); b++)
    {
        if(rtMode == RTMODE_DEBUG)
        {
            WriteRawData(spDefPtr->varNameList[b]);
        }
        WriteRawData(spDefPtr->varTypeList[b]);
    }
    
    //Write array definitions
    WriteRawData(spDefPtr->arrayDefList.size());
    for(b = 0; b < spDefPtr->arrayDefList.size(); b++)
    {
        if(rtMode == RTMODE_DEBUG)
        {
            WriteRawData(spDefPtr->arrayDefList[b]->arrayName);
        }
        WriteRawData(spDefPtr->arrayDefList[b]->arrayType);
        WriteRawData(spDefPtr->arrayDefList[b]->dimSizeList.size());
        for(c = 0; c < spDefPtr->arrayDefList[b]->dimSizeList.size(); c++)
        {
            WriteRawData(spDefPtr->arrayDefList[b]->dimSizeList[c]);
        }
    }
    
    //Write bytecode commands
    WriteRawData(spDefPtr->byteCodeList.size());
    for(b = 0; b < spDefPtr->byteCodeList.size(); b++)
    {
        WriteRawData(spDefPtr->byteCodeList[b]->argList.size());
        for(c = 0; c < spDefPtr->byteCodeList[b]->argList.size(); c++)
        {
            WriteRawData(spDefPtr->byteCodeList[b]->argList[c]);
        }
    }

}

void WriteRawData(const string& dataStr)
//
{
    rawData += dataStr;
    rawData += '\n';
}

void WriteRawData(double dataNum)
//
{
    WriteRawData(static_cast<ostringstream*>(&(ostringstream() << dataNum))->str());
}

void ETask(string& dataStr)
//
{
    char eKey;
    string headStr;
    string tailStr;
    
    //Create key
    srand(time(NULL));
    eKey = char(rand() % 10 + 10);
    
    //Encrypt data
    for(int n=0; n < dataStr.length(); n++)
    {
        dataStr[n] = char( int(dataStr[n]) + int(eKey) - ((n%2) ? 0 : 3) );
    }
    
    //Generate head padding with key
    headStr.resize(19);
    for(int n=0; n<=9; n++)
    {
        srand(time(NULL));
        headStr[n] = char(rand() % 127 + 1);
    }
    headStr[10] = eKey;
    for(int n=11; n<=18; n++)
    {
        srand(time(NULL));
        headStr[n] = char(rand() % 127 + 1);
    }
    
    //Generate tail padding
    tailStr.resize(10);
    for(int n=0; n<=9; n++)
    {
        srand(time(NULL));
        tailStr[n] = char(rand() % 127 + 1);
    }
    
    //Add head and tail padding to data
    dataStr.insert(0, headStr);
    dataStr.append(tailStr);
}

void AppendToFile(string targetFile, string& dataBuffer)
//
{
    CFile rtFile;
    long rtFileSize;
    long dataSize;
    long dataPos;
    long oldDataSize;
    long truncSize;
    long nextReadPos;
    string tmpStr;

    //Open file
    if (rtFile.OpenFile(targetFile.c_str(), 1, FT_BINARY))
    {
        //Get file size
        rtFileSize = rtFile.GetFileLength();
        
        //Get footerID string (if present)
        nextReadPos = rtFileSize - strlen(fileFooterID);
        rtFile.SetFilePos(nextReadPos);
        rtFile.InputBytes(tmpStr, strlen(fileFooterID));
        
        //Get new append data size
        dataSize = dataBuffer.length();
        
        //Old append data is in the EXE
        if(tmpStr.compare(fileFooterID) == 0)
        {
            //Get append data position in file
            nextReadPos = nextReadPos - sizeof(dataPos);
            rtFile.SetFilePos(nextReadPos);
            rtFile.InputBytes((char*)&dataPos, sizeof(dataPos));
        
            //Get old append data size
            nextReadPos = nextReadPos - sizeof(oldDataSize);
            rtFile.SetFilePos(nextReadPos);
            rtFile.InputBytes((char*)&oldDataSize, sizeof(oldDataSize));
            
            //Write new append data to EXE file
            rtFile.SetFilePos(dataPos);
            rtFile.Print(dataBuffer);
            rtFile.Print((char*)&dataSize, sizeof(dataSize));
            rtFile.Print((char*)&dataPos, sizeof(dataPos));
            rtFile.Print(fileFooterID, strlen(fileFooterID));
    
            //If new data size is less than old data, truncate EXE file
            if(dataSize < oldDataSize)
            {
                truncSize = oldDataSize - dataSize;
                rtFile.TruncateFile(truncSize);
            }
            
            //Close EXE file
            rtFile.CloseFile();
        }
        else
        {
            //The data will be written to the end of the file
            dataPos = rtFileSize;
            
            //Write new append data to and close EXE file
            rtFile.SetFilePos(dataPos);
            rtFile.Print(dataBuffer);
            rtFile.Print((char*)&dataSize, sizeof(dataSize));
            rtFile.Print((char*)&dataPos, sizeof(dataPos));
            rtFile.Print(fileFooterID, strlen(fileFooterID));
            rtFile.CloseFile();
        }
    }
    else 
    {
        //ERROR
        MessageBox(NULL, "Failed to open file in AppendToFile().", "MacroByteCompiler", MB_OK | MB_ICONERROR | MB_SETFOREGROUND);
        ExitProcess(0);
    }
}

string ParseFilePath(string fileName)
//
{
    return fileName.substr(0, fileName.find_last_of("\\"));
}

