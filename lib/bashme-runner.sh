# shellcheck shell=bash

set -euo pipefail

SOURCE_DIR="$(dirname "${BASH_SOURCE[0]}")"
source "$SOURCE_DIR/coreutils.sh"
source "$SOURCE_DIR/bashme_extract.sh"
source "$SOURCE_DIR/bashme_subst.sh"
unset SOURCE_DIR

declare -a __BASHME_OWNED_BUFFERS __BASHME_GENERAL_BUFFER_QUEUE __BASHME_INTERACTIVE_BUFFER_QUEUE
declare -i __BASHME_CURRENT_BUFFER_INDEX

__BASHME_CURRENT_BUFFER_KIND=GENERAL
__BASHME_CURRENT_BUFFER_INDEX=-1

# Switch `bashme_print` to the next print stage (and creates it if it doesn't already exist).
# The subsequent `bashme_print` executions write to that stage.
# Every stage is to be written in the resulted startup script one after another.
#
# Options:
# If '--interactive' option is specified,
# then switch `bashme_print` to the interactive mode.
# The subsequent `bashme_print` executions write to separate, interactive-mode stage group.
# Interactive-mode stages are always written in the resulted startup script after the general
# ones and only under a condition that shell runs in interactive mode.
function bashme_hold {
    if [[ ${1:-} == --interactive &&
        ${__BASHME_CURRENT_BUFFER_KIND:-} != INTERACTIVE ]]; then

        __BASHME_CURRENT_BUFFER_KIND=INTERACTIVE
        __BASHME_CURRENT_BUFFER_INDEX=-1
    fi

    builtin local -n queue="__BASHME_${__BASHME_CURRENT_BUFFER_KIND}_BUFFER_QUEUE"

    __BASHME_CURRENT_BUFFER_INDEX+=1

    builtin local buffer
    if [[ -v queue["$__BASHME_CURRENT_BUFFER_INDEX"] ]]; then
        buffer="${queue["$__BASHME_CURRENT_BUFFER_INDEX"]}"
    else
        buffer=$(mktemp -t bashme-buffer-XXX)
        __BASHME_OWNED_BUFFERS+=("$buffer")
        queue+=("$buffer")
    fi

    exec 3>> "$buffer"
}

# bashme_print [--] <content> [<additional_content>]...
#   Print the specified content to the current print stage.
# bashme_print -f|--function <function_name> [-s|--subst <var_name>]...
#   Print the body of the specified function to the current print stage.
#   `-s`/`--subst` option specifies to apply `bashme_subst` to the body with the given value.
function bashme_print {
    local func_name
    local -a subst_args

    while [[ -v 1 ]]; do
        case "$1" in
            -f | --function)
                shift
                func_name="$1"
                shift
                ;;
            -s | --subst)
                shift
                subst_args+=("$1")
                shift
                ;;
            --)
                shift
                builtin break
                ;;
            -*)
                >&2 printf 'bashme_print: %s: unknown option\n' "$1"
                builtin exit 1
                ;;
            *)
                builtin break
                ;;
        esac
    done

    if [[ -v subst_args[0] && ! -v func_name ]]; then
        >&2 echo 'bashme_print: function to substitute to is not specified'
        builtin exit 1
    fi

    if [[ -v 1 ]]; then
        if [[ -v func_name || -v subst_args[0] ]]; then
            >&2 printf 'bashme_print: %s: unrecognized argument\n' "$@"
            builtin exit 1
        fi

        echo "$@" >&3
    elif [[ -v func_name ]]; then
        if [[ -v subst_args[0] ]]; then
            bashme_extract "$func_name" | bashme_subst "${subst_args[@]}" >&3
        else
            bashme_extract "$func_name" >&3
        fi
    else
        builtin local line

        while builtin read -r line || [[ -n "$line" ]]; do
            builtin printf '%s\n' "$line" >&3
        done
    fi
}

function __bashme_on_exit {
    builtin command rm -f "${__BASHME_OWNED_BUFFERS[@]}"
}

# This function runs in a subshell
function __bashme_import_impl {
    # Collect and clear temporary files in a subshell when interrupted
    __BASHME_OWNED_BUFFERS=()
    builtin trap __bashme_on_exit EXIT

    builtin cd "$(dirname "$1")"
    builtin source "$(basename "$1")" < /dev/null > /dev/null

    # If there're new buffers then give them to the parent shell
    # shellcheck disable=SC2034
    if [[ -v __BASHME_OWNED_BUFFERS[0] ]]; then
        local -a general_buffers interactive_buffers owned_buffers

        general_buffers=("${__BASHME_GENERAL_BUFFER_QUEUE[@]}")
        builtin declare -p general_buffers

        interactive_buffers=("${__BASHME_INTERACTIVE_BUFFER_QUEUE[@]}")
        builtin declare -p interactive_buffers

        owned_buffers=("${__BASHME_OWNED_BUFFERS[@]}")
        builtin declare -p owned_buffers
    fi

    builtin trap - EXIT
}

# Runs a BashMe script at the given path in a sub-shell.
# `.bashme` in the end of the path may be omitted.
function bashme_import {
    if [[ -d $1 ]]; then
        builtin set -- "$(builtin cd "$1" && builtin pwd)"
        builtin set -- "$1/$(builtin command basename "$1").bashme"
    elif [[ $1 != *.bashme && -f "$1.bashme" ]]; then
        builtin set -- "$1.bashme"
    fi

    if [[ ! -f $1 ]]; then
        >&2 builtin printf 'bashme_import: %s: file not found\n' "$1"
        builtin return 2
    fi

    # Import a script in a subshell so that foreign scripts couldn't affect each other
    set -- "$(__bashme_import_impl "$1")"

    if [[ -n $1 ]]; then
        local -a general_buffers interactive_buffers owned_buffers
        builtin eval "$1"

        __BASHME_OWNED_BUFFERS+=("${owned_buffers[@]}")
        __BASHME_GENERAL_BUFFER_QUEUE=("${general_buffers[@]}")
        __BASHME_INTERACTIVE_BUFFER_QUEUE=("${interactive_buffers[@]}")
    fi
}

function exit {
    >&2 builtin echo 'exit: not allowed to be used inside a BashMe script'
    builtin return "${1:-'1'}"
}

readonly -f \
    bashme_hold \
    bashme_print \
    bashme_import \
    __bashme_import_impl \
    __bashme_on_exit \
    exit

trap __bashme_on_exit EXIT

while [[ -v 1 ]]; do
    bashme_import "$1"
    shift
done

if [[ -v __BASHME_GENERAL_BUFFER_QUEUE[0] ]]; then
    cat "${__BASHME_GENERAL_BUFFER_QUEUE[@]}" >&3
fi

if [[ -v __BASHME_INTERACTIVE_BUFFER_QUEUE[0] ]]; then
    echo $'\nif [[ $- == *i* ]]; then\n\n' '' >&3
    cat "${__BASHME_INTERACTIVE_BUFFER_QUEUE[@]}" >&3
    echo $'\nfi\n' >&3
fi
