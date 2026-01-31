# Performance Optimization

## Model Selection

| Model | Use Case | Notes |
|-------|----------|-------|
| Haiku 4.5 | Lightweight agents | 90% of Sonnet capability, 3x cost savings |
| Sonnet 4.5 | Primary development | Default for most tasks |
| Opus 4.5 | Architectural decisions | Deepest reasoning |

## Context Window Management

- Avoid final 20% of context during:
  - Large-scale refactoring
  - Multi-file debugging
- Reserve final context for:
  - Single-file modifications
  - Documentation tasks

## Advanced Techniques

For complex problems:
1. Use ultrathink + Plan Mode
2. Split role sub-agents for diverse analysis:
   - Factual reviewer
   - Senior engineer
   - Security expert
   - Performance analyst

## Error Resolution

Use build-error-resolver agent:
1. Address compilation issues incrementally
2. Fix one error at a time
3. Re-verify after each fix
4. Document recurring patterns
