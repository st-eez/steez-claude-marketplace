---
description: Scaffold Ralph Loop files (specs, prompt.md, plan)
arguments:
  - name: mode
    description: "forward (build from scratch), reverse (extract from existing)"
    required: false
user_invocable: true
---

# Loop Setup v2

Scaffold files for a Ralph Loop workflow. This command ONLY creates files.

## Step 1: Check PIN

Read `specs/readme.md`. If not found, ask:
- Project name?
- Tech stack?
- Test command?

Create `specs/readme.md`:

```markdown
# [Project] Specs

**Stack**: [stack]
**Tests**: [command]

## Lookup Table

| Spec | File | Keywords |
|------|------|----------|
```

## Step 2: Interview

{{#if mode}}Mode: {{mode}}{{else}}Ask: "Forward (new build) or Reverse (existing code)?"{{/if}}

**Forward**: What are you building? Constraints?
**Reverse**: What existing feature to document?

Max 5 exchanges. Accept "I don't care" as complete.

## Step 3: Generate Files

Create `specs/[name].md` (spec) and `specs/[name]-plan.md` (checklist).

Update lookup table with 8+ keywords.

## Step 4: Create prompt.md

```markdown
<!-- loop-setup:active -->
Study specs/readme.md.
Study specs/[name]-plan.md.

Pick the most important unchecked item. Implement it.

After: Mark [x] in plan. Commit. EXIT.
```

## Step 5: Summary

Output files created, next steps:
```
cat prompt.md | claude --dangerously-skip-permissions
```

STOP. Do not implement.
