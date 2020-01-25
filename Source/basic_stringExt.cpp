#include <sstream>
#include <string>
#include "basic_stringExt.h"

using namespace std;


string MidStr(const string& inStr, unsigned int cutPos, unsigned int cutLen)
{
    if(cutPos >= inStr.length())
    {
        return string("");
    }
    else
    {
        return inStr.substr(cutPos, cutLen);
    }
}

string LeftStr(const string& inStr, unsigned int cutLen)
{
	return inStr.substr(0, cutLen);
}

string RightStr(const string& inStr, unsigned int cutLen)
{
    if(cutLen == 0)
    {
        return string("");
    }
    else if(cutLen < inStr.length())
    {
        return inStr.substr(inStr.length()-cutLen);
    }
    else
    {
	    return inStr;
	}
}

string TrimStr(const string& inStr)
{
    unsigned int cutPos;
    unsigned int cutLen;
    
    cutPos = inStr.find_first_not_of(' ');
    
    if(cutPos != string::npos)
    {
        cutLen = inStr.find_last_not_of(' ') - cutPos + 1;
        return inStr.substr(cutPos, cutLen);
    }
    else
    { 
        return string("");
    }
    
    return inStr;
}

string LTrimStr(const string& inStr)
{
    unsigned int cutPos;
    
    cutPos = inStr.find_first_not_of(' ');
    
    if(cutPos != string::npos)
    {
        return inStr.substr(cutPos);
    }
    else
    { 
        return string("");
    }
}

string RTrimStr(const string& inStr)
{
    unsigned int cutPos;

    cutPos = inStr.find_last_not_of(' ');
    
    if(cutPos != string::npos)
    {
        return inStr.substr(0, cutPos + 1);
    }
    else
    { 
        return string("");
    }
}

string UCaseStr(const string& inStr)
{
    string outStr = inStr;
    
    for(int n=0; n<inStr.length(); n++)
    {
        if( (int(inStr[n]) >= 97) && (int(inStr[n]) <= 122) )
        {
            outStr[n] = char( int(inStr[n]) - 32 );
        }
    }

    return outStr;
}

string LCaseStr(const string& inStr)
{
	string outStr = inStr;
    
    for(int n=0; n < inStr.length(); n++)
    {
        if( (int(inStr[n]) >= 65) && (int(inStr[n]) <= 90) )
        {
            outStr[n] = char( int(inStr[n]) + 32 );
        }
    }

    return outStr;
}

string NumToStr(double num)
//Convert the given number into a string object
{
    return static_cast<ostringstream*>(&(ostringstream() << num))->str();
}

double StrToNum(const string& str)
//Convert a string object to a number
{
	double tmpNum;
    istringstream(str) >> tmpNum;
    return tmpNum;
}

bool IsNumericStr(const string& str)
//Find out if a string contains a number
{
    stringstream tmpStream;
    double tmpNum;
    tmpStream << str;
    tmpStream >> tmpNum;
    return tmpStream.eof();
}
