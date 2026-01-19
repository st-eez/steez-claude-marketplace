---
description: Scaffold Ralph Loop files (specs, prompt.md, plan)
arguments:
  - name: mode
    description: "forward (build), reverse (extract), investigate (identify), resolve (fix), specialized (domain patterns)"
    required: false
user_invocable: true
---

# Loop Setup v2

Scaffold files for Ralph Loop. This command creates files only.

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

{{#if mode}}Mode: {{mode}}{{else}}Ask: "Which mode? Forward (build), Reverse (extract), Investigate (identify), Resolve (fix), or Specialized (domain patterns)?"{{/if}}

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

### Investigate Mode

**Purpose**: Identify root cause of bugs/issues. Produces findings for resolution loop.

1. Ask: "What's the issue/symptom to investigate?"

2. **Explore**: Launch Explore agent to identify affected code:
   > "Find code related to [symptom]. Return: files, functions, data flow."

3. **Document findings**: Create `specs/investigate-[issue].md`:
```markdown
# Investigation: [Issue]
**Symptom**: [description]
**Affected files**: [file:line citations]
**Root cause**: [hypothesis]
**Resolution**: [recommended fix approach]
```

4. Update lookup table with keywords: issue, bug, investigate, [symptom terms].

5. **Create prompt.md** for resolution:
```markdown
<!-- loop-setup:active -->
Study specs/readme.md.
Study specs/investigate-[issue].md.

Implement the recommended resolution. Verify fix works.

After: Delete investigate file. Commit. EXIT.
```

---

### Resolve Mode

**Purpose**: Fix issues from investigation findings.

1. **Check for investigation**: Read `specs/investigate-*.md`. If none found:
   - Ask: "Which investigation file, or describe the issue to resolve?"
   - If user describes issue directly, create brief `specs/investigate-[issue].md` first.

2. **Create resolution plan**: Create `specs/resolve-[issue]-plan.md` with:
   - Checklist of fixes with `file:line` citations
   - Verification steps (tests, manual checks)

3. **Create prompt.md**:
```markdown
<!-- loop-setup:active -->
Study specs/readme.md.
Study specs/investigate-[issue].md.
Study specs/resolve-[issue]-plan.md.

Pick the most important unchecked fix. Implement it.

After: Mark [x] in plan. Commit. EXIT.
```

---

### Specialized Mode

**Purpose**: Domain-specific loops (i18n, security, quality, testing). One concern per loop.

1. Ask: "Which pattern? i18n, security, quality, or testing?"

2. **Explore**: Launch Explore agent for affected files:
   - i18n: "Find user-facing strings, labels, error messages"
   - security: "Find auth, input validation, data exposure points"
   - quality: "Find code smells, duplication, naming inconsistencies"
   - testing: "Find untested functions, edge cases, coverage gaps"

3. **Create pattern spec** `specs/[pattern]-patterns.md`:
```markdown
# [Pattern] Patterns
**Purpose**: [what this loop enforces]
**Targets**: [file:line citations]
**Rules**: [specific patterns to apply]
```

4. **Create plan** `specs/[pattern]-plan.md` with checklist of targets.

5. Update lookup table with keywords: [pattern], loop, specialized, [domain terms].

6. **Create prompt.md**:
```markdown
<!-- loop-setup:active -->
Study specs/readme.md.
Study specs/[pattern]-patterns.md.
Study specs/[pattern]-plan.md.

Pick the most important unchecked item. Apply the pattern.

After: Mark [x] in plan. Commit. EXIT.
```

---

## Step 3: Create CLAUDE.md

If `.claude/CLAUDE.md` doesn't exist, create it:
```markdown
# [Project]

Read `specs/readme.md` for spec lookup. One goal per context window.
Cite `file:line` when referencing code. Verify changes compile/pass tests.
```

## Step 4: Create prompt.md

```markdown
<!-- loop-setup:active -->
Study specs/readme.md.
Study specs/[name]-plan.md.

Pick the most important unchecked item. Implement it.

After: Mark [x] in plan. Commit. EXIT.
```

## Step 5: Summary

Output files created. Next:
```
cat prompt.md | claude --dangerously-skip-permissions
```

STOP here. Scaffolding complete.
