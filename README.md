# BashMe

BashMe is a framework for generating Bash startup scripts.

Bash is an extremely powerful tool, but without a proper setup it can be hard to use. Many shell options are not enabled by default even though they are useful in practice, and many tools extend Bash with additional features that require extra configuration.

BashMe helps you manage this configuration in a simple and predictable way.

## Why BashMe

Bash startup scripts like `.bashrc` and `.bash_profile` often grow over time as you add more tools and customizations. They are not designed to be modular, so keeping them clean and maintainable can be difficult.

BashMe takes a different approach: instead of being a framework inside your startup script, it generates the startup script for you.

In other words, BashMe lets you write Bash scripts that generate Bash scripts.

This means:

- your startup scripts are generated from clean, modular sources
- you can share common configuration across environments
- you can keep environment-specific setup separate
- the generated scripts contain only what you need
- the whole process is simple and easy to control

## Features

- Generates `.bash_profile` and `.bashrc` from your own BashMe scripts
- Includes [standard scripts](./docs/std.md) for common Bash defaults and tool setup
- Supports environment-specific configuration
- Optional minification with `shfmt`
- Optional obfuscation with `gzip` and `base64`
- Runs generated scripts in isolated subshells
- Provides a simple command-line interface

## Requirements

1. A POSIX-compliant operating system
2. Bash 5.0 or higher
   - **Linux distributions:** usually preinstalled
   - **macOS:** `brew install bash`
3. `setsid` from util-linux (optional, but **highly** recommended)
   - **Linux distributions:** usually preinstalled
   - **macOS:**
     - `brew install util-linux`
     - make sure `setsid` is available on your `PATH`
4. `shfmt` for minification (only if you use `--minify`)
   - **Arch Linux:** `sudo pacman -S shfmt`
   - **Debian:** `sudo apt install shfmt`
   - **macOS:** `brew install shfmt`
5. `gzip` for obfuscation (only if you use `--obfuscate`)
   - **Linux distributions:** usually preinstalled
   - **macOS:** preinstalled

## Installation

You can use BashMe without installing it by cloning the repository and running the `bashme` script directly.

For convenience, you can also install it system-wide. In the repository root:

- **Arch Linux:** `makepkg -fsi`
- Other: `./install` (and `./uninstall` to uninstall)

*Why `BashMe` isn't published to any of the package repositories?*

Because there is no demand. Be the first.

## Usage

```bash
bashme profile              # Generate `~/.bash_profile`
bashme profile ~/.mybashrc  # Generate bash_profile file to a custom path
bashme profile --force      # Replace existing `~/.bash_profile` if exists
bashme profile --minify     # Generate and minify `~/.bash_profile`
bashme profile --obfuscate  # Generate and obfuscate `~/.bash_profile`

bashme rc              # Generate `~/.bashrc`
bashme rc ~/.mybashrc  # Generate bashrc file to a custom path
bashme rc --force      # Replace existing `~/.bashrc` if exists
bashme rc --minify     # Generate and minify `~/.bashrc`
bashme rc --obfuscate  # Generate and obfuscate `~/.bashrc`

# Generate the startup scripts using custom BashMe scripts
bashme profile --script ~/.profile.bashme
bashme rc --script ~/.rc.bashme

# Generate the startup scripts from scratch, without the standard BashMe scripts
bashme --script ~/.profile.bashme ~/.bash_profile
bashme --script ~/.rc.bashme ~/.bashrc
```

See `bashme --help` for the full list of options.

## Customization

You can write your own BashMe scripts and use them just like the built-in ones.
See [Customization](./docs/custom.md) doc for details.

## Security

Bash scripts can be vulnerable to malicious code injection, so it is important to keep your startup scripts safe.

BashMe recommends:

- installing BashMe with `root` or a dedicated system user
- keeping generated startup scripts owned by `root` or a dedicated user
- giving other users read-only access to the generated scripts
- using `--obfuscate` if you want an extra layer of protection

BashMe also takes several precautions:

1. Scripts are run without `stdin` or a `tty` (if `setsid` is present),
making privilege escalation harder.
2. Each script runs in a separate subshell, so scripts cannot affect each other's variables or functions.

## License

This project is licensed under the MIT License. See the `LICENSE` file for details.
