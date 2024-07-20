'Test #10

showconsol

New mainWin As Window( "Main Window", "normal", 200, 200, 400, 300 )
New btn1 As Button( mainWin, "Button #1", 100, 10, 80, 35 )
New btn2 As Button( mainWin, "Button #2", 100, 50, 80, 35 )
New btn3 As Button( mainWin, "Button #3", 100, 90, 80, 35 )
New btn4 As Button( mainWin, "Button #4", 100, 130, 80, 35 )

[mainWin] OnClose win_Close
[btn1] OnClick btn_Click

InputEvents


sub btn_Click(aBtn)
    print "Button #" + str$(aBtn-1) + " clicked"
end sub

sub win_Close(aWin)
    delete aWin
    end
end sub