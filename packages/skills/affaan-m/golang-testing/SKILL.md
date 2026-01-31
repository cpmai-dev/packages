---
name: golang-testing
description: Go testing patterns including table-driven tests, subtests, benchmarks, fuzzing, and test coverage. Follows TDD methodology with idiomatic Go practices.
---

# Go Testing Patterns

Comprehensive Go testing patterns for writing reliable, maintainable tests following TDD methodology.

## TDD Workflow for Go

### The RED-GREEN-REFACTOR Cycle

```
RED     → Write a failing test first
GREEN   → Write minimal code to pass the test
REFACTOR → Improve code while keeping tests green
REPEAT  → Continue with next requirement
```

## Table-Driven Tests

```go
func TestAdd(t *testing.T) {
    tests := []struct {
        name     string
        a, b     int
        expected int
    }{
        {"positive numbers", 2, 3, 5},
        {"negative numbers", -1, -2, -3},
        {"zero values", 0, 0, 0},
        {"mixed signs", -1, 1, 0},
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            got := Add(tt.a, tt.b)
            if got != tt.expected {
                t.Errorf("Add(%d, %d) = %d; want %d",
                    tt.a, tt.b, got, tt.expected)
            }
        })
    }
}
```

### Table-Driven Tests with Error Cases

```go
func TestParseConfig(t *testing.T) {
    tests := []struct {
        name    string
        input   string
        want    *Config
        wantErr bool
    }{
        {
            name:  "valid config",
            input: `{"host": "localhost", "port": 8080}`,
            want:  &Config{Host: "localhost", Port: 8080},
        },
        {
            name:    "invalid JSON",
            input:   `{invalid}`,
            wantErr: true,
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            got, err := ParseConfig(tt.input)

            if tt.wantErr {
                if err == nil {
                    t.Error("expected error, got nil")
                }
                return
            }

            if err != nil {
                t.Fatalf("unexpected error: %v", err)
            }

            if !reflect.DeepEqual(got, tt.want) {
                t.Errorf("got %+v; want %+v", got, tt.want)
            }
        })
    }
}
```

## Parallel Subtests

```go
func TestParallel(t *testing.T) {
    tests := []struct {
        name  string
        input string
    }{
        {"case1", "input1"},
        {"case2", "input2"},
    }

    for _, tt := range tests {
        tt := tt // Capture range variable
        t.Run(tt.name, func(t *testing.T) {
            t.Parallel()
            result := Process(tt.input)
            _ = result
        })
    }
}
```

## Test Helpers

```go
func setupTestDB(t *testing.T) *sql.DB {
    t.Helper()

    db, err := sql.Open("sqlite3", ":memory:")
    if err != nil {
        t.Fatalf("failed to open database: %v", err)
    }

    t.Cleanup(func() {
        db.Close()
    })

    return db
}
```

## Mocking with Interfaces

```go
type UserRepository interface {
    GetUser(id string) (*User, error)
    SaveUser(user *User) error
}

type MockUserRepository struct {
    GetUserFunc  func(id string) (*User, error)
    SaveUserFunc func(user *User) error
}

func (m *MockUserRepository) GetUser(id string) (*User, error) {
    return m.GetUserFunc(id)
}

func TestUserService(t *testing.T) {
    mock := &MockUserRepository{
        GetUserFunc: func(id string) (*User, error) {
            if id == "123" {
                return &User{ID: "123", Name: "Alice"}, nil
            }
            return nil, ErrNotFound
        },
    }

    service := NewUserService(mock)
    user, err := service.GetUserProfile("123")
    if err != nil {
        t.Fatalf("unexpected error: %v", err)
    }
    if user.Name != "Alice" {
        t.Errorf("got name %q; want %q", user.Name, "Alice")
    }
}
```

## Benchmarks

```go
func BenchmarkProcess(b *testing.B) {
    data := generateTestData(1000)
    b.ResetTimer()

    for i := 0; i < b.N; i++ {
        Process(data)
    }
}

// Run: go test -bench=BenchmarkProcess -benchmem
```

## Fuzzing (Go 1.18+)

```go
func FuzzParseJSON(f *testing.F) {
    f.Add(`{"name": "test"}`)
    f.Add(`{"count": 123}`)

    f.Fuzz(func(t *testing.T, input string) {
        var result map[string]interface{}
        err := json.Unmarshal([]byte(input), &result)

        if err != nil {
            return
        }

        _, err = json.Marshal(result)
        if err != nil {
            t.Errorf("Marshal failed after successful Unmarshal: %v", err)
        }
    })
}

// Run: go test -fuzz=FuzzParseJSON -fuzztime=30s
```

## Test Coverage

```bash
go test -cover ./...
go test -coverprofile=coverage.out ./...
go tool cover -html=coverage.out
```

| Code Type | Target |
|-----------|--------|
| Critical business logic | 100% |
| Public APIs | 90%+ |
| General code | 80%+ |

## HTTP Handler Testing

```go
func TestHealthHandler(t *testing.T) {
    req := httptest.NewRequest(http.MethodGet, "/health", nil)
    w := httptest.NewRecorder()

    HealthHandler(w, req)

    resp := w.Result()
    defer resp.Body.Close()

    if resp.StatusCode != http.StatusOK {
        t.Errorf("got status %d; want %d", resp.StatusCode, http.StatusOK)
    }
}
```

## Testing Commands

```bash
go test ./...              # Run all tests
go test -v ./...           # Verbose output
go test -run TestAdd ./... # Run specific test
go test -race ./...        # Race detector
go test -bench=. ./...     # Run benchmarks
go test -count=10 ./...    # Flaky test detection
```

## Best Practices

**DO:**
- Write tests FIRST (TDD)
- Use table-driven tests
- Test behavior, not implementation
- Use `t.Helper()` in helper functions
- Use `t.Parallel()` for independent tests

**DON'T:**
- Test private functions directly
- Use `time.Sleep()` in tests
- Ignore flaky tests
- Mock everything

**Remember**: "Tests are documentation. They show how your code is meant to be used."
