---
name: springboot-tdd
description: Spring Boot TDD workflow with JUnit 5, MockMvc, Testcontainers, and JaCoCo for 80%+ code coverage.
---

# Spring Boot TDD Workflow

Testing guidance for Spring Boot applications targeting 80%+ code coverage.

## Core Workflow

**Test-First Development:**
1. Write failing test
2. Implement minimal code to pass
3. Refactor while maintaining green tests

## Test Categories

### 1. Unit Tests (JUnit 5 + Mockito)

```java
@ExtendWith(MockitoExtension.class)
class MarketServiceTest {
  @Mock
  private MarketRepository repository;

  @InjectMocks
  private MarketService service;

  @Test
  void shouldCreateMarket() {
    // Arrange
    CreateMarketRequest request = new CreateMarketRequest("Test Market");
    MarketEntity entity = new MarketEntity(1L, "Test Market");
    when(repository.save(any())).thenReturn(entity);

    // Act
    Market result = service.create(request);

    // Assert
    assertThat(result.name()).isEqualTo("Test Market");
    verify(repository).save(any());
  }
}
```

### 2. Web Layer (MockMvc)

```java
@WebMvcTest(MarketController.class)
class MarketControllerTest {
  @Autowired
  private MockMvc mockMvc;

  @MockBean
  private MarketService service;

  @Test
  void shouldReturnMarkets() throws Exception {
    when(service.findAll()).thenReturn(List.of(
        new Market(1L, "Test Market")
    ));

    mockMvc.perform(get("/api/markets"))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$[0].name").value("Test Market"));
  }

  @Test
  void shouldValidateInput() throws Exception {
    mockMvc.perform(post("/api/markets")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{}"))
        .andExpect(status().isBadRequest());
  }
}
```

### 3. Integration (SpringBootTest)

```java
@SpringBootTest
@AutoConfigureMockMvc
class MarketIntegrationTest {
  @Autowired
  private MockMvc mockMvc;

  @Autowired
  private MarketRepository repository;

  @BeforeEach
  void setUp() {
    repository.deleteAll();
  }

  @Test
  void shouldCreateAndRetrieveMarket() throws Exception {
    String json = """
        {"name": "Test Market", "description": "Test"}
        """;

    mockMvc.perform(post("/api/markets")
            .contentType(MediaType.APPLICATION_JSON)
            .content(json))
        .andExpect(status().isCreated());

    assertThat(repository.count()).isEqualTo(1);
  }
}
```

### 4. Database (DataJpaTest + Testcontainers)

```java
@DataJpaTest
@Testcontainers
class MarketRepositoryTest {
  @Container
  static PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:15");

  @DynamicPropertySource
  static void configureProperties(DynamicPropertyRegistry registry) {
    registry.add("spring.datasource.url", postgres::getJdbcUrl);
    registry.add("spring.datasource.username", postgres::getUsername);
    registry.add("spring.datasource.password", postgres::getPassword);
  }

  @Autowired
  private MarketRepository repository;

  @Test
  void shouldFindBySlug() {
    MarketEntity entity = new MarketEntity();
    entity.setName("Test Market");
    entity.setSlug("test-market");
    repository.save(entity);

    Optional<MarketEntity> found = repository.findBySlug("test-market");

    assertThat(found).isPresent();
    assertThat(found.get().getName()).isEqualTo("Test Market");
  }
}
```

## Parameterized Tests

```java
@ParameterizedTest
@CsvSource({
    "valid@email.com, true",
    "invalid-email, false",
    "'', false"
})
void shouldValidateEmail(String email, boolean expected) {
  boolean result = validator.isValidEmail(email);
  assertThat(result).isEqualTo(expected);
}
```

## Coverage with JaCoCo

```xml
<plugin>
  <groupId>org.jacoco</groupId>
  <artifactId>jacoco-maven-plugin</artifactId>
  <version>0.8.10</version>
  <executions>
    <execution>
      <goals><goal>prepare-agent</goal></goals>
    </execution>
    <execution>
      <id>report</id>
      <phase>verify</phase>
      <goals><goal>report</goal></goals>
    </execution>
  </executions>
</plugin>
```

Run: `mvn verify`

## Best Practices

- Avoid partial mocks; prefer explicit stubbing
- Use `@ParameterizedTest` for multiple input variants
- Leverage Testcontainers for production-like tests
- Use AssertJ's `assertThat()` for readability
- Target 80%+ coverage on business logic

## Commands

```bash
mvn test                    # Run all tests
mvn test -Dtest=MarketTest  # Run specific test
mvn verify                  # Run with coverage
```
