#!/usr/bin/env wish

# We don't need a visible window.
wm withdraw .

encoding system utf-8

set otherDisplay [lindex $argv 0]
set selection [lindex $argv 1]

# This gets called when another process tries to paste from our selection.
proc handleSelection {offset maxChars} {
    global otherDisplay selection
    variable status
    try {
        exec -keepnewline -ignorestderr {%%PREFIX%%/libexec/xclipsync/smart-xclip-out.sh} ${otherDisplay} ${selection}
    } trap CHILDSTATUS {results options} {
        set status [lindex [dict get $options -errorcode] 2]
        exit $status
    }
}

# This gets called when we lose ownership of the clipboard, which generally
# means someone cut/copy something on the current display.  We don't want
# to override that, so we exit and leave them alone.  xclipsync can start
# another copy of xclipfrom going in the other direction, from the newly-
# copied data on this display to the now-obsolete clipboard on the other
# display.
proc lostSelection {} {
    exit 0
}

# If we get asked for clipboard data, this is what we provide.
selection handle -selection ${selection} . handleSelection

# Take ownership of the clipboard, so if someone wants to paste, they
# come to us first.  We get called if someone else subsequently takes
# ownership.
selection own -selection ${selection} -command lostSelection .
