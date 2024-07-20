#include <cstdlib>
#include <iostream>
#include <cstring>
#include "windows.h"

using namespace std;

int main(int argc, char *argv[])
{
    HANDLE fileHandle;
    string fileName;
    int fileSize;
    char fileInput;
    int filePtr;
    DWORD bytesRead;
    
    fileName = "test.txt";
    
    fileHandle = CreateFile(fileName.c_str(), GENERIC_WRITE | GENERIC_READ, 0, NULL,
                               OPEN_EXISTING, 
                               FILE_ATTRIBUTE_NORMAL, 
                               NULL);
    /*
    fileSize = GetFileSize(fileHandle, NULL);
    cout << fileSize << endl << endl;
    
    //SetFilePointer(fileHandle, -1, NULL, FILE_END);
    WriteFile(fileHandle, "abcdefgh", 8, &bytesRead, NULL);
    
    fileSize = GetFileSize(fileHandle, NULL);
    cout << fileSize << endl << endl;
    */
    
    fileSize = GetFileSize(fileHandle, NULL);
    cout << fileSize << endl << endl;
    
    filePtr = SetFilePointer(fileHandle, 0, NULL, FILE_CURRENT);
    cout << filePtr << endl << endl;
    
    for(int n=1; n<=fileSize; n++)
    {
    ReadFile(fileHandle, &fileInput, 1, &bytesRead, NULL);
    cout << fileInput << endl;
    filePtr = SetFilePointer(fileHandle, 0, NULL, FILE_CURRENT);
    cout << filePtr << endl << endl;
    }
    
    
    
    CloseHandle(fileHandle);
    
    system("PAUSE");
    return EXIT_SUCCESS;
}
