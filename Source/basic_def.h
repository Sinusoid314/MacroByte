#ifndef _BASIC_DEF_H
#define _BASIC_DEF_H

extern const char* fileFooterID;

class CArrayDef
{
      public:
             std::string arrayName;
             int arrayType;
             std::vector<int> dimSizeList;
             CArrayDef(void);
             ~CArrayDef(void);
};

class CCommand
{
      public:
             std::vector<int> argList;
             CCommand(void);
             CCommand(int, int argCount = 1);
             ~CCommand(void);
};

class CSubProgDef
{
      public:
             std::string subProgName;
             int paramNum;
             bool isFunc;
             std::vector<std::string> varNameList;
             std::vector<int> varTypeList;
             std::vector<CArrayDef*> arrayDefList;
             std::vector<CCommand*> byteCodeList;
             
             #ifdef _COMPONENT_COMPILER
             int forBlockNum;
             int whileBlockNum;
             std::vector<std::string> labelNameList;
             std::vector<int> labelLocList;             
             std::vector<std::string> sourceCodeList;
             std::vector<int> rawCodeIndexList;
             #endif
             
             CSubProgDef(void);
             ~CSubProgDef(void);
};

extern int rtMode;
extern std::string workingDir;

extern std::vector<std::string> rawSourceCodeList;
extern std::vector<CSubProgDef*> spDefList;

#endif
