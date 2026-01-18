---
description: Scaffold specs and prompt.md for the Ralph Loop bash workflow
arguments:
  - name: feature
    description: Optional feature seed to start the conversation
    required: false
user_invocable: true
---

**CRITICAL: This command ONLY scaffolds files. You must NEVER implement anything.**

Your ONLY job is to:
1. Interview the user about their work
2. Create spec files, implementation plan, and prompt.md
3. Output the summary
4. **STOP COMPLETELY**

Implementation happens in a SEPARATE terminal via `cat prompt.md | claude`. You are NOT that terminal. You are the setup phase only.

---

# Loop Setup

You are having a conversation to create specifications for a bash loop workflow.

## How This Works

Geoffrey's approach:
- "It starts with a conversation and the conversation creates specs"
- "And it's a dance, folks. This is how you build your specifications"
- "You can interview me"

The human gives a seed like "I want to add product analytics like PostHog" and you interview them. They give quick answers. The conversation creates the spec.

## Key Concepts

**Two types of files in specs/:**
1. **Specs** (`[feature-name].md`) - Permanent documentation of codebase features. Indexed in lookup table.
2. **Plans** (`[name]-implementation-plan.md`) - Implementation checklists. NOT indexed. The loop works from these.

## Step 1: Check for Existing PIN

**CRITICAL: Do NOT use Search or Glob tools. Use ONLY the Read tool.**

Call `Read(specs/README.md)` now. If that fails, try `Read(specs/readme.md)`.

- **File not found (Read fails with error):** Proceed to Step 2.
- **File found (Read succeeds):** Read and understand the project context, then check for existing spec files:
  - Use `Glob("specs/*.md")` to find all spec files
  - **If ONLY readme.md exists** (no other spec files): Proceed to Step 2b (bootstrap existing features)
  - **If other spec files exist** (besides readme.md): Skip to Step 3 (already bootstrapped)

## Step 2: Create the PIN (First Time Only)

Ask the human:
- What's this project called?
- What's the tech stack?
- How do you run tests?

Create `specs/readme.md`:

```markdown
# [Project Name] Specifications

**Stack**: [languages/frameworks]
**Test command**: [command]

## Keyword Lookup Table

| Spec | File | Search Keywords |
|------|------|-----------------|

## Current Functionality

[To be evolved as specs are added]
```

**CHECKPOINT:** Read back specs/readme.md.
- Success: Output "Created specs/readme.md ✓"
- Failure: Retry write, then report error

→ Proceed to Step 2b: Bootstrap Existing Features

---

## Step 2b: Bootstrap Existing Features (First Time Only)

**Geoffrey's principle:** "It starts with a conversation and the conversation creates specs"

**Context optimization:** Use sub-agents for exploration to keep main context lean.

### 2b.1: Launch Parallel Exploration Agents

Launch 2-3 Explore agents IN PARALLEL to analyze the codebase:

**Agent 1 - Core Features:**
"Explore this codebase to identify the main features and functionality. Look at entry points, main modules, and key directories. Return a list of distinct features with: name, what it does, key files involved."

**Agent 2 - Architecture & Patterns:**
"Explore this codebase to understand the architecture and patterns. Identify: tech stack, project structure, how modules connect, shared utilities. Return a summary of the codebase organization."

**Agent 3 (optional, for larger codebases) - Secondary Features:**
"Explore this codebase for secondary features, integrations, and utilities that Agent 1 might miss. Look at: API endpoints, background jobs, CLI commands, integrations. Return a list of features with: name, description, key files."

Wait for all agents to complete.

### 2b.2: Consolidate and Propose Features

Merge agent findings into a deduplicated list. Present to user:

---
**EXISTING CODEBASE ANALYSIS**

I explored the codebase and found these existing features/modules:

1. **[Feature name]** - [brief description of what it does]
2. **[Feature name]** - [brief description]
3. ...

Which should we document as specs?
- Reply with numbers (e.g., "1, 3") or "all"
- Add your own: "1, 3, and also the caching layer"
- Reply "skip" to skip bootstrapping and go straight to new work

(We can always add more specs later)
---

**STOP and WAIT for user response.**

### 2b.3: Interview About Selected Features

For each selected feature, brief conversational interview (max 3 exchanges per feature):

- Confirm your understanding: "So [feature] handles X by doing Y - is that right?"
- Ask about constraints: "Any important limitations or design decisions?"
- Ask about integrations: "What does this depend on or connect to?"

**Accept brief answers.** "That's right", "yep", "I don't care" are all valid. Move quickly.

### 2b.4: Generate Specs

For each discussed feature, create `specs/[feature-name].md`:

```markdown
# [Feature Name]

## What It Does
[Description from conversation/exploration]

## Constraints
[Any limitations discussed, or "None specified"]

## Implementation Notes
[Key patterns discovered - file locations, dependencies, conventions]
```

**CHECKPOINT:** Read back each spec file.
- Success: Output "Created specs/[name].md ✓"
- Failure: Retry write, then report error

### 2b.5: Update Lookup Table

Add entry to `specs/readme.md` for each new spec with 8+ generative keywords:

| [Feature Name] | specs/[name].md | keyword1, keyword2, synonym, related-term, ... |

**CHECKPOINT:** Read specs/readme.md and verify entries.
- Success: Output "Bootstrapped [N] existing features ✓"

→ Proceed to Step 3: Determine Work Type

---

## Step 3: Determine Work Type

{{#if feature}}
Human's seed: "{{feature}}"
Analyze the seed to determine work type, then proceed accordingly.
{{else}}
Ask the user using AskUserQuestion tool:

**Question:** "What type of work are you doing?"

**Options:**
1. **New feature** - Adding new functionality (one feature at a time, creates spec + plan)
2. **Bug fixes** - Fixing broken behavior (gather ALL bugs into one plan, no spec)
3. **Improvement/refactor** - Enhancing existing code (plan only, no spec unless functionality changes)
{{/if}}

**Based on work type, follow the appropriate path:**

---

## PATH A: New Feature (Single Feature)

### A1: Interview About the Feature (Ephemeral Analysis)

**NOTE:** This interview and research captures context for YOU to understand the work. The plan is just a checklist—"why" analysis stays in this conversation.

**Geoffrey's Quick Conversation Pattern:**
- Maximum 5 question-answer exchanges
- Accept "I don't care" as complete answer
- When in doubt, YOU decide

Interview about:
- What it should do
- Constraints/preferences ("I don't care about privacy", "No mobile", "Use SQLite")
- Search the codebase to find existing patterns they should follow

**MANDATORY: Research BEFORE Proposing**
- **NEVER guess** or hypothesize an approach before researching
- **NEVER propose** any implementation until you have consulted official docs
- **STOP and research FIRST** - then propose based on what you learned

You MUST:
1. Use Context7 (mcp__plugin_context7_context7__resolve-library-id → mcp__plugin_context7_context7__query-docs) to fetch official documentation for any libraries/frameworks involved
2. Search for established patterns and best practices
3. Understand the "right way" to implement this, not just "a way that works"

Never compromise on code quality for speed. A proper solution following best practices is always worth the extra research time.

After covering: what it does + constraints + existing patterns + **completed Context7 research** → proceed to A2.

### A2: Confirm Readiness

Output:

---
**READY TO GENERATE FILES?**

What I understand:
- [Feature goal in one sentence]
- [Key constraints]

Patterns found: [file paths or "none searched"]
Files to modify: [file paths with reasons]

Will create:
- Spec: `specs/[feature-name].md`
- Plan: `specs/[feature-name]-implementation-plan.md`

Reply "go" to generate files, or add more context.
---

**STOP and WAIT for user response.**

### A3: Generate Spec

Create `specs/[feature-name].md`:

```markdown
# [Feature Name]

## What It Does
[Clear description from conversation]

## Constraints
[Any limitations or preferences discussed]

## Existing Patterns
[Code patterns found that should be followed]
```

**CHECKPOINT:** Read back the spec file.
- Success: Output "Created specs/[name].md ✓"
- Failure: Retry write, then report error

### A4: Generate Plan

Create `specs/[feature-name]-implementation-plan.md`:

```markdown
# [Feature Name] Implementation Plan

- [ ] `[file path]:[start-end lines]`: [specific change]
- [ ] `[file path]:[start-end lines]`: [specific change]
- [ ] `[test file]`: [tests to add]
```

**Plan format:** Just a title and checklist items. No Sources, Why, or Notes sections—that context lives in this planning conversation, not in the plan the loop executes.

**CHECKPOINT:** Read back the plan file.
- Success: Output "Created specs/[name]-implementation-plan.md ✓"
- Failure: Retry write, then report error

### A5: Update Lookup Table

Add entry to `specs/readme.md` with MANY keywords (8+ generative words):

```markdown
| [Feature Name] | specs/[name].md | keyword1, keyword2, synonym, related-term, alternate-name, ... |
```

**CHECKPOINT:** Read specs/readme.md and verify entry exists.
- Success: Output "Updated specs/readme.md ✓"

→ Skip to Step 4: Create prompt.md

---

## PATH B: Bug Fixes (Gather All Bugs)

### B1: Gather ALL Bugs

Ask: "What bugs are you experiencing? Describe them all."

For each bug mentioned, interview briefly:
- How to reproduce (exact steps)
- Expected vs actual behavior
- Suspected cause (or explore codebase to find it)

**Keep asking:** "Any other bugs to fix?" until user says "that's all" or equivalent.

### B2: Find Root Causes (Ephemeral Analysis)

**NOTE:** This analysis stays in the conversation—it doesn't go in the plan. The plan is just a checklist.

For each bug, search the codebase to:
- Identify the root cause
- Find the files that need changes
- Understand the fix approach

**MANDATORY: Research BEFORE Diagnosing**
- **NEVER guess** or hypothesize a root cause before researching
- **NEVER propose** any fix until you have consulted official docs AND verified the actual root cause
- **STOP and research FIRST** - use Context7, then diagnose based on what you learned

You MUST:
1. Use Context7 (mcp__plugin_context7_context7__resolve-library-id → mcp__plugin_context7_context7__query-docs) to fetch official documentation for any libraries/frameworks involved
2. Verify you've found the ACTUAL root cause, not just a symptom
3. Ensure the fix addresses the root cause, not a bandaid that masks the problem
4. Check official docs for the "correct" way to handle this scenario

**Root Cause vs Bandaid Test:**
- Bandaid: "Add a null check here" (masks the problem)
- Root cause: "The data is null because X upstream isn't initializing it correctly"

Never compromise on code quality for speed. A proper fix is always worth the extra investigation time.

### B3: Confirm Readiness

Output:

---
**READY TO GENERATE BUG FIX PLAN?**

Bugs to fix:
1. [Bug 1]: [root cause] → [fix approach]
2. [Bug 2]: [root cause] → [fix approach]
3. ...

Files to modify: [file paths]

Will create:
- Plan: `specs/bug-fixes-implementation-plan.md` (no spec - bugs don't need permanent docs)

Reply "go" to generate, or add more bugs/context.
---

**STOP and WAIT for user response.**

### B4: Generate Bug Fix Plan

Create `specs/bug-fixes-implementation-plan.md`:

```markdown
# Bug Fixes Implementation Plan

## Bug 1: [Short Name]
- [ ] `[file path]:[start-end lines]`: [specific change]
- [ ] `[test file]`: [regression test]

---

## Bug 2: [Short Name]
- [ ] `[file path]:[start-end lines]`: [specific change]
- [ ] `[test file]`: [regression test]
```

**Plan format:** Just bug section headers and checklist items. Problem/Reproduction/Root Cause/Why analysis happens in this conversation—it doesn't go in the plan.

**CHECKPOINT:** Read back the plan file.
- Success: Output "Created specs/bug-fixes-implementation-plan.md ✓"
- Failure: Retry write, then report error

→ Skip to Step 4: Create prompt.md (no lookup table update for bugs)

---

## PATH C: Improvement/Refactor

### C1: Interview About the Improvement (Ephemeral Analysis)

**NOTE:** This interview captures context for YOU to understand the work. The plan is just a checklist—Goal/Current/Target/Why stays in this conversation.

Interview about:
- What improvement this achieves
- Current state (how it works now)
- Target state (how it should work after)
- Search codebase for affected files

**MANDATORY: Research BEFORE Proposing**
- **NEVER guess** or hypothesize a refactor approach before researching
- **NEVER propose** any changes until you have consulted official docs
- **STOP and research FIRST** - then propose based on what you learned

You MUST:
1. Use Context7 (mcp__plugin_context7_context7__resolve-library-id → mcp__plugin_context7_context7__query-docs) to fetch official documentation for any libraries/frameworks involved
2. Research established patterns for this type of refactoring
3. Ensure the target state follows best practices, not just "different code"

Never compromise on code quality for speed. A proper refactor following best practices is always worth the extra research time.

### C2: Confirm Readiness

Output:

---
**READY TO GENERATE REFACTOR PLAN?**

What I understand:
- Goal: [improvement goal]
- Current: [how it works now]
- Target: [how it should work]

Files to modify: [file paths]

Will create:
- Plan: `specs/[name]-refactor-implementation-plan.md`
- Spec: Only if functionality changes

Reply "go" to generate, or add more context.
---

**STOP and WAIT for user response.**

### C3: Generate Plan

Create `specs/[name]-refactor-implementation-plan.md`:

```markdown
# Refactor: [Name] Implementation Plan

- [ ] `[file path]:[start-end lines]`: [specific change]
- [ ] `[file path]:[start-end lines]`: [specific change]
```

**Plan format:** Just a title and checklist items. Goal/Current/Target/Why analysis happens in this conversation—it doesn't go in the plan.

**CHECKPOINT:** Read back the plan file.
- Success: Output "Created specs/[name]-refactor-implementation-plan.md ✓"
- Failure: Retry write, then report error

→ Skip to Step 4: Create prompt.md

---

## Step 4: Create prompt.md

**IMPORTANT: prompt.md goes in the PROJECT ROOT, NOT in specs/.**

The loop runs `cat prompt.md | claude` from the project root, so prompt.md must be there.

**Always refresh prompt.md with the latest template.**

**If `./prompt.md` exists (project root):**
1. Read it to extract the current plan reference (look for `specs/[name]-implementation-plan.md`)
2. If setting up NEW work: use the new plan file just created
3. If just refreshing: keep the extracted plan reference
4. **Auto-migrate verbose plan if detected** (see migration logic below)
5. Regenerate `./prompt.md` with latest template
6. Output: "prompt.md refreshed ✓ (Plan: [plan-file])"

**If `./prompt.md` doesn't exist (project root):**
1. Create `./prompt.md` in the project root (NOT specs/)
2. Output: "Created prompt.md ✓"

**Auto-Migration Logic (for refreshing existing plans):**

If refreshing and plan file exists, check for verbose format markers:
- `### Problem`, `### Reproduction`, `### Root Cause`, `### Fix`
- `**Confidence:`, `**Why This Fix`, `**Trade-off:`
- `## Workflow` embedded section
- `## Sources Consulted`
- `## Why This Approach`, `## Goal`, `## Current State`, `## Target State`, `## Notes`

If verbose format detected:
1. Extract section headers (`## Bug 1: [Name]`, `## Phase 1: [Name]`, etc.)
2. Extract all checklist items (`- [ ]` and `- [x]` lines with nested bullets)
3. Preserve `## Discovered Issues` section if present
4. Discard everything else (Problem, Reproduction, Root Cause, Why, Sources, etc.)
5. Reconstruct lean plan:
   ```markdown
   # [Plan Title]

   ## [Section Header]
   - [ ] `[file]:[lines]`: [change]
   - [x] `[file]:[lines]`: [completed change]

   ---

   ## [Next Section]
   - [ ] `[file]:[lines]`: [change]

   ## Discovered Issues
   - [ ] `[file]:[lines]`: [issue] (discovered during [task])
   ```
6. Write migrated plan, output: "Migrated plan to lean format ✓"

**Placeholder substitution when generating prompt.md:**

| Placeholder | Description | Example |
|-------------|-------------|---------|
| `[name]` | Base name for this work | `auth-feature`, `bug-fixes`, `perf-refactor` |
| `[test command]` | Test command from specs/readme.md | `pnpm test`, `swift test` |
| `[prefix]` | Conventional commit prefix: `feat` (PATH A), `fix` (PATH B), `refactor` (PATH C) | `feat`, `fix`, `refactor` |

**File types in specs/:**
- **Plan** (`specs/[name]-implementation-plan.md`): The checklist the loop works from. Always exists.
- **Spec** (`specs/[name].md`): Permanent feature documentation. Only for PATH A (features). Referenced by SYNC SPEC step.

**Template (Geoffrey's lean approach):**

```markdown
<!-- loop-setup:active -->
Study specs/readme.md.
Study specs/[name]-implementation-plan.md.

Pick the most important unchecked item and implement it.

Important:
- Use existing patterns (search tool to find examples)
- Build tests (property-based or unit, whichever is best)

After implementing:
1. Run code-simplifier agent on modified files
2. Run loop-setup:validate skill
3. Fix any blocking issues, append discovered issues to plan
4. Run [test command] - fix failures from your changes
5. Update specs/*.md if behavior changed
6. Mark item `[x]` in plan, commit with "[prefix]: [description]"
7. Output `<promise>COMMITTED</promise>` and EXIT
```

**CHECKPOINT:** Read back `./prompt.md` (project root) and verify it references the correct plan file.
- Success: Output "prompt.md refreshed ✓" or "Created prompt.md ✓"
- Failure: Retry, then report error
- **If you accidentally created specs/prompt.md, delete it and recreate in project root**

---

## Step 5: Ensure CLAUDE.md Has Specs Integration

**Check for existing CLAUDE.md in project root:**

### If CLAUDE.md doesn't exist:

Create it with full template:

```markdown
# [Project Name]

## Commands
- Run tests: `[test command]`

## Rules

- **Workflow continuity**: After any tool completes (Skill, Task, or otherwise), immediately proceed to the next workflow step. Tool completion is NOT a pause point—only stop when the workflow is fully complete (committed) or genuinely blocked.
- **Test failures**: Only fix tests that fail due to YOUR changes. Pre-existing test failures are DISCOVERED issues—append them to the plan and continue.

## Specs Workflow
- **Before implementing:** Search `specs/readme.md` keyword table to find existing patterns and related specs
- **Before modifying a feature:** Check if `specs/[feature].md` exists and read it first
- **After implementation changes behavior:** Update the relevant spec in specs/ to stay in sync
```

Output: "Created CLAUDE.md ✓"

### If CLAUDE.md exists:

1. Read the file
2. Check for **Rules section** (look for "## Rules")
3. Check for **Specs section** (look for "specs/readme" or "specs/" or "## Specs")

**Append missing sections (check each independently):**

**If NO Rules section found**, append:

```markdown

## Rules

- **Workflow continuity**: After any tool completes (Skill, Task, or otherwise), immediately proceed to the next workflow step. Tool completion is NOT a pause point—only stop when the workflow is fully complete (committed) or genuinely blocked.
- **Test failures**: Only fix tests that fail due to YOUR changes. Pre-existing test failures are DISCOVERED issues—append them to the plan and continue.
```

Output: "Added Rules section to CLAUDE.md ✓"

**If NO Specs section found**, append:

```markdown

## Specs Workflow
- **Before implementing:** Search `specs/readme.md` keyword table to find existing patterns and related specs
- **Before modifying a feature:** Check if `specs/[feature].md` exists and read it first
- **After implementation changes behavior:** Update the relevant spec in specs/ to stay in sync
```

Output: "Added Specs Workflow section to CLAUDE.md ✓"

**If both sections already exist:** Output "CLAUDE.md already configured ✓"

**CHECKPOINT:** Read CLAUDE.md and verify both Rules and Specs Workflow sections exist.

---

## Step 6: Output Summary

```
Loop setup complete for [name]

Files created:
- specs/[feature].md ✓ (bootstrapped)               [for each bootstrapped spec]
- specs/[name].md ✓ (feature spec - indexed)        [features only]
- specs/[name]-implementation-plan.md ✓ (plan)
- specs/readme.md (lookup table updated) ✓          [features only]
- prompt.md ✓
- CLAUDE.md ✓                                       [created or updated with specs workflow]

Workflow per task (SEQUENTIAL - no parallel agents):
  implement → simplify (wait) → validate → test → commit (includes plan update)
       ↑                                      │
       └────────── fix if tests fail ─────────┘

Next steps (Geoffrey's approach):

1. Review the files - "I generate them. Then I review them and edit them by hand"

2. Create a NEW ARRAY (new terminal) - "This context window already has one goal... create a new array"

3. Run ATTENDED first:
   ```
   cat prompt.md | claude --dangerously-skip-permissions
   ```
   "You don't just let it rip. You watch this."

4. Watch it. "I'll call out anything that's a little bit weird and I'll cancel this. I'll go back and adjust my prompt."

5. When stable:
   ```
   while true; do cat prompt.md | claude --dangerously-skip-permissions; done
   ```

If something's wrong: "That's just another Ralph loop"
```

---

## COMMAND COMPLETE

**STOP. Do not implement anything.**

This command scaffolds files only. Implementation happens in a fresh context window per Geoffrey's approach:

> "This context window already has one goal... create a new array"

The human will now:
1. Review generated files
2. Open new terminal
3. Run the loop there

Your job here is done. If the user asks you to implement, remind them: "Implementation should happen in a new terminal with `cat prompt.md | claude`. This keeps the context clean."
