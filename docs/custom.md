# Customization

You can write your own BashMe scripts and use them just like the built-in ones.

The built-in scripts are located in:

- [std/profile/](../std/profile/) for `.bash_profile`
- [std/rc/](..std/rc/) for `.bashrc`

You can use them as examples.

## BashMe Script API

When writing your own BashMe scripts, you have access to the following functions:

- `bashme_import <script>`
  Import another BashMe script (`.bashme` extension optional).
  Example: `bashme_import my-custom-tool`

- `bashme_print [--] <content>`
  Print literal content to the generated startup script.
  Example: `bashme_print 'export PATH="$HOME/bin:$PATH"'`

- `bashme_print -f|--function <function_name> [-s|--subst <var_name>]...`
  Print the body of a function to the generated startup script.
  Optionally substitute variables with their values using `-s/--subst`.
  Example: `bashme_print -f my_function -s VAR1 -s VAR2`

- `bashme_hold [--interactive]`
  Switch output sections. Without `--interactive`, writes to the general section (always executed).
  With `--interactive`, writes to the interactive section (only executed in interactive shells).
  Call multiple times to create multiple sections that are concatenated in order.

## Custom Script Example

```bash
# shellcheck shell=bash

# Import a tool setup script
bashme_import my-editor-config

# Define a function
function my_custom_path {
    export PATH="$HOME/my-tools:$PATH"
}

# Print the function to the general section (always runs)
bashme_print -f my_custom_path

# Switch to interactive section
bashme_hold --interactive

# Print aliases that only make sense in interactive shells
bashme_print 'alias ll="ls -la"'
```
