# tigfiles

Portable `tig` configuration plus a setup script that installs the current theme and configures `diff-highlight` correctly on macOS and Linux.

## Install

```bash
git clone https://github.com/guerrerocarlos/tigfiles.git
cd tigfiles
./setup.sh
```

The script:

- finds a working `diff-highlight` binary or script
- backs up an existing `~/.tigrc`
- installs this repo's `tig` configuration with the detected `diff-highlight` path

## Notes

- On macOS, `diff-highlight` is commonly provided by Homebrew's `git` package.
- On Ubuntu and other Linux distributions, it is often installed under Git's contrib documentation path.
- If `diff-highlight` cannot be found automatically, the script exits with an actionable error.
