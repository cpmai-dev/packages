---
name: coding-standards
description: Universal coding standards, best practices, and patterns for TypeScript, JavaScript, React, and Node.js development.
---

# Coding Standards & Best Practices

Universal coding standards applicable across all projects.

## Code Quality Principles

### 1. Readability First
- Code is read more than written
- Clear variable and function names
- Self-documenting code preferred over comments
- Consistent formatting

### 2. KISS (Keep It Simple, Stupid)
- Simplest solution that works
- Avoid over-engineering
- No premature optimization
- Easy to understand > clever code

### 3. DRY (Don't Repeat Yourself)
- Extract common logic into functions
- Create reusable components
- Share utilities across modules
- Avoid copy-paste programming

### 4. YAGNI (You Aren't Gonna Need It)
- Don't build features before they're needed
- Avoid speculative generality
- Add complexity only when required

## TypeScript/JavaScript Standards

### Variable Naming

```typescript
// ✅ GOOD: Descriptive names
const marketSearchQuery = 'election'
const isUserAuthenticated = true
const totalRevenue = 1000

// ❌ BAD: Unclear names
const q = 'election'
const flag = true
const x = 1000
```

### Function Naming

```typescript
// ✅ GOOD: Verb-noun pattern
async function fetchMarketData(marketId: string) { }
function calculateSimilarity(a: number[], b: number[]) { }
function isValidEmail(email: string): boolean { }

// ❌ BAD: Unclear or noun-only
async function market(id: string) { }
function similarity(a, b) { }
```

### Immutability Pattern (CRITICAL)

```typescript
// ✅ ALWAYS use spread operator
const updatedUser = {
  ...user,
  name: 'New Name'
}

const updatedArray = [...items, newItem]

// ❌ NEVER mutate directly
user.name = 'New Name'  // BAD
items.push(newItem)     // BAD
```

### Error Handling

```typescript
// ✅ GOOD: Comprehensive error handling
async function fetchData(url: string) {
  try {
    const response = await fetch(url)

    if (!response.ok) {
      throw new Error(`HTTP ${response.status}: ${response.statusText}`)
    }

    return await response.json()
  } catch (error) {
    console.error('Fetch failed:', error)
    throw new Error('Failed to fetch data')
  }
}
```

### Async/Await Best Practices

```typescript
// ✅ GOOD: Parallel execution when possible
const [users, markets, stats] = await Promise.all([
  fetchUsers(),
  fetchMarkets(),
  fetchStats()
])

// ❌ BAD: Sequential when unnecessary
const users = await fetchUsers()
const markets = await fetchMarkets()
const stats = await fetchStats()
```

### Type Safety

```typescript
// ✅ GOOD: Proper types
interface Market {
  id: string
  name: string
  status: 'active' | 'resolved' | 'closed'
  created_at: Date
}

function getMarket(id: string): Promise<Market> {
  // Implementation
}

// ❌ BAD: Using 'any'
function getMarket(id: any): Promise<any> {
  // Implementation
}
```

## React Best Practices

### Component Structure

```typescript
// ✅ GOOD: Functional component with types
interface ButtonProps {
  children: React.ReactNode
  onClick: () => void
  disabled?: boolean
  variant?: 'primary' | 'secondary'
}

export function Button({
  children,
  onClick,
  disabled = false,
  variant = 'primary'
}: ButtonProps) {
  return (
    <button
      onClick={onClick}
      disabled={disabled}
      className={`btn btn-${variant}`}
    >
      {children}
    </button>
  )
}
```

### Custom Hooks

```typescript
export function useDebounce<T>(value: T, delay: number): T {
  const [debouncedValue, setDebouncedValue] = useState<T>(value)

  useEffect(() => {
    const handler = setTimeout(() => {
      setDebouncedValue(value)
    }, delay)

    return () => clearTimeout(handler)
  }, [value, delay])

  return debouncedValue
}
```

## API Design Standards

### REST API Conventions

```
GET    /api/markets              # List all markets
GET    /api/markets/:id          # Get specific market
POST   /api/markets              # Create new market
PUT    /api/markets/:id          # Update market (full)
PATCH  /api/markets/:id          # Update market (partial)
DELETE /api/markets/:id          # Delete market
```

### Response Format

```typescript
interface ApiResponse<T> {
  success: boolean
  data?: T
  error?: string
  meta?: {
    total: number
    page: number
    limit: number
  }
}
```

### Input Validation

```typescript
import { z } from 'zod'

const CreateMarketSchema = z.object({
  name: z.string().min(1).max(200),
  description: z.string().min(1).max(2000),
  endDate: z.string().datetime(),
  categories: z.array(z.string()).min(1)
})
```

## File Organization

```
src/
├── app/                    # Next.js App Router
├── components/             # React components
│   ├── ui/                # Generic UI components
│   ├── forms/             # Form components
│   └── layouts/           # Layout components
├── hooks/                 # Custom React hooks
├── lib/                   # Utilities and configs
├── types/                 # TypeScript types
└── styles/               # Global styles
```

## Code Smell Detection

### Long Functions
```typescript
// ❌ BAD: Function > 50 lines
// ✅ GOOD: Split into smaller functions
function processMarketData() {
  const validated = validateData()
  const transformed = transformData(validated)
  return saveData(transformed)
}
```

### Deep Nesting
```typescript
// ❌ BAD: 5+ levels of nesting
// ✅ GOOD: Early returns
if (!user) return
if (!user.isAdmin) return
if (!market) return
// Do something
```

### Magic Numbers
```typescript
// ❌ BAD: Unexplained numbers
if (retryCount > 3) { }

// ✅ GOOD: Named constants
const MAX_RETRIES = 3
if (retryCount > MAX_RETRIES) { }
```

**Remember**: Code quality is not negotiable. Clear, maintainable code enables rapid development and confident refactoring.
