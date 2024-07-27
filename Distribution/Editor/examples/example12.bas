showconsole

var inStR as string
var cutPos, cutLen as number

print "Left, Mid, Right"
print
print

input "Enter something: ", instr
input "Enter position: ", cUtPos
input "Enter length: ", cutLen

print
print "Left: " + chr(34) + Left(inStr, cutLen) + chr(34)
print "Mid: " + chr(34) + Mid(inStr, cutPos, cutLen) + chr(34)
print "Right: " + chr(34) + Right(inStr, cutLen) + chr(34)

print
print "Done."
