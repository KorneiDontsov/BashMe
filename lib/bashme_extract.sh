# shellcheck shell=bash

# Remove termorary files on exit
# Write the body of a function with the given name to the output.
function bashme_extract {
    builtin local indent=
    if [[ $1 == --indent ]]; then
        builtin shift
        indent="$1"
        builtin shift
    fi

    # Check that function exists
    if ! builtin declare -F "$1" > /dev/null; then
        >&2 builtin printf 'bashme_extract: %s: function not found\n' "$1"
        builtin return 2
    fi

    builtin declare -pf "$1" | (
        IFS=

        # Skip first two lines (function signature and opening bracket)
        builtin read -r
        builtin read -r

        builtin read -r previous_line

        while builtin read -r line || [[ -n "$line" ]]; do
            printf '%s%s\n' "$indent" "${previous_line:4}"

            # Do not print the last line (closing bracket)
            previous_line="$line"
        done
    )
}

readonly -f bashme_extract
