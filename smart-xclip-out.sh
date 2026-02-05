#!/bin/sh

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
