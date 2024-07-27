showconsole

var inStr as string

print "Trim, LTrim, RTrim"
print
print

input "Enter something: ", inStr

print
print "Trim: " + chr(34) + Trim(inStr) + chr(34)
print "LTrim: " + chr(34) + LTrim(inStr) + chr(34)
print "RTrim: " + chr(34) + RTrim(inStr) + chr(34)

print
print "Done."
