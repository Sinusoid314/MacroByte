#ifndef _BASIC_FILEIO_H
#define _BASIC_FILEIO_H

#define FT_INPUT 1
#define FT_OUTPUT 2
#define FT_APPEND 3
#define FT_BINARY 4

class CFile
{
      public:
		     int fileID;
		     int fileType;
		     HANDLE fileHandle;
		     std::string fileErrorStr;
		     CFile(void);
		     ~CFile(void);
		     bool OpenFile(const char*, int, int);
		     void CloseFile(void);
		     void SetFilePos(long);
		     long GetFilePos(void);
		     long GetFileLength(void);
		     bool EndOfFile(void);
		     bool Print(const std::string&);
		     bool Print(const char*, long);
		     bool InputField(std::string&);
	         bool InputLine(std::string&);
		     bool InputBytes(std::string&, long);
		     bool InputBytes(char*, long);
		     bool TruncateFile(long);
};

bool DirectoryExists(const std::string&);
bool FileExists(const std::string&);

#endif
