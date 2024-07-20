showconsol
consoltitle "Redim Test 3 - RedimAdd/RedimRemove"

var listSize as number
array listNames(1) as string
var menuSel as number

listSize = 0
listNames(0) = ""


@mainMenu

print
print "----------------"
print "Redim Menu"
print "----------------"
print
print "1 - List all names"
print "2 - Add name"
print "3 - Remove name"
print "4 - Exit"
print

input "Enter selection: ", menuSel
print

if menuSel = 1 then
    call ListNames
elseif menuSel = 2 then
    call AddName
elseif menuSel = 3 then
    call RemoveName
else
    call Exit
end if

goto @mainMenu


sub ListNames()
    var tmpIdx as number
    
    print
    print "ListNames"
    print
    
    for tmpIdx = 1 to listSize
         print listNames(tmpidx)
    next tmpidx
    
    print
end sub


sub AddName()
    var tmpName as string
    var tmpIdx as number
    
    print
    print "AddName"
    print
    
    input "Enter name: ", tmpName
    input "Enter index: ", tmpidx
    
    RedimAdd listNames, tmpName, tmpidx
    listSize = listSize + 1
    
    print 
end sub


sub RemoveName()
    var tmpIdx as number
    
    print
    print "RemoveName"
    print
    
    input "Enter index: ", tmpIdx
    
    RedimRemove listNames, tmpidx
    listSize = listSize - 1
    
    print
end sub


sub Exit()
    print
    print "Done."
    consoltitle "Done - Redim Test 3"
    end
end sub
