# CPM Packages

The official package registry for [CPM](https://cpm-ai.dev) - the package manager for Claude Code.

## Install a Package

```bash
npm install -g @cpm/cli
cpm install @official/code-review
```

## Browse Packages

Visit [cpm-ai.dev/packages](https://cpm-ai.dev/packages) to browse all available packages.

## Publish Your Own

Visit [cpm-ai.dev/publish](https://cpm-ai.dev/publish) to share your Claude Code skills with the community.

## Structure

```
packages/
├── official/           # Official CPM packages
│   └── code-review/
├── username/           # Community packages
│   └── package-name/
└── ...
```

Each package contains:

- `meta.json` - Package metadata
- `skill.md` / `rules.md` - Package content

## License

MIT
