# Environment Configuration Setup

This project uses environment variables to securely manage Firebase configuration and other sensitive data. This approach keeps sensitive keys out of version control and allows for different configurations across environments.

## Setup Instructions

1. **Copy the example environment file:**
   ```bash
   cp .env.example .env
   ```

2. **Fill in your Firebase configuration values:**
   Open the `.env` file and replace the placeholder values with your actual Firebase configuration values:

   ```env
   # Firebase Configuration - Web
   FIREBASE_API_KEY_WEB=your_actual_web_api_key
   FIREBASE_APP_ID_WEB=your_actual_web_app_id
   # ... etc
   ```

3. **Get your Firebase configuration:**
   - Go to your Firebase Console
   - Select your project
   - Click on the gear icon (Project Settings)
   - Scroll down to "Your apps" section
   - Select your app and copy the configuration values

## Security Notes

- **Never commit the `.env` file to version control** - it's already added to `.gitignore`
- **The `.env.example` file should be committed** - it serves as a template for other developers
- **Each developer/environment should have their own `.env` file**

## Files Modified

- `pubspec.yaml`: Added `flutter_dotenv` dependency and `.env` asset
- `lib/firebase_options.dart`: Updated to read from environment variables
- `lib/main.dart`: Added environment variable loading before Firebase initialization
- `.env`: Contains actual configuration (not committed)
- `.env.example`: Template file (committed to repo)
- `.gitignore`: Updated to ignore `.env` file

## Environment Variables

The following environment variables are used:

### Common across platforms:
- `FIREBASE_MESSAGING_SENDER_ID`
- `FIREBASE_PROJECT_ID` 
- `FIREBASE_AUTH_DOMAIN`
- `FIREBASE_DATABASE_URL`
- `FIREBASE_STORAGE_BUCKET`

### Platform-specific:
- `FIREBASE_API_KEY_WEB`, `FIREBASE_API_KEY_ANDROID`, `FIREBASE_API_KEY_IOS`, `FIREBASE_API_KEY_WINDOWS`
- `FIREBASE_APP_ID_WEB`, `FIREBASE_APP_ID_ANDROID`, `FIREBASE_APP_ID_IOS`, `FIREBASE_APP_ID_WINDOWS`
- `FIREBASE_MEASUREMENT_ID_WEB`, `FIREBASE_MEASUREMENT_ID_WINDOWS`
- `FIREBASE_IOS_BUNDLE_ID`

## Troubleshooting

1. **If you get "Missing environment variable" errors:**
   - Ensure your `.env` file exists in the project root
   - Verify all required environment variables are set
   - Check for typos in variable names

2. **If Firebase initialization fails:**
   - Verify your Firebase configuration values are correct
   - Ensure the `.env` file is properly loaded before Firebase.initializeApp()

3. **For production builds:**
   - Ensure environment variables are properly set in your CI/CD pipeline
   - Consider using different environment files for different environments (e.g., `.env.prod`, `.env.staging`)