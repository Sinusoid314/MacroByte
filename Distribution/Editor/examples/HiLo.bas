'**** HiLo ****
'
'Ask the user to guess a randomly-generated
'number between 1 and 100

var guessMe as number
var guess as number
var count as number
var play as string

showconsol

consoltitle "Now playing HiLo..."

@start
    guessMe = int(rnd()*100) + 1
    
    cls

    print
    print
    print
    print "        HI-LO         "
    print "----------------------"
    print
    print
    
@ask
    input "What is your guess? ", guess
    
    count = count + 1
    
    print
    
    if guess = guessMe then goto @win
    if guess < guessMe then print "Guess higher."
    if guess > guessMe then print "Guess lower."
    
    print

    goto @ask
    
@win
    print
    print "YOU A WINNA! HAHAHA!! It only took " + str(count) + " guesses."
    
    count = 0
    
    input "Play again? (y/n): ", play
    if play = "y" then goto @start
    
    print
    print "Done."
    consoltitle "HiLo - Done."
