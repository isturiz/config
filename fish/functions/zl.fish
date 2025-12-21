function zl
    if test (count $argv) -eq 0
        if not set -q ZELLIJ
            zellij
        else
            echo "Zellij is already running."
        end
    else
        zellij $argv
    end
end

