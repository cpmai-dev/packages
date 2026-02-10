# CPM Packages

The official package registry for [CPM](https://cpm-ai.dev) - the package manager for AI agents.

## Install a Package

```bash
npm install -g @cpm/cli
cpm install @official/code-review
```

## Browse Packages

Visit [cpm-ai.dev/packages](https://cpm-ai.dev/packages) to browse all available packages.

## Publish Your Own

Visit [cpm-ai.dev/publish](https://cpm-ai.dev/publish) to share your skills, rules, and MCP servers with the community.

## Structure

```
packages/
├── skills/             # Slash commands that extend agent capabilities (Claude Code)
├── rules/              # Markdown rules that guide agent behavior (Claude Code, Cursor)
├── mcp/                # Model Context Protocol server integrations (Claude Code, Cursor)
├── official/           # Official CPM packages
│   └── code-review/
├── username/           # Community packages
│   └── package-name/
└── ...
```

Each package contains:

- `cpm.yaml` - Package manifest
- `SKILL.md` / `*.md` - Package content

## License

MIT
