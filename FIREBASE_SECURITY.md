# Firebase Credentials Security

## IMPORTANT: Credentials Removed

The `google-services.json` file has been removed from this repository for security reasons. This file contained sensitive Firebase API keys and should never be committed to version control.

## Setup Instructions

### For Development:

1. Create your own Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Enable Phone Authentication in Firebase Console > Authentication > Sign-in method
3. Download the `google-services.json` file from Firebase Console
4. Place it in `android/app/google-services.json`
5. The file is automatically ignored by `.gitignore`

### For iOS:

1. Download `GoogleService-Info.plist` from Firebase Console
2. Add it to `ios/Runner/` directory using Xcode
3. The file is automatically ignored by `.gitignore`

### For CI/CD:

The workflow files use GitHub Secrets for Firebase configuration:
- Set up secrets in GitHub repository settings
- Secrets are automatically injected into `.env` file during build
- See `.github/workflows/pr-checks.yml` and `release.yml` for required secret names

## Security Best Practices

1. **Never commit** `google-services.json` or `GoogleService-Info.plist`
2. **Rotate API keys** immediately if they were accidentally exposed
3. **Use environment variables** for sensitive configuration
4. **Set up Firebase Security Rules** to restrict access
5. **Enable App Check** for production deployments

## Required GitHub Secrets

For CI/CD pipelines, configure these secrets in your repository:

### Common:
- `FIREBASE_PROJECT_ID`
- `FIREBASE_MESSAGING_SENDER_ID`
- `FIREBASE_DATABASE_URL`
- `FIREBASE_STORAGE_BUCKET`
- `FIREBASE_AUTH_DOMAIN`

### Platform-specific:
- `FIREBASE_API_KEY_ANDROID`
- `FIREBASE_APP_ID_ANDROID`
- `FIREBASE_API_KEY_IOS`
- `FIREBASE_APP_ID_IOS`
- `FIREBASE_IOS_BUNDLE_ID`
- `FIREBASE_API_KEY_WEB`
- `FIREBASE_APP_ID_WEB`
- `FIREBASE_MEASUREMENT_ID_WEB`
- `FIREBASE_API_KEY_WINDOWS`
- `FIREBASE_APP_ID_WINDOWS`
- `FIREBASE_MEASUREMENT_ID_WINDOWS`

## If Credentials Were Exposed

If you accidentally committed Firebase credentials:

1. **Immediately rotate** all API keys in Firebase Console
2. **Remove from git history** using:
   ```bash
   git filter-branch --force --index-filter \
     'git rm --cached --ignore-unmatch android/app/google-services.json' \
     --prune-empty --tag-name-filter cat -- --all
   ```
   Or use [BFG Repo-Cleaner](https://rtyley.github.io/bfg-repo-cleaner/)
3. **Force push** to remote repository (coordinate with team)
4. **Update all clones** of the repository
5. **Verify** credentials are no longer accessible

## Additional Resources

- [Firebase Security Best Practices](https://firebase.google.com/docs/projects/learn-more#best-practices)
- [GitHub Secrets Documentation](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
