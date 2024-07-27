'**** FiZZBuZZ ****
'
'Write a program that prints the numbers
'from 1 to 100. But for multiples of three
'print "Fizz" instead of the number and for
'the multiples of five print "Buzz". For
'numbers which are multiples of both three
'and five print "FizzBuzz".


var n as number
var outStr as string

showconsole

for n = 1 to 100

    outStr = ""

    if (n/3) = int(n/3) then outStr = outStr + "FiZZ"

    if (n/5) = int(n/5) then outStr = outStr + "BuZZ"

    if outStr = "" then
        print n
    else
        print outStr
    end if

next n

print
print "Done."
