showconsole

var n as number

input "Enter number: ", n

print
'print str(n) + " * 2 = " + str(TimesTwo(n))
'message str(n), "Source Debug"
print TimesTwo(n)
print
print "Done."

function TimesTwo(num as number) as number
    TimesTwo = num * 2
    print
end function
