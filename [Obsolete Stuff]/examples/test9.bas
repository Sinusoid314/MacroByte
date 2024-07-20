'Test #9

New mainWin As Window( "Main Window", "normal", 200, 200, 400, 300 )

[mainWin] OnClose mainWin_Close

InputEvents


sub mainWin_Close(aWin)
    delete aWin
    end
end sub