showconsol

var inVar as number
var outVar as string

input "Yo! ", inVar

if inVar = 4 then
    @foo
    input "EXIT???? ", outVar
    if outVar = "y" then
        goto @zeeEnd
    else
        goto @foo
    end if
else
    print "D'OH!"
end if

@zeeEnd
print "FIN."
end
