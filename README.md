# up.cmd
A Windows script for updating a bunch of things with one command. Engineered explicitly for home use and COMES WITH ABSOLUTELY NO WARRANTY! 🎉

## Currently supports
- [Chocolatey](https://chocolatey.org)
- [Windows Package Manager](https://learn.microsoft.com/en-us/windows/package-manager/) a.k.a. `winget`
- [TinyNvidiaUpdateChecker](https://github.com/ElPumpo/TinyNvidiaUpdateChecker/)
- Windows Update

This is also the execution order so that `winget` won't steal `choco`'s thunder, TNUC does its thing in the background while you got bored watching the app packages roll in and potential reboot prompts from Windows Update come in last.

## Features
- **A goddamn exclude list for `winget`.**
  - For when `winget upgrade --all` is just too dangerous/stupid
  - You gotta admit that's pretty good

## Requirements
- `sudo` ([`scoop install sudo`](https://scoop.sh/#/apps?q=sudo&id=df5613f576f7cf79a40bd32f16ba2b0eb5c18f68))
  - Optional, if you want to start a dedicated Administrator terminal every time, like a chump. The rest are non-negotiable.
- `grep`
  - Looks like I did [`choco install grep`](https://community.chocolatey.org/packages/grep) mine
- `head`, `tail` and `sort`
  - Mine look like GnuWin CoreUtils but didn't come from [`choco install gnuwin32-coreutils.install`](https://community.chocolatey.org/packages/gnuwin32-coreutils.install) so I probably just downloaded them from [SourceForge](https://sourceforge.net/projects/gnuwin32/files/coreutils/5.3.0/). LOL, this box is old.

Make sure you get this stuff installed and along your `PATH` as we're gonna be working on first name basis.

## How to
You go `up` and if you did everything correctly, it works.

## But
> You mentioned a `winget` exclude list?

Yeah. You put a file called `winget-exclude.lst` in your home directory, or `%USERPROFILE%`. It's a text file of `winget` IDs, one per line, that you don't want [`up.cmd`](https://github.com/SyntaxErrol/up.cmd) to tell `winget` to update.

## TODO
- Kinda feel like I should support Scoop since I'm using it.
- Configurability
  - Preserve Desktop .lnk garbage, anyone?
- Run modes for
  - Update checking
  - Unattended updating
  - Interactive mode
  - Current state is a mish-mash of all of the above
