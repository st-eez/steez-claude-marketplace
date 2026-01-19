---
description: Scaffold specs and prompt.md for Ralph Loop workflow
arguments:
  - name: mode
    description: "forward (build from specs), reverse (extract specs from code), investigate, resolve"
    required: false
user_invocable: true
---

# Loop Setup v2

Scaffold files for Ralph Loop workflow. This command creates specs, plans, and prompt.md.

**You scaffold files only. You never implement.**

## Core Principles

- One context window = one goal
- ~5K tokens for specs (PIN context)
- Minimize allocation (stay out of dumb zone: 60-70%)
- Strong linkage (file:line citations)
- 8+ keywords in lookup table for cache hits

## Step 1: Check Project State

Read `specs/readme.md`. If not found, this is a new project.

**If new project:** Create specs/readme.md with lookup table structure:

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

## Step 2: Determine Mode

{{#if mode}}
Mode: {{mode}}
{{else}}
Ask: "What type of work? (forward/reverse/investigate/resolve)"
{{/if}}

### Forward Mode
Build from specs. Interview about the feature, create spec + plan.

### Reverse Mode
Extract specs from existing code. Analyze codebase, generate documentation.

### Investigate Mode
Identify issues. Research, diagnose, document findings.

### Resolve Mode
Fix identified issues. Work from investigation output.

## Step 3: Generate Files

Based on mode, create appropriate files in specs/ directory.

**Plan format (lean):**
```markdown
# [Name] Implementation Plan

- [ ] `[file]:[lines]`: [change]
- [ ] `[file]:[lines]`: [change]
```

## Step 4: Create prompt.md

Create in project root (not specs/):

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

## Step 5: Output Summary

```
Loop setup complete.

Files: [list created files]

Next: cat prompt.md | claude --dangerously-skip-permissions
```

**STOP. Do not implement.**
