showconsole

var num As Number
var path As Number

@go

input "Enter number: ", num

input "Enter path: ", path

if path = 10 AND num = 2 then
    print "one"
    print (num+2) / 3
else
    print "two"
    print num + 2 / 3
    goto @go
end if

print "End."