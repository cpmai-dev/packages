---
name: iterative-retrieval
description: Systematic approach for multi-agent workflows where subagents progressively refine their context needs through iterative search and evaluation.
---

# Iterative Retrieval Pattern

A systematic approach for multi-agent workflows where subagents progressively refine their context needs through four phases.

## Core Challenge

The fundamental issue is that "subagents are spawned with limited context" and face a dilemma:
- Sending all information exceeds capacity
- Sending nothing leaves them unprepared
- Guessing requirements often fails

## Four-Phase Solution

The pattern implements a controlled loop:

### 1. DISPATCH
Execute a broad initial query to identify candidate files using patterns, keywords, and exclusions.

```markdown
Initial Search:
- Patterns: ["**/auth/**", "**/user/**", "**/session/**"]
- Keywords: ["authenticate", "login", "token"]
- Exclusions: ["**/test/**", "**/mock/**"]
```

### 2. EVALUATE
Score retrieved files on relevance:
- 0.0-0.3: Likely irrelevant
- 0.3-0.6: Potentially useful
- 0.6-0.8: Probably relevant
- 0.8-1.0: Direct functionality implementation

### 3. REFINE
Update search criteria by:
- Extracting new patterns from high-scoring files
- Incorporating discovered terminology
- Excluding confirmed irrelevant items
- Targeting identified gaps

### 4. LOOP
Repeat the cycle up to three times, terminating early if sufficient high-relevance content is acquired.

## Practical Examples

### Example 1: Fixing Authentication Token Bug

**Round 1:**
- Search: "token", "auth"
- Discover: Uses "jwt" not "token" internally

**Round 2:**
- Search: "jwt", "refresh", "validate"
- Find: Token validation in `auth/jwt-handler.ts`

**Round 3:**
- Search: Specific file imports
- Complete: Full context gathered

### Example 2: Implementing Rate Limiting

**Round 1:**
- Search: "rate limit", "throttle"
- Discover: Codebase uses "throttle" terminology

**Round 2:**
- Search: "throttle", "bucket"
- Find: Existing throttle middleware

## Implementation Guidelines

1. **Start Broad**: Initial searches should cast a wide net
2. **Learn Terminology Early**: Project-specific naming conventions matter
3. **Track Gaps Explicitly**: Note what's missing, not just what's found
4. **Know When to Stop**: "Good enough" beats exhaustive retrieval

## Configuration

```json
{
  "max_iterations": 3,
  "relevance_threshold": 0.6,
  "early_termination_score": 0.85,
  "max_files_per_round": 20
}
```

## Integration

Use with Task tool for complex searches:

```markdown
Task: Find all files related to user authentication
Agent: Explore
Approach: iterative-retrieval
Max Rounds: 3
```

**Remember**: Context quality beats context quantity. Three highly relevant files are better than twenty marginally useful ones.
