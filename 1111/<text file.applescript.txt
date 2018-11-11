# create file in Finder
tell application "Finder"
	try
		set myFolder to (the target of the front window) as alias
	on error
		beep
	end try
	
	display dialog ¬
		"New text file name:" default answer ".txt" buttons {"Cancel", "Create"} ¬
		default button 2
	set myFileName to text returned of result
	
	if exists file myFileName of myFolder then
		display alert ¬
			"A file named ‘" & myFileName & "’ already exists in this folder." as informational
		return
	end if
	
	set myPath to quoted form of ((POSIX path of myFolder) & myFileName)
	do shell script "touch " & myPath
	
	#open file in Emacs
	display dialog ¬
		"Open file with Emacs?" buttons {"Yes", "Cancel"} ¬
		default button 1
	if button returned of result is "Yes" then
		try
			tell application "System Events" to tell process "Emacs" to set frontmost to true
		on error
			tell application "/Users/suzume/Documents/Code/emacs/nextstep/Emacs.app"
				activate
				delay 1
			end tell
		end try
		
		set the clipboard to ((POSIX path of myFolder) & myFileName)
		tell application "/Users/suzume/Documents/Code/emacs/nextstep/Emacs.app"
			tell application "System Events"
				delay 0.5
				keystroke "x" using {control down}
				keystroke "f" using {control down}
				keystroke "a" using {control down}
				keystroke "y" using {control down}
				keystroke "k" using {control down}
				key code 36 # Escape
				delay 0.1
			end tell
		end tell
	end if
end tell

# found on http://daringfireball.net/2007/03/new_text_files_contextual_menu
