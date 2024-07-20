#ifndef _RUNTIME_LOADER_H
#define _RUNTIME_LOADER_H

extern std::string rtFilePath;
extern std::string rtFileName;

void LoadRunFile(void);
void ExtractRunData(std::string&);
void DTask(std::string&);
void SplitLines(std::string&, std::vector<std::string>&);

#endif
