# Convenience wrapper: open current dir when no args.
# Uses bob's active version (whichever `bob use` set) and does not touch NVIM_APPNAME.
function nv --description 'Open Neovim in CWD if no args'
    if test (count $argv) -eq 0
        # command nvim .
        command nvim # trying with dashboard
    else
        command nvim $argv
    end
end
