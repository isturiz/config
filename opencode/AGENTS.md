# Global OpenCode instructions

## Package manager

- Prefer `pnpm` over `npm` whenever the project supports it.

## Project guidance

- Before changing a project, look for existing `CONTRIBUTING.md`,
  `docs/guidelines.md`, and `.cursor/rules/*.md` within that project.
- Read relevant guidance when those files exist. Apply only rules that match
  the current project and task; do not import another project's conventions.
- Keep persistent project-specific instructions in the applicable `AGENTS.md`.
  OpenCode V2 does not currently load the `instructions` configuration array.

## Commit message suggestions

After completing an implementation task that changed files, load and follow
exactly one applicable commit-message skill before writing the final response.

- Prefer a project-specific or technology-specific commit-message skill over a
  generic one.
- For Odoo work, use `odoo-commit-message`.
- Otherwise, use `generic-commit-message`.
- Follow an explicit commit-message format requested by the user over these
  defaults.
- Do not load a commit-message skill for research, planning, or other tasks that
  did not change files.
- If a change is required after the commit message, use it again, but review all
  related changes, not just the latest ones requested.
- Never run `git commit` unless the user explicitly asks for it.
