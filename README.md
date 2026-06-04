# freebsd-sh-macos

FreeBSD sh(1) built for macOS.

A Bourne-lineage shell with faithful echo — no escape
interpretation by default, honoring the original contract.

## Why

macOS ships zsh as the default shell.  zsh's builtin echo
interprets escape sequences (`\n`, `\t`, etc.) by default.
The standalone `/bin/echo` is faithful, but the shell builtin
is not.  This means `echo "$var"` produces different output
depending on whether the shell or the binary handles it.

FreeBSD sh does not have this problem.  Its echo builtin
reproduces input faithfully.  Escape interpretation is opt-in
via `-e`, not the default.

## Build

    brew install libedit
    make
    make install

Requires Xcode Command Line Tools and Homebrew libedit.
Default install prefix is `~/bin`.

<!--
## Install via Homebrew

    brew tap dotike/freebsd-sh-macos
    brew install freebsd-sh
-->

## Test

    $ fsh -c 'echo "hello\nworld"'
    hello\nworld

Compare with zsh:

    $ zsh -c 'echo "hello\nworld"'
    hello
    world

## Source

Shell source from FreeBSD main (February 2023 snapshot),
directory layout follows upstream.  A small compat.h provides
Darwin shims.  Linked against Homebrew libedit for
line editing, history, and tab completion.

## License

BSD-2-Clause.  See COPYRIGHT.
