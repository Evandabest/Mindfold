# API Configuration Guide

## Setting the API Base URL

The app supports multiple ways to configure the API base URL:

### Method 1: Environment Variable (Recommended for Development)

Set the `API_BASE_URL` environment variable when running the app:

**In Xcode:**
1. Go to Product → Scheme → Edit Scheme
2. Select "Run" in the left sidebar
3. Go to the "Arguments" tab
4. Under "Environment Variables", click "+"
5. Add:
   - Name: `API_BASE_URL`
   - Value: `http://localhost:6000` (or your API URL)

**From Command Line:**
```bash
export API_BASE_URL=http://localhost:6000
# Then run your app
```

### Method 2: Info.plist (For Production)

Add to your Info.plist:
```xml
<key>API_BASE_URL</key>
<string>http://your-api-url.com</string>
```

### Default

If neither is set, the app defaults to `http://localhost:6000`

## App Transport Security (ATS)

For iOS Simulator, HTTP connections to `localhost` typically work without additional configuration.

If you need to allow HTTP connections to other hosts (for testing on real devices or different hosts), you'll need to add App Transport Security exceptions in Info.plist:

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsLocalNetworking</key>
    <true/>
    <key>NSExceptionDomains</key>
    <dict>
        <key>localhost</key>
        <dict>
            <key>NSExceptionAllowsInsecureHTTPLoads</key>
            <true/>
        </dict>
    </dict>
</dict>
```

## Testing

Make sure your Flask backend is running on `localhost:6000` before testing the Shikaku game.

