# Contributing to CPM Package Registry

This guide explains how to submit packages to the CPM (Claude Package Manager) registry.

## Package Types

| Type | Description | Directory |
|------|-------------|-----------|
| **skill** | Slash commands that extend Claude's capabilities | `packages/skills/` |
| **rules** | Markdown rules that guide Claude's behavior | `packages/rules/` |
| **mcp** | Model Context Protocol server integrations | `packages/mcp/` |

## How to Submit a Package

### Step 1: Create Your Package Directory

Create your package in the appropriate directory following this structure:

```
packages/{type}/{your-username}/{package-name}/
├── cpm.yaml          # Required: Package manifest
├── SKILL.md          # Required for skills: Skill content
└── *.md              # Required for rules: Rule files
```

**Directory naming rules:**
- Use lowercase letters, numbers, and hyphens only
- Your username should match your GitHub username
- Package name should be descriptive and kebab-case

**Example paths:**
```
packages/skills/johndoe/my-awesome-skill/
packages/rules/johndoe/coding-standards/
packages/mcp/johndoe/database-connector/
```

### Step 2: Create cpm.yaml Manifest

Every package requires a `cpm.yaml` file with these fields:

#### Required Fields (All Types)

```yaml
name: "@your-username/package-name"   # Must match @{username}/{package-name}
version: "1.0.0"                       # Semantic versioning (X.Y.Z)
description: "Brief description"       # What your package does
author: "your-username"                # Your username
type: skill                            # One of: skill, rules, mcp
```

#### Type-Specific Fields

**For Skills:**
```yaml
name: "@johndoe/my-skill"
version: "1.0.0"
description: "A skill that does something useful"
author: "johndoe"
type: skill
source: "https://github.com/johndoe/my-skill"  # Optional: source repo
skill:
  command: /my-skill                            # Slash command (must start with /)
  description: "Brief command description"      # Shown in help
```

**For Rules:**
```yaml
name: "@johndoe/my-rules"
version: "1.0.0"
description: "Rules for consistent coding"
author: "johndoe"
type: rules
source: "https://github.com/johndoe/my-rules"  # Optional
rules:
  glob: "*.md"                                  # File pattern
  files:                                        # List all rule files
    - coding-style.md
    - best-practices.md
```

**For MCP Servers:**
```yaml
name: "@johndoe/my-mcp"
version: "1.0.0"
description: "MCP server for database access"
author: "johndoe"
type: mcp
source: "https://github.com/johndoe/my-mcp"    # Optional
mcp:
  command: npx                                  # One of: npx, node, python, uvx, docker
  args:                                         # Command arguments
    - "@johndoe/my-mcp-server"
```

### Step 3: Add Content Files

**For Skills** - Create `SKILL.md`:
```markdown
---
name: my-skill
description: Brief description
---

# My Skill

Instructions and content for Claude to follow when this skill is invoked.

## Usage

Explain how to use the skill...
```

**For Rules** - Create your markdown rule files:
```markdown
# Coding Style Rules

## Naming Conventions

Use camelCase for variables...
```

### Step 4: Update registry.json

Add your package to `registry.json` in the `packages` array:

```json
{
  "name": "@your-username/package-name",
  "path": "skills/your-username/package-name",
  "version": "1.0.0",
  "description": "Same description as cpm.yaml",
  "author": "your-username"
}
```

**Important:** The `version` and `description` must match your `cpm.yaml`.

### Step 5: Create a Pull Request

1. Fork this repository
2. Create a new branch: `git checkout -b add-package-name`
3. Add your package files
4. Commit your changes: `git commit -m "Add @username/package-name"`
5. Push to your fork: `git push origin add-package-name`
6. Open a Pull Request

## Validation Rules

Your PR will be automatically validated. Here's what we check:

### Schema & Structure
| Check | Requirement |
|-------|-------------|
| cpm.yaml exists | Every package must have a manifest |
| Valid YAML | No syntax errors |
| Required fields | name, version, description, author, type |
| Valid semver | Version must be X.Y.Z format (e.g., 1.0.0) |
| Valid type | Must be `skill`, `rules`, or `mcp` |
| Type-specific fields | Skills need `skill.command`, rules need `rules.files`, etc. |

### Naming & Paths
| Check | Requirement |
|-------|-------------|
| Name format | Must be `@author/package-name` |
| Path matches name | `@johndoe/my-pkg` → `skills/johndoe/my-pkg/` |
| No path traversal | No `..` in file paths |
| No hidden files | No files starting with `.` (except `.gitkeep`) |

### Security (MCP Only)
| Check | Requirement |
|-------|-------------|
| Allowed commands | Only: `npx`, `node`, `python`, `uvx`, `docker` |
| No shell characters | No `;`, `|`, `&`, `` ` ``, `$()`, `&&`, `\|\|` |
| No dangerous flags | No `--eval`, `-e`, `--exec`, `-c` |
| No network commands | No `curl`, `wget`, `nc`, `netcat`, `telnet` |

### File Types
| Allowed | Not Allowed |
|---------|-------------|
| `.md`, `.yaml`, `.yml`, `.json`, `.mdc` | `.sh`, `.exe`, `.py`, `.js`, `.ts`, etc. |

### Registry Consistency
| Check | Requirement |
|-------|-------------|
| Registry entry exists | Package must be in `registry.json` |
| Version matches | cpm.yaml and registry.json versions must match |

## Reserved Namespaces

The following namespaces are reserved for official packages:
- `@cpm/*`
- `@cpmai/*`
- `@official/*`

Using these namespaces requires maintainer approval.

## Versioning Guidelines

We follow [Semantic Versioning](https://semver.org/):

- **MAJOR** (1.0.0 → 2.0.0): Breaking changes
- **MINOR** (1.0.0 → 1.1.0): New features, backward compatible
- **PATCH** (1.0.0 → 1.0.1): Bug fixes, backward compatible

For new packages, start with `1.0.0`.

## Example: Complete Skill Package

```
packages/skills/johndoe/code-reviewer/
├── cpm.yaml
└── SKILL.md
```

**cpm.yaml:**
```yaml
name: "@johndoe/code-reviewer"
version: "1.0.0"
description: "Automated code review with best practices and security checks"
author: "johndoe"
type: skill
source: "https://github.com/johndoe/code-reviewer"
skill:
  command: /code-review
  description: "Review code for quality and security issues"
```

**SKILL.md:**
```markdown
---
name: code-reviewer
description: Automated code review
---

# Code Review Skill

When invoked, perform a comprehensive code review covering:

## Quality Checks
- Code readability
- Function complexity
- Naming conventions

## Security Checks
- Input validation
- SQL injection
- XSS vulnerabilities
```

**registry.json entry:**
```json
{
  "name": "@johndoe/code-reviewer",
  "path": "skills/johndoe/code-reviewer",
  "version": "1.0.0",
  "description": "Automated code review with best practices and security checks",
  "author": "johndoe"
}
```

## Getting Help

- **Validation errors?** Check the CI output for specific error codes and fixes
- **Questions?** Open an issue with the `question` label
- **Bug reports?** Open an issue with the `bug` label

## Code of Conduct

- Be respectful and constructive
- No malicious packages
- No packages that violate terms of service
- Credit original authors when adapting existing work
