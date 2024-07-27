showconsole

var tmpStr as string

consoletitle "While/Wend Test"

tmpStr = ""
While lower(tmpStr) <> "exit"
    input "Enter string: ", tmpStr
    print tmpStr
Wend

print
print "While loop done."

consoletitle "Done - While/Wend Test"
