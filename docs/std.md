# Standard scripts

BashMe includes standard scripts for the following software and features.

## Profile Scripts ([std/profile](../std/profile))
These are included when generating with `--type profile` option.

### .bashrc
- Sources the user's `~/.bashrc` file (if readable) when generating `.bash_profile`.

### .NET
- Exports `$HOME/.dotnet/tools` to PATH (if not already present).
- Sets `DOTNET_ROOT` to the base path of the .NET SDK.
- Disables .NET telemetry by setting `DOTNET_CLI_TELEMETRY_OPTOUT=1`.

### Homebrew
- Detects Homebrew installation (in common paths: `/opt/homebrew/bin/brew`, `/usr/local/bin/brew`).
- Exports Homebrew environment via `brew shellenv`.
- Adds keg-only paths (util-linux, grep, gnu-tar, gnu-sed, gnu-indent, gnu-getopt, gettext, gawk, coreutils) to PATH if installed via Homebrew.

## RC Scripts ([std/rc](../std/rc))
These are included when generating with `--type rc` option.

### Ble.sh
- Sources `ble.sh` with `--noattach`.
- If no Blesh configuration exists (`~/.blerc` or `$XDG_CONFIG_HOME/blesh/init.sh`):
- Sets emacs-mode key bindings:
    - Up: history-search-backward
    - Down: history-search-forward
    - Right: forward-char
    - Left: backward-char
- Attaches Ble.sh after configuration.

### GPG
- Sets `GPG_TTY` to the output of `tty`.

### grep
- Creates alias: `grep='grep --color=auto'`.

### less
- Exports `LESS=-R` (to allow ANSI color escape sequences).

### ls
- Creates aliases:
- `ls='ls --color=auto'`
- `la='ls -A'`
- `ll='ls -l'`
- `l='ls -CF'`
- `l1='ls -1F'`.

### Readline Inputs
- If `~/.inputrc` does **not** exist:
  - Sets readline defaults:
    - `completion-ignore-case on`
    - `mark-symlinked-directories on`
    - `Space:magic-space`
    - `show-all-if-ambiguous on`
    - `"\e[A": history-search-backward` (Up arrow)
    - `"\e[B": history-search-forward` (Down arrow)
    - `"\e[C": forward-char` (Right arrow)
    - `"\e[D": backward-char` (Left arrow).

### Shell Defaults
- Sets various shell options (based on bash-sensible):
  - **General** (always):
    - `set -o noclobber` (prevent overwriting files with `>`)
    - `shopt -s histappend cmdhist` (history settings)
    - `HISTCONTROL=erasedups:ignoreboth`
    - `HISTIGNORE='&:[ ]*:exit:ls:la:ll:l:l1:bg:fg:history:clear'`
    - `HISTTIMEFORMAT='%F %T '` (ISO 8601 timestamp in history)
  - **Interactive** (only in interactive shells):
    - `shopt -s cdable_vars globstar checkwinsize autocd dirspell cdspell`
    - `PROMPT_DIRTRIM=2` (trim long paths in prompt)
    - Records history on each prompt (if Bash ≥5.1, uses `PROMPT_COMMAND` array; otherwise, string).

### Starship
- Initializes Starship prompt for bash: `eval "$(starship init bash --print-full-init)"`.

### Superfile
- If `cd_on_quit = true` in Superfile config:
    - Defines a `spf` function that:
        - Runs `spf "$@"`.
        - Sources the last directory from `$XDG_STATE_HOME/superfile/lastdir` (or platform-specific) if it exists.
        - Removes the last directory file after sourcing.

### Ghostty
- If using Ghostty terminal (version ≥1.3) and shell-integration is set to `none`:
  - Sources Ghostty's shell-integration script if `$TERM == xterm-ghostty`.
  - Sets up features if enabled:
    - `cursor:blink` or `cursor:steady` (based on cursor-style-blink setting)
    - `path` (current directory)
    - `ssh-env` (SSH environment variables)
    - `ssh-terminfo` (install terminfo on remote host)
    - `sudo` (sudo integration)
    - `title` (terminal title)
