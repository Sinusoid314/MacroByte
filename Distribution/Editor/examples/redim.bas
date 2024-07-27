var a, b as number
var stuffCount as number
array stuff(1, 1) as string

showconsole
consoletitle "Redim Test 1"

for a = 1 to 4
    input "Enter stuff size: ", stuffCount

    ReDim stuff(stuffCount, 3)

    for b = 0 to stuffCount-1
        stuff(b, 0) = str(b*1)
        stuff(b, 1) = str(b*2)
        stuff(b, 2) = str(b*3)
    next b

    for b = 0 to stuffCount-1
        print stuff(b, 0) + "    -    " & stuff(b, 1) + "    -    " + stuff(b, 2)
    next b
next a

consoletitle "Done - Redim Test 1"