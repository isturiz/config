function _odooctl_help
    echo "Uso: odx <comando> [opciones]"
    echo
    echo "Comandos principales:"
    echo "  up                     Levanta contenedores (docker compose up -d)"
    echo "  down                   Baja contenedores"
    echo "  deps [--dry-run]       Instala requisitos del proyecto, Odoo y addons"
    echo "  addons                 Ejecuta clone_addons_repos.py"
    echo "  run [args...]          Inicia odoo-bin con --dev=all"
    echo "  update [opts]          Actualiza módulos (--no-http --stop-after-init)"
    echo "  db <subcomando>        Gestiona bases: list, restore, drop"
    echo "  restore <zip> [opts]   Alias de db restore (SQL y filestore, sin HTTP)"
    echo "  passwd [opts]          Resetea contraseña de usuario"
    echo "  sh                     Abre shell fish dentro del contenedor odoo"
    echo "  logs [servicio]        Muestra logs en follow (por defecto: odoo)"
    echo "  doctor                 Muestra contexto detectado"
    echo "  root                   Imprime raíz del proyecto detectado"
    echo
    echo "Opciones de update:"
    echo "  -d, --db <db>          Base de datos objetivo"
    echo "  -u, --modules <mods>   Módulos (por defecto: all)"
    echo
    echo "Opciones de passwd:"
    echo "  -d, --db <db>          Base de datos objetivo"
    echo "  -u, --user <login>     Usuario (por defecto: admin)"
    echo "  -p, --password <pass>  Password (por defecto: admin)"
    echo
    echo "Opciones de restore:"
    echo "  -d, --db <db>          Destino (fallback: ODOOCTL_DB en .env)"
    echo "  --force               Elimina la DB y filestore existentes"
    echo "  --no-neutralize       No neutraliza la copia restaurada"
    echo "  -p, --password <pass>  Password del admin restaurado (por defecto: admin)"
    echo "  Tras restaurar, prepara unaccent IMMUTABLE y resetea el password del admin."
    echo "  Detén odx run antes de restaurar; mantén odoo y pgdb levantados."
    echo
    echo "Gestión de bases de datos:"
    echo "  odx db list [--pattern 'test_*']"
    echo "  odx db restore <zip> [-d <db>] [opciones de restore]"
    echo "  odx db drop -d <db>"
    echo "  odx db drop --pattern 'test_*' [--exclude <db>] [--dry-run]"
    echo "  odx db drop --all --exclude <db> [--yes]"
    echo "  drop exige selector explícito y confirmación; elimina DB y filestore."
    echo ""
    echo "Tips:"
    echo "  - Si defines ODOOCTL_DB en .env, update usa esa DB por defecto."
    echo "  - El proyecto se detecta automáticamente buscando compose.yaml + odoo.conf."
    echo "  - odx significa Odoo eXecutor: el comando principal para ejecutar estas operaciones."
end

function _odooctl_error --argument-names message
    echo "odx: $message" >&2
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

    _odooctl_error "El servicio '$service' no está corriendo. Ejecuta: odx up"
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

function odx --description "Comando principal para proyectos Odoo con Docker Compose"
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
            if test -f "$root/install_odoo_deps.py"
                _odooctl_compose "$root" exec -T odoo python3 /workspace/install_odoo_deps.py $argv[2..-1]
            else
                # Preserve the existing workflow for other Odoo workspaces.
                if test (count $argv) -gt 1
                    _odooctl_error "Este proyecto no admite opciones para deps"
                    return 2
                end
                _odooctl_compose "$root" exec -T odoo bash -lc 'cd /workspace && uv sync && uv pip install -r /workspace/odoo/requirements.txt'
            end

        case addons
            _odooctl_require_service_running "$root" odoo; or return 1
            _odooctl_compose "$root" exec -T odoo python /workspace/clone_addons_repos.py

        case run
            _odooctl_require_service_running "$root" odoo; or return 1
            _odooctl_compose "$root" exec -it odoo /workspace/.venv/bin/python /workspace/odoo/odoo-bin -c /workspace/odoo.conf --dev=all $argv[2..-1]

        case db
            set -l subcommand $argv[2]
            switch "$subcommand"
                case '' help -h --help
                    echo "Uso: odx db <list|restore|drop> [opciones]"
                    echo "  list [--pattern 'test_*'] [--exclude <db>]"
                    echo "  restore <zip> [-d <db>] [--force] [--no-neutralize] [-p <password>]"
                    echo "  drop <-d <db>|--pattern 'test_*'|--all> [--exclude <db>] [--dry-run] [--yes]"
                    echo "--exclude usa nombres exactos y puede repetirse. drop elimina DB y filestore."
                    return 0
                case restore
                    odx restore $argv[3..-1]
                    return $status
                case list drop
                    set -l backend "$__fish_config_dir/functions/odx_db.py"
                    if not test -f "$backend"
                        _odooctl_error "Falta $backend. Instala scripts/odx_db.py junto al helper global."
                        return 1
                    end
                    set -l source (string collect < "$backend")
                    if contains -- --help $argv[3..-1]; or contains -- -h $argv[3..-1]
                        _odooctl_compose "$root" exec -T odoo /workspace/.venv/bin/python -c "$source" $argv[2..-1]
                        return $status
                    end
                    _odooctl_require_service_running "$root" odoo; or return 1
                    _odooctl_require_service_running "$root" pgdb; or return 1
                    set -l interactive 0
                    if isatty stdin
                        set interactive 1
                    end
                    _odooctl_compose "$root" exec -T -e ODOOCTL_INTERACTIVE=$interactive odoo /workspace/.venv/bin/python -c "$source" $argv[2..-1]
                    return $status
                case '*'
                    _odooctl_error "Subcomando db desconocido: $subcommand. Consulta odx db --help"
                    return 2
            end

        case restore
            set -l args $argv[2..-1]
            argparse 'd/db=' 'p/password=' force no-neutralize 'h/help' -- $args; or return 2
            if set -q _flag_help
                echo "Uso: odx db restore <zip> [-d <db>] [-p <password>] [--force] [--no-neutralize]"
                echo "Alias compatible: odx restore <zip> [opciones]"
                echo "ZIP local dentro del proyecto o ruta /workspace/...; DB por defecto: ODOOCTL_DB."
                echo "Neutraliza por defecto. --force elimina DB y filestore existentes."
                echo "Prepara unaccent IMMUTABLE y resetea el admin (password por defecto: admin)."
                echo "Detén odx run antes de restaurar y reserva espacio para descomprimir el ZIP."
                return 0
            end
            if test (count $argv) -ne 1
                _odooctl_error "Debes indicar exactamente un backup ZIP. Consulta odx restore --help"
                return 2
            end
            set -l db (_odooctl_env_get "$root" ODOOCTL_DB)
            if set -q _flag_db
                set db "$_flag_db"
            end
            if test -z "$db"; or string match -q -- '-*' "$db"
                _odooctl_error "Debes indicar una DB válida con -d/--db o definir ODOOCTL_DB en .env"
                return 2
            end
            set -l password admin
            if set -q _flag_password
                set password "$_flag_password"
            end
            if test -z "$password"
                _odooctl_error "El password del administrador no puede estar vacío"
                return 2
            end
            set -l backup "$argv[1]"
            if not string match -q '/workspace/*' -- "$backup"
                set -l local_path (path resolve -- "$backup")
                set -l project_path (path resolve -- "$root")
                if not test -f "$local_path"; or not string match -q -- "$project_path/*" "$local_path"
                    _odooctl_error "El ZIP debe existir dentro del proyecto o usar una ruta /workspace/..."
                    return 2
                end
                set backup /workspace/(string sub -s (math (string length -- "$project_path") + 2) -- "$local_path")
            end
            _odooctl_require_service_running "$root" odoo; or return 1
            _odooctl_require_service_running "$root" pgdb; or return 1
            # Validate before Odoo processes --force (which drops the target first).
            _odooctl_compose "$root" exec -T odoo /workspace/.venv/bin/python -c '
import sys
import zipfile
from pathlib import Path

try:
    backup = Path(sys.argv[1]).resolve(strict=True)
    if not backup.is_relative_to("/workspace") or not backup.is_file():
        raise ValueError("El backup debe ser un archivo dentro de /workspace")
    print("Validando integridad del ZIP (puede tardar)...", flush=True)
    with zipfile.ZipFile(backup) as archive:
        if "dump.sql" not in archive.namelist() or not archive.getinfo("dump.sql").file_size:
            raise ValueError("El ZIP no contiene un dump.sql válido")
        bad_member = archive.testzip()
        if bad_member:
            raise ValueError(f"Miembro ZIP corrupto: {bad_member}")
except Exception as error:
    sys.exit(f"odx: backup inválido: {error}")
' "$backup"; or return $status
            set -l options --neutralize
            if set -q _flag_no_neutralize
                set options
            end
            if set -q _flag_force
                echo "ATENCIÓN: se eliminarán la DB '$db' y su filestore si existen." >&2
                set -a options --force
            end
            echo "Restaurando '$backup' en '$db'. Mantén esta terminal abierta y odx run detenido."
            _odooctl_compose "$root" exec -T odoo /workspace/.venv/bin/python /workspace/odoo/odoo-bin db -c /workspace/odoo.conf load $options -- "$db" "$backup"
            or return $status

            echo "Preparando unaccent IMMUTABLE en '$db'..."
            # Use SQL without loading a registry, which may require unaccent already.
            _odooctl_compose "$root" exec -T odoo /workspace/.venv/bin/python -c '
import sys

sys.path.insert(0, "/workspace/odoo")
from odoo import sql_db
from odoo.tools import config

config.parse_config(["-c", "/workspace/odoo.conf"])
with sql_db.db_connect(sys.argv[1]).cursor() as cr:
    cr.execute("CREATE EXTENSION IF NOT EXISTS unaccent WITH SCHEMA public")
    cr.execute("ALTER FUNCTION public.unaccent(text) IMMUTABLE")
' "$db"
            set -l prepare_status $status
            if test $prepare_status -ne 0
                _odooctl_error "La base '$db' está restaurada, pero falló la preparación de unaccent. No se cambió el password."
                return $prepare_status
            end

            odx passwd -d "$db" -u admin -p "$password"
            set -l password_status $status
            if test $password_status -ne 0
                _odooctl_error "La base '$db' está restaurada y unaccent preparado, pero falló el cambio de password del admin."
                return $password_status
            end
            echo "Base '$db' restaurada: unaccent IMMUTABLE y password del administrador actualizado."
            return 0

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
                        echo "Uso: odx update -d <db> [-u <mods>] [extra args odoo-bin]"
                        echo "Ejemplo: odx update -d rea -u all"
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

            _odooctl_compose "$root" exec -T odoo /workspace/.venv/bin/python /workspace/odoo/odoo-bin server -c /workspace/odoo.conf -d "$db" -u "$modules" --no-http --stop-after-init $extra

        case passwd reset-password
            _odooctl_require_service_running "$root" odoo; or return 1

            set -l db (_odooctl_env_get "$root" ODOOCTL_DB)
            set -l login admin
            set -l password admin
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

                    case -u --user
                        set i (math $i + 1)
                        if test $i -gt (count $args)
                            _odooctl_error "Falta valor para $token"
                            return 1
                        end
                        set login $args[$i]

                    case -p --password
                        set i (math $i + 1)
                        if test $i -gt (count $args)
                            _odooctl_error "Falta valor para $token"
                            return 1
                        end
                        set password $args[$i]

                    case -h --help
                        echo "Uso: odx passwd -d <db> [-u <login>] [-p <password>]"
                        echo "Defaults: user=admin password=admin"
                        echo "Ejemplo: odx passwd -d rea -u admin -p admin"
                        return 0

                    case '*'
                        _odooctl_error "Opción desconocida para passwd: $token"
                        return 1
                end

                set i (math $i + 1)
            end

            if test -z "$db"
                _odooctl_error "Debes indicar DB con -d/--db o definir ODOOCTL_DB en .env"
                return 1
            end

            _odooctl_compose "$root" exec -T \
                -e ODOOCTL_TARGET_LOGIN="$login" \
                -e ODOOCTL_NEW_PASSWORD="$password" \
                -e ODOOCTL_TARGET_DB="$db" \
                odoo bash -lc '/workspace/.venv/bin/python /workspace/odoo/odoo-bin shell -c /workspace/odoo.conf -d "$ODOOCTL_TARGET_DB" <<'"'"'PY'"'"'
import os

if "env" not in globals():
    raise RuntimeError("This script must be executed through `odoo-bin shell ... < script.py`")

target_login = os.environ.get("ODOOCTL_TARGET_LOGIN", "admin")
new_password = os.environ.get("ODOOCTL_NEW_PASSWORD", "admin")

users = env["res.users"].sudo().with_context(active_test=False)
user = users.search([("login", "=", target_login)], limit=1)

if not user and target_login == "admin":
    user = env.ref("base.user_admin", raise_if_not_found=False)
    if user:
        user = user.sudo().with_context(active_test=False)

if not user:
    raise SystemExit(f"[ODOOCTL-PASSWD] user not found: {target_login}")

hashed_password = users._crypt_context().hash(new_password)
users._set_encrypted_password(user.id, hashed_password)
env.cr.commit()

print(f"[ODOOCTL-PASSWD] password updated for login={user.login} id={user.id}")
PY'

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
