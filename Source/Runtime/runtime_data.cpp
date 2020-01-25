#include <cstdlib>
#include <string>
#include <vector>
#include <deque>
#include <windows.h>
#include "..\[Libraries]\String Extension\stringExt.h"
#include "..\basic_tags.h"
#include "..\basic_def.h"
#include "runtime_main.h"
#include "runtime_data.h"
#include "runtime_cmd.h"

using namespace std;

deque<int> ArrayIdxStack;
deque<CDataCell*> DataStack;



//CDataCell Methods ****************************************************

CDataCell::CDataCell(void)
//
{
    Initialize();
}

CDataCell::CDataCell(const CDataCell& dataCell)
//Allocate memory and initialize it's data
{
    Initialize();
    SetData(dataCell.dataType, dataCell.dataPtr, dataCell.dataSize);
}

CDataCell::CDataCell(int initType, void* srcPtr, int srcSize)
//Allocate memory and initialize it's data
{
    Initialize();
    SetData(initType, srcPtr, srcSize);
}

CDataCell::CDataCell(CDataCell* dataCellPtr)
//Allocate memory and initialize it's data
{
    Initialize();
    SetData(dataCellPtr->dataType, dataCellPtr->dataPtr, dataCellPtr->dataSize);
}

CDataCell::~CDataCell(void)
//Deallocate memory
{
    ClearData();
}

void CDataCell::Initialize(void)
//
{
     dataPtr = NULL;
     dataSize = 0;
     dataType = DT_VOID;
}

CDataCell& CDataCell::operator=(const CDataCell& dataCell)
//Set raw data to a copy of the raw data from dataCell
{
    SetData(dataCell.dataType, dataCell.dataPtr, dataCell.dataSize);
    return *this;
}

void CDataCell::SetData(CDataCell* srcDat)
//Copy data from srcDat object to this object
{
     SetData(srcDat->dataType, srcDat->dataPtr, srcDat->dataSize);
}

void CDataCell::SetData(int srcType, void* srcPtr, int srcSize)
//Deallocate current memory, allocate new memory,
//and copy data from srcPtr to new memory location
{
    
    if(dataType == DT_VOID)
    {
        if(srcType == DT_VOID)
        {
            //Nothing to do here
            return;
        }
        else
        {
            //Allocate new memory and copy data
            if(srcPtr == NULL)
            {
                SetDefaultData(srcType);
            }
            else
            {
                dataPtr = malloc(srcSize);
                memcpy(dataPtr, srcPtr, srcSize);
                dataSize = srcSize;
                dataType = srcType;
            }
        }
    }
    else
    {
        if(srcType == DT_VOID)
        {
            //Deallocate current memory
            ClearData();
        }
        else
        {
            //Deallocate old, allocate new, and copy data
            if(srcPtr == NULL)
            {
                ClearData();
                SetDefaultData(srcType);
            }
            else
            {
                //Only reallocate if the source data size is different from the current
                if(dataSize != srcSize)
                {
                    ClearData();
                    dataPtr = malloc(srcSize);
                    dataSize = srcSize;
                }
                
                memcpy(dataPtr, srcPtr, srcSize);
                dataType = srcType;
            }
        }
    }
}

void CDataCell::SetDefaultData(int srcType)
{
    char tmpStr = '\0';
    double tmpNum = 0;
    
    if(srcType == DT_NUMBER)
    {
        dataPtr = malloc(sizeof(tmpNum));
        memcpy(dataPtr, &tmpNum, sizeof(tmpNum));
        dataSize = sizeof(tmpNum);
    }
    else if(srcType == DT_STRING)
    {
        dataPtr = malloc(sizeof(tmpStr));
        memcpy(dataPtr, &tmpStr, sizeof(tmpStr));
        dataSize = sizeof(tmpStr);
    }
    dataType = srcType;
}

void CDataCell::GetData(void* destPtr)
//Copy data to another memory location
{
    memcpy(destPtr, dataPtr, dataSize);
}

void CDataCell::ClearData(void)
//Clean up current data and set to DT_VOID
{
    if(dataPtr != NULL) free(dataPtr);
    dataPtr = NULL;
    dataSize = 0;
    dataType = DT_VOID;
}

bool CDataCell::isEqualTo(CDataCell* cmpDat)
//Compare data in dataPtr and cmpDat->dataPtr, and
//return TRUE or FALSE
{
      if(dataType != cmpDat->dataType) return false;
      
      if(dataSize != cmpDat->dataSize) return false;
      
      if(memcmp(dataPtr, cmpDat->dataPtr, dataSize) == 0)
      {
          return true;
      }
      else
      {
          return false;
      }
}

bool CDataCell::Op_Add(CDataCell* opDat, CDataCell* resDat)
//Add data from dataPtr and opDat->dataPtr and
//place the result in resDat
{
      double numRes;
      char* strRes;
      int strResSize;
      
      if(dataType != opDat->dataType) return false;
      
      if(dataType == DT_NUMBER)
      {
          numRes = (*((double*)dataPtr)) + (*((double*)opDat->dataPtr));
          resDat->SetData(DT_NUMBER, &numRes, sizeof(double));
      }
      else if(dataType == DT_STRING)
      {
          strResSize = dataSize + opDat->dataSize - 1;
          strRes = new char[strResSize];
          memcpy(strRes, dataPtr, dataSize-1);
          memcpy(strRes + (dataSize-1), opDat->dataPtr, opDat->dataSize);
          resDat->SetData(DT_STRING, (void*)strRes, strResSize);
          delete [] strRes;
      }
      
      return true;
}

bool CDataCell::Op_Subtract(CDataCell* opDat, CDataCell* resDat)
//Subtract data from dataPtr and opDat->dataPtr and
//place the result in resDat
{
      double numRes;
      
      if((dataType != DT_NUMBER) || (opDat->dataType != DT_NUMBER)) return false;
      
      numRes = (*((double*)dataPtr)) - (*((double*)opDat->dataPtr));
      resDat->SetData(DT_NUMBER, &numRes, sizeof(double));
      
      return true;
}

bool CDataCell::Op_Multiply(CDataCell* opDat, CDataCell* resDat)
//Multiply data from dataPtr and opDat->dataPtr and
//place the result in resDat
{
      double numRes;
    
      if((dataType != DT_NUMBER) || (opDat->dataType != DT_NUMBER)) return false;
      
      numRes = (*((double*)dataPtr)) * (*((double*)opDat->dataPtr));
      resDat->SetData(DT_NUMBER, &numRes, sizeof(double));
      
      return true;
}

bool CDataCell::Op_Divide(CDataCell* opDat, CDataCell* resDat)
//Divide data from dataPtr and opDat->dataPtr and
//place the result in resDat
{      
      double numRes;
      
      if((dataType != DT_NUMBER) || (opDat->dataType != DT_NUMBER)) return false;
      
      numRes = (*((double*)dataPtr)) / (*((double*)opDat->dataPtr));
      resDat->SetData(DT_NUMBER, &numRes, sizeof(double));
      
      return true;
}

bool CDataCell::Op_Mod(CDataCell* opDat, CDataCell* resDat)
//
{     
      double numRes;
      
      if((dataType != DT_NUMBER) || (opDat->dataType != DT_NUMBER)) return false;
      
      numRes = long(*((double*)dataPtr)) % long(*((double*)opDat->dataPtr));
      resDat->SetData(DT_NUMBER, &numRes, sizeof(double));
      
      return true;
}

bool CDataCell::Op_Exp(CDataCell* opDat, CDataCell* resDat)
//TODO
{

}

bool CDataCell::Op_Equal(CDataCell* cmpDat, CDataCell* resDat)
//Compare data in dataPtr and cmpDat->dataPtr, and
//place the result in resDat
{
      double numRes;
      
      if(isEqualTo(cmpDat))
      {
          numRes = 1;
      }
      else
      {
          numRes = 0;
      }
      
      resDat->SetData(DT_NUMBER, &numRes, sizeof(double));
      
      return true;
}

bool CDataCell::Op_Less(CDataCell* cmpDat, CDataCell* resDat)
//
{
      double numRes;
      string str1;
      string str2;
      
      if(dataType != cmpDat->dataType) return false;

      if(dataType == DT_NUMBER)
      {
          numRes = (*((double*)dataPtr)) < (*((double*)cmpDat->dataPtr));
          resDat->SetData(DT_NUMBER, &numRes, sizeof(double));
      }
      else if(dataType == DT_STRING)
      {
          str1 = (char*)dataPtr;
          str2 = (char*)cmpDat->dataPtr;
          numRes = (str1 < str2);
          resDat->SetData(DT_NUMBER, &numRes, sizeof(double));
          str1 = ""; str2 = "";
      }
      
      return true;
}

bool CDataCell::Op_Greater(CDataCell* cmpDat, CDataCell* resDat)
//
{
      double numRes;
      string str1;
      string str2;
      
      if(dataType != cmpDat->dataType) false;
      
      if(dataType == DT_NUMBER)
      {
          numRes = (*((double*)dataPtr)) > (*((double*)cmpDat->dataPtr));
          resDat->SetData(DT_NUMBER, &numRes, sizeof(double));
      }
      else if(dataType == DT_STRING)
      {
          str1 = (char*)dataPtr;
          str2 = (char*)cmpDat->dataPtr;
          numRes = (str1 > str2);
          resDat->SetData(DT_NUMBER, &numRes, sizeof(double));
          str1 = ""; str2 = "";
      }
      
      return true;
}

bool CDataCell::Op_LessOrEqual(CDataCell* cmpDat, CDataCell* resDat)
//
{
      double numRes;
      string str1;
      string str2;
      
      if(dataType != cmpDat->dataType) return false;
      
      if(dataType == DT_NUMBER)
      {
          numRes = (*((double*)dataPtr)) <= (*((double*)cmpDat->dataPtr));
          resDat->SetData(DT_NUMBER, &numRes, sizeof(double));
      }
      else if(dataType == DT_STRING)
      {
          str1 = (char*)dataPtr;
          str2 = (char*)cmpDat->dataPtr;
          numRes = (str1 <= str2);
          resDat->SetData(DT_NUMBER, &numRes, sizeof(double));
          str1 = ""; str2 = "";
      }
      
      return true;
}

bool CDataCell::Op_GreaterOrEqual(CDataCell* cmpDat, CDataCell* resDat)
//
{
      double numRes;
      string str1;
      string str2;
      
      if(dataType != cmpDat->dataType) false;
      
      if(dataType == DT_NUMBER)
      {
          numRes = (*((double*)dataPtr)) >= (*((double*)cmpDat->dataPtr));
          resDat->SetData(DT_NUMBER, &numRes, sizeof(double));
      }
      else if(dataType == DT_STRING)
      {
          str1 = (char*)dataPtr;
          str2 = (char*)cmpDat->dataPtr;
          numRes = (str1 >= str2);
          resDat->SetData(DT_NUMBER, &numRes, sizeof(double));
          str1 = ""; str2 = "";
      }
      
      return true;
}

bool CDataCell::Op_NotEqual(CDataCell* cmpDat, CDataCell* resDat)
//
{      
      double numRes;
      
      if(!isEqualTo(cmpDat))
      {
          numRes = 1;
      }
      else
      {
          numRes = 0;
      }
      
      resDat->SetData(DT_NUMBER, &numRes, sizeof(double));
      
      return true;
}

bool CDataCell::Op_LogicalAND(CDataCell* opDat, CDataCell* resDat)
{
      double numRes;
      
      if((dataType != DT_NUMBER) || (opDat->dataType != DT_NUMBER)) false;
      
      numRes = long(*((double*)dataPtr)) && long(*((double*)opDat->dataPtr));
      resDat->SetData(DT_NUMBER, &numRes, sizeof(double));
      
      return true;
}

bool CDataCell::Op_LogicalOR(CDataCell* opDat, CDataCell* resDat)
{
      double numRes;
      
      if((dataType != DT_NUMBER) || (opDat->dataType != DT_NUMBER)) false;
      
      numRes = long(*((double*)dataPtr)) || long(*((double*)opDat->dataPtr));
      resDat->SetData(DT_NUMBER, &numRes, sizeof(double));
      
      return true;
}

bool CDataCell::Op_LogicalXOR(CDataCell* opDat, CDataCell* resDat)
{
      double numRes;
      
      if((dataType != DT_NUMBER) || (opDat->dataType != DT_NUMBER)) false;
      
      //TODO
      numRes = long(*((double*)dataPtr)) ^ long(*((double*)opDat->dataPtr));
      resDat->SetData(DT_NUMBER, &numRes, sizeof(double));
      
      return true;
}

bool CDataCell::Op_BitwiseAND(CDataCell* opDat, CDataCell* resDat)
{
      double numRes;
      
      if((dataType != DT_NUMBER) || (opDat->dataType != DT_NUMBER)) false;
      
      numRes = long(*((double*)dataPtr)) & long(*((double*)opDat->dataPtr));
      resDat->SetData(DT_NUMBER, &numRes, sizeof(double));
      
      return true;
}

bool CDataCell::Op_BitwiseOR(CDataCell* opDat, CDataCell* resDat)
{
      double numRes;
      
      if((dataType != DT_NUMBER) || (opDat->dataType != DT_NUMBER)) false;
      
      numRes = long(*((double*)dataPtr)) | long(*((double*)opDat->dataPtr));
      resDat->SetData(DT_NUMBER, &numRes, sizeof(double));
      
      return true;
}

bool CDataCell::Op_BitwiseXOR(CDataCell* opDat, CDataCell* resDat)
{
      double numRes;
      
      if((dataType != DT_NUMBER) || (opDat->dataType != DT_NUMBER)) false;
      
      numRes = long(*((double*)dataPtr)) ^ long(*((double*)opDat->dataPtr));
      resDat->SetData(DT_NUMBER, &numRes, sizeof(double));
      
      return true;
}

//*********************************************************************



//CArray Methods ******************************************************

CArray::CArray(void)
//
{
    arrayDefPtr = NULL;
}

CArray::~CArray(void)
//Delete all CDataCell objects individually, then
//delete the pointer and dimension-size lists
{
     for(int n=0; n < elementList.size(); n++)
     {
         delete elementList[n];
     }
     elementList.clear();
     
     dimSizeList.clear();
}

void CArray::Initialize(CArrayDef* arrayDef)
//Initialize array properties using info in arrayDef
{
    arrayDefPtr = arrayDef;

    ReDim(arrayDefPtr->dimSizeList);
}

void CArray::ReDim(vector<int>& newDimSizeList)
//Delete current array data, calcoolate new linear
//size from the newDimSize list, create new array
//items, and initialize their values
{
    int newLinearSize;
    
    //If this isn't the first redim, delete the current array data
    if(elementList.size() > 0)
    {
        for(int n=0; n < elementList.size(); n++)
        {
            delete elementList[n];
        }
        elementList.clear();
    }
    
    //Calcoolate new linear size
    newLinearSize = 1;
    for(int n=0; n < arrayDefPtr->dimSizeList.size(); n++)
    {
        //Check if new dimension size is greater than zero
        if(!(newDimSizeList[n] > 0))
        {
            //ERROR
            errorMsg = "Size of array dimension " + NumToStr(n) + " is not greater than zero.";
            RuntimeError();
        }
        dimSizeList[n] = newDimSizeList[n];
        newLinearSize *= dimSizeList[n];
    }
    
    //Create new array with default data
    elementList.resize(newLinearSize);
    for(int n=0; n < elementList.size(); n++)
    {
        elementList[n] = new CDataCell(arrayDefPtr->arrayType, NULL, 0);
    }
}

CDataCell* CArray::Item(deque<int>& idxList)
//Calcoolate linear index from index numbers
//at the top of idxList, and return pointer
//to CDataCell object
{
    int linearIdx = 0;
    int multiplier = 1;

    if(idxList.size() < arrayDefPtr->dimSizeList.size()) return (CDataCell*) 0;

    for(int n=0; n < arrayDefPtr->dimSizeList.size(); n++)
    {
        if((idxList[n] < 0) || (idxList[n] >= dimSizeList[n]))
        {
            //ERROR
            errorMsg = "Array index '" + NumToStr(idxList[n]) + "' is out of bounds.";
            RuntimeError();
        }
        linearIdx += (idxList[n] * (multiplier));
        multiplier *= dimSizeList[n];
    }
    
    return elementList[linearIdx];
}

void CArray::ReDimAdd(CDataCell* newDatPtr, int beforeIdx)
//Insert newDatPtr into elementList at the index
//specified by beforeIdx
{    
    //Make sure this array only has one dimension
    if(arrayDefPtr->dimSizeList.size() != 1)
    {
        //ERROR
    }

    //Make sure beforeIdx is in the correct range
    if((beforeIdx < 0) || (beforeIdx > elementList.size())) beforeIdx = elementList.size();
    
    //Add new element
    elementList.insert(elementList.begin() + beforeIdx, newDatPtr);
    
    //Update array info
    dimSizeList[0] = elementList.size();
}

void CArray::ReDimRemove(int itemIdx)
//Remove the item specified by itemIdx from elementList
{    
    //Make sure this array only has one dimension
    if(arrayDefPtr->dimSizeList.size() != 1)
    {
        //ERROR
    }

    //Make sure itemIdx is in the correct range
    if((itemIdx < 0) || (itemIdx > (elementList.size()-1)))
    {
        //ERROR
    }
    
    //Delete array element
    delete elementList[itemIdx];
    elementList.erase(elementList.begin() + itemIdx);
    
    //Update array info
    dimSizeList[0] = elementList.size();
}

//*********************************************************************



//CDataRef Methods ************************************************

CDataRef::CDataRef(void)
//
{
}

CDataRef::~CDataRef(void)
//
{
    dcrArrayIdxList.clear();
}

void CDataRef::Initialize(int dataRefID, int dataRefIndex)
//Retrieve pointer to the CDataCell object identified by dataRefID
//and dataRefIndex, and save its data-cell reference info
{
    CArray* arrayPtr = NULL;
    
    //Save general data-cell reference info
    dcrID = dataRefID;
    dcrIndex = dataRefIndex;
    
    switch(dataRefID)
    {
        case DATAREF_DATASTACK:
            dataCellPtr = DataStack[dataRefIndex];
            break;
            
        case DATAREF_LITERAL:
            dataCellPtr = LiteralList[dataRefIndex];
            break;
            
        case DATAREF_GLOBALVAR:
            dataCellPtr = spList.front()->varList[dataRefIndex];
            break;
            
        case DATAREF_GLOBALARRAYITEM:
            arrayPtr = spList.front()->arrayList[dataRefIndex];
            dataCellPtr = arrayPtr->Item(ArrayIdxStack);
            break;
            
        case DATAREF_LOCALVAR:
            dataCellPtr = spList.back()->varList[dataRefIndex];
            break;
            
        case DATAREF_LOCALARRAYITEM:
            arrayPtr = spList.back()->arrayList[dataRefIndex];
            dataCellPtr = arrayPtr->Item(ArrayIdxStack);
            break;
            
        default:
            dataCellPtr = NULL;
            break;
    }
    
    //Save array item's index values (if applicable)
    if(arrayPtr != NULL)
    {
        dcrArrayIdxList.resize(arrayPtr->arrayDefPtr->dimSizeList.size());
        for(int n = 0; n < dcrArrayIdxList.size(); n++)
        {
            dcrArrayIdxList[n] = ArrayIdxStack[n];
        }
        ArrayIdxStack.erase(ArrayIdxStack.begin(), ArrayIdxStack.begin() + dcrArrayIdxList.size());
    }
}

void CDataRef::SetCellData(int srcType, void* srcPtr, int srcSize)
//Set the data of dataCellPtr
{
    dataCellPtr->SetData(srcType, srcPtr, srcSize);
}

//*********************************************************************


void PushDataCell(CDataCell* dataCellPtr)
//
{
    DataStack.push_front(dataCellPtr);
}

CDataCell* PopDataCell(void)
//
{
    CDataCell* dataCellPtr;
    
    dataCellPtr = DataStack[0];
    DataStack.pop_front();
    return dataCellPtr;
}

