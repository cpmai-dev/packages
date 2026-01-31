# React Rules

Best practices and conventions for React development.

## Component Structure

- Use functional components with hooks
- Keep components small and focused
- Extract reusable logic into custom hooks
- Separate presentational and container components

## State Management

- Use local state for UI-only state
- Lift state up when needed by siblings
- Use context for deeply nested props
- Consider external state managers for complex apps

## Performance

- Memoize expensive computations with useMemo
- Wrap callbacks with useCallback when passed to children
- Use React.memo for pure components
- Avoid inline object/array creation in JSX

## Naming Conventions

- PascalCase for components
- camelCase for hooks (use prefix)
- kebab-case for CSS files
- Descriptive prop names

## File Organization

- One component per file
- Co-locate tests with components
- Group by feature, not by type
- Keep files under 300 lines
