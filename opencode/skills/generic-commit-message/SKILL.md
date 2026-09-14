---
name: generic-commit-message
description: Generate an English, repository-aware commit message after completing a task that changes files. Use only as the fallback when no project-specific or technology-specific commit-message skill applies; do not create the commit.
---

# Generic commit message

At the end of the task, generate a commit message for only the changes made as
part of that task. Do not run `git commit`.

## Inspect the task changes

- Base the message on the completed work, the relevant staged and unstaged
  diff, and verification results.
- Exclude unrelated changes that were already present in the worktree.
- Check repository instructions and recent commit history before choosing the
  message format.
- If the task produced multiple independent changes that should be committed
  separately, provide one message per logical commit.
- If no files changed, output exactly:

  `Commit message: Not applicable (no files changed).`

## Choose the repository's format

Write the entire commit message in English. Select its format in this order:

1. Follow an explicit format requested by the user.
2. Follow commit conventions documented by the repository, such as in
   `AGENTS.md`, `CONTRIBUTING.md`, or equivalent project documentation.
3. Follow a clear and consistent pattern in the recent commit history.
4. If no convention can be established, use the Conventional Commit fallback
   below.

Preserve the repository's established capitalization, scope syntax, and use of
a body or references. Do not blindly apply Conventional Commits when the
repository clearly uses another style.

## Conventional Commit fallback

Use this structure only when the repository has no established convention:

```text
type(scope): concise imperative description

Explain why the change is needed and its user or technical impact. Mention what
was changed only when it clarifies a technical decision or non-obvious behavior.

[Optional reference]
```

- Use the narrowest applicable type: `feat`, `fix`, `refactor`, `perf`, `test`,
  `docs`, `build`, `ci`, `style`, `chore`, or `revert`.
- Use a short, meaningful scope when one is evident; otherwise omit it.
- Keep the header concise and make it complete the sentence: "If applied, this
  commit will ...".
- Focus the body on why the change is necessary rather than merely restating
  the diff.
- Wrap body lines at a readable width, approximately 72 characters.
- Add references only when they are known. Never invent task, issue, PR, or
  ticket identifiers.

## Output

End the final response with this section and a fenced text block that is ready
to copy:

````markdown
**Suggested commit message**

```text
Repository-appropriate commit header

Optional commit body in English.
```
````

Do not claim that the commit was created.
