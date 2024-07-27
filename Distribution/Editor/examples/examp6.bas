showconsole

var num as number

input "Enter number: ", num

print num
print

if num < 10 then
    print "Less than 10"
    if num < 6 then
        print "Less than 6"
    else
        print "NOT less than 6"
    end if
else
    print "NOT less than 10"
    if num < 6 then
        print "Less than 6"
    else
        print "NOT less than 6"
    end if
end if

print
print "Done."
