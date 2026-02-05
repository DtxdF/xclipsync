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

#
# See https://www.w3.org/TR/clipboard-apis/#mandatory-data-types-x
#
SUPPORTED_TYPES="\
image/png \
UTF8_STRING \
TEXT \
STRING \
text/plain \
text/html"
GUEST_TYPES="images text"

main()
{
    local display="${1:-:0}"
    local selection="${2:-CLIPBOARD}"
    local targets target
    local found=false

    targets=`xclip -out -display "${display}" -target TARGETS -selection "${selection}"` || exit $?

    for target in ${SUPPORTED_TYPES}; do
        if chklist "${targets}" "${target}"; then
            found=true
            break
        fi
    done

    if ! ${found}; then
        for target in ${GUEST_TYPES}; do
            local match

            match=`echo ${targets} | tr ' ' $'\n' | grep -m1 -Ee "^${target}/"`

            if [ -z "${match}" ]; then
                continue
            fi

            target="${match}"
            found=true

            break
        done
    fi

    if ! ${found}; then
        local match

        match=`echo ${targets} | tr ' ' $'\n' | tail -1`

        target="${match}"
    fi

    if [ -z "${target}" ]; then
        return 0
    fi

    xclip -out -display "${display}" -target "${target}" -selection "${selection}" || exit $?
}

chklist()
{
    local list target item

    list="$1"
    target="$2"

    for item in ${list}; do
        if [ "${item}" = "${target}" ]; then
            return 0
        fi
    done

    return 1
}

main "$@"
