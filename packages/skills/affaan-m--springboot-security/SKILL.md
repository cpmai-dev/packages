---
name: springboot-security
description: Spring Boot security patterns for authentication, authorization, input validation, and operational security best practices.
---

# Spring Boot Security Review

Comprehensive guidance for securing Java Spring Boot applications.

## Authentication

### Stateless JWT Validation

```java
@Component
public class JwtAuthFilter extends OncePerRequestFilter {
  private final JwtService jwtService;

  @Override
  protected void doFilterInternal(HttpServletRequest request,
      HttpServletResponse response, FilterChain chain) throws ServletException, IOException {

    String header = request.getHeader("Authorization");
    if (header == null || !header.startsWith("Bearer ")) {
      chain.doFilter(request, response);
      return;
    }

    String token = header.substring(7);
    try {
      UserDetails user = jwtService.validateToken(token);
      SecurityContextHolder.getContext().setAuthentication(
          new UsernamePasswordAuthenticationToken(user, null, user.getAuthorities())
      );
    } catch (JwtException e) {
      response.setStatus(HttpStatus.UNAUTHORIZED.value());
      return;
    }

    chain.doFilter(request, response);
  }
}
```

## Authorization

### Method-Level Security

```java
@Configuration
@EnableMethodSecurity
class SecurityConfig {}

@Service
class MarketService {
  @PreAuthorize("hasRole('ADMIN')")
  public void deleteMarket(Long id) {
    // Only admins can delete
  }

  @PreAuthorize("#userId == authentication.principal.id")
  public UserProfile getProfile(Long userId) {
    // Users can only access their own profile
  }
}
```

## Input Protection

### Bean Validation

```java
public record CreateUserRequest(
    @NotBlank @Size(max = 100) String name,
    @NotBlank @Email String email,
    @NotBlank @Size(min = 8, max = 128) String password
) {}

@PostMapping("/users")
public ResponseEntity<?> create(@Valid @RequestBody CreateUserRequest request) {
  // Input is validated
}
```

### HTML Sanitization

```java
import org.owasp.html.PolicyFactory;
import org.owasp.html.Sanitizers;

public class HtmlSanitizer {
  private static final PolicyFactory POLICY = Sanitizers.FORMATTING
      .and(Sanitizers.LINKS);

  public static String sanitize(String html) {
    return POLICY.sanitize(html);
  }
}
```

## SQL Safety

```java
// ✅ GOOD: Spring Data repository (parameterized)
public interface UserRepository extends JpaRepository<User, Long> {
  Optional<User> findByEmail(String email);

  @Query("SELECT u FROM User u WHERE u.status = :status")
  List<User> findByStatus(@Param("status") UserStatus status);
}

// ❌ BAD: String concatenation
String query = "SELECT * FROM users WHERE email = '" + email + "'";
```

## CSRF Configuration

```java
@Configuration
class SecurityConfig {
  @Bean
  SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
    return http
        // Disable CSRF for stateless Bearer token APIs
        .csrf(csrf -> csrf.disable())
        // Or enable for session-based auth
        .csrf(csrf -> csrf.csrfTokenRepository(
            CookieCsrfTokenRepository.withHttpOnlyFalse()))
        .build();
  }
}
```

## Secrets Management

```java
// ✅ GOOD: Environment variables
@Value("${api.key}")
private String apiKey;

// ✅ GOOD: Spring Cloud Vault
@Configuration
@PropertySource("vault:secret/myapp")
class VaultConfig {}

// ❌ BAD: Hardcoded secrets
private String apiKey = "sk-xxxxx";
```

## Security Headers

```java
@Bean
SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
  return http
      .headers(headers -> headers
          .contentSecurityPolicy(csp -> csp
              .policyDirectives("default-src 'self'; script-src 'self'"))
          .frameOptions(frame -> frame.deny())
          .xssProtection(xss -> xss.block(true))
          .referrerPolicy(referrer -> referrer
              .policy(ReferrerPolicyHeaderWriter.ReferrerPolicy.STRICT_ORIGIN_WHEN_CROSS_ORIGIN))
      )
      .build();
}
```

## Rate Limiting

```java
@Bean
public Bucket createRateLimiter() {
  return Bucket.builder()
      .addLimit(Bandwidth.classic(100, Refill.greedy(100, Duration.ofMinutes(1))))
      .build();
}
```

## Dependency Security

```xml
<!-- pom.xml -->
<plugin>
  <groupId>org.owasp</groupId>
  <artifactId>dependency-check-maven</artifactId>
  <version>8.4.0</version>
  <executions>
    <execution>
      <goals><goal>check</goal></goals>
    </execution>
  </executions>
</plugin>
```

## Pre-Release Checklist

- [ ] Token lifecycle (expiration, refresh, revocation)
- [ ] Authorization on all endpoints
- [ ] Input sanitization
- [ ] Secrets externalized
- [ ] Security headers configured
- [ ] Rate limiting enabled
- [ ] Dependencies audited
- [ ] Logs sanitized (no secrets/PII)
