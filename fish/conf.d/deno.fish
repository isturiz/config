set -l deno_env "$HOME/.deno/env.fish"

if test -f "$deno_env"
    source "$deno_env"
end
