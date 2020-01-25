#ifndef _RUNTIME_FILEIO_H
#define _RUNTIME_FILEIO_H

extern std::vector<CFile*> fileList;

void AddFile(std::string&, int, int);
void RemoveFile(int);
bool GetFileIndex(int, int&);

#endif
