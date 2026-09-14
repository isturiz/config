---
name: odoo-commit-message
description: Use ONLY after completing an Odoo implementation task that actually changed files in the current task. Generate an English Odoo-style commit message instead of using generic-commit-message. Do not use in plan mode, analysis, research, or proposal discussions, or for hypothetical or pre-existing changes; do not create the commit.
---

# Odoo commit message

## Activation gate

Generate a commit message only after completing an Odoo implementation task
that actually produced file changes. Base it only on changes made as part of
the current task. Do not run `git commit`.

- Do not activate in plan mode or while analyzing, researching, discussing,
  reviewing, or refining a plan or proposal.
- Planned edits, hypothetical implementations, and code snippets suggested in
  chat do not count as actual file changes.
- Pre-existing worktree changes do not qualify. Neither do changes from an
  earlier implementation in the conversation when the current task is only
  planning or discussion.
- Changes only to planning artifacts do not qualify as an implementation.
- If this skill is loaded without meeting these conditions, stop applying it
  and continue the response without any commit message, commit section, or
  "not applicable" notice.

## Inspect the task changes

- Base the message on the completed work, the relevant diff, and verification
  results.
- Exclude unrelated changes that were already present in the worktree.
- If the task produced multiple independent changes that should be committed
  separately, provide one message per logical commit.
- Confirm that actual file changes from the current implementation remain.
  If no qualifying changes remain (including when edits were fully reverted),
  omit all commit-related output.

## Follow the Odoo format

Write the entire commit message in English using this structure:

```text
[TAG] module: concise imperative description

Explain why the change is needed and the user or business impact. Mention what
was changed only when it clarifies a technical decision or non-obvious behavior.
Include relevant verification details when useful.

[Optional reference]
```

- Keep the header meaningful and preferably around 50 characters.
- Make the header complete the sentence: "If applied, this commit will ...".
- Use the technical addon name as `module`, without an `odoo/addons/` or
  `addons/.../` path prefix.
- List module names when a tightly related change affects a small number of
  addons. Use `various` only for genuinely cross-module changes.
- For repository tooling or configuration outside an addon, use the most
  specific technical area, such as `tools`, `setup`, or `ci`.
- Focus the body on why the change is necessary rather than merely restating
  the diff.
- Wrap body lines at a readable width, approximately 72 characters.
- Add references only when they are known. Never invent task, issue, PR, or
  ticket identifiers. Accepted examples include `task-123`, `Fixes #123`,
  `Closes #123`, and `opw-123`.

## Select the tag

Choose the narrowest applicable Odoo tag:

- `[FIX]`: correct faulty behavior.
- `[IMP]`: improve existing behavior or add an incremental feature.
- `[ADD]`: add a new addon or major standalone resource.
- `[REF]`: substantially refactor or rewrite an implementation.
- `[REM]`: remove code, views, modules, or other resources.
- `[REV]`: revert an earlier change.
- `[MOV]`: move files or code without mixing unrelated content changes.
- `[REL]`: prepare a release.
- `[MERGE]`: merge or forward-port related work.
- `[I18N]`: change translations.
- `[PERF]`: improve performance.
- `[CLN]`: clean up code without changing behavior.
- `[LINT]`: apply lint-only changes.
- `[CLA]`: sign the Odoo Contributor License Agreement.

Prefer `[FIX]` for a bug fix and `[IMP]` for a feature or incremental
enhancement. Do not use Conventional Commit prefixes such as `feat:` or `fix:`.

## Output

Only when the activation gate above is satisfied, end the final response with
this section and a fenced text block that is ready to copy:

````markdown
**Suggested commit message**

```text
[TAG] module: concise imperative description

Commit body in English.
```
````

Do not claim that the commit was created.
