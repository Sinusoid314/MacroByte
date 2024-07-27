'Example #15
'File Handling Test #2
'Open a file for input and read data from it
'Test Eof() function

var fileData as string
var n as number

showconsole

'Compose file for input
print "Writing test file..."
open "testFile.txt" for output as #1
    print #1, "Line One,";
    print #1, "Line Two"
    print #1, "Line Three,";
    print #1, "Line Four"
close #1
print "Test file written."
print

print "Opening file for input..."

Open "testFile.txt" For Input As #1

print "File opened."
print

print "Reading data..."
print

for n = 1 to 5
    if Eof(1) = 0 then
        Input #1, fileData
        '**Line Input #1, fileData
        print fileData
    end if
next n

print

print "Data read."
print

print "Closing file..."

Close #1

print "File closed."
print
