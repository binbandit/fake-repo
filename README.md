# Git Test Repository

A comprehensive fake repository designed for testing git-related tools, wrappers, and integrations.

## Purpose

This repository serves as a testing ground for developers building git-related tools. It contains a realistic project history with various git scenarios that your tool might encounter in real-world usage.

## Repository Features

### Branch Structure
- **21 branches** with different states and relationships
- Feature branches (`feature/*`) including stacked branches
- Bugfix branches (`bugfix/*`) including unicode names
- Hotfix branches (`hotfix/*`)
- Release branches (`release/*`)
- Orphan branch (`gh-pages`)
- Special test branches (unicode, long names, octopus merge)

### Commit History
- **Multiple authors**: 7 different contributors
- **Date range**: Commits spanning January-February 2024
- **Varied commit types**: features, fixes, refactors, chores
- **Merge commits**: Both fast-forward and non-fast-forward merges

### Complex Scenarios

#### 1. Merge Conflicts
- `src/helpers.js` has different implementations across branches
- Date formatting conflicts between `feature/user-auth` and `feature/database`

#### 2. File Operations
- **Renamed files**: `utils.js` → `helpers.js`
- **Moved files**: `database.js` → `core/database.js`
- **Binary files**: PNG image in `assets/`
- **Large JSON files**: Sample data in `data/`
- **Symbolic links**: Including broken links for edge case testing
- **File permissions**: Executable scripts with permission changes

#### 3. Branch Relationships
- Branches ahead/behind main
- Stacked branches (branches created from other branches)
- Divergent histories
- Cross-branch merges
- **Octopus merge**: 3-parent merge commit

#### 4. Advanced Git Features
- **Tags**: Annotated (`v1.0.0`, `v1.1.0`) and lightweight (`v0.9.0`, `v1.2.0-beta`)
- **Git LFS**: Large file storage for `*.psd`, `*.zip`, `*.mov` files
- **Cherry-picked commits**: With `-x` flag showing origin
- **Revert commits**: Demonstrating revert history
- **Empty commits**: Testing edge cases
- **Git hooks**: Pre-commit and commit-msg hooks
- **Submodules**: Simulated submodule structure
- **Unicode branch names**: Testing special characters and emojis

## How to Use This Repository

### For Testing Git Wrappers

```bash
# Clone the repository
git clone https://github.com/crazywolf132/fake-repo.git
cd fake-repo

# List all branches
git branch -a

# View the complex history
git log --oneline --graph --all --decorate

# Test branch operations
git checkout feature/user-auth
git checkout feature/database

# Test merge conflict scenarios
git checkout -b test-conflicts main
git merge feature/user-auth
git merge feature/database  # This will conflict
```

### Test Scenarios

#### 1. Branch Analysis
Test your tool's ability to:
- List all branches with their status
- Identify branches ahead/behind main
- Detect merged vs unmerged branches
- Find branch creation points

#### 2. History Traversal
- Parse complex merge histories
- Handle multiple parents in merge commits
- Track file changes across renames
- Identify author contributions

#### 3. Conflict Detection
- Detect potential merge conflicts
- Analyze conflicting changes
- Suggest conflict resolution

#### 4. File Tracking
- Follow files through renames
- Track files moved to different directories
- Handle binary files appropriately

## Repository Structure

```
.
├── assets/             # Binary files (images)
├── config/             # Configuration files
├── data/               # Sample data files
├── docs/               # Documentation
├── src/                # Source code
│   ├── core/           # Core modules
│   ├── middleware/     # Express middleware
│   ├── migrations/     # Database migrations
│   ├── models/         # Data models
│   ├── routes/         # API routes
│   ├── services/       # Service layer
│   └── validators/     # Input validation
└── tests/              # Test files
```

## Branch Tree Structure

```
main (current)
│
├─ Already Merged:
│  ├─ hotfix/security-patch → merged at commit 2848c2c
│  ├─ feature/database → partially merged at db86cf6  
│  ├─ feature/octopus-1 ┐
│  ├─ feature/octopus-2 ├─ Octopus merge at 321b498
│  └─ feature/octopus-3 ┘
│
└─ Active Branches:
   │
   ├─ From early history (Initial commit):
   │  ├─ feature/user-auth
   │  │  └─ feature/user-auth-api [STACKED]
   │  └─ feature/refactor-old
   │
   ├─ From feature/database merge point:
   │  ├─ feature/database (continues after merge)
   │  │  └─ feature/database-models [STACKED]
   │  └─ bugfix/memory-leak
   │
   ├─ From after hotfix merge:
   │  └─ feature/experimental (has cherry-picked commit)
   │
   ├─ From main history:
   │  ├─ feature/api-v2 (includes merge from release/v2.0)
   │  ├─ feature/api-v2-routes 
   │  └─ release/v2.0
   │
   ├─ Recent branches:
   │  └─ feature/long-running
   │
   └─ Special Test Branches:
      ├─ feature/🚀-unicode-测试-émojis
      ├─ bugfix/пофиксить-баг-🐛
      └─ feature/this-is-an-extremely-long-branch-name-that-tests-the-limits...

ORPHAN: gh-pages (no common ancestor with main)
```

## Branch Descriptions

- **main**: Primary development branch
- **feature/user-auth**: Authentication implementation (branched from early main)
- **feature/user-auth-api**: API routes for authentication [STACKED on feature/user-auth]
- **feature/database**: Database integration (partially merged, continues development)
- **feature/database-models**: Mongoose models [STACKED on feature/database]
- **feature/api-v2**: Version 2 API development (includes release/v2.0 merge)
- **feature/api-v2-routes**: API v2 routes implementation
- **feature/experimental**: Experimental caching features
- **feature/long-running**: Performance metrics implementation
- **feature/refactor-old**: Legacy code refactoring
- **bugfix/memory-leak**: Memory leak fixes
- **hotfix/security-patch**: Security updates (MERGED)
- **release/v2.0**: Release preparation branch
- **gh-pages**: Documentation site (orphan branch - no common history)
- **feature/octopus-1,2,3**: Branches for octopus merge testing (MERGED)
- **feature/🚀-unicode-测试-émojis**: Unicode branch name testing
- **bugfix/пофиксить-баг-🐛**: Cyrillic unicode branch testing
- **feature/this-is-an-extremely-long-branch-name...**: Testing branch name length limits

## Testing Pull Requests

To test PR functionality with this repository, use the following base and compare branch combinations. These maintain the intended structure and provide realistic PR scenarios:

### Recommended PR Scenarios

1. **Stacked Feature Development**
   - Base: `feature/user-auth` → Compare: `feature/user-auth-api`
   - Base: `feature/database` → Compare: `feature/database-models`
   - Tests: Stacked PR workflows, dependent changes

2. **Feature to Main**
   - Base: `main` → Compare: `feature/experimental`
   - Base: `main` → Compare: `feature/long-running`
   - Base: `main` → Compare: `bugfix/memory-leak`
   - Tests: Standard feature integration

3. **Release Management**
   - Base: `release/v2.0` → Compare: `feature/api-v2`
   - Base: `main` → Compare: `release/v2.0`
   - Tests: Release branch workflows, version management

4. **Cross-Feature Integration**
   - Base: `feature/api-v2` → Compare: `feature/api-v2-routes`
   - Tests: Feature branch integration before main

5. **Legacy Code Updates**
   - Base: `main` → Compare: `feature/refactor-old`
   - Tests: Long-running refactoring PRs

6. **Unicode/Special Characters**
   - Base: `main` → Compare: `feature/🚀-unicode-测试-émojis`
   - Base: `main` → Compare: `bugfix/пофиксить-баг-🐛`
   - Tests: Unicode handling in PR titles/branches

7. **Conflict Scenarios**
   - Base: `feature/user-auth` → Compare: `feature/database`
   - Tests: Merge conflicts in PRs (both modify helpers.js differently)

### PR Testing Tips

- The repository includes pre-commit hooks that may affect PR commits
- Some branches have cherry-picked commits that will show in PR history
- The octopus merge branches demonstrate complex merge scenarios
- Use the long branch name to test UI display limits in PR tools

## Automated Test PR Creation

The repository includes a `create-test-prs.sh` script that automatically creates test pull requests using GitHub CLI. This is useful for testing PR-related functionality in git tools.

### Prerequisites

1. Install GitHub CLI (gh): https://cli.github.com/
2. Authenticate with GitHub: `gh auth login`
3. Ensure all test branches are pushed to remote

### Usage

```bash
# Run the script
./create-test-prs.sh
```

The script will:
1. Ask if you want to include stacked PRs (PRs targeting other feature branches)
2. Ask if you want to create ALL possible PRs or a random subset
3. Create the selected PRs with realistic titles and descriptions

### Features

- **Random PR Creation**: Creates a random subset of possible PRs by default
- **Stacked PR Support**: Optional creation of stacked PRs for testing dependent changes
- **Automatic Branch Pushing**: Pushes branches to remote if needed
- **Conflict Detection**: Skips branches that are already merged
- **Error Handling**: Continues if a PR already exists or fails

### Available PR Scenarios

The script can create PRs for:
- Feature branches → main
- Bugfix branches → main
- Release branches → main
- Stacked features (feature → feature)
- Branches with merge conflicts
- Unicode branch names
- Long-running branches

After running the script:
- View all PRs: `gh pr list`
- View PR details: `gh pr view <number>`

## Contributing

This is a test repository designed to remain static for consistent testing. If you have suggestions for additional git scenarios that would be helpful for testing, please open an issue.

## License

This repository is provided as-is for testing purposes. Feel free to use it in developing and testing your git-related tools.