# Global OpenCode instructions

## Commit message suggestions

After completing an implementation task that changed files, load and follow
exactly one applicable commit-message skill before writing the final response.

- Prefer a project-specific or technology-specific commit-message skill over a
  generic one.
- For Odoo work, use `odoo-commit-message`.
- Otherwise, use `generic-commit-message` as the fallback.
- Follow an explicit commit-message format requested by the user over these
  defaults.
- Do not load a commit-message skill for research, planning, or other tasks that
  did not change files.
- Never run `git commit` unless the user explicitly asks for it.
