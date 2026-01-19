---
description: Scaffold specs and prompt.md for Ralph Loop workflow
arguments:
  - name: mode
    description: "forward (build from specs), reverse (extract specs from code), investigate, resolve"
    required: false
user_invocable: true
---

# Loop Setup v2

Scaffold files for Ralph Loop workflow. Creates specs, plans, and prompt.md.

**You scaffold files only. You never implement.**

## Core Principles

- One context window = one goal
- ~5K tokens for specs (PIN context)
- Minimize allocation (stay out of dumb zone: 60-70%)
- Strong linkage (file:line citations)
- 8+ keywords in lookup table for cache hits

---

## Step 1: Check Project State

Read `specs/readme.md`. If not found, this is a new project.

**New project:** Interview for basics, then create specs/readme.md:
- "What's this project called?"
- "Tech stack?" (languages/frameworks)
- "Test command?" (e.g., `pnpm test`, `swift test`)

```markdown
# [Project] Specifications

**Stack**: [tech]
**Test command**: [cmd]

## Keyword Lookup Table

| Spec | File | Search Keywords |
|------|------|-----------------|

## Current Functionality

[Evolves as specs are added]
```

**CHECKPOINT:** Read back specs/readme.md. Success → proceed.

---

## Step 2: Determine Mode

{{#if mode}}
Mode: {{mode}} → skip to that mode's section.
{{else}}
Ask using AskUserQuestion:
- **Question:** "What type of work?"
- **Options:** Forward (build new), Reverse (extract specs), Investigate (diagnose), Resolve (fix known issue)
{{/if}}

---

## MODE: Forward (Build from Specs)

### Interview (max 5 exchanges)

Quick conversation pattern—accept "I don't care" as complete.

1. **What it does:** "What should [feature] do?"
2. **Constraints:** "Any limitations? (perf, security, compatibility)"
3. **Patterns:** Search codebase for similar features. "Found [X pattern] in [file:lines]—follow this?"
4. **Dependencies:** "What does this connect to?"

**Research before proposing:** Use Context7 for library docs. Never guess.

### Generate Files

**Spec** (`specs/[feature].md`):
```markdown
# [Feature Name]

## What It Does
[From interview]

## Constraints
[Any limitations, or "None specified"]

## Patterns
[Existing code to follow: file:lines]
```

**Plan** (`specs/[feature]-implementation-plan.md`):
```markdown
# [Feature] Implementation Plan

- [ ] `[file]:[lines]`: [specific change]
- [ ] `[file]:[lines]`: [specific change]
- [ ] `[test-file]`: [tests to add]
```

**Update lookup table** in specs/readme.md with 8+ keywords.

---

## MODE: Reverse (Extract Specs from Code)

### Interview (max 3 exchanges)

1. **Scope:** "Which part of the codebase? (all, specific feature, module)"
2. **Depth:** "Documentation level? (overview, detailed, exhaustive)"
3. **Existing docs:** "Any docs to incorporate?" (READMEs, wikis, comments)

### Analysis (use sub-agents)

Launch Explore agents to keep main context lean:
- **Agent 1:** "Identify main features, entry points, key modules. Return: name, purpose, key files."
- **Agent 2:** "Analyze architecture, patterns, how modules connect. Return: structure summary."

### Generate Files

For each discovered feature, create `specs/[feature].md`:
```markdown
# [Feature Name]

## What It Does
[Extracted from code analysis]

## Implementation Notes
[Key files, patterns, dependencies]
```

Update lookup table with 8+ keywords per spec.

---

## MODE: Investigate (Diagnose Issues)

### Interview (max 4 exchanges)

1. **Symptom:** "What's happening?" (error, wrong behavior, performance)
2. **Reproduction:** "Steps to reproduce? Or intermittent?"
3. **Suspected area:** "Any idea where it might be?" (or "no clue")
4. **Recent changes:** "Did this work before? What changed?"

### Analysis

- Search codebase for suspected areas
- Check logs, error patterns
- Trace data flow

**Output findings, do not fix.** Investigation identifies; resolution fixes.

### Generate Files

**Investigation report** (`specs/[issue]-investigation.md`):
```markdown
# Investigation: [Issue Name]

## Symptom
[What was observed]

## Findings
- Root cause: [or "suspected: X"]
- Affected files: `[file]:[lines]`, `[file]:[lines]`
- Evidence: [what pointed to this]

## Recommended Fix
[Approach, not implementation]
```

---

## MODE: Resolve (Fix Known Issues)

### Input

Requires investigation output. If none exists:
- "No investigation found. Run investigate mode first, or describe the issue."

### Interview (max 2 exchanges)

1. **Confirm scope:** "Fixing [issue] by [approach from investigation]—correct?"
2. **Constraints:** "Any constraints? (backwards compat, timeline)"

### Generate Files

**Plan** (`specs/[issue]-resolution-plan.md`):
```markdown
# Resolution: [Issue] Implementation Plan

- [ ] `[file]:[lines]`: [specific fix]
- [ ] `[file]:[lines]`: [specific fix]
- [ ] `[test-file]`: [regression test]
```

---

## Step 3: Create prompt.md

Create in **project root** (not specs/).

```markdown
<!-- loop-setup:active -->
Study specs/readme.md.
Study specs/[plan-file].md.

Pick the most important unchecked item. Build it.

Important:
- Use existing patterns (search first)
- Build tests (property-based or unit)

After: Mark `[x]` in plan. Commit. EXIT.
```

**CHECKPOINT:** Read back prompt.md, verify correct plan reference.

---

## Step 4: Output Summary

```
Loop setup complete ([mode] mode)

Files:
- specs/[name].md ✓
- specs/[name]-implementation-plan.md ✓
- specs/readme.md (updated) ✓
- prompt.md ✓

Next: cat prompt.md | claude --dangerously-skip-permissions
```

**STOP. Do not implement.**
