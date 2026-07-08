```markdown
# hackathon-team-template Development Patterns

> Auto-generated skill from repository analysis

## Overview
This skill teaches the core development patterns and conventions used in the `hackathon-team-template` TypeScript repository. It covers file naming, import/export styles, commit message conventions, and testing patterns. While no specific framework or automated workflows were detected, this guide will help you contribute code that aligns with the project's established practices.

## Coding Conventions

### File Naming
- **Pattern:** camelCase
- **Example:**  
  ```
  userProfile.ts
  teamManager.test.ts
  ```

### Import Style
- **Pattern:** Relative imports
- **Example:**
  ```typescript
  import { UserProfile } from './userProfile';
  import { TeamManager } from '../managers/teamManager';
  ```

### Export Style
- **Pattern:** Named exports
- **Example:**
  ```typescript
  // userProfile.ts
  export function getUserProfile(id: string) { ... }

  // teamManager.ts
  export const TeamManager = { ... };
  ```

### Commit Messages
- **Pattern:** Conventional commits
- **Prefix used:** `feat`
- **Example:**
  ```
  feat: add user profile management module
  ```

## Workflows

_No automated workflows detected in this repository._

## Testing Patterns

- **Test Framework:** Unknown (not detected)
- **Test File Pattern:** Files ending with `.test.*`
- **Example:**
  ```
  teamManager.test.ts
  ```
- **Typical Test Structure:**
  ```typescript
  // teamManager.test.ts
  import { TeamManager } from './teamManager';

  describe('TeamManager', () => {
    it('should add a user to the team', () => {
      // test logic here
    });
  });
  ```

## Commands
| Command         | Purpose                                    |
|-----------------|--------------------------------------------|
| /test           | Run all test files matching `*.test.*`     |
| /contribute     | Show coding conventions and commit patterns |
| /import-example | Show import/export style examples           |
```