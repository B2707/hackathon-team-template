```markdown
# hackathon-team-template Development Patterns

> Auto-generated skill from repository analysis

## Overview
This skill teaches the core development patterns and conventions used in the `hackathon-team-template` JavaScript repository. You'll learn how to structure files, write code, follow commit conventions, and organize tests according to the project's established standards. This guide is ideal for contributors aiming for consistency and maintainability in a collaborative hackathon environment.

## Coding Conventions

### File Naming
- **Style:** kebab-case
- **Example:**  
  ```
  team-list.js
  user-profile.test.js
  ```

### Import Style
- **Relative imports** are used for all internal modules.
- **Example:**
  ```js
  import { getTeam } from './team-utils.js';
  ```

### Export Style
- **Named exports** are preferred over default exports.
- **Example:**
  ```js
  // team-utils.js
  export function getTeam(id) { ... }
  export function listTeams() { ... }
  ```

### Commit Messages
- **Conventional commits** are used.
- **Prefix:** `fix`
- **Average length:** ~72 characters
- **Example:**
  ```
  fix: correct team member sorting in team-list.js
  ```

## Workflows

### Commit Workflow
**Trigger:** When making any code change  
**Command:** `/commit`

1. Make your code changes following the coding conventions.
2. Stage your changes:  
   ```
   git add .
   ```
3. Write a conventional commit message prefixed with `fix` (or other relevant type):  
   ```
   git commit -m "fix: update team member display order"
   ```
4. Push your changes:  
   ```
   git push
   ```

### Testing Workflow
**Trigger:** Before pushing code or submitting a pull request  
**Command:** `/test`

1. Identify test files matching the `*.test.*` pattern.
2. Run your preferred JavaScript test runner (framework not specified; use `node`, `jest`, or similar).
   ```
   # Example with node
   node user-profile.test.js
   ```
3. Ensure all tests pass before pushing changes.

## Testing Patterns

- **Test File Pattern:** Files are named with the `.test.` infix (e.g., `user-profile.test.js`).
- **Framework:** Not specified; use your preferred JavaScript test runner.
- **Example:**
  ```js
  // user-profile.test.js
  import { getUserProfile } from './user-profile.js';

  // Simple assertion
  if (getUserProfile('alice').name !== 'Alice') {
    throw new Error('User profile name mismatch');
  }
  ```

## Commands
| Command   | Purpose                                      |
|-----------|----------------------------------------------|
| /commit   | Standardize commit workflow                  |
| /test     | Run all test files before pushing changes    |
```
