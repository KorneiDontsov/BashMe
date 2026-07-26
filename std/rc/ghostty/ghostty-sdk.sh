# shellcheck shell=bash

# shellcheck disable=SC2034

GHOSTTY_PATH=$(which ghostty 2> /dev/null) || return 2

GHOSTTY_FULL_VERSION=$("$GHOSTTY_PATH" +version | (
    read -r ghostty_name full_version
    [[ $ghostty_name == Ghostty ]]
    printf '%s' "$full_version"
)) || return 2

if [[ $GHOSTTY_FULL_VERSION =~ ^([0-9]+)\.([0-9]+)\.([0-9]+) ]]; then
    declare -i GHOSTTY_MAJOR_VERSION GHOSTTY_MINOR_VERSION GHOSTTY_PATCH_VERSION

    GHOSTTY_MAJOR_VERSION="${BASH_REMATCH[1]}"
    GHOSTTY_MINOR_VERSION="${BASH_REMATCH[2]}"
    GHOSTTY_PATCH_VERSION="${BASH_REMATCH[3]}"
else
    return 2
fi

function get_ghostty_config {
    local -a options
    options=()

    while [[ $1 == --* ]]; do
        options=("$1")
        shift
    done

    "$GHOSTTY_PATH" +show-config "${options[@]}" | (
        IFS=
        while read -r line || [[ -n "$line" ]]; do
            if [[ $line == "$1 = "* ]]; then
                printf '%s' "${line#"$1 = "}"
                break
            fi
        done
    )
}

function get_ghostty_config_flags {
    local -A flag_set
    local -a flags layers
    local flag layer

    layers=(--default --changes-only)

    for layer in "${layers[@]}"; do
        IFS=',' read -r -a flags < <(get_ghostty_config "$layer" "$1")
        for flag in "${flags[@]}"; do
            case "$flag" in
                true)
                    unset flag_set
                    local -A flag_set
                    flag_set[true]=
                    ;;
                false)
                    unset flag_set
                    local -A flag_set
                    ;;
                no-*)
                    flag="${flag#'no-'}"
                    unset "flag_set[${flag@Q}]"
                    ;;
                *)
                    flag_set["$flag"]=
                    ;;
            esac
        done
    done

    (
        IFS=:
        printf '%s' "${!flag_set[*]}"
    )
}
