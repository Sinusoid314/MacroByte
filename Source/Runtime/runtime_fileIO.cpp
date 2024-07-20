#include <cstdlib>
#include <string>
#include <vector>
#include <windows.h>
#include "..\..\..\[Libraries]\String Extension\stringExt.h"
#include "..\..\..\[Libraries]\File IO\FileIO.h"
#include "runtime_main.h"
#include "runtime_fileIO.h"
    
using namespace std;

vector<CFile*> fileList;


void AddFile(string& newName, int newID, int newType)
//Create a new CFile object and add it to fileList[]
{
    CFile* newFilePtr;
    int tmpIdx;
    
    //Check fileList to see if file already exists
    if(GetFileIndex(newID, tmpIdx))
    {
        //ERROR
        errorMsg = "File handle #" + NumToStr(newID) + " is already in use.";
        RuntimeError();
    }
    
    //Add new file object to fileList
    newFilePtr = new CFile;
    if( !(newFilePtr->OpenFile(newName.c_str(), newID, newType)) )
    {
        //ERROR
        errorMsg = newFilePtr->fileErrorStr;
        RuntimeError();
    }
    fileList.push_back(newFilePtr);
}

void RemoveFile(int fileID)
//Remove the CFile object, identified by fileID, from fileList[]
{
    int tmpIdx;
    
    //Get file object's index from ID
    if(!GetFileIndex(fileID, tmpIdx))
    {
        //ERROR
        errorMsg = "File handle #" + NumToStr(fileID) + " not found.";
        RuntimeError();
    }
    
    //Delete file object and remove fileList entry
    delete fileList[tmpIdx];
    fileList.erase(fileList.begin()+tmpIdx);
}

bool GetFileIndex(int fileID, int& fileIdx)
//Get file index from ID
{
    fileIdx = -1;
    
    for(int n=0; n<fileList.size(); n++)
    {
        if(fileID == fileList[n]->fileID)
        {
            fileIdx = n;
            return true;
        }
    }
    
    return false;
}

