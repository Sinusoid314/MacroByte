#include <cstdlib>
#include <sstream>
#include <string>
#include <windows.h>
#include "basic_fileIO.h"
    
using namespace std;


//CFile Methods *******************************************************

CFile::CFile(void)
{
    
}

CFile::~CFile(void)
//
{
    CloseFile();
}

bool CFile::OpenFile(const char* newFileName, int newID, int newType)
//
{
    //Set file properties
    fileType = newType;
    fileID = newID;
    
    //Open file
    switch(fileType)
    {
        case FT_INPUT:
            fileHandle = CreateFile(newFileName, GENERIC_READ, 0, NULL,
                               OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL);
            break;
            
        case FT_OUTPUT:
            fileHandle = CreateFile(newFileName, GENERIC_WRITE, 0, NULL,
                               CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL);
            break;
            
        case FT_APPEND:
            fileHandle = CreateFile(newFileName, GENERIC_WRITE, 0, NULL,
                               OPEN_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL);
            SetFilePointer(fileHandle, 0, NULL, FILE_END);
            break;
            
        case FT_BINARY:
            fileHandle = CreateFile(newFileName, GENERIC_READ | GENERIC_WRITE, 0, NULL,
                               OPEN_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL);
            break;
            
        default:
            //ERROR
            fileErrorStr = "Invalid file type.";
            return false;
            break;
    }
    
    if(fileHandle == INVALID_HANDLE_VALUE)
    {
        //ERROR
        fileErrorStr = "Failed to open file \"";
        fileErrorStr += string(newFileName); fileErrorStr += "\".";
        return false;
    }
    
    return true;
}

void CFile::CloseFile(void)
//Close file object
{
    CloseHandle(fileHandle);
}

void CFile::SetFilePos(long newPos)
//Set the read/write position of the file
{
    SetFilePointer(fileHandle, newPos, NULL, FILE_BEGIN);
}

long CFile::GetFilePos(void)
//Return the current read/write position of the file
{
    return SetFilePointer(fileHandle, 0, NULL, FILE_CURRENT);
}

long CFile::GetFileLength(void)
//Return the current length (in bytes) of the file
{
    return GetFileSize(fileHandle, NULL);
}

bool CFile::EndOfFile(void)
//Return TRUE if end-of-file is reached, FALSE if not
{
    if(SetFilePointer(fileHandle, 0, NULL, FILE_CURRENT)
       == GetFileSize(fileHandle, NULL))
    {
        return true;
    }
    else
    {
        return false;
    }
}

bool CFile::Print(const string& outputStr)
//Print output string to the file, if the file's type allows printing
{
    DWORD bytesWritten;

    //Check if output is allowed
    if((fileType == FT_INPUT))
    {
        //ERROR
        fileErrorStr = "Writing to file #";
        fileErrorStr += static_cast<ostringstream*>(&(ostringstream() << fileID))->str();
        fileErrorStr += " is not allowed.";
        return false;
    }
    
    //Print string
    WriteFile(fileHandle, outputStr.c_str(), outputStr.length(),
              &bytesWritten, NULL);
    
    return true;
}

bool CFile::Print(const char* outputBytes, long byteLen)
//
{
    DWORD bytesWritten;
    
    //Check if output is allowed
    if((fileType == FT_INPUT))
    {
        //ERROR
        fileErrorStr = "Writing to file #";
        fileErrorStr += static_cast<ostringstream*>(&(ostringstream() << fileID))->str();
        fileErrorStr += " is not allowed.";
        return false;
    }
    
    //Print string
    WriteFile(fileHandle, outputBytes, byteLen,
              &bytesWritten, NULL);
    
    return true;
}

bool CFile::InputField(string& inputStr)
//Reads in a field (data seperated by a comma or newline) from the file
{
    char tmpChar;
    DWORD bytesRead;
    
    //Check if input is allowed
    if((fileType != FT_INPUT) && (fileType != FT_BINARY))
    {
        //ERROR
        fileErrorStr = "Reading from file #";
        fileErrorStr += static_cast<ostringstream*>(&(ostringstream() << fileID))->str();
        fileErrorStr += " is not allowed.";
        return false;
    }
    
    //Read in data from file
    while(!EndOfFile())
    {
        ReadFile(fileHandle, &tmpChar, 1, &bytesRead, NULL);
        
        if(tmpChar == '\r')
        {
            if(!EndOfFile())
            {
                ReadFile(fileHandle, &tmpChar, 1, &bytesRead, NULL);
                if(tmpChar == '\n')
                {
                    break;
                }
                else
                {
                    inputStr += '\r';
                    inputStr += tmpChar;
                }
            }
            else
            {
                inputStr += '\r';
                break;
            }
        }
        else if(tmpChar == ',')
        {
            break;
        }
        else
        {
            inputStr += tmpChar;
        }
    }
    
    return true;
}

bool CFile::InputLine(string& inputStr)
//Reads in a line (data seperated by a newline) from the file
{
    char tmpChar;
    DWORD bytesRead;
    
    //Check if input is allowed
    if((fileType != FT_INPUT) && (fileType != FT_BINARY))
    {
        //ERROR
        fileErrorStr = "Reading from file #";
        fileErrorStr += static_cast<ostringstream*>(&(ostringstream() << fileID))->str();
        fileErrorStr += " is not allowed.";
        return false;
    }
    
    //Read in data from file
    while(!EndOfFile())
    {
        ReadFile(fileHandle, &tmpChar, 1, &bytesRead, NULL);
        
        if(tmpChar == '\r')
        {
            if(!EndOfFile())
            {
                ReadFile(fileHandle, &tmpChar, 1, &bytesRead, NULL);
                if(tmpChar == '\n')
                {
                    break;
                }
                else
                {
                    inputStr += '\r';
                    inputStr += tmpChar;
                }
            }
            else
            {
                inputStr += '\r';
                break;
            }
        }
        else
        {
            inputStr += tmpChar;
        }
    }
    
    return true;
}

bool CFile::InputBytes(string& inputStr, long byteLen)
//Reads in a specified number of bytes from the file
{
    char* tmpStr;
    DWORD bytesRead;
    BOOL rfRes;
    
    //Check if input is allowed
    if((fileType != FT_INPUT) && (fileType != FT_BINARY))
    {
        //ERROR
        fileErrorStr = "Reading from file #";
        fileErrorStr += static_cast<ostringstream*>(&(ostringstream() << fileID))->str();
        fileErrorStr += " is not allowed.";
        return false;
    }
    
    //Read in data from file
    tmpStr = new char[byteLen + 1];
    rfRes = ReadFile(fileHandle, tmpStr, byteLen, &bytesRead, NULL);
    tmpStr[byteLen] = '\0';
    inputStr = tmpStr;
    delete [] tmpStr;
    if((rfRes) && (bytesRead == 0))
    {
        fileErrorStr  = "Cannot read past end of file #";
        fileErrorStr += static_cast<ostringstream*>(&(ostringstream() << fileID))->str();
        fileErrorStr += ".";
        return false;
    }
    
    return true;
}

bool CFile::InputBytes(char* inputBytes, long byteLen)
//
{
    DWORD bytesRead;
    BOOL rfRes;
    
    //Check if input is allowed
    if((fileType != FT_INPUT) && (fileType != FT_BINARY))
    {
        //ERROR
        fileErrorStr = "Reading from file #";
        fileErrorStr += static_cast<ostringstream*>(&(ostringstream() << fileID))->str();
        fileErrorStr += " is not allowed.";
        return false;
    }
    
    //Read in data from file
    rfRes = ReadFile(fileHandle, inputBytes, byteLen, &bytesRead, NULL);
    if((rfRes) && (bytesRead == 0))
    {
        fileErrorStr  = "Cannot read past end of file #";
        fileErrorStr += static_cast<ostringstream*>(&(ostringstream() << fileID))->str();
        fileErrorStr += ".";
        return false;
    }
    
    return true;
}

bool CFile::TruncateFile(long truncSize)
//
{
    DWORD newFileSize;
    DWORD dwFileSizeLow;
    DWORD dwFileSizeHigh;
    
    //Make sure file is opened for BINARY
    if(fileType != FT_BINARY)
    {
        //ERROR
        fileErrorStr = "Cannot truncate file #";
        fileErrorStr += static_cast<ostringstream*>(&(ostringstream() << fileID))->str();
        fileErrorStr += " - file must be opened in BINARY mode.";
        return false;
    }
    
    //Get the file size
    dwFileSizeLow = GetFileSize(fileHandle, &dwFileSizeHigh);
    
    if(dwFileSizeHigh == 0)
    {
        //Calcoolate new size
        newFileSize = dwFileSizeLow - truncSize;
        
        //Move file pointer to the new end position
        if(SetFilePointer(fileHandle, newFileSize, (PLONG)&dwFileSizeHigh, FILE_BEGIN) > 0)
        {
            //Resize file
            SetEndOfFile(fileHandle);
        }
    }
    
    return true;
}

bool DirectoryExists(const string& dirName)
{
  DWORD dwAttrib = GetFileAttributes(dirName.c_str());

  return (dwAttrib != INVALID_FILE_ATTRIBUTES && 
         (dwAttrib & FILE_ATTRIBUTE_DIRECTORY));
}

bool FileExists(const string& fileName)
{
  DWORD dwAttrib = GetFileAttributes(fileName.c_str());

  return (dwAttrib != INVALID_FILE_ATTRIBUTES && 
         !(dwAttrib & FILE_ATTRIBUTE_DIRECTORY));
}

//*********************************************************************
