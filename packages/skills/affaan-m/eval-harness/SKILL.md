---
name: eval-harness
description: Formal evaluation framework for Claude Code sessions implementing eval-driven development (EDD) principles.
---

# Eval Harness Skill

A formal evaluation framework for Claude Code sessions, implementing eval-driven development (EDD) principles.

## Philosophy

Eval-Driven Development treats evals as the "unit tests of AI development":
- Define expected behavior BEFORE implementation
- Run evals continuously during development
- Track regressions with each change
- Use pass@k metrics for reliability measurement

## Eval Types

### Capability Evals
Test if Claude can do something it couldn't before:
```markdown
[CAPABILITY EVAL: feature-name]
Task: Description of what Claude should accomplish
Success Criteria:
  - [ ] Criterion 1
  - [ ] Criterion 2
  - [ ] Criterion 3
Expected Output: Description of expected result
```

### Regression Evals
Ensure changes don't break existing functionality:
```markdown
[REGRESSION EVAL: feature-name]
Baseline: SHA or checkpoint name
Tests:
  - existing-test-1: PASS/FAIL
  - existing-test-2: PASS/FAIL
Result: X/Y passed (previously Y/Y)
```

## Grader Types

### 1. Code-Based Grader
```bash
grep -q "export function handleAuth" src/auth.ts && echo "PASS" || echo "FAIL"
npm test -- --testPathPattern="auth" && echo "PASS" || echo "FAIL"
```

### 2. Model-Based Grader
```markdown
[MODEL GRADER PROMPT]
Evaluate the following code change:
1. Does it solve the stated problem?
2. Is it well-structured?
Score: 1-5
```

### 3. Human Grader
```markdown
[HUMAN REVIEW REQUIRED]
Change: Description of what changed
Reason: Why human review is needed
Risk Level: LOW/MEDIUM/HIGH
```

## Metrics

### pass@k
"At least one success in k attempts"
- pass@1: First attempt success rate
- pass@3: Success within 3 attempts
- Typical target: pass@3 > 90%

### pass^k
"All k trials succeed"
- Higher bar for reliability
- Use for critical paths

## Eval Workflow

### 1. Define (Before Coding)
```markdown
## EVAL DEFINITION: feature-xyz

### Capability Evals
1. Can create new user account
2. Can validate email format
3. Can hash password securely

### Success Metrics
- pass@3 > 90% for capability evals
- pass^3 = 100% for regression evals
```

### 2. Implement
Write code to pass the defined evals.

### 3. Evaluate
Run each eval, record PASS/FAIL.

### 4. Report
```markdown
EVAL REPORT: feature-xyz
========================
Capability Evals: 3/3 passed
Regression Evals: 3/3 passed
Metrics:
  pass@1: 67%
  pass@3: 100%
Status: READY FOR REVIEW
```

## Best Practices

1. **Define evals BEFORE coding** - Forces clear thinking
2. **Run evals frequently** - Catch regressions early
3. **Use code graders when possible** - Deterministic > probabilistic
4. **Human review for security** - Never fully automate security checks
5. **Keep evals fast** - Slow evals don't get run
