---
name: postgres-patterns
description: PostgreSQL database patterns for query optimization, schema design, indexing, and security. Based on Supabase best practices.
---

# PostgreSQL Patterns

Quick reference for PostgreSQL best practices. For detailed guidance, use the `database-reviewer` agent.

## When to Activate

- Writing SQL queries or migrations
- Designing database schemas
- Troubleshooting slow queries
- Implementing Row Level Security
- Setting up connection pooling

## Index Cheat Sheet

| Index Type | Use Case |
|------------|----------|
| B-tree | Equality/range queries (default) |
| Composite | Multi-column filters |
| GIN | JSONB and text search |
| BRIN | Time-series data |

```sql
-- Composite index (equality before range)
CREATE INDEX idx_orders_status_date ON orders (status, created_at);

-- Covering index
CREATE INDEX idx_users_email ON users (email) INCLUDE (name, status);

-- Partial index
CREATE INDEX idx_active_orders ON orders (user_id) WHERE status = 'active';

-- GIN for JSONB
CREATE INDEX idx_metadata ON items USING GIN (metadata);
```

## Data Type Recommendations

| Use Case | Type |
|----------|------|
| IDs | `bigint` or `uuid` |
| Strings | `text` |
| Timestamps | `timestamptz` |
| Money | `numeric(10,2)` |
| Flags | `boolean` |

## Common Patterns

### UPSERT

```sql
INSERT INTO users (id, email, name)
VALUES ($1, $2, $3)
ON CONFLICT (id) DO UPDATE
SET email = EXCLUDED.email,
    name = EXCLUDED.name,
    updated_at = now();
```

### Cursor-Based Pagination

```sql
SELECT * FROM orders
WHERE id > $1
ORDER BY id
LIMIT 20;
```

### Queue Processing

```sql
UPDATE tasks
SET status = 'processing',
    worker_id = $1
WHERE id = (
    SELECT id FROM tasks
    WHERE status = 'pending'
    ORDER BY created_at
    FOR UPDATE SKIP LOCKED
    LIMIT 1
)
RETURNING *;
```

### Row Level Security

```sql
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users view own data"
  ON users FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users update own data"
  ON users FOR UPDATE
  USING (auth.uid() = id);
```

## Anti-Pattern Detection

### Find Unindexed Foreign Keys

```sql
SELECT
    conrelid::regclass AS table_name,
    a.attname AS column_name
FROM pg_constraint c
JOIN pg_attribute a ON a.attrelid = c.conrelid AND a.attnum = ANY(c.conkey)
WHERE c.contype = 'f'
AND NOT EXISTS (
    SELECT 1 FROM pg_index i
    WHERE i.indrelid = c.conrelid
    AND a.attnum = ANY(i.indkey)
);
```

### Find Slow Queries

```sql
SELECT query, calls, mean_exec_time, total_exec_time
FROM pg_stat_statements
ORDER BY mean_exec_time DESC
LIMIT 10;
```

### Table Bloat

```sql
SELECT
    schemaname || '.' || relname AS table,
    pg_size_pretty(pg_total_relation_size(relid)) AS total_size,
    n_dead_tup AS dead_tuples
FROM pg_stat_user_tables
WHERE n_dead_tup > 1000
ORDER BY n_dead_tup DESC;
```

## Configuration Template

```sql
-- Connection limits
ALTER SYSTEM SET max_connections = 100;

-- Timeouts
ALTER SYSTEM SET idle_in_transaction_session_timeout = '5min';
ALTER SYSTEM SET statement_timeout = '30s';

-- Monitoring
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;

-- Security defaults
REVOKE ALL ON SCHEMA public FROM PUBLIC;
```

## Related Resources

- `database-reviewer` agent for full database reviews
- `clickhouse-io` skill for analytics patterns
- `backend-patterns` skill for API patterns

*Based on Supabase Agent Skills (MIT License)*
