'Not() Function Test
'Take user input and compare it to a string using Not()

var tmpStr as string

showconsol

input "Enter string: ", tmpStr
print

if Not(tmpStr = "abc") then
    print "NOT Equal to"
else
    print "Equal to"
end if

print Not(tmpStr = "abc")

print
print "Done."
