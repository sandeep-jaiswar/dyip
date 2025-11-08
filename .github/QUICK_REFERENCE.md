# CI/CD Quick Reference

Quick reference guide for common CI/CD operations.

## Daily Operations

### Checking CI Status
```bash
# View workflow status
gh workflow list

# View recent runs
gh run list --limit 5

# View specific run
gh run view RUN_ID
```

### Local Pre-commit Checks
```bash
# Run all checks locally before pushing
flutter analyze --fatal-infos
flutter format --set-exit-if-changed lib test
flutter test --coverage
```

## Release Operations

### Creating a Release
```bash
# Tag and push
git tag v1.0.0
git push origin v1.0.0

# Or use gh CLI
gh release create v1.0.0 --generate-notes
```

### Viewing Releases
```bash
# List releases
gh release list

# View release details
gh release view v1.0.0
```

## Artifact Operations

### Download Build Artifacts
```bash
# List artifacts from latest run
gh run list --limit 1
gh run download RUN_ID

# Download specific artifact
gh run download RUN_ID --name android-release-apks
```

## Troubleshooting

### Re-run Failed Workflow
```bash
# Re-run all failed jobs
gh run rerun RUN_ID --failed

# Re-run entire workflow
gh run rerun RUN_ID
```

### Cancel Running Workflow
```bash
gh run cancel RUN_ID
```

### View Logs
```bash
# View workflow logs
gh run view RUN_ID --log

# View specific job logs
gh run view RUN_ID --job JOB_ID --log
```

## Common Issues

### Issue: Tests fail locally but pass in CI
**Check**:
- Flutter version mismatch
- Missing dependencies
- Environment variables

```bash
flutter --version
flutter pub get
flutter clean && flutter test
```

### Issue: Cache not working
**Fix**:
```bash
# Clear GitHub Actions cache
gh cache list
gh cache delete CACHE_KEY
```

### Issue: Workflow not triggering
**Check**:
- Branch name matches trigger pattern
- Workflow file syntax is valid
- Push includes commits (not just tags)

```bash
# Validate workflow syntax locally
yamllint .github/workflows/*.yml
```

## Monitoring

### Check Workflow Performance
```bash
# View workflow run times
gh run list --workflow="PR Checks" --limit 10 --json conclusion,startedAt,updatedAt
```

### Check Coverage Trends
- Codecov: https://codecov.io/gh/OWNER/REPO/trend
- Coveralls: https://coveralls.io/github/OWNER/REPO

### Monitor Dependencies
- Dependabot PRs: Check "Pull requests" tab, filter by label: `dependencies`

## GitHub CLI Setup

Install GitHub CLI for easier CI/CD management:

```bash
# Install gh CLI
# macOS
brew install gh

# Linux
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install gh

# Authenticate
gh auth login
```

## Useful Aliases

Add to your `.bashrc` or `.zshrc`:

```bash
# CI status
alias ci-status='gh run list --limit 5'

# Latest build
alias ci-latest='gh run view $(gh run list --limit 1 --json databaseId --jq ".[0].databaseId")'

# Download latest artifacts
alias ci-download='gh run download $(gh run list --limit 1 --json databaseId --jq ".[0].databaseId")'

# Pre-commit checks
alias pre-commit='flutter analyze && flutter format lib test && flutter test'

# Create release
release() { git tag "v$1" && git push origin "v$1" && gh release create "v$1" --generate-notes; }
```

## Environment Variables

Common environment variables used in workflows:

| Variable | Description | Example |
|----------|-------------|---------|
| `GITHUB_TOKEN` | Auto-generated token | Auto-provided |
| `CODECOV_TOKEN` | Codecov upload token | From secrets |
| `FIREBASE_APP_ID` | Firebase app ID | From secrets |
| `PUB_CACHE` | Pub cache directory | Auto-set |
| `GITHUB_WORKSPACE` | Workspace directory | Auto-set |

## Workflow Triggers Summary

| Workflow | Trigger | Branches |
|----------|---------|----------|
| PR Checks | push, pull_request | main, develop |
| Release | tag (v*.*.*), manual | all |

## Job Dependencies

```
PR Checks:
  code-quality (matrix) → build-android → workflow-summary

Release:
  create-release → build-release-android
```

## Cache Keys

| Cache | Key Pattern | Location |
|-------|-------------|----------|
| Flutter SDK | `flutter-{channel}-{pubspec.lock}` | Tool cache |
| Pub dependencies | `pub-{os}-{pubspec.lock}` | ~/.pub-cache |
| Gradle | `gradle-{os}-{gradle files}` | ~/.gradle |

## Performance Targets

| Metric | Target | Current |
|--------|--------|---------|
| PR Check (Quality) | <5 min | ~3-4 min |
| PR Check (Full) | <10 min | ~8-9 min |
| Release Build | <30 min | ~20-25 min |
| Cache Hit Rate | >80% | ~85% |

## Security Checklist

- ✅ All actions use pinned versions (@v4, @v2)
- ✅ Explicit GITHUB_TOKEN permissions set
- ✅ Secrets stored in GitHub Secrets
- ✅ No secrets in logs
- ✅ CodeQL scanning enabled
- ✅ Dependabot enabled

## Quick Links

- [Actions Tab](../../actions)
- [Releases](../../releases)
- [Codecov Dashboard](https://codecov.io/gh/OWNER/REPO)
- [Coveralls Dashboard](https://coveralls.io/github/OWNER/REPO)
- [Security Alerts](../../security)

## Support Commands

```bash
# Check workflow syntax
yamllint .github/workflows/*.yml

# List all workflows
gh workflow list

# View workflow file
gh workflow view "PR Checks"

# Enable/disable workflow
gh workflow enable "PR Checks"
gh workflow disable "PR Checks"

# List secrets
gh secret list

# Set secret
gh secret set SECRET_NAME
```

## Tips

1. **Run checks locally first** - Saves CI minutes and catches issues early
2. **Use draft PRs** - For WIP changes, mark PR as draft to skip some checks
3. **Review logs** - Check logs even for passing runs to spot warnings
4. **Monitor costs** - Check Actions usage in Settings → Billing
5. **Keep workflows simple** - Easier to maintain and debug

## Next Steps

After setup:
1. ✅ Verify first workflow run
2. ✅ Check coverage reports
3. ✅ Create first release
4. ✅ Review Dependabot PRs
5. ✅ Set up notifications (optional)

For detailed documentation, see [CICD_SETUP.md](CICD_SETUP.md)
