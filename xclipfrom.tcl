#!/usr/bin/env wish
#
# Copyright (c) 2026, Jesús Daniel Colmenares Oviedo <DtxdF@disroot.org>
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# * Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.
#
# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
#
# * Neither the name of the copyright holder nor the names of its
#   contributors may be used to endorse or promote products derived from
#   this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# We don't need a visible window.
wm withdraw .

fconfigure stdout -translation binary

set otherDisplay [lindex $argv 0]
set selection [lindex $argv 1]

set cachedData ""
set lastOffset -1

# This gets called when another process tries to paste from our selection.
proc handleSelection {offset maxChars} {
    global otherDisplay selection cachedData lastOffset
    variable status
    # Avoid unnecessary execution of smart-xclip-out.sh when the data is very large.
    if {$offset == 0} {
        try {
            set cachedData [exec -keepnewline -ignorestderr -- %%PREFIX%%/libexec/xclipsync/smart-xclip-out.sh ${otherDisplay} ${selection}]
        } trap CHILDSTATUS {results options} {
            set status [lindex [dict get $options -errorcode] 2]
            exit $status
        }
    }
    return [string range $cachedData $offset [expr {$offset + $maxChars}]]
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

# Without this, this script can't handle multiple targets even when
# smart-xclip-out.sh does.
set supportedTargets {
    UTF8_STRING 
    STRING 
    TEXT 
    image/png 
    image/jpeg 
    image/bmp 
    text/html 
    text/plain
}

foreach target $supportedTargets {
    selection handle -selection ${selection} -type $target . handleSelection
}

# Take ownership of the clipboard, so if someone wants to paste, they
# come to us first.  We get called if someone else subsequently takes
# ownership.
selection own -selection ${selection} -command lostSelection .
