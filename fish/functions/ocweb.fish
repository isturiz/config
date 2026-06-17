function ocweb --description "Start opencode web on the LAN with Basic Auth"
    set -l keychain_service "opencode-web"
    set -l username "opencode"
    set -l rotate_password 0
    set -l web_args

    if set -q OPENCODE_SERVER_USERNAME; and test -n "$OPENCODE_SERVER_USERNAME"
        set username "$OPENCODE_SERVER_USERNAME"
    end

    set -l i 1
    while test $i -le (count $argv)
        set -l arg $argv[$i]

        switch $arg
            case --new-password --regen-password --rotate-password
                set rotate_password 1

            case --username -u
                set -l next_i (math "$i + 1")
                if test $next_i -gt (count $argv)
                    echo "ocweb: missing value for $arg" >&2
                    return 2
                end
                set username $argv[$next_i]
                set i $next_i

            case '--username=*'
                set username (string replace -- '--username=' '' -- "$arg")

            case --help -h
                echo "Usage: ocweb [--new-password] [--username USER] [opencode web flags...]"
                echo
                echo "Starts: opencode web --hostname 0.0.0.0"
                echo
                echo "Options:"
                echo "  --new-password      Generate and save a new 8-digit password"
                echo "  --regen-password    Alias for --new-password"
                echo "  --rotate-password   Alias for --new-password"
                echo "  --username USER     Basic Auth username (default: opencode)"
                echo
                echo "Examples:"
                echo "  ocweb --new-password --port 4096"
                echo "  ocweb --port 4096"
                return 0

            case '*'
                set -a web_args "$arg"
        end

        set i (math "$i + 1")
    end

    if test -z "$username"
        echo "ocweb: username cannot be empty" >&2
        return 2
    end

    set -l password ""

    if test $rotate_password -eq 1
        if command -q python3
            set password (python3 -c 'import secrets; print(f"{secrets.randbelow(100000000):08d}")' 2>/dev/null | string collect)
        end

        if test -z "$password"
            set password (od -An -N4 -tu4 /dev/urandom 2>/dev/null | awk '{printf "%08d\n", $1 % 100000000}' | string collect)
        end

        if not string match -rq '^[0-9]{8}$' -- "$password"
            echo "ocweb: failed to generate an 8-digit password" >&2
            return 1
        end

        if not security add-generic-password -a "$username" -s "$keychain_service" -w "$password" -U >/dev/null 2>&1
            echo "ocweb: failed to save password in macOS Keychain" >&2
            return 1
        end
    else
        set password (security find-generic-password -a "$username" -s "$keychain_service" -w 2>/dev/null | string collect)

        if test -z "$password"
            if set -q OPENCODE_SERVER_PASSWORD; and test -n "$OPENCODE_SERVER_PASSWORD"
                set password "$OPENCODE_SERVER_PASSWORD"
            else
                echo "ocweb: no saved password found for user '$username'." >&2
                echo "ocweb: run: ocweb --new-password" >&2
                return 1
            end
        end
    end

    set -l has_hostname 0
    set -l j 1
    while test $j -le (count $web_args)
        set -l web_arg $web_args[$j]
        if test "$web_arg" = "--hostname"; or string match -q -- '--hostname=*' "$web_arg"; or test "$web_arg" = "--mdns"
            set has_hostname 1
            break
        end
        set j (math "$j + 1")
    end

    if test $has_hostname -eq 0
        set -p web_args --hostname 0.0.0.0
    end

    echo "OpenCode Web Basic Auth"
    echo "  Username: $username"
    echo "  Password: $password"
    echo

    env OPENCODE_SERVER_USERNAME="$username" OPENCODE_SERVER_PASSWORD="$password" opencode web $web_args
end
