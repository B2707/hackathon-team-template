```markdown
# hackathon-team-template Development Patterns

> Auto-generated skill from repository analysis

## Overview
This skill teaches the core development patterns and conventions used in the `hackathon-team-template` TypeScript repository. It covers file naming, import/export styles, commit patterns, and testing conventions, providing clear examples and step-by-step workflows to help you contribute effectively.

## Coding Conventions

### File Naming
- **Style:** snake_case
- **Example:**  
  ```plaintext
  team_utils.ts
  project_config.ts
  ```

### Import Style
- **Style:** Relative imports
- **Example:**  
  ```typescript
  import { getTeamMembers } from './team_utils';
  ```

### Export Style
- **Style:** Named exports
- **Example:**  
  ```typescript
  // In team_utils.ts
  export function getTeamMembers() { ... }
  ```

### Commit Patterns
- **Type:** Freeform (no enforced prefix or structure)
- **Average length:** 43 characters
- **Example:**  
  ```
  Add initial team member management functions
  ```

## Workflows

### Adding a New Utility Function
**Trigger:** When you need to add a reusable function.
**Command:** `/add-utility`

1. Create a new file in snake_case (e.g., `new_utility.ts`).
2. Write your function using named exports.
   ```typescript
   export function newUtility() { ... }
   ```
3. Import the function where needed using a relative path.
   ```typescript
   import { newUtility } from './new_utility';
   ```
4. Commit your changes with a descriptive message.

### Writing and Running Tests
**Trigger:** When you add or update code that needs testing.
**Command:** `/run-tests`

1. Create a test file using the pattern `*.test.*` (e.g., `team_utils.test.ts`).
2. Write your test cases (framework is unknown; follow existing patterns).
3. Run your tests using the project's test runner (see project documentation or scripts).
4. Review test results and fix any issues.

## Testing Patterns

- **File Pattern:** Test files use the `*.test.*` naming convention.
  - Example: `team_utils.test.ts`
- **Framework:** Not explicitly detected; follow existing test file structure.
- **Typical Structure:**
  ```typescript
  import { getTeamMembers } from './team_utils';

  describe('getTeamMembers', () => {
    it('should return all team members', () => {
      // test implementation
    });
  });
  ```

## Commands
| Command        | Purpose                                   |
|----------------|-------------------------------------------|
| /add-utility   | Scaffold a new utility function file      |
| /run-tests     | Run all test files in the repository      |
```
