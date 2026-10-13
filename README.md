# dotfiles

zsh (Oh My Zsh + Powerlevel10k), Homebrew packages, and kitty config for macOS.

## Install on a new Mac

```sh
xcode-select --install          # if git isn't available yet
git clone <repo-url> ~/dotfiles
~/dotfiles/install.sh
```

Then put your tokens in `~/.zshrc.local` (it's created from `zsh/.zshrc.local.example`).

The script installs Homebrew, the `Brewfile` packages, Oh My Zsh and its plugins, then
symlinks the configs into place. Any files it replaces are backed up to `~/.dotfiles-backup/`.

## Day-to-day

Configs are symlinked, so edits to `~/.zshrc` or kitty config are edits to this repo — just commit.

Refresh the Brewfile after installing or removing packages:

```sh
brew bundle dump --file=~/dotfiles/Brewfile --force
```
