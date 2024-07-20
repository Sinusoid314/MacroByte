#ifndef _RUNTIME_DATA_H
#define _RUNTIME_DATA_H

class CDataCell
{
      public:
             void* dataPtr;
             int dataSize;
             int dataType;
             void Initialize(void);
             CDataCell& operator=(const CDataCell&);
             void SetData(CDataCell*);
             void SetData(int,void*,int);
             void SetDefaultData(int);
             void GetData(void*);
             void ClearData(void);
             bool isEqualTo(CDataCell*);
             bool Op_Add(CDataCell*,CDataCell*);
             bool Op_Subtract(CDataCell*,CDataCell*);
             bool Op_Multiply(CDataCell*,CDataCell*);
             bool Op_Divide(CDataCell*,CDataCell*);
             bool Op_Mod(CDataCell*,CDataCell*);
             bool Op_Exp(CDataCell*,CDataCell*);
             bool Op_Equal(CDataCell*,CDataCell*);
             bool Op_Less(CDataCell*,CDataCell*);
             bool Op_Greater(CDataCell*,CDataCell*);
             bool Op_LessOrEqual(CDataCell*,CDataCell*);
             bool Op_GreaterOrEqual(CDataCell*,CDataCell*);
             bool Op_NotEqual(CDataCell*,CDataCell*);
             bool Op_LogicalAND(CDataCell*,CDataCell*);
             bool Op_LogicalOR(CDataCell*,CDataCell*);
             bool Op_LogicalXOR(CDataCell*,CDataCell*);
             bool Op_BitwiseAND(CDataCell*,CDataCell*);
             bool Op_BitwiseOR(CDataCell*,CDataCell*);
             bool Op_BitwiseXOR(CDataCell*,CDataCell*);
             CDataCell(void);
             CDataCell(const CDataCell&);
             CDataCell(int,void*,int);
             CDataCell(CDataCell*);
             ~CDataCell(void);
};

class CArray
{
      public:
             CArrayDef* arrayDefPtr;
             std::vector<CDataCell*> elementList;
             std::vector<int> dimSizeList;
             CArray(void);
             ~CArray(void);
             CDataCell* Item(std::deque<int>&);
             void Initialize(CArrayDef*);
             void ReDim(std::vector<int>&);
             void ReDimAdd(CDataCell*, int);
             void ReDimRemove(int);
};

class CDataRef
{
      public:
             int dcrID;
	         int dcrIndex;
	         std::vector<int> dcrArrayIdxList;
	         CDataCell* dataCellPtr;
	         CDataRef(void);
	         ~CDataRef(void);
             void Initialize(int, int);
	         void SetCellData(int, void*, int);
};


extern std::vector<CDataCell*> LiteralList;
extern std::deque<int> ArrayIdxStack;
extern std::deque<CDataCell*> DataStack;

extern void PushDataCell(CDataCell*);
extern CDataCell* PopDataCell(void);

#endif
