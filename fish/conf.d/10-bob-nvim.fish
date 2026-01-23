# Ensure bob's shim directory is in PATH so `nvim` resolves to bob's active version.
# Prepend to PATH so it's preferred over other nvim installs.
if test -d "$HOME/.local/share/bob/nvim-bin"
    fish_add_path -g -p "$HOME/.local/share/bob/nvim-bin"
end
