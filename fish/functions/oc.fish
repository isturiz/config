function oc
    set container_name (docker ps --format "{{.Names}}" | grep "_odoo\$" | head -n1)
    if test -n "$container_name"
        docker exec -it -w /workspace $container_name opencode $argv
    else
        echo "Error: No se encuentra el contenedor de Odoo en ejecución"
        return 1
    end
end
