complete -c odooctl -f

complete -c odooctl -n "__fish_use_subcommand" -a help -d "Ayuda"
complete -c odooctl -n "__fish_use_subcommand" -a up -d "Levantar contenedores"
complete -c odooctl -n "__fish_use_subcommand" -a down -d "Bajar contenedores"
complete -c odooctl -n "__fish_use_subcommand" -a deps -d "Instalar dependencias"
complete -c odooctl -n "__fish_use_subcommand" -a addons -d "Sincronizar addons"
complete -c odooctl -n "__fish_use_subcommand" -a run -d "Ejecutar odoo-bin --dev=all"
complete -c odooctl -n "__fish_use_subcommand" -a update -d "Actualizar módulos"
complete -c odooctl -n "__fish_use_subcommand" -a passwd -d "Resetear contraseña"
complete -c odooctl -n "__fish_use_subcommand" -a reset-password -d "Alias de passwd"
complete -c odooctl -n "__fish_use_subcommand" -a sh -d "Entrar al contenedor odoo"
complete -c odooctl -n "__fish_use_subcommand" -a logs -d "Ver logs"
complete -c odooctl -n "__fish_use_subcommand" -a doctor -d "Ver diagnóstico"
complete -c odooctl -n "__fish_use_subcommand" -a root -d "Mostrar raíz detectada"

complete -c odooctl -n "__fish_seen_subcommand_from update" -s d -l db -r -d "Nombre de base de datos"
complete -c odooctl -n "__fish_seen_subcommand_from update" -s u -l modules -r -d "Módulos a actualizar"
complete -c odooctl -n "__fish_seen_subcommand_from update" -s h -l help -d "Ayuda de update"

complete -c odooctl -n "__fish_seen_subcommand_from passwd reset-password" -s d -l db -r -d "Nombre de base de datos"
complete -c odooctl -n "__fish_seen_subcommand_from passwd reset-password" -s u -l user -r -d "Login del usuario"
complete -c odooctl -n "__fish_seen_subcommand_from passwd reset-password" -s p -l password -r -d "Nueva contraseña"
complete -c odooctl -n "__fish_seen_subcommand_from passwd reset-password" -s h -l help -d "Ayuda de passwd"
