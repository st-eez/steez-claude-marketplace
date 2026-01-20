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

## Plan Format Rules (ALL MODES)

Plans are flat checklists. The loop picks ONE item per iteration.

**Required structure:**
```markdown
# [Name] Plan

## Checklist
- [ ] `file:lines`: [change] | refs: specs/[name].md
- [ ] `file:lines`: [change] | refs: specs/[name].md
```

**Forbidden in plans:**
- Phase headers (`### Phase 1`, `## Phase 2`)
- Section groupings (`## Setup`, `## Configuration`, `## Verification`)
- Nested task groups
- Any structure that implies "complete this group together"

Each checklist item is independent. Order by priority if natural order exists, otherwise list as discovered. The loop handles one item, commits, exits, repeats.

## prompt.md Rules (ALL MODES)

prompt.md has exactly 2 study lines—no more:
1. `Study specs/readme.md` (the PIN/lookup table)
2. `Study specs/[name]-plan.md` (the plan for this work)

**Never add additional study lines.** Specs are accessed via:
- The PIN's keyword lookup table (triggers search tool when needed)
- The plan's `refs:` links (strong linkage to relevant specs)

Adding `Study specs/[name].md` wastes tokens every loop iteration. The lookup table pattern exists precisely to avoid this.

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

<!-- Include: abbreviations (auth/authentication), related concepts (login/session/jwt),
     and terms users might search for. More keywords = better cache hits. -->
<!-- | Auth | specs/auth.md | authentication, login, logout, session, jwt, token, oauth, signin, signup | -->
```

**Checkpoint**: Read back `specs/readme.md`. Verify: file exists, structure matches template, content reflects interview. If missing or malformed, retry. Output "✓ PIN created" when verified.

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

**Explore codebase**: Launch Explore agent to discover patterns:
> "Find patterns in the codebase: naming conventions, test approaches, error handling, code organization, API styles. Return: pattern name, example file:line."

**Present patterns**: List discovered patterns, ask which to enforce:
> "Found these patterns: [list]. Which should the loop follow? (select all that apply, or 'none')"

Store confirmed patterns for prompt.md Important section.

**Check for existing files:**
If any target files exist (`specs/[name].md`, `specs/[name]-plan.md`, `prompt.md`), ask:
> "Found existing files. Update to current format (keeps your intent)?"

- **Yes**: Read existing files. Extract: goals, constraints, key decisions, file references.
  Overwrite with proper structure, carrying forward what the user was trying to accomplish.
- **No**: Skip existing files, only create missing ones

Create `specs/[name].md` using this template:
```markdown
# [Name]
**Stack**: [relevant stack subset] | **Tests**: [test command if different from root]

## What It Does
[Core behavior in 2-3 sentences. Brevity matters—specs are read every loop iteration.]

## Constraints
- [Technical constraints]
- [Business rules]
- [Performance requirements]

## Key Files
- `src/file.ts:42-58`: [what this code handles]
- `src/other.ts:15`: [what this code handles]
```

<!-- Strong linkage: file:line lets the loop find exact code. refs: links to spec for context. -->
Create `specs/[name]-plan.md` (see Plan Format Rules—flat checklist only):
```markdown
# [Name] Plan

## Checklist
- [ ] `src/file.ts:42-58`: [change description] | refs: specs/[name].md
- [ ] `src/other.ts:15`: [change description] | refs: specs/[name].md
- [ ] `tests/[name].test.ts`: add tests for [feature] | refs: specs/[name].md
```

Update lookup table with 8+ keywords.

**Checkpoint**: Read back `specs/[name].md`. If content matches intent, output "✓ spec created". If missing or malformed, retry.
**Checkpoint**: Read back `specs/[name]-plan.md`. If content matches intent, output "✓ plan created". If missing or malformed, retry.

---

### Reverse Mode

**Purpose**: Extract specs from existing code/features/documentation.

Interview (max 5 exchanges, "I don't care" = complete):
- What do you want to document?
- What sources should I look at? (codebase paths, URLs, PDFs, user guides, marketing materials, documentation)

**Confirm understanding**: Present summary:
> "Extracting specs for [target] from [sources]. READY? Reply 'go' to proceed."

Wait for user confirmation before creating files.

**Check for existing files:**
If any target files exist (`specs/reverse-[target]-plan.md`, `prompt.md`), ask:
> "Found existing files. Update to current format (keeps your intent)?"

- **Yes**: Read existing files. Extract: goals, constraints, key decisions, file references.
  Overwrite with proper structure, carrying forward what the user was trying to accomplish.
- **No**: Skip existing files, only create missing ones

1. **Create extraction plan** `specs/reverse-[target]-plan.md` (see Plan Format Rules—flat checklist only):
```markdown
# Reverse [Target] Plan

## Checklist
- [ ] Extract from `[source]`: [what to document] | type: [codebase/URL/PDF]
- [ ] Extract from `[source]`: [what to document] | type: [codebase/URL/PDF]
```

2. Update lookup table with keywords: reverse, extract, document, [target terms].

3. **Create prompt.md**:
```markdown
<!-- loop-setup:active -->
Study specs/readme.md.
Study specs/reverse-[target]-plan.md.

Pick the most important unchecked item. Extract the spec:
1. Study the source
2. Create specs/[name].md using standard template
3. Update lookup table with 8+ keywords

After: Mark [x] in plan. Commit. EXIT.
```

**Checkpoint**: Read back files. If content matches intent, output "✓ created". If missing or malformed, retry.

**Note**: Reverse mode extracts specs from existing sources. To build new features, run `/setup forward` (new session).

---

### Investigate Mode

**Purpose**: Identify root cause of bugs/issues. Produces findings for resolution loop.

Interview (max 5 exchanges, "I don't care" = complete):
- What's the issue/symptom to investigate?
- What sources should I look at? (codebase paths, error logs, stack traces, bug report URLs, issue tracker links)

**Confirm understanding**: Present summary:
> "Investigating [issue/symptom] using [sources]. READY? Reply 'go' to proceed."

Wait for user confirmation before creating files.

**Check for existing files:**
If any target files exist (`specs/investigate-[issue].md`, `specs/investigate-[issue]-plan.md`, `prompt.md`), ask:
> "Found existing files. Update to current format (keeps your intent)?"

- **Yes**: Read existing files. Extract: goals, constraints, key decisions, file references.
  Overwrite with proper structure, carrying forward what the user was trying to accomplish.
- **No**: Skip existing files, only create missing ones

1. **Create findings file** `specs/investigate-[issue].md`:
```markdown
# Investigation: [Issue]
**Symptom**: [description]

## Findings
<!-- Loop documents findings here -->

## Conclusion
**Root cause**: TBD
**Recommended resolution**: TBD
```

2. **Create investigation plan** `specs/investigate-[issue]-plan.md` (see Plan Format Rules—flat checklist only):
```markdown
# Investigate [Issue] Plan

## Checklist
- [ ] Check `[source]`: [what to look for] | refs: specs/investigate-[issue].md
- [ ] Check `[source]`: [what to look for] | refs: specs/investigate-[issue].md
```

3. Update lookup table with keywords: investigate, bug, issue, [symptom terms].

4. **Create prompt.md**:
```markdown
<!-- loop-setup:active -->
Study specs/readme.md.
Study specs/investigate-[issue]-plan.md.

Pick the most important unchecked task. Investigate:
1. Examine the source
2. Document findings in specs/investigate-[issue].md
3. If root cause found: Update conclusion section

After: Mark [x] in plan. Commit. EXIT.
```

**Checkpoint**: Read back files. If content matches intent, output "✓ created". If missing or malformed, retry.

**Note**: After investigation complete, run `/setup resolve` to create fix plan.

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

**Check for existing files:**
If any target files exist (`specs/resolve-[issue]-plan.md`, `prompt.md`), ask:
> "Found existing files. Update to current format (keeps your intent)?"

- **Yes**: Read existing files. Extract: goals, constraints, key decisions, file references.
  Overwrite with proper structure, carrying forward what the user was trying to accomplish.
- **No**: Skip existing files, only create missing ones

2. **Create resolution plan** `specs/resolve-[issue]-plan.md` (see Plan Format Rules—flat checklist only):
```markdown
# Resolve [Issue] Plan

## Checklist
- [ ] `file:lines`: [fix description] | refs: specs/investigate-[issue].md
- [ ] `tests/[file].test.ts`: add regression test for [issue] | refs: specs/investigate-[issue].md
```

3. **Create prompt.md**:
```markdown
<!-- loop-setup:active -->
Study specs/readme.md.
Study specs/resolve-[issue]-plan.md.

Pick the most important unchecked fix. Implement it.

After: Mark [x] in plan. Commit. EXIT.
```

**Checkpoint**: Read back files. If content matches intent, output "✓ created". If missing or malformed, retry.

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

**Check for existing files:**
If any target files exist (`specs/[concern]-patterns.md`, `specs/[concern]-plan.md`, `prompt.md`), ask:
> "Found existing files. Update to current format (keeps your intent)?"

- **Yes**: Read existing files. Extract: goals, constraints, key decisions, file references.
  Overwrite with proper structure, carrying forward what the user was trying to accomplish.
- **No**: Skip existing files, only create missing ones

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

5. **Create plan** `specs/[concern]-plan.md` (see Plan Format Rules—flat checklist only):
```markdown
# [Concern] Plan

## Checklist
- [ ] `file:lines`: [pattern to apply] | refs: specs/[concern]-patterns.md
- [ ] `file:lines`: [pattern to apply] | refs: specs/[concern]-patterns.md
```

6. Update lookup table with keywords: [concern], loop, specialized, [domain terms].

7. **Create prompt.md**:
```markdown
<!-- loop-setup:active -->
Study specs/readme.md.
Study specs/[concern]-plan.md.

Pick the most important unchecked item. Apply the pattern.

After: Mark [x] in plan. Commit. EXIT.
```

**Checkpoint**: Read back files. If content matches intent, output "✓ created". If missing or malformed, retry.

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

Avoid multi-line bash—use separate tool calls.
Configure test runner to only output failing tests (minimizes context usage).
```

**Checkpoint**: Read back `.claude/CLAUDE.md`. If content matches intent, output "✓ CLAUDE.md created". If missing or malformed, retry.

## Step 4: Create prompt.md

**Forward mode only.** Other modes create their own prompt.md in Step 2. If not Forward mode, skip to Step 5.

Create `prompt.md` (see prompt.md Rules—exactly 2 study lines):
```markdown
<!-- loop-setup:active -->
Study specs/readme.md.
Study specs/[name]-plan.md.

Pick the most important unchecked item. Implement it.

Important:
- Build tests (property-based or unit, whichever is best)
- Use existing patterns in the codebase (search to find examples)
[For each confirmed pattern from exploration:]
- Follow [pattern name] (see [file:line] for example)

Permissions:
- You may add temporary logging for debugging
[Add user-specified permissions here, e.g.: deploy, modify configs, etc.]

After: Run [test command]. Update specs if behavior changed. Mark [x] in plan. Commit. Exit.
```

**Checkpoint**: Read back `prompt.md`. If content matches intent, output "✓ prompt.md created". If missing or malformed, retry.

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
```

**Before running**: Read your specs yourself. One bad spec compounds into 10,000 lines of wrong code.

**Running the loop:**

1. **Attended first** - Run single iteration, watch output:
   ```
   cat prompt.md | claude
   ```
   Get curious why it did what it did. Check the commit, the tests, the changes.

2. **Tune** - If something weird happens, adjust `prompt.md` or specs. Run again attended. Repeat until behavior matches expectations.

3. **Unattended** - Once you trust it, let it loop:
   ```
   cat prompt.md | claude --dangerously-skip-permissions
   ```

STOP here. Scaffolding complete.
