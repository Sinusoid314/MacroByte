showconsol

var tmpStr as string

consoltitle "While/Wend Test"

tmpStr = ""
While lower(tmpStr) <> "exit"
    input "Enter string: ", tmpStr
    print tmpStr
Wend

print
print "While loop done."

consoltitle "Done - While/Wend Test"
