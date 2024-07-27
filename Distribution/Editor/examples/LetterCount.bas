'**** LetterCount ****

showconsole
consoletitle "LetterCount"

'Loop counters
Var a,b As Number

'Dimension array to 26 elements
Array LetterCount(26) As Number

'Temporary index number
Var tmpIdx As Number

'Temporary character
Var tmpChar As String

'String to check
Var checkStr As String

'Initialize variables/arrays
for a = 0 to 25
    LetterCount(a) = 0
next a
tmpIdx = 0
tmpChar = ""
checkStr = ""

@start

'Input string to count
Input "Enter string: ", checkStr

'Change all letters to lower case (since the upper case
'of each letter has a different ASCII value than its
'lower case)
checkStr = Lower(checkStr)

'Loop through each character
For a = 1 to Len(checkStr)

  'Get current character
  tmpChar = Mid(checkStr, a, 1)

  'Is the character a letter?
  If (Asc(tmpChar) >= Asc("a")) And (Asc(tmpChar) <= Asc("z")) Then

    'Calcoolate index number from letter's ASCII number
    tmpIdx = Asc(tmpChar) - Asc("a")

    'Increase letter's count
    LetterCount(tmpIdx) = LetterCount(tmpIdx) + 1

  End If

Next a

'Now print results
For a = 0 to 25
  Print Chr(Asc("a") + a) & " - ";
  For b = 1 to LetterCount(a)
    Print "*";
  Next b
  Print LetterCount(a)
Next a



consoletitle "LetterCount - Done."
end
