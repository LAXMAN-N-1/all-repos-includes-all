<div align="center">

# 📚 Git Quick Reference Guide

*Your complete guide to version control for the Live Call Intelligence project*

[![Git](https://img.shields.io/badge/Git-F05032?style=for-the-badge&logo=git&logoColor=white)](https://git-scm.com/)
[![GitHub](https://img.shields.io/badge/GitHub-100000?style=for-the-badge&logo=github&logoColor=white)](https://github.com)

</div>

---

## 📋 Table of Contents

- [Daily Workflow](#-daily-workflow-commands)
- [Common Scenarios](#-common-scenarios)
- [Commit Messages](#-commit-message-format)
- [Branch Naming](#-branch-naming-convention)
- [Emergency Commands](#-emergency-commands)
- [Status Checks](#-checking-status)
- [Configuration](#️-configuration)
- [Pro Tips](#-pro-tips)

---

## 🚀 Daily Workflow Commands

### 🌅 Starting Your Work Day

```bash
# 1. Switch to your team's main branch
git checkout backend/main

# 2. Get the latest changes from GitHub
git pull origin backend/main

# 3. Create a new feature branch
git checkout -b backend/feature/my-feature-name
```

### 💻 During Development

```bash
# Check what files have changed
git status

# Stage all changes for commit
git add .

# Stage a specific file only
git add path/to/file.py

# Stage multiple specific files
git add file1.py file2.js

# Commit your changes with a message
git commit -m "feat: Add user authentication"

# Push your changes to GitHub
git push origin backend/feature/my-feature-name
```

### 🏁 Finishing Your Work

```bash
# 1. Push your final changes
git push origin backend/feature/my-feature-name

# 2. Go to GitHub and create a Pull Request:
#    Base branch: backend/main
#    Compare branch: backend/feature/my-feature-name

# 3. Request review from your team lead
```

---

## 🔄 Common Scenarios

### 🔃 Update Your Branch with Latest Changes

```bash
# 1. Switch to main branch
git checkout backend/main

# 2. Get latest changes
git pull origin backend/main

# 3. Switch back to your feature branch
git checkout backend/feature/my-feature

# 4. Merge main into your branch
git merge backend/main
```

**Alternative: Using Rebase (cleaner history)**
```bash
git checkout backend/feature/my-feature
git rebase backend/main
```

### ⚔️ Resolve Merge Conflicts

```bash
# After merge/rebase, if conflicts occur:

# 1. Check which files have conflicts
git status

# 2. Open conflicted files in your editor
# Look for conflict markers: <<<<<<<, =======, >>>>>>>

# 3. Fix the conflicts manually

# 4. Stage the resolved files
git add path/to/resolved-file.py

# 5. Complete the merge/rebase
git commit -m "fix: Resolve merge conflicts"
# OR for rebase:
git rebase --continue

# 6. Push your changes
git push origin backend/feature/my-feature
```

### ↩️ Undo Changes

#### Undo Last Commit (Not Pushed Yet)
```bash
# Keep changes staged
git reset --soft HEAD~1

# Keep changes unstaged
git reset HEAD~1

# Discard changes completely (⚠️ DANGEROUS)
git reset --hard HEAD~1
```

#### Discard All Uncommitted Changes
```bash
# ⚠️ WARNING: This deletes all your local changes!
git reset --hard HEAD
```

#### Undo Specific File Changes
```bash
# Discard changes in a specific file
git checkout -- path/to/file.py

# Unstage a file (keep changes)
git reset HEAD path/to/file.py
```

### 📜 View Commit History

```bash
# Beautiful one-line graph view
git log --oneline --graph --all

# Last 5 commits
git log --oneline -5

# Commits by specific author
git log --author="Your Name"

# Commits in date range
git log --since="2024-01-01" --until="2024-01-31"
```

### 🔀 Switch Between Branches

```bash
# Switch to existing branch
git checkout branch-name

# Create and switch to new branch
git checkout -b backend/feature/new-feature

# Switch to previous branch
git checkout -
```

### 🗑️ Delete Branches

```bash
# Delete local branch (safe - prevents deleting unmerged)
git branch -d backend/feature/old-feature

# Force delete local branch (⚠️ deletes even if unmerged)
git branch -D backend/feature/old-feature

# Delete remote branch
git push origin --delete backend/feature/old-feature
```

### 💾 Temporarily Save Changes (Stash)

```bash
# Save current changes temporarily
git stash

# Save with a description
git stash save "WIP: working on authentication"

# List all stashes
git stash list

# Apply most recent stash
git stash pop

# Apply specific stash
git stash apply stash@{0}

# Delete a stash
git stash drop stash@{0}

# Clear all stashes
git stash clear
```

---

## 📝 Commit Message Format

### Structure

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Commit Types

| Type | Description | Example |
|------|-------------|---------|
| ✨ `feat` | New feature | `feat(api): Add user authentication endpoint` |
| 🐛 `fix` | Bug fix | `fix(db): Resolve connection timeout issue` |
| 📚 `docs` | Documentation only | `docs(readme): Update installation steps` |
| 💎 `style` | Formatting, semicolons, etc. | `style(ui): Apply consistent indentation` |
| ♻️ `refactor` | Code restructuring | `refactor(auth): Simplify token validation` |
| ✅ `test` | Adding or updating tests | `test(api): Add integration tests for auth` |
| 🔧 `chore` | Maintenance tasks | `chore(deps): Update dependencies` |
| ⚡ `perf` | Performance improvements | `perf(db): Optimize query performance` |
| 🔨 `ci` | CI/CD changes | `ci(github): Add automated testing workflow` |

### Examples

#### Good Commit Messages ✅

```bash
feat(twilio): Add voice call streaming endpoint
fix(whisper): Resolve audio transcription timeout
docs(api): Add REST API documentation
refactor(graph): Optimize Neo4j query performance
test(nlp): Add unit tests for entity extraction
```

#### Bad Commit Messages ❌

```bash
update
fix bug
changes
WIP
asdf
```

### Commit Message Best Practices

- ✅ Use imperative mood ("Add feature" not "Added feature")
- ✅ Limit subject line to 50 characters
- ✅ Capitalize the subject line
- ✅ Don't end subject line with a period
- ✅ Wrap body at 72 characters
- ✅ Use body to explain *what* and *why*, not *how*

---

## 🌿 Branch Naming Convention

### Format

```
<domain>/<type>/<short-description>
```

### Domains

| Domain | Description |
|--------|-------------|
| `backend/` | Backend API, databases, services |
| `frontend/` | UI, React components, styling |
| `ai-ml/` | Machine learning models, training |
| `mobile/` | Flutter mobile applications |
| `audio-processing/` | Audio streaming, denoising |
| `devops/` | Infrastructure, deployment |

### Types

| Type | Purpose |
|------|---------|
| `feature/` | New functionality |
| `fix/` | Bug fixes |
| `refactor/` | Code improvements |
| `docs/` | Documentation updates |
| `test/` | Test additions/updates |
| `hotfix/` | Urgent production fixes |

### Examples

✅ **Good Branch Names:**
```
backend/feature/twilio-integration
frontend/fix/button-alignment-mobile
ai-ml/feature/whisper-model-training
mobile/refactor/state-management
audio-processing/fix/kafka-streaming
devops/feature/kubernetes-setup
```

❌ **Bad Branch Names:**
```
fix
my-branch
test-stuff
john-dev
temp
```

---

## 🚨 Emergency Commands

### 😱 "I Messed Up Everything!"

```bash
# OPTION 1: Save your work and start fresh
git stash save "backup before reset"
git fetch origin
git reset --hard origin/backend/main

# Get your work back if needed
git stash pop

# OPTION 2: Create backup branch first
git branch backup-branch
git reset --hard origin/backend/main
```

### 🔀 "I Committed to the Wrong Branch!"

```bash
# 1. Note the commit hash
git log --oneline  # Copy the commit hash (e.g., abc1234)

# 2. Switch to the correct branch
git checkout backend/feature/correct-branch

# 3. Apply the commit
git cherry-pick abc1234

# 4. Go back to wrong branch and remove commit
git checkout wrong-branch
git reset --hard HEAD~1
```

### 📤 "I Pushed Sensitive Data!"

```bash
# ⚠️ CRITICAL: Contact team lead immediately!

# Remove from history (⚠️ USE WITH CAUTION)
git filter-branch --force --index-filter \
  "git rm --cached --ignore-unmatch path/to/sensitive-file" \
  --prune-empty --tag-name-filter cat -- --all

# Force push (requires team lead approval)
git push origin --force --all
```

### 🔙 "I Need to Undo a Pushed Commit"

```bash
# Create a revert commit (safe, preserves history)
git revert <commit-hash>
git push origin backend/feature/my-feature

# OR reset and force push (⚠️ only if no one else pulled)
git reset --hard HEAD~1
git push --force origin backend/feature/my-feature
```

### 🌐 "My Local Branch is Behind Remote"

```bash
# If you haven't made local changes
git pull origin backend/feature/my-feature

# If you have local changes and want to keep them
git pull --rebase origin backend/feature/my-feature
```

---

## 🔍 Checking Status

### Current State

```bash
# See current branch and changes
git status

# Short status format
git status -s

# See what's changed in detail
git diff

# See staged changes
git diff --cached

# See changes in specific file
git diff path/to/file.py
```

### Branch Information

```bash
# List all local branches
git branch

# List all branches (including remote)
git branch -a

# See branch tracking info
git branch -vv

# See which branches are merged
git branch --merged
```

### Remote Information

```bash
# See remote repositories
git remote -v

# See remote branches
git remote show origin

# Fetch remote info without merging
git fetch origin
```

### Commit Information

```bash
# Recent commits
git log --oneline -10

# Commits with file changes
git log --stat

# Search commits by message
git log --grep="authentication"

# See who changed what in a file
git blame path/to/file.py
```

---

## ⚙️ Configuration

### User Information

```bash
# Set your name globally
git config --global user.name "Your Name"

# Set your email globally
git config --global user.email "your.email@example.com"

# Set for current repository only
git config user.name "Your Name"
git config user.email "your.email@example.com"
```

### Editor Configuration

```bash
# Set VS Code as default editor
git config --global core.editor "code --wait"

# Set Vim as default editor
git config --global core.editor "vim"

# Set Nano as default editor
git config --global core.editor "nano"
```

### Helpful Aliases

```bash
# Create shortcuts for common commands
git config --global alias.st status
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.cm commit
git config --global alias.lg "log --oneline --graph --all"

# Usage: git st (instead of git status)
```

### Other Useful Configs

```bash
# Colorful output
git config --global color.ui auto

# Default branch name
git config --global init.defaultBranch main

# Pull strategy (rebase instead of merge)
git config --global pull.rebase true

# See all configuration
git config --list

# See specific config
git config user.name
```

---

## 💡 Pro Tips

### 1. 📝 Commit Often, Push Regularly

```bash
# Make small, focused commits
git commit -m "feat(auth): Add login endpoint"
git commit -m "test(auth): Add login tests"
git commit -m "docs(auth): Document login API"

# Push at least daily
git push origin backend/feature/my-feature
```

### 2. 🔄 Always Pull Before Starting Work

```bash
# Morning routine
git checkout backend/main
git pull origin backend/main
git checkout backend/feature/my-feature
git merge backend/main
```

### 3. 📊 Review Changes Before Committing

```bash
# Check what you're about to commit
git status
git diff
git diff --cached  # See staged changes
```

### 4. 🌿 Keep Branches Focused

- One feature per branch
- Small, reviewable pull requests
- Delete branches after merging

### 5. 💬 Write Descriptive Commit Messages

```bash
# ✅ Good: Explains what and why
git commit -m "feat(api): Add rate limiting to prevent abuse

Added Redis-based rate limiter with 100 req/min limit.
Prevents API abuse and ensures fair usage."

# ❌ Bad: Vague and unhelpful
git commit -m "updates"
```

### 6. 🔍 Use Git Ignore

```bash
# Create .gitignore file
cat > .gitignore << EOF
.env
*.pyc
__pycache__/
node_modules/
.DS_Store
*.log
EOF

git add .gitignore
git commit -m "chore: Add .gitignore file"
```

### 7. 🏷️ Use Tags for Releases

```bash
# Create annotated tag
git tag -a v1.0.0 -m "Release version 1.0.0"

# Push tags to remote
git push origin v1.0.0

# Push all tags
git push origin --tags
```

### 8. 🔐 Never Commit Secrets

```bash
# Always check before committing
git diff --cached

# If you accidentally staged secrets
git reset HEAD .env
echo ".env" >> .gitignore
```

---

## 🆘 Getting Help

### Command-Line Help

```bash
# General help
git help

# Help for specific command
git help commit
git help branch
git help merge

# Quick reference
git <command> --help
```

### Common Issues & Solutions

#### "Permission denied (publickey)"
```bash
# Generate SSH key
ssh-keygen -t ed25519 -C "your.email@example.com"

# Add to GitHub: Settings > SSH Keys > Add new key
```

#### "Your branch has diverged"
```bash
# See what's different
git log HEAD..origin/backend/feature/my-feature
git log origin/backend/feature/my-feature..HEAD

# Resolve by rebasing
git pull --rebase origin backend/feature/my-feature
```

#### "Merge conflict in file.py"
```bash
# Open the file and look for:
<<<<<<< HEAD
your changes
=======
their changes
>>>>>>> branch-name

# Fix manually, then:
git add file.py
git commit -m "fix: Resolve merge conflict in file.py"
```

### 📞 Team Support

- **Git Issues**: Create GitHub issue with `[git-help]` tag
- **Access Problems**: Contact DevOps team lead
- **Quick Questions**: Team Slack `#git-help` channel
- **Emergencies**: Tag `@devops-team` in Slack

---

## 📚 Additional Resources

- [Official Git Documentation](https://git-scm.com/doc)
- [GitHub Guides](https://guides.github.com/)
- [Atlassian Git Tutorials](https://www.atlassian.com/git/tutorials)
- [Git Flight Rules](https://github.com/k88hudson/git-flight-rules)
- [Interactive Git Branching](https://learngitbranching.js.org/)

---

<div align="center">

### 🎯 Happy Coding!

*Remember: Commit early, commit often, and write clear messages!*

[← Back to Main README](../README.md)

</div>
