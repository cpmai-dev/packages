---
name: tdd-workflow
description: Test-driven development workflow enforcing tests-first methodology with 80%+ coverage including unit, integration, and E2E tests.
---

# Test-Driven Development Workflow

This skill ensures all code development follows TDD principles with comprehensive test coverage.

## When to Activate

- Writing new features or functionality
- Fixing bugs or issues
- Refactoring existing code
- Adding API endpoints
- Creating new components

## Core Principles

### 1. Tests BEFORE Code
ALWAYS write tests first, then implement code to make tests pass.

### 2. Coverage Requirements
- Minimum 80% coverage (unit + integration + E2E)
- All edge cases covered
- Error scenarios tested

### 3. Test Types

| Type | Purpose | Tools |
|------|---------|-------|
| Unit | Individual functions | Jest/Vitest |
| Integration | API endpoints, services | Supertest |
| E2E | Critical user flows | Playwright |

## TDD Workflow Steps

### Step 1: Write User Journeys
```
As a [role], I want to [action], so that [benefit]
```

### Step 2: Generate Test Cases
```typescript
describe('Semantic Search', () => {
  it('returns relevant markets for query', async () => {})
  it('handles empty query gracefully', async () => {})
  it('falls back when Redis unavailable', async () => {})
})
```

### Step 3: Run Tests (Should Fail)
```bash
npm test
```

### Step 4: Implement Code
Write minimal code to make tests pass.

### Step 5: Run Tests Again (Should Pass)
```bash
npm test
```

### Step 6: Refactor
Improve code while keeping tests green.

### Step 7: Verify Coverage
```bash
npm run test:coverage
```

## Testing Patterns

### Unit Test Pattern
```typescript
import { render, screen, fireEvent } from '@testing-library/react'

describe('Button Component', () => {
  it('renders with correct text', () => {
    render(<Button>Click me</Button>)
    expect(screen.getByText('Click me')).toBeInTheDocument()
  })

  it('calls onClick when clicked', () => {
    const handleClick = jest.fn()
    render(<Button onClick={handleClick}>Click</Button>)
    fireEvent.click(screen.getByRole('button'))
    expect(handleClick).toHaveBeenCalledTimes(1)
  })
})
```

### API Integration Test Pattern
```typescript
describe('GET /api/markets', () => {
  it('returns markets successfully', async () => {
    const request = new NextRequest('http://localhost/api/markets')
    const response = await GET(request)
    const data = await response.json()

    expect(response.status).toBe(200)
    expect(data.success).toBe(true)
    expect(Array.isArray(data.data)).toBe(true)
  })
})
```

### E2E Test Pattern (Playwright)
```typescript
test('user can search and filter markets', async ({ page }) => {
  await page.goto('/')
  await page.click('a[href="/markets"]')
  await page.fill('input[placeholder="Search markets"]', 'election')
  await page.waitForTimeout(600)

  const results = page.locator('[data-testid="market-card"]')
  await expect(results).toHaveCount(5, { timeout: 5000 })
})
```

## Common Mistakes to Avoid

### Test Implementation Details
```typescript
// ❌ WRONG
expect(component.state.count).toBe(5)

// ✅ CORRECT
expect(screen.getByText('Count: 5')).toBeInTheDocument()
```

### Brittle Selectors
```typescript
// ❌ WRONG
await page.click('.css-class-xyz')

// ✅ CORRECT
await page.click('button:has-text("Submit")')
```

## Coverage Thresholds

```json
{
  "jest": {
    "coverageThresholds": {
      "global": {
        "branches": 80,
        "functions": 80,
        "lines": 80,
        "statements": 80
      }
    }
  }
}
```

## Best Practices

1. **Write Tests First** - Always TDD
2. **One Assert Per Test** - Focus on single behavior
3. **Descriptive Test Names** - Explain what's tested
4. **Arrange-Act-Assert** - Clear test structure
5. **Mock External Dependencies** - Isolate unit tests
6. **Test Edge Cases** - Null, undefined, empty, large
7. **Test Error Paths** - Not just happy paths
8. **Keep Tests Fast** - Unit tests < 50ms each

**Remember**: "Tests are not optional. They are the safety net that enables confident refactoring."
