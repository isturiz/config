function _odooctl_help
    echo "Uso: odooctl <comando> [opciones]"
    echo
    echo "Comandos principales:"
    echo "  up                     Levanta contenedores (docker compose up -d)"
    echo "  down                   Baja contenedores"
    echo "  deps                   Ejecuta uv sync + requirements de Odoo"
    echo "  addons                 Ejecuta clone_addons_repos.py"
    echo "  run [args...]          Inicia odoo-bin con --dev=all"
    echo "  update [opts]          Actualiza módulos (--no-http --stop-after-init)"
    echo "  sh                     Abre shell fish dentro del contenedor odoo"
    echo "  logs [servicio]        Muestra logs en follow (por defecto: odoo)"
    echo "  doctor                 Muestra contexto detectado"
    echo "  root                   Imprime raíz del proyecto detectado"
    echo
    echo "Opciones de update:"
    echo "  -d, --db <db>          Base de datos objetivo"
    echo "  -u, --modules <mods>   Módulos (por defecto: all)"
    echo ""
    echo "Tips:"
    echo "  - Si defines ODOOCTL_DB en .env, update usa esa DB por defecto."
    echo "  - El proyecto se detecta automáticamente buscando compose.yaml + odoo.conf."
end

function _odooctl_error --argument-names message
    echo "odooctl: $message" >&2
end

function _odooctl_find_root
    set -l dir (pwd)

    while true
        if test -f "$dir/odoo.conf"
            if test -f "$dir/compose.yaml" -o -f "$dir/docker-compose.yml" -o -f "$dir/docker-compose.yaml"
                echo "$dir"
                return 0
            end
        end

        if test "$dir" = "/"
            return 1
        end

        set dir (path dirname "$dir")
    end
end

function _odooctl_compose_file --argument-names root
    for candidate in compose.yaml docker-compose.yml docker-compose.yaml
        if test -f "$root/$candidate"
            echo "$root/$candidate"
            return 0
        end
    end

    return 1
end

function _odooctl_compose --argument-names root
    set -l compose_file (_odooctl_compose_file "$root")
    if test $status -ne 0
        _odooctl_error "No se encontró archivo de compose en $root"
        return 1
    end

    set -l cmd
    if command docker compose version >/dev/null 2>&1
        set cmd docker compose
    else if type -q docker-compose
        set cmd docker-compose
    else
        _odooctl_error "No se encontró docker compose ni docker-compose en PATH"
        return 127
    end

    set -l args --project-directory "$root" -f "$compose_file"
    if test -f "$root/.env"
        set args $args --env-file "$root/.env"
    end

    command $cmd $args $argv[2..-1]
end

function _odooctl_env_get --argument-names root key
    set -l env_file "$root/.env"
    if not test -f "$env_file"
        return 1
    end

    while read -l line
        set line (string trim -- "$line")

        if test -z "$line"
            continue
        end

        if string match -qr '^#' -- "$line"
            continue
        end

        if string match -qr "^$key=" -- "$line"
            set -l value (string replace -r "^$key=" '' -- "$line")
            set value (string trim --chars '"\'' -- "$value")
            echo "$value"
            return 0
        end
    end < "$env_file"

    return 1
end

function _odooctl_expand_home --argument-names input_path
    if string match -q '~*' -- "$input_path"
        echo (string replace -r '^~' "$HOME" -- "$input_path")
    else
        echo "$input_path"
    end
end

function _odooctl_guess_odoo_version --argument-names root
    set -l base (_odooctl_env_get "$root" ODOO_BASE)
    if test -z "$base"
        return 1
    end

    set base (_odooctl_expand_home "$base")
    set -l tail (path basename "$base")
    set -l guessed (string match -r -g '([0-9]+\.[0-9]+)$' -- "$tail")
    if test -n "$guessed"
        echo "$guessed"
        return 0
    end

    return 1
end

function _odooctl_service_running --argument-names root service
    set -l running (_odooctl_compose "$root" ps --status running --services 2>/dev/null)
    if test $status -ne 0
        return 1
    end

    if contains -- "$service" $running
        return 0
    end

    return 1
end

function _odooctl_require_service_running --argument-names root service
    if _odooctl_service_running "$root" "$service"
        return 0
    end

    _odooctl_error "El servicio '$service' no está corriendo. Ejecuta: odooctl up"
    return 1
end

function _odooctl_doctor --argument-names root
    set -l compose_project (_odooctl_env_get "$root" COMPOSE_PROJECT_NAME)
    set -l default_db (_odooctl_env_get "$root" ODOOCTL_DB)
    set -l odoo_base (_odooctl_env_get "$root" ODOO_BASE)
    set -l odoo_version (_odooctl_guess_odoo_version "$root")

    echo "Proyecto detectado"
    echo "  root: $root"

    if test -n "$compose_project"
        echo "  compose project: $compose_project"
    else
        echo "  compose project: (sin COMPOSE_PROJECT_NAME en .env)"
    end

    if test -n "$odoo_base"
        echo "  ODOO_BASE: $odoo_base"
    end

    if test -n "$odoo_version"
        echo "  versión Odoo (estimada): $odoo_version"
    end

    if test -n "$default_db"
        echo "  DB por defecto (ODOOCTL_DB): $default_db"
    else
        echo "  DB por defecto (ODOOCTL_DB): no configurada"
    end

    for service in odoo pgdb
        if _odooctl_service_running "$root" "$service"
            echo "  servicio $service: running"
        else
            echo "  servicio $service: stopped"
        end
    end
end

function odooctl --description "Atajos diarios para proyectos Odoo con Docker Compose"
    set -l cmd $argv[1]

    if test -z "$cmd"
        set cmd help
    end

    switch $cmd
        case help -h --help
            _odooctl_help
            return 0
    end

    set -l root (_odooctl_find_root)
    if test $status -ne 0
        _odooctl_error "No se detectó raíz de proyecto (faltan compose.yaml y/o odoo.conf)."
        return 1
    end

    switch $cmd
        case root
            echo "$root"

        case doctor
            _odooctl_doctor "$root"

        case up
            _odooctl_compose "$root" up -d

        case down
            _odooctl_compose "$root" down

        case deps
            _odooctl_require_service_running "$root" odoo; or return 1
            _odooctl_compose "$root" exec -T odoo bash -lc 'uv sync && uv pip install -r odoo/requirements.txt'

        case addons
            _odooctl_require_service_running "$root" odoo; or return 1
            _odooctl_compose "$root" exec -T odoo python /workspace/clone_addons_repos.py

        case run
            _odooctl_require_service_running "$root" odoo; or return 1
            _odooctl_compose "$root" exec -it odoo /workspace/.venv/bin/python /workspace/odoo/odoo-bin -c /workspace/odoo.conf --dev=all $argv[2..-1]

        case update
            _odooctl_require_service_running "$root" odoo; or return 1

            set -l db (_odooctl_env_get "$root" ODOOCTL_DB)
            set -l modules all
            set -l extra
            set -l args $argv[2..-1]
            set -l i 1

            while test $i -le (count $args)
                set -l token $args[$i]
                switch $token
                    case -d --db
                        set i (math $i + 1)
                        if test $i -gt (count $args)
                            _odooctl_error "Falta valor para $token"
                            return 1
                        end
                        set db $args[$i]

                    case -u --modules
                        set i (math $i + 1)
                        if test $i -gt (count $args)
                            _odooctl_error "Falta valor para $token"
                            return 1
                        end
                        set modules $args[$i]

                    case -h --help
                        echo "Uso: odooctl update -d <db> [-u <mods>] [extra args odoo-bin]"
                        echo "Ejemplo: odooctl update -d rea -u all"
                        return 0

                    case '*'
                        set extra $extra $token
                end

                set i (math $i + 1)
            end

            if test -z "$db"
                _odooctl_error "Debes indicar DB con -d/--db o definir ODOOCTL_DB en .env"
                return 1
            end

            _odooctl_compose "$root" exec -T odoo /workspace/odoo/odoo-bin server -c /workspace/odoo.conf -d "$db" -u "$modules" --no-http --stop-after-init $extra

        case sh
            _odooctl_require_service_running "$root" odoo; or return 1
            _odooctl_compose "$root" exec -it odoo fish

        case logs
            set -l service odoo
            if test -n "$argv[2]"
                set service $argv[2]
            end
            _odooctl_compose "$root" logs -f "$service"

        case '*'
            _odooctl_error "Comando desconocido: $cmd"
            _odooctl_help
            return 1
    end
end
