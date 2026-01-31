---
name: security-review
description: Security best practices and vulnerability detection for web applications including authentication, input validation, and OWASP Top 10.
---

# Security Review Skill

This skill ensures all code follows security best practices and identifies potential vulnerabilities.

## When to Activate

- Implementing authentication or authorization
- Handling user input or file uploads
- Creating new API endpoints
- Working with secrets or credentials
- Implementing payment features
- Storing or transmitting sensitive data

## Security Checklist

### 1. Secrets Management

```typescript
// ❌ NEVER: Hardcoded secrets
const apiKey = "sk-proj-xxxxx"

// ✅ ALWAYS: Environment variables
const apiKey = process.env.OPENAI_API_KEY

if (!apiKey) {
  throw new Error('OPENAI_API_KEY not configured')
}
```

**Verification:**
- [ ] No hardcoded API keys, tokens, or passwords
- [ ] All secrets in environment variables
- [ ] `.env.local` in .gitignore
- [ ] No secrets in git history

### 2. Input Validation

```typescript
import { z } from 'zod'

const CreateUserSchema = z.object({
  email: z.string().email(),
  name: z.string().min(1).max(100),
  age: z.number().int().min(0).max(150)
})

export async function createUser(input: unknown) {
  const validated = CreateUserSchema.parse(input)
  return await db.users.create(validated)
}
```

**Verification:**
- [ ] All user inputs validated with schemas
- [ ] File uploads restricted (size, type, extension)
- [ ] Whitelist validation (not blacklist)

### 3. SQL Injection Prevention

```typescript
// ❌ DANGEROUS
const query = `SELECT * FROM users WHERE email = '${userEmail}'`

// ✅ Safe - parameterized query
const { data } = await supabase
  .from('users')
  .select('*')
  .eq('email', userEmail)
```

### 4. Authentication & Authorization

```typescript
// Tokens in httpOnly cookies, not localStorage
res.setHeader('Set-Cookie',
  `token=${token}; HttpOnly; Secure; SameSite=Strict`)

// Always verify authorization
if (requester.role !== 'admin') {
  return NextResponse.json({ error: 'Unauthorized' }, { status: 403 })
}
```

### 5. XSS Prevention

```typescript
import DOMPurify from 'isomorphic-dompurify'

// Sanitize user-provided HTML
const clean = DOMPurify.sanitize(html, {
  ALLOWED_TAGS: ['b', 'i', 'em', 'strong', 'p'],
  ALLOWED_ATTR: []
})
```

### 6. CSRF Protection

```typescript
// SameSite cookies
res.setHeader('Set-Cookie',
  `session=${sessionId}; HttpOnly; Secure; SameSite=Strict`)

// CSRF tokens for state-changing operations
if (!csrf.verify(token)) {
  return NextResponse.json({ error: 'Invalid CSRF token' }, { status: 403 })
}
```

### 7. Rate Limiting

```typescript
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100,
  message: 'Too many requests'
})
```

### 8. Sensitive Data Exposure

```typescript
// ❌ WRONG: Logging sensitive data
console.log('User login:', { email, password })

// ✅ CORRECT: Redact sensitive data
console.log('User login:', { email, userId })

// Generic error messages to users
catch (error) {
  console.error('Internal error:', error)
  return NextResponse.json(
    { error: 'An error occurred. Please try again.' },
    { status: 500 }
  )
}
```

## Pre-Deployment Security Checklist

- [ ] **Secrets**: No hardcoded secrets, all in env vars
- [ ] **Input Validation**: All user inputs validated
- [ ] **SQL Injection**: All queries parameterized
- [ ] **XSS**: User content sanitized
- [ ] **CSRF**: Protection enabled
- [ ] **Authentication**: Proper token handling
- [ ] **Authorization**: Role checks in place
- [ ] **Rate Limiting**: Enabled on all endpoints
- [ ] **HTTPS**: Enforced in production
- [ ] **Security Headers**: CSP, X-Frame-Options configured
- [ ] **Error Handling**: No sensitive data in errors
- [ ] **Logging**: No sensitive data logged
- [ ] **Dependencies**: Up to date, no vulnerabilities

## Resources

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [Next.js Security](https://nextjs.org/docs/security)
- [Supabase Security](https://supabase.com/docs/guides/auth)

**Remember**: Security is not optional. One vulnerability can compromise the entire platform.
