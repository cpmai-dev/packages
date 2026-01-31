---
name: springboot-verification
description: Verification loop for Spring Boot projects - build, static analysis, tests with coverage, security scans, and diff review.
---

# Spring Boot Verification Loop

Run before PRs, after major changes, and pre-deploy.

## Phase 1: Build

```bash
mvn -T 4 clean verify -DskipTests
# or
./gradlew clean assemble -x test
```

If build fails, stop and fix.

## Phase 2: Static Analysis

```bash
# Maven
mvn -T 4 spotbugs:check pmd:check checkstyle:check

# Gradle
./gradlew checkstyleMain pmdMain spotbugsMain
```

## Phase 3: Tests + Coverage

```bash
mvn -T 4 test
mvn jacoco:report   # verify 80%+ coverage

# or Gradle
./gradlew test jacocoTestReport
```

Report:
- Total tests, passed/failed
- Coverage % (lines/branches)

## Phase 4: Security Scan

```bash
# Dependency CVEs
mvn org.owasp:dependency-check-maven:check
# or
./gradlew dependencyCheckAnalyze

# Secrets (git)
git secrets --scan  # if configured
```

## Phase 5: Lint/Format

```bash
mvn spotless:apply   # if using Spotless plugin
./gradlew spotlessApply
```

## Phase 6: Diff Review

```bash
git diff --stat
git diff
```

Checklist:
- No debugging logs left
- Meaningful errors and HTTP statuses
- Transactions and validation present
- Config changes documented

## Output Template

```
VERIFICATION REPORT
===================
Build:     [PASS/FAIL]
Static:    [PASS/FAIL] (spotbugs/pmd/checkstyle)
Tests:     [PASS/FAIL] (X/Y passed, Z% coverage)
Security:  [PASS/FAIL] (CVE findings: N)
Diff:      [X files changed]

Overall:   [READY / NOT READY]

Issues to Fix:
1. ...
2. ...
```

## Continuous Mode

- Re-run phases on significant changes
- Keep a short loop: `mvn -T 4 test` + spotbugs for quick feedback

**Remember**: Fast feedback beats late surprises. Keep the gate strict.
