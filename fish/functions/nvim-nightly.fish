# Launch Neovim nightly managed by bob with an isolated config.
# - Temporarily switches bob's active version to 'nightly'
# - Uses NVIM_APPNAME=nvim-nightly so it reads ~/.config/nvim-nightly
# - Restores previous active version on exit
function nvim-nightly --description 'Neovim nightly (isolated config) via bob'
    # Capture the currently active version from `bob list`
    set -l prev (bob list | string match -rg '^\s*([^\s]+)\s+\(active\)')
    if test -z "$prev"
        set prev ""
    end

    # Ensure nightly is installed
    if test -z (bob list | string match -r '^\s*nightly\b')
        bob install nightly >/dev/null 2>&1
    end

    # Switch to nightly if not already active
    set -l switched 0
    if test "$prev" != "nightly"
        set switched 1
        bob use nightly >/dev/null 2>&1
    end

    # Isolate config/data/cache under nvim-nightly
    set -lx NVIM_APPNAME nvim-nightly
    command ~/.local/share/bob/nvim-bin/nvim $argv
    set -l code $status

    # Restore previous active version
    if test $switched -eq 1
        if test -n "$prev"
            bob use $prev >/dev/null 2>&1
        end
    end

    return $code
end
