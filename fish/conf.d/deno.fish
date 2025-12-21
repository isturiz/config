
set user_home (eval echo ~$USER)
set deno_env "$user_home/.deno/env.fish"

if test -f $deno_env
    source $deno_env
end

