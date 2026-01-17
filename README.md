# steez-claude-marketplace

Claude Code plugin marketplace.

## Installation

```bash
/plugin marketplace add st-eez/steez-claude-marketplace
```

## Available Plugins

### loop-setup

Ralph Loop scaffolding - specs, PIN, implementation plans for bash loop workflow.

```bash
/plugin install loop-setup@steez-claude-marketplace
```

**Commands:**
- `/loop-setup:setup` - Scaffold specs and prompt.md for the Ralph Loop bash workflow
- `/loop-setup:validate` - Multi-agent validation for loop changes

**Hooks:**
- `UserPromptSubmit` - Creates state file on first prompt when loop workflow is active
- `Stop` - Prevents premature stopping during Ralph loop workflow (requires `<promise>COMMITTED</promise>`)

## License

MIT
