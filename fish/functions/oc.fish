function oc --description "Sync host config to server, then attach"
    set -l server_url "http://localhost:4096"
    set -l attach_args $argv

    if test (count $argv) -gt 0
        if string match -rq '^https?://' -- $argv[1]
            set server_url $argv[1]
            set attach_args $argv[2..-1]
        end
    end

    set server_url (string replace -r '/+$' '' -- "$server_url")

    set -l sync_password "$OPENCODE_SERVER_PASSWORD"
    set -l i 1
    while test $i -le (count $attach_args)
        set -l arg $attach_args[$i]

        if test "$arg" = "-p" -o "$arg" = "--password"
            set -l next_i (math "$i + 1")
            if test $next_i -le (count $attach_args)
                set sync_password $attach_args[$next_i]
            end
            set i (math "$i + 2")
            continue
        end

        if string match -rq '^--password=' -- "$arg"
            set sync_password (string replace -- '--password=' '' -- "$arg")
        end

        set i (math "$i + 1")
    end

    set -l auth_args
    if test -n "$sync_password"
        set -l auth_b64 ""

        if command -q python3
            set auth_b64 (python3 -c 'import base64,sys; print(base64.b64encode(f"opencode:{sys.argv[1]}".encode()).decode())' "$sync_password" 2>/dev/null)
        end

        if test -z "$auth_b64"
            if command -q base64
                set auth_b64 (printf "opencode:%s" "$sync_password" | base64 | tr -d '\n')
            end
        end

        if test -n "$auth_b64"
            set auth_args -H "Authorization: Basic $auth_b64"
        end
    end

    set -l path_response (curl -fsS $auth_args "$server_url/path" 2>/dev/null | string collect)
    set -l path_status $status
    set -l remote_config_dir ""

    if test $path_status -eq 0 -a -n "$path_response"
        if command -q jq
            set remote_config_dir (printf "%s" "$path_response" | jq -r '.config // empty' 2>/dev/null)
        else if command -q python3
            set remote_config_dir (printf "%s" "$path_response" | python3 -c 'import json,sys; print(json.load(sys.stdin).get("config", ""))' 2>/dev/null)
        else
            set -l one_line (string join '' -- $path_response)
            set remote_config_dir (string replace -r '.*"config"\s*:\s*"([^"]+)".*' '$1' -- "$one_line")
        end

        if string match -rq '^\s*\{' -- "$remote_config_dir"
            set remote_config_dir ""
        end
    end

    if test -n "$remote_config_dir"
        set -l has_python 0
        if command -q python3
            set has_python 1
        end

        set -l config_keys_json ""
        set -l can_filter 0
        if test $has_python -eq 1
            set config_keys_json (curl -fsS $auth_args "$server_url/doc" 2>/dev/null \
                | python3 -c 'import json,sys; doc=json.load(sys.stdin); props=((doc.get("components") or {}).get("schemas") or {}).get("Config",{}).get("properties",{}); print(json.dumps(list(props.keys())))' 2>/dev/null \
                | string collect)

            if test $status -eq 0 -a -n "$config_keys_json" -a "$config_keys_json" != "[]"
                set can_filter 1
            end
        end

        set -l temp_dir (mktemp -d 2>/dev/null)
        if test -z "$temp_dir"
            set temp_dir "/tmp/oc-sync-$fish_pid"
            mkdir -p "$temp_dir" >/dev/null 2>&1
        end

        for sync_kind in global project
            set -l payload_file "$temp_dir/$sync_kind.raw.json"
            set -l filtered_file "$temp_dir/$sync_kind.filtered.json"
            set -l response_file "$temp_dir/$sync_kind.response.txt"

            if test "$sync_kind" = "global"
                env OPENCODE_DISABLE_PROJECT_CONFIG=1 opencode debug config >"$payload_file" 2>/dev/null
            else
                opencode debug config >"$payload_file" 2>/dev/null
            end

            set -l payload_status $status
            if test $payload_status -ne 0 -o ! -s "$payload_file"
                echo "oc: warning: failed to resolve $sync_kind host config"
                continue
            end

            set -l patch_payload_file "$payload_file"
            if test $can_filter -eq 1 -a $has_python -eq 1
                python3 -c 'import json,sys; keys=set(json.loads(sys.argv[1])); src=sys.argv[2]; dst=sys.argv[3]; data=json.load(open(src)); out={k:v for k,v in data.items() if k in keys} if isinstance(data, dict) else data; json.dump(out, open(dst, "w"), ensure_ascii=False)' "$config_keys_json" "$payload_file" "$filtered_file" 2>/dev/null

                if test $status -eq 0 -a -s "$filtered_file"
                    set patch_payload_file "$filtered_file"
                end
            end

            set -l http_code (curl -sS -o "$response_file" -w '%{http_code}' -X PATCH \
                -H "Content-Type: application/json" \
                -H "x-opencode-directory: $remote_config_dir" \
                $auth_args \
                --data-binary @"$patch_payload_file" \
                "$server_url/config")

            set -l patch_status $status

            if test $patch_status -ne 0
                echo "oc: warning: failed to sync $sync_kind host config to $server_url (network error)"
                continue
            end

            if not string match -rq '^2' -- "$http_code"
                set -l response_body ""
                if test -f "$response_file"
                    set response_body (string trim -- (string collect < "$response_file"))
                end
                if test -z "$response_body"
                    set response_body "no response body"
                end
                echo "oc: warning: failed to sync $sync_kind host config to $server_url (HTTP $http_code): $response_body"
            end
        end

        if test -n "$temp_dir"
            rm -rf "$temp_dir" >/dev/null 2>&1
        end
    else
        echo "oc: warning: could not resolve remote config path from $server_url/path"
    end

    command opencode attach "$server_url" $attach_args
end
