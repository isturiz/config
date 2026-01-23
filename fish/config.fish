# Only run in interactive shells
if status is-interactive
    # zoxide init (if installed)
    if command -q zoxide
        zoxide init fish | source
    end

    # Load abbrs if the function exists
    if functions -q abbrs
        abbrs
    end

    # Load nvm.fish if nvm is installed
    if type -q nvm
        nvm use latest > /dev/null 2>&1
    end
end

# Load Homebrew environment if installed
if test -x /opt/homebrew/bin/brew
    eval (/opt/homebrew/bin/brew shellenv)
end

# Add pipx binaries to PATH if it exists
if test -d "$HOME/.local/bin"
    fish_add_path -g -p "$HOME/.local/bin"
end

# Add npm global binaries to PATH if it exists
if test -d "$HOME/.npm-global/bin"
    fish_add_path -g -p "$HOME/.npm-global/bin"
end

# Set important environment variables
set -x HOMEBREW_NO_ENV_HINTS 1

# Preferred editor and pager
if command -q nvim
    set -gx EDITOR nvim
    set -gx VISUAL nvim
    set -gx MANPAGER 'nvim +Man!'
else if command -q vim
    set -gx EDITOR vim
    set -gx VISUAL vim
else if command -q vi
    set -gx EDITOR vi
    set -gx VISUAL vi
end

# Set XDG config directory for all compatible apps (e.g., lazygit)
if not set -q XDG_CONFIG_HOME
    set -x XDG_CONFIG_HOME $HOME/.config
end

# bun
if test -d "$HOME/.bun"
    set --export BUN_INSTALL "$HOME/.bun"
    fish_add_path -g -p "$BUN_INSTALL/bin"
end

# opencode
if test -d "$HOME/.opencode/bin"
    fish_add_path -g -p "$HOME/.opencode/bin"
end
