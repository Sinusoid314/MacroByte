#ifndef _ASSEMBLER_MAIN_H
#define _ASSEMBLER_MAIN_H

class CLiteral
{
    public:
           string litStr;
           int litType;
           CLiteral(void);
           CLiteral(const string&, int);
};

extern std::string rawData;
extern std::string rtExeFileName;

extern std::vector<CLiteral> LiteralList;

void AssembleFile(void);
void AssembleSubProg(int);
void WriteRawData(const std::string&);
void WriteRawData(double);
void ETask(std::string&);
void AppendToFile(std::string, std::string&);
std::string ParseFilePath(std::string);

#endif
