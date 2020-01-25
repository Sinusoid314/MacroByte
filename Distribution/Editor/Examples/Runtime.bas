
New bgWin As Window( "Background Window", "normal", 200, 200, 400, 300 )

@start
    guessMe = int(rnd()*100) + 1
    
    cls

    print
    print
    print
    print "        HI-LO         "
    print "-----------------"
    print
    print
    
@ask
    input "OK. What is your guess? ", guess
    
    count = count + 1
    
    if guess = guessMe then goto @win
    if guess < guessMe then print "Guess higher."
    if guess > guessMe then print "Guess lower."
    
    goto @ask
    
@win
    print
    print "YOU A WINNA! HAHAHA!! It only took " + str$(count) + " guesses."
    
    count = 0
    
    input "Play again? (y/n): ", play$
    if play$ = "y" then goto @start

    delete bgWin

    print
    print "Done."
