# Team Workflow Guide

## Daily Workflow for Developers

### 1. Start Your Day
```bash
# Pull latest changes from your team's main branch
git checkout backend/main  # or your domain: frontend/main, ai-ml/main, etc.
git pull origin backend/main
```

### 2. Create Feature Branch
```bash
# Create a new branch for your feature
git checkout -b backend/feature/your-feature-name

# Examples:
# backend/feature/twilio-integration
# frontend/feature/dashboard-ui
# ai-ml/feature/whisper-model
```

### 3. Make Changes

- Write your code
- Test locally
- Commit frequently
```bash
git add .
git commit -m "feat: Add description of your changes"
```

### 4. Push to GitHub
```bash
git push origin backend/feature/your-feature-name
```

### 5. Create Pull Request

1. Go to GitHub repository
2. Click "Pull requests"
3. Click "New pull request"
4. Base: `backend/main`
5. Compare: `backend/feature/your-feature-name`
6. Click "Create pull request"
7. Fill in the template
8. Assign reviewers from your team
9. Click "Create pull request"

### 6. Code Review

- Wait for team member to review
- Address feedback
- Push changes to same branch
- Request re-review

### 7. Merge

- After approval, click "Squash and merge"
- Delete your feature branch

## Commit Message Format
