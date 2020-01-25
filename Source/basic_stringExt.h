#ifndef _BASIC_STRINGEXT_H
#define _BASIC_STRINGEXT_H

std::string MidStr(const std::string&, unsigned int, unsigned int cutLen = std::string::npos);
std::string LeftStr(const std::string&, unsigned int);
std::string RightStr(const std::string&, unsigned int);
std::string TrimStr(const std::string&);
std::string LTrimStr(const std::string&);
std::string RTrimStr(const std::string&);
std::string UCaseStr(const std::string&);
std::string LCaseStr(const std::string&);
std::string NumToStr(double);
double StrToNum(const std::string&);
bool IsNumericStr(const std::string&);

#endif
