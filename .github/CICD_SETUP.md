# GitHub Actions CI/CD Setup Guide

This document provides detailed information about the GitHub Actions workflows implemented for this Flutter project.

## Overview

The CI/CD pipeline consists of two main workflows:
1. **PR Checks** - Automated validation for pull requests
2. **Release Build** - Automated release creation and distribution

## Workflows

### 1. PR Checks Workflow (`pr-checks.yml`)

**Purpose**: Validates code quality, runs tests, and builds the app for every push and pull request.

**Triggers**:
- Push to `production` or `development` branches
- Pull requests targeting `production` or `development` branches

**Jobs**:

#### Code Quality & Tests
- Runs on: `ubuntu-latest`
- Timeout: 15 minutes
- Matrix: Tests on Flutter `stable` and `beta` channels
- Steps:
  1. Static analysis (`flutter analyze --fatal-infos`)
  2. Format checking (`flutter format --set-exit-if-changed`)
  3. Test execution with coverage
  4. Coverage upload to Codecov and Coveralls

#### Android Build
- Runs on: `ubuntu-latest`
- Timeout: 20 minutes
- Requires: Code quality job to pass first
- Steps:
  1. Build debug APKs (split per ABI)
  2. Build release APKs (split per ABI)
  3. Validate build outputs and sizes
  4. Upload artifacts (7 days retention for debug, 30 days for release)

#### Workflow Summary
- Always runs at the end
- Reports overall workflow status
- Creates a summary in the GitHub Actions UI

**Performance Optimizations**:
- Aggressive caching (Flutter SDK, pub dependencies, Gradle)
- Concurrency control (cancels in-progress runs for the same PR)
- Parallel matrix builds
- Target runtime: <5 minutes for typical PRs

### 2. Release Workflow (`release.yml`)

**Purpose**: Automates the creation of releases with versioned builds.

**Triggers**:
- Git tags matching `v*.*.*` pattern (e.g., `v1.0.0`)
- Manual workflow dispatch (with version input)

**Jobs**:

#### Create Release
- Generates changelog from git history
- Creates GitHub Release with release notes
- Outputs version for downstream jobs

#### Build Release Android
- Builds production-ready APKs and AAB
- Names artifacts with version numbers
- Uploads to GitHub Release
- Stores artifacts for 90 days

**Outputs**:
- Android App Bundle (AAB) for Play Store
- Split APKs by architecture (arm64-v8a, armeabi-v7a, x86_64)
- Universal APK for maximum compatibility

## Setup Instructions

### 1. Required Secrets

Add these secrets in your GitHub repository settings (Settings → Secrets and variables → Actions):

#### For Code Coverage (Optional)
- `CODECOV_TOKEN` - Token from codecov.io (if using Codecov)
  - Get it from: https://codecov.io/gh/YOUR_USERNAME/YOUR_REPO/settings

#### For Release Signing (Optional)
If you want to sign release builds, add:
- `ANDROID_KEYSTORE_FILE` - Base64 encoded keystore
- `ANDROID_KEYSTORE_PASSWORD` - Keystore password
- `ANDROID_KEY_ALIAS` - Key alias
- `ANDROID_KEY_PASSWORD` - Key password

#### For Firebase App Distribution (Optional)
If using Firebase App Distribution:
- `FIREBASE_APP_ID` - Firebase app ID
- `FIREBASE_SERVICE_ACCOUNT` - Service account JSON

### 2. Branch Protection Rules

Recommended settings for `production` and `development` branches:

1. Go to Settings → Branches → Add rule
2. Branch name pattern: `production` (repeat for `development`)
3. Enable:
   - ✅ Require a pull request before merging
   - ✅ Require status checks to pass before merging
     - Add: `Code Quality & Tests (Flutter stable)`
     - Add: `Build Android APK`
   - ✅ Require branches to be up to date before merging
   - ✅ Require linear history (optional)

### 3. Code Coverage Setup

#### Codecov
1. Sign up at https://codecov.io
2. Add your repository
3. Copy the upload token
4. Add it as `CODECOV_TOKEN` secret in GitHub

#### Coveralls
1. Sign up at https://coveralls.io
2. Add your repository
3. No additional configuration needed (uses `GITHUB_TOKEN`)

### 4. Dependabot

Dependabot is already configured in `.github/dependabot.yml`. It will:
- Check for GitHub Actions updates weekly
- Check for Flutter/Dart package updates weekly
- Create PRs automatically

To configure Dependabot notifications:
1. Go to Settings → Notifications
2. Configure under "Dependabot alerts"

## Usage

### Running PR Checks

PR checks run automatically on every push and pull request. No manual action needed.

**To view results**:
1. Go to your PR or commit
2. Click on the "Checks" tab
3. View detailed logs for each job

### Creating a Release

#### Method 1: Git Tag (Recommended)
```bash
# Create and push a version tag
git tag v1.0.0
git push origin v1.0.0
```

#### Method 2: Manual Dispatch
1. Go to Actions → Release Build
2. Click "Run workflow"
3. Enter the version number (e.g., 1.0.0)
4. Click "Run workflow"

The workflow will:
1. Generate a changelog from commits
2. Create a GitHub Release
3. Build and upload APKs and AAB
4. Name artifacts with version numbers

### Downloading Build Artifacts

#### From PR Checks
1. Go to the workflow run
2. Scroll to the bottom (Artifacts section)
3. Download:
   - `android-debug-apks` (7-day retention)
   - `android-release-apks` (30-day retention)

#### From Releases
1. Go to the Releases page
2. Download attached APK files
3. Or download from workflow artifacts (90-day retention)

## Monitoring

### Workflow Status
- Check the badges in README.md
- Green badge = passing
- Red badge = failing

### Coverage Reports
- Codecov: View at https://codecov.io/gh/YOUR_USERNAME/YOUR_REPO
- Coveralls: View at https://coveralls.io/github/YOUR_USERNAME/YOUR_REPO

### Build Times
Target times:
- PR checks: <5 minutes for code quality
- Full pipeline: <10 minutes total
- Release build: <30 minutes

View actual times in the Actions tab.

## Troubleshooting

### Common Issues

#### Issue: "Flutter command not found"
**Solution**: This should not happen as we use `subosito/flutter-action@v2`. If it does, check the action version.

#### Issue: "Gradle build failed"
**Solution**: 
1. Check if `android/` directory is properly committed
2. Verify `gradle-wrapper.properties` is present
3. Check Java version (we use Java 17)

#### Issue: "Tests failing"
**Solution**:
1. Run tests locally first: `flutter test`
2. Ensure all dependencies are in `pubspec.yaml`
3. Check if tests depend on specific environment variables

#### Issue: "Coverage upload failed"
**Solution**:
1. Verify `CODECOV_TOKEN` is set correctly
2. Check if coverage file is generated: `coverage/lcov.info`
3. Coverage upload failures are non-blocking (workflow continues)

#### Issue: "Build artifacts too large"
**Solution**:
- Workflow warns if APK > 50MB
- Consider using ProGuard/R8 for release builds
- Check for unused resources

### Getting Help

1. Check workflow logs in the Actions tab
2. Review this documentation
3. Check Flutter documentation: https://docs.flutter.dev
4. Open an issue in the repository

## Customization

### Adding iOS Builds

To enable iOS builds (requires macOS runners):

1. Uncomment the `build-ios` job in `pr-checks.yml`
2. Update the `workflow-summary` job needs:
   ```yaml
   needs: [code-quality, build-android, build-ios]
   ```
3. Note: macOS runners are more expensive than Linux runners

### Adding Notifications

To add Slack/Discord notifications on failure:

Add at the end of any job:
```yaml
- name: Notify on failure
  if: failure()
  uses: 8398a7/action-slack@v3
  with:
    status: ${{ job.status }}
    webhook_url: ${{ secrets.SLACK_WEBHOOK }}
```

### Integrating SonarCloud

Add a new job to `pr-checks.yml`:
```yaml
sonarcloud:
  name: SonarCloud Analysis
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v4
      with:
        fetch-depth: 0
    - name: SonarCloud Scan
      uses: SonarSource/sonarcloud-github-action@master
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
```

## Best Practices

1. **Always run tests locally before pushing**
   ```bash
   flutter analyze
   flutter format lib test
   flutter test
   ```

2. **Use semantic versioning for releases**
   - Format: `v<major>.<minor>.<patch>`
   - Example: `v1.2.3`

3. **Keep workflows up to date**
   - Dependabot will create PRs for action updates
   - Review and merge these PRs regularly

4. **Monitor build times**
   - If builds get slower, review caching strategies
   - Consider splitting jobs for better parallelization

5. **Review workflow logs regularly**
   - Check for warnings
   - Optimize slow steps

## Additional Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Flutter CI/CD Best Practices](https://docs.flutter.dev/deployment/cd)
- [subosito/flutter-action](https://github.com/subosito/flutter-action)
- [Codecov Documentation](https://docs.codecov.io/)
- [Dependabot Documentation](https://docs.github.com/en/code-security/dependabot)

## Maintenance

### Regular Tasks

**Weekly**:
- Review Dependabot PRs
- Check workflow run times
- Monitor coverage trends

**Monthly**:
- Review and update pinned action versions if needed
- Clean up old workflow runs (automatic after 90 days)
- Review security alerts

**Quarterly**:
- Review caching strategies
- Update Flutter channel in matrix if needed
- Review and update this documentation

## Support

For issues specific to this CI/CD setup, please open an issue in the repository with:
- Workflow run link
- Error messages
- Steps to reproduce
