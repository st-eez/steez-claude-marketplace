---
description: Scaffold Ralph Loop files (specs, prompt.md, plan)
arguments:
  - name: mode
    description: "forward (build from scratch), reverse (extract from existing)"
    required: false
user_invocable: true
---

# Loop Setup v2

Scaffold files for Ralph Loop. This command ONLY creates files—never implement.

## Step 1: Check PIN

Read `specs/readme.md`. If not found, ask: Project name? Stack? Test command?

Create `specs/readme.md`:
```markdown
# [Project] Specs
**Stack**: [stack] | **Tests**: [command]

## Lookup Table
| Spec | File | Keywords |
|------|------|----------|
```

## Step 2: Determine Mode

{{#if mode}}Mode: {{mode}}{{else}}Ask: "Forward (new build) or Reverse (extract from existing)?"{{/if}}

---

### Forward Mode

Interview (max 5 exchanges, "I don't care" = complete):
- What are you building?
- Constraints/preferences?

Create `specs/[name].md` (spec) and `specs/[name]-plan.md` (checklist with `file:lines` citations).
Update lookup table with 8+ keywords.

---

### Reverse Mode

**Purpose**: Extract specs from existing code/features.

1. **Explore**: Launch Explore agent to identify existing features/modules:
   > "Identify main features in this codebase. Return: name, description, key files."

2. **Present findings**: List discovered features, ask which to document.

3. **For each selected feature**:
   - Read key files to understand behavior
   - Interview briefly: "So [feature] does X—correct? Any constraints?"
   - Create `specs/[name].md` documenting current behavior
   - Update lookup table with 8+ keywords

4. **Optional plan**: If user wants improvements/tests, create `specs/[name]-plan.md`.

---

## Step 3: Create prompt.md

```markdown
<!-- loop-setup:active -->
Study specs/readme.md.
Study specs/[name]-plan.md.

Pick the most important unchecked item. Implement it.

After: Mark [x] in plan. Commit. EXIT.
```

## Step 4: Summary

Output files created. Next:
```
cat prompt.md | claude --dangerously-skip-permissions
```

STOP. Do not implement.
