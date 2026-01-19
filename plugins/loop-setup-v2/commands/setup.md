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

Read `specs/readme.md`. If it exists, proceed to Step 2.

If not found, interview (max 3 exchanges):
- What's the project name?
- What's the tech stack?
- What command runs tests?

Create `specs/readme.md`:
```markdown
# [Project] Specs
**Stack**: [stack] | **Tests**: [command]

## Lookup Table
| Spec | File | Keywords (8+ for cache hits) |
|------|------|------------------------------|
| [name] | specs/[name].md | term1, term2, term3, term4, term5, term6, term7, term8 |
```

## Step 2: Determine Mode

{{#if mode}}Mode: {{mode}}{{else}}Ask: "Which mode? Forward (build), Reverse (extract), Investigate (identify), Resolve (fix), or Specialized (domain patterns)?"{{/if}}

---

### Forward Mode

Interview (max 5 exchanges, "I don't care" = complete):
- What are you building?
- What sources should I look at? (design docs, API specs, URLs, code patterns, feature requests)
- Constraints/preferences?

**Confirm understanding**: Present summary:
> "Building [feature] using [sources]. Constraints: [constraints]. READY? Reply 'go' to proceed."

Wait for user confirmation before creating files.

Create `specs/[name].md` (spec) and `specs/[name]-plan.md` (checklist with `file:lines` citations).
Update lookup table with 8+ keywords.

---

### Reverse Mode

**Purpose**: Extract specs from existing code/features/documentation.

Interview (max 5 exchanges, "I don't care" = complete):
- What do you want to document?
- What sources should I look at? (codebase paths, URLs, PDFs, user guides, marketing materials, documentation)

**Confirm understanding**: Present summary:
> "Documenting [target] from [sources]. READY? Reply 'go' to proceed."

Wait for user confirmation before exploring sources.

1. **Explore sources**: For each source type:
   - Codebase paths: Launch Explore agent to identify features/modules
   - URLs/PDFs/docs: Read and extract key behaviors, constraints, patterns

2. **Present findings**: List discovered features/behaviors, ask which to document.

3. **For each selected item**:
   - Synthesize understanding from all sources
   - Interview briefly: "So [feature] does X—correct? Any constraints?"
   - Create `specs/[name].md` documenting current behavior
   - Update lookup table with 8+ keywords

4. **Optional plan**: If user wants improvements/tests, create `specs/[name]-plan.md`.

---

### Investigate Mode

**Purpose**: Identify root cause of bugs/issues. Produces findings for resolution loop.

Interview (max 5 exchanges, "I don't care" = complete):
- What's the issue/symptom to investigate?
- What sources should I look at? (codebase paths, error logs, stack traces, bug report URLs, issue tracker links)

**Confirm understanding**: Present summary:
> "Investigating [issue/symptom] using [sources]. READY? Reply 'go' to proceed."

Wait for user confirmation before exploring sources.

1. **Explore sources**: For each source type:
   - Codebase paths: Launch Explore agent to identify affected code
   - Error logs/stack traces: Analyze for root cause patterns
   - Bug reports/URLs: Extract reproduction steps and context

2. **Document findings**: Create `specs/investigate-[issue].md`:
```markdown
# Investigation: [Issue]
**Symptom**: [description]
**Affected files**: [file:line citations]
**Root cause**: [hypothesis]
**Resolution**: [recommended fix approach]
```

3. Update lookup table with keywords: issue, bug, investigate, [symptom terms].

4. **Create prompt.md** for resolution:
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

Interview (max 3 exchanges, "I don't care" = complete):
- What sources should I look at? (library docs, similar fixes, StackOverflow, related PRs, codebase patterns)

1. **Check for investigation**: Read `specs/investigate-*.md`. If none found:
   - Ask: "Which investigation file, or describe the issue to resolve?"
   - If user describes issue directly, create brief `specs/investigate-[issue].md` first.

**Confirm understanding**: Present summary:
> "Resolving [issue] using [sources]. Investigation: [findings summary]. READY? Reply 'go' to proceed."

Wait for user confirmation before creating plan.

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

**Purpose**: Single-concern loops. One domain concern per loop (caching, accessibility, error handling, performance, etc.).

1. Ask: "What concern should this loop address?" (user describes it)

2. **Interview** (max 3 exchanges):
   - Understand the concern
   - What sources should I look at? (external style guides, best practices URLs, library docs, codebase patterns)

**Confirm understanding**: Present summary:
> "Addressing [concern] using [sources]. READY? Reply 'go' to proceed."

Wait for user confirmation before exploring sources.

3. **Explore**: Launch Explore agent for affected files based on described concern:
   > "Find code related to [concern]. Return: files, patterns, opportunities."

4. **Create concern spec** `specs/[concern]-patterns.md`:
```markdown
# [Concern] Patterns
**Purpose**: [what this loop enforces]
**Sources**: [guides, docs consulted]
**Targets**: [file:line citations]
**Rules**: [specific patterns to apply]
```

5. **Create plan** `specs/[concern]-plan.md` with checklist of targets.

6. Update lookup table with keywords: [concern], loop, specialized, [domain terms].

7. **Create prompt.md**:
```markdown
<!-- loop-setup:active -->
Study specs/readme.md.
Study specs/[concern]-patterns.md.
Study specs/[concern]-plan.md.

Pick the most important unchecked item. Apply the pattern.

After: Mark [x] in plan. Commit. EXIT.
```

---

## Step 3: Create CLAUDE.md

If `.claude/CLAUDE.md` doesn't exist, create minimal starter (user expands iteratively, 60-70 lines MAX):
```markdown
# [Project]

Read specs/readme.md for context lookup. One goal per context window.
Cite file:line when referencing code.

Before implementing: Search specs keywords for existing patterns.
Stay focused: Only fix issues caused by your changes. Discovered issues → append to plan, continue.
After changes: Run tests. Update specs if behavior changed.
```

## Step 4: Create prompt.md

```markdown
<!-- loop-setup:active -->
Study specs/readme.md.
Study specs/[name]-plan.md.

Pick the most important unchecked item. Implement it.

After: Run [test command]. Mark [x] in plan. Commit. Exit.
```

## Step 5: Summary

List all files created during this setup:
- `specs/readme.md` (if created new)
- `specs/[name].md` (spec file)
- `specs/[name]-plan.md` (plan file, if applicable)
- `prompt.md`
- `.claude/CLAUDE.md` (if created new)

Output format:
```
✓ Created: specs/readme.md, specs/[name].md, specs/[name]-plan.md, prompt.md
Next: cat prompt.md | claude --dangerously-skip-permissions
```

STOP here. Scaffolding complete.
