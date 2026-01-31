---
name: java-coding-standards
description: Java coding standards for Spring Boot services - naming, immutability, Optional usage, streams, exceptions, generics, and project layout.
---

# Java Coding Standards

Standards for readable, maintainable Java (17+) code in Spring Boot services.

## Core Principles

- Prefer clarity over cleverness
- Immutable by default; minimize shared mutable state
- Fail fast with meaningful exceptions
- Consistent naming and package structure

## Naming

| Element | Convention | Example |
|---------|------------|---------|
| Classes/Records | PascalCase | `MarketService`, `Money` |
| Methods/Fields | camelCase | `findBySlug`, `totalAmount` |
| Constants | UPPER_SNAKE_CASE | `MAX_PAGE_SIZE` |

## Immutability

```java
// ✅ GOOD: Immutable record
public record Market(String id, String name, MarketStatus status) {}

// ✅ GOOD: Final fields
public final class MarketService {
    private final MarketRepository repository;

    public MarketService(MarketRepository repository) {
        this.repository = repository;
    }
}
```

## Optional Usage

```java
// ✅ GOOD: Return Optional from find methods
public Optional<Market> findById(String id) {
    return repository.findById(id);
}

// ✅ GOOD: Use mapping operations
Optional<String> name = findById(id)
    .map(Market::name);

// ❌ BAD: Direct get() without check
String name = findById(id).get();
```

## Streams Best Practices

```java
// ✅ GOOD: Concise pipeline
List<String> activeNames = markets.stream()
    .filter(m -> m.status() == MarketStatus.ACTIVE)
    .map(Market::name)
    .toList();

// ❌ BAD: Complex nested streams
// Prefer loops for clarity when logic is complex
```

## Exceptions

```java
// ✅ GOOD: Unchecked exceptions for domain errors
public class MarketNotFoundException extends RuntimeException {
    public MarketNotFoundException(String id) {
        super("Market not found: " + id);
    }
}

// ✅ GOOD: Wrap technical exceptions
try {
    return parseJson(data);
} catch (JsonParseException e) {
    throw new InvalidInputException("Invalid JSON format", e);
}

// ❌ BAD: Broad catches, silent swallowing
catch (Exception e) { }
```

## Generics and Type Safety

```java
// ✅ GOOD: Bounded generics
public <T extends Comparable<T>> T max(List<T> items) {
    return items.stream()
        .max(Comparable::compareTo)
        .orElseThrow();
}

// ❌ BAD: Raw types
List items = new ArrayList();
```

## Project Structure

```
src/main/java/com/example/
├── config/          # Configuration classes
├── controller/      # REST controllers
├── service/         # Business logic
├── repository/      # Data access
├── domain/          # Domain models
├── dto/             # Data transfer objects
└── util/            # Utilities
```

## Formatting and Style

- Consistent indentation (2 or 4 spaces)
- One public type per file
- Short focused methods (<30 lines)
- Logical member ordering: constants, fields, constructors, methods

## Code Smells to Avoid

- Long parameter lists (>4 params → use builder or object)
- Deep nesting (>3 levels → extract methods)
- Magic numbers (use named constants)
- Static mutable state
- Silent exceptions

## Logging

```java
// ✅ GOOD: SLF4J with structured messages
private static final Logger log = LoggerFactory.getLogger(MarketService.class);

public Market create(CreateMarketRequest request) {
    log.info("Creating market name={}", request.name());
    // ...
}
```

## Null Handling

```java
// ✅ GOOD: Use @NonNull and Bean Validation
public void save(@NonNull Market market) { }

// ✅ GOOD: Validation annotations
public record CreateRequest(
    @NotBlank @Size(max = 200) String name,
    @NotNull @FutureOrPresent Instant endDate
) {}
```

## Testing Expectations

- JUnit 5 for test framework
- AssertJ for fluent assertions
- Mockito for mocking
- Deterministic, isolated tests
- Target 80%+ coverage on business logic
