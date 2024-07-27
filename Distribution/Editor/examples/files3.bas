'Example #16
'File Handling Test #3
'Open a file for binary and read/write data
'Test Loc() function
'Test Seek statement
'Test Input() function

var fileData as string
var n as number

showconsole

'Compose file for input
print "Writing test file..."
open "testFile.txt" for output as #1
    print #1, "Line One"
    print #1, "Line Two"
    print #1, "Line Three"
    print #1, "Line Four"
close #1
print "Test file written."
print

print "Opening file for binary..."
Open "testFile.txt" For Binary As #1
print "File opened."
print

print "Reading data..."
print

Seek #1, 20
print "    Loc = " + str( Loc(1) )
fileData = Input(1, 12)
print fileData
print "    Loc = " + str( Loc(1) )
fileData = Input(1, 11)
print fileData
print "    Loc = " + str( Loc(1) )

'Seek #1, 10
'print "    Loc = " + str( Loc(1) )
'for n = 1 to 4
'    if Eof(1) = 0 then
'        Input #1, fileData
'        print fileData
'        print "    Loc = " + str( Loc(1) )
'    end if
'next n
'print

print "Data read."
print

'print "Writing data..."
'Seek #1, 10
'print "    Loc = " + str( Loc(1) )
'print #1, "Line One"
'print "Data written."
'print

print "Closing file..."
Close #1
print "File closed."
print