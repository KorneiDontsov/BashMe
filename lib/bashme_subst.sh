# shellcheck shell=bash

# Substitute the variable expansions with their values as constants.
#
# Arguments are one or more names of the variables to substitute.
#
# Examples
#   bashme_extract my_func | bashme_subst VAR1 VAR2
#
# Patterns
#   "$<variable_name>"
#   "${<variable_name>}"
#   function <name_prefix>[<variable_name>]
function bashme_subst {
    if [[ ! -v 1 ]]; then
        >&2 echo 'bashme_subst: no arguments'
        exit 1
    fi

    builtin local varchain line prefix varname

    varchain=":$(
        IFS=:
        builtin echo "$*"
    ):"

    while IFS= builtin read -r line || [[ -n "$line" ]]; do
        while [[ $line =~ (\"\$(([a-zA-Z_][a-zA-Z0-9_]*)|\{([a-zA-Z_][a-zA-Z0-9_]*)(\[@\])*\})\"|(function[[:blank:]]+[a-zA-Z0-9_]*)\[([a-zA-Z_][a-zA-Z0-9_]*)\]) ]]; do
            # Print everything before the match
            prefix="${line%%"${BASH_REMATCH[0]}"*}"
            builtin printf '%s' "$prefix"

            # Cut the line
            line="${line:"$((${#prefix} + ${#BASH_REMATCH[0]}))"}"

            varname="${BASH_REMATCH[3]:-"${BASH_REMATCH[4]:-"${BASH_REMATCH[7]?}"}"}"
            if [[ $varchain != *:"$varname":* ]]; then
                # Wrong match - print without changes
                builtin printf '%s' "${BASH_REMATCH[0]}"
                builtin continue
            fi

            builtin local -n value="$varname"

            if [[ -n ${BASH_REMATCH[2]} ]]; then
                # Syntax: "$var" / "${var}" / "${var[@]}"
                if [[ ${BASH_REMATCH[5]} == '[@]' ]]; then
                    # Substutute a list of constants
                    [[ ! -v value[0] ]] || builtin printf '%q' "${value[0]}"
                    [[ ! -v value[1] ]] || builtin printf ' %q' "${value[@]:1}"
                else
                    # Substutute a constant
                    builtin printf '%q' "$value"
                fi
            else
                # Syntax: function ...[var]
                # Substitute a function name
                builtin printf '%s%q' "${BASH_REMATCH[6]}" "$value"
            fi
        done

        builtin printf '%s\n' "$line"
    done
}

readonly -f bashme_subst
