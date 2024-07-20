showconsol
consoltitle "Redim Test 2"

var xIdx, yIdx, zIdx as number
var xCount, yCount, zCount as number
array stuffGrid(1, 1, 1) as string

input "Enter cube width: ", xCount
input "Enter cube height: ", yCount
input "Enter cude depth: ", zCount
print
print

ReDim stuffGrid(xCount, yCount, zCount)

for zIdx = 0 to zCount-1
    for yIdx = 0 to yCount-1
        for xIdx = 0 to xCount-1
            stuffGrid(xIdx, yIdx, zIdx) = "(" + str(xIdx) + "," + str(yIdx) + "," + str(zIdx) + ") "
            print stuffGrid(xIdx, yIdx, zIdx);
        next xIdx
        print
    next yIdx
    print
next zIdx

consoltitle "Done - Redim Test 2"