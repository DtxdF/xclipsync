NAME
     xclipsync - Trivial tool for synchronizing the clipboard between two X11
     sessions

SYNOPSIS
     xclipsync -v
     xclipsync [-O] [-s selection] [-a display] -b display

DESCRIPTION
     xclipsync is a simple and lightweight script for synchronizing the
     clipboard between two X servers created, for example, by Xephyr(1) or
     Xnest(1), or even for synchronizing the clipboard between the host and
     another X server.

     When started, xclipsync calls xclip(1) to attempt to synchronize the
     clipboard from server A to server B, and continues silently if it fails.
     After this step, the magic begins.

     xclipsync acquires ownership of the clipboard on server A, and when
     someone on server A attempts to paste the clipboard, it sends the data
     from server B. If someone else acquires the clipboard on server A,
     xclipsync does the same thing, but now server B is server A and server A
     is server B. This is done infinitely unless an error occurs or the
     process is terminated.

     Unlike a basic loop script that retrieves the clipboard from one server
     and simply sends the modified clipboard to another server, xclipsync
     acquires ownership, so we paste on one server when it is truly necessary.
     Furthermore, there is no need to specify a delay between
     synchronizations.	It is performed instantly and more intelligently.

     xclipsync is also smart when it comes to automatically selecting the X
     clipboard target, as it supports images, plain text, rich text, and even
     binaries.	xclipsync attempts to guess the destination and selects by
     preference and in order: image/png, UTF8_STRING, TEXT, STRING,
     text/plain, text/html. If these guesses fail, xclipsync tries the first
     matching type by preference and in order: image, text. And if these
     guesses fail again, the last target returned by the X server is selected.
     And if, again, this does not work, the clipboard will be empty on the
     destination server. However, see the -O flag below for a well-known
     limitation of Tcl/Tk.

     -O   Although this tool does its best to guess the format and succeeds
	  99% of the time, the Tcl/Tk selection handle command has no way of
	  informing the requester the target, so it will always paste the data
	  as text.  xclip(1) does not have this limitation, but it is
	  necessary to first detect the target on both sides, both at the
	  input and at the output. This shouldn't be a major issue, since in
	  most cases all that's really needed is text.

	  When this flag is set, the clipboard is synchronized from server A
	  to server B and closed immediately, without ignoring stderr as
	  happens when this option isn't set.

     -v   Display version information about xclipsync.

     -s selection
	  X clipboard selection.

	  CLIPBOARD, PRIMARY, and SECONDARY are the only valid options.

     -a display
	  Server A.

	  If not specified, the DISPLAY environment variable is used, and if
	  it is not defined, :0 is used.

     -b display
	  Server B.

EXIT STATUS
     The xclipsync utility exits 0 on success, and >0 if an error occurs.

SEE ALSO
     xclip(1) Xserver(1)

AUTHORS
     Jesus Daniel Colmenares Oviedo <DtxdF@disroot.org>
