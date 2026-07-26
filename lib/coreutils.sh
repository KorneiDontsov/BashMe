# shellcheck shell=bash

if [[ "$(uname)" == "Darwin" ]]; then
    # shellcheck disable=SC2329
    function mktemp {
        local -a args

        while [[ -v 1 ]]; do
            args+=("$1")

            case "$1" in
                -t)
                    if [[ $2 =~ (-)?XXX+$ ]]; then
                        args+=("${2//"${BASH_REMATCH[0]}"/}")
                    else
                        args+=("$2")
                    fi

                    shift 2
                    ;;
                *)
                    shift
                    ;;
            esac
        done

        command -p mktemp "${args[@]}"
    }
fi
