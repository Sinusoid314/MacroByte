#include <cstdlib>
#include <cstring>
#include <string>
#include "basic_tags.h"
#include "basic_datacell.h"

using namespace std;


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

