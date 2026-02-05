#!/bin/sh
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

# xclipsync version.
VERSION="%%VERSION%%"

# see sysexits(3)
EX_OK=0
EX_USAGE=64

set -o pipefail

main()
{
    local _o
    local selection="CLIPBOARD"
    local a_display="${DISPLAY:-:0}"
    local b_display=

    while getopts ":vs:a:b:" _o; do
        case "${_o}" in
            v)
                version
                exit ${EX_OK}
                ;;
            s)
                selection="${OPTARG}"
                ;;
            a)
                a_display="${OPTARG}"
                ;;
            b)
                b_display="${OPTARG}"
                ;;
            *)
                usage
                exit ${EX_USAGE}
                ;;
        esac
    done
    shift $((OPTIND-1))

    if [ -z "${b_display}" ]; then
        usage
        exit ${EX_USAGE}
    fi

    selection=`printf "%s" "${selection}" | tr '[[:lower:]]' '[[:upper:]]'`

    case "${selection}" in
        CLIPBOARD|PRIMARY|SECONDARY) ;;
        *) usage; exit ${EX_USAGE} ;;
    esac

    if ! which -s "xclip"; then
        err "xclip utility not found."
    fi

    if ! which -s "wish"; then
        err "wish utility not found."
    fi

    unset DISPLAY

    "%%PREFIX%%/libexec/xclipsync/smart-xclip-out.sh" "${a_display}" "${selection}" 2> /dev/null |
        xclip -in -display "${b_display}" -selection "${selection}" 2> /dev/null

    while :; do
        env DISPLAY="${a_display}" "%%PREFIX%%/libexec/xclipsync/xclipfrom" "${b_display}" "${selection}" || exit $?
        env DISPLAY="${b_display}" "%%PREFIX%%/libexec/xclipsync/xclipfrom" "${a_display}" "${selection}" || exit $?
    done

    exit ${EX_OK}
}

version()
{
    echo "${VERSION}"
}

usage()
{
    cat << EOF
usage: xclipsync -v
       xclipsync [-s <CLIPBOARD|PRIMARY|SECONDARY>] [-a <display>] -b <display>
EOF
}

warn()
{
    printf "##!> %s\n" "$1" >&2
}

err()
{
    printf "###> %s\n" "$1" >&2
}

info()
{
    printf "===> %s\n" "$1" >&2
}

main "$@"
