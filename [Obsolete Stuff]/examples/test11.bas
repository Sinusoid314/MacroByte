'Test #11

'var clickCount
clickCount = 0

New mainWin As Window( "Main Window", "normal", 200, 200, 400, 300 )
New button1 As Button( mainWin, "Button1", 100, 100, 80, 35 )

[mainWin] OnClose win_Close
[button1] OnClick button_Click

InputEvents


sub button_Click(aButton)
    clickCount = clickCount + 1
    [aButton] SetText "Click #" + str$(clickCount)
end sub

sub win_Close(aWin)
    delete aWin
    end
end sub