## Package Submission

**Package name:** `@username/package-name`
**Type:** <!-- skill / rules / mcp -->

### Description
<!-- Brief description of what your package does -->

### Checklist

#### Package Structure
- [ ] Created package in correct directory (`packages/{type}/{username}/{package-name}/`)
- [ ] Created `cpm.yaml` with all required fields
- [ ] Added content files (SKILL.md for skills, *.md for rules)

#### cpm.yaml Validation
- [ ] `name` matches `@{username}/{package-name}` format
- [ ] `version` is valid semver (X.Y.Z)
- [ ] `type` is correct (skill/rules/mcp)
- [ ] Type-specific fields are present:
  - Skills: `skill.command` and `skill.description`
  - Rules: `rules.glob` and `rules.files`
  - MCP: `mcp.command` and `mcp.args`

#### Registry
- [ ] Added entry to `registry.json`
- [ ] Version in registry matches cpm.yaml
- [ ] Description in registry matches cpm.yaml

#### Security (MCP packages only)
- [ ] Command is on allowlist (npx, node, python, uvx, docker)
- [ ] No shell metacharacters in args
- [ ] No network commands in args

### Testing
<!-- How did you test your package? -->

### Additional Notes
<!-- Any additional context or notes for reviewers -->
