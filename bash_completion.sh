# shellcheck shell=bash

((BASH_VERSINFO[0] >= 5)) || return 0

shopt -s extglob

function __bashme_completion {
    local current_word previous_word opts

    # Current word and previous word typed
    current_word="${COMP_WORDS[COMP_CWORD]}"
    ((COMP_CWORD == 0)) || previous_word="${COMP_WORDS[COMP_CWORD - 1]}"

    # Available options
    opts="-- --force --minify --obfuscate --script --help"

    if [[ $current_word == './'* || $current_word == '/'* ]]; then
        mapfile -t COMPREPLY < <(compgen -f -- "$current_word")
        return 0
    fi

    case "${previous_word:-}" in
        bashme)
            mapfile -t COMPREPLY < <(compgen -W "profile rc $opts" -- "$current_word")
            return 0
            ;;
        -- | -s | --script)
            # Complete file paths for the destination path option
            mapfile -t COMPREPLY < <(compgen -f -- "$current_word")
            return 0
            ;;
    esac

    mapfile -t COMPREPLY < <(compgen -W "$opts" -- "${current_word}")
}

complete -F __bashme_completion bashme
