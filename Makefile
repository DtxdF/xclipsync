MKDIR?=mkdir -p
INSTALL?=install
SED?=sed -i ''
RM?=rm -f
PREFIX?=/usr/local
MANDIR?=${PREFIX}/share/man

XCLIPSYNC_VERSION?=0.1.2

all: install

install:
	${MKDIR} -m 755 -p "${DESTDIR}${MANDIR}"
	${MKDIR} -m 755 -p "${DESTDIR}${MANDIR}/man1"
	${INSTALL} -m 444 xclipsync.1 "${DESTDIR}${MANDIR}/man1/xclipsync.1"
	${MKDIR} -m 755 -p "${DESTDIR}${PREFIX}/libexec/xclipsync"
	${INSTALL} -m 555 xclipfrom.tcl "${DESTDIR}${PREFIX}/libexec/xclipsync/xclipfrom"
	${SED} -e 's|%%PREFIX%%|${PREFIX}|' "${DESTDIR}${PREFIX}/libexec/xclipsync/xclipfrom"
	${INSTALL} -m 555 smart-xclip-out.sh "${DESTDIR}${PREFIX}/libexec/xclipsync/smart-xclip-out.sh"
	${MKDIR} -m 755 -p "${DESTDIR}${PREFIX}/bin"
	${INSTALL} -m 555 xclipsync.sh "${DESTDIR}${PREFIX}/bin/xclipsync"
	${SED} -e 's|%%VERSION%%|${XCLIPSYNC_VERSION}|' "${DESTDIR}${PREFIX}/bin/xclipsync"
	${SED} -e 's|%%PREFIX%%|${PREFIX}|' "${DESTDIR}${PREFIX}/bin/xclipsync"

uninstall:
	${RM} "${DESTDIR}${MANDIR}/man1/xclipsync.1"
	${RM} "${DESTDIR}${PREFIX}/bin/xclipsync"
	${RM} -r "${DESTDIR}${PREFIX}/libexec/xclipsync"
