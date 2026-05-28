# ─────────────────────────────────────────────────────────────────────────────
# pnpm – reemplaza npm/npx por pnpm (más seguro por defecto)
# ─────────────────────────────────────────────────────────────────────────────

# ---------------------------------------------------------------------------
# Abreviaciones (shell interactiva): expanden visualmente al pulsar espacio
# ---------------------------------------------------------------------------
if status is-interactive
    abbr --add npm pnpm
    abbr --add npx 'pnpm dlx'
end

# ---------------------------------------------------------------------------
# Función wrapper npm → pnpm (scripts + herramientas externas)
# Traduce los subcomandos cuya interfaz difiere entre npm y pnpm.
# ---------------------------------------------------------------------------
function npm --wraps pnpm --description 'npm → pnpm wrapper (security)'
    if not command -q pnpm
        command npm $argv
        return
    end

    set --local sub $argv[1]

    switch $sub
        case ci
            # npm ci  →  pnpm install --frozen-lockfile
            pnpm install --frozen-lockfile $argv[2..]
        case uninstall un remove rm
            # npm uninstall  →  pnpm remove
            pnpm remove $argv[2..]
        case '*'
            pnpm $argv
    end
end

# ---------------------------------------------------------------------------
# Función wrapper npx → pnpm dlx
# ---------------------------------------------------------------------------
function npx --wraps 'pnpm dlx' --description 'npx → pnpm dlx wrapper (security)'
    if not command -q pnpm
        command npx $argv
        return
    end

    pnpm dlx $argv
end
