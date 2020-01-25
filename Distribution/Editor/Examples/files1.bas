'Example #14
'File Handling Test #1
'Open a file for output and write data to it

showconsol

print "Opening file..."
'**Open "testFile.txt" For Output As #1
Open "testFile.txt" For Append As #1
print "File opened."
print

print "LOF = " + str( Lof(1) )
print

print "Printing lines..."

print #1, "Line One"
print #1, "Line Two"
print #1, "Line Three"

print "Lines printed."
print

print "LOF = " + str( Lof(1) )
print

print "Closing file..."
Close #1
print "File closed."
print
