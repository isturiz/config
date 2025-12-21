set user_home (eval echo ~$USER)
set cargo_env "$user_home/.cargo/env.fish"

if test -f $deno_env
    source $cargo_env
end

