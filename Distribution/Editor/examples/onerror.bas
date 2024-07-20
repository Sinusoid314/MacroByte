showconsol
consoltitle "OnError Test"

array testArray(10) as string
var itemIdx as number

OnError HandleError

input "Enter array index: ", itemIdx

print
print testArray(itemIdx)

consoltitle "Done - OnError Test"


sub HandleError(errMsg as string)
    message errMsg, "OnError Test"
end sub
