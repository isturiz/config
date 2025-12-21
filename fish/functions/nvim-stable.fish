# Launch Neovim stable via bob with your default config (NVIM_APPNAME=nvim).
# Temporarily selects stable and restores the previous version after exit.
function nvim-stable --description 'Neovim stable (default config) via bob'
    set -l prev (bob list | string match -rg '^\s*([^\s]+)\s+\(active\)')
    if test -z "$prev"
        set prev ""
    end

    # Ensure stable is installed
    if test -z (bob list | string match -r '^\s*(stable|v?[0-9]+\.[0-9]+\.[0-9]+)\b')
        bob install stable >/dev/null 2>&1
    end

    # Switch to stable (this resolves to the latest stable, e.g., 0.11.4)
    bob use stable >/dev/null 2>&1

    set -lx NVIM_APPNAME nvim
    command ~/.local/share/bob/nvim-bin/nvim $argv
    set -l code $status

    # Restore previous active version
    if test -n "$prev" -a "$prev" != "stable"
        bob use $prev >/dev/null 2>&1
    end

    return $code
end
