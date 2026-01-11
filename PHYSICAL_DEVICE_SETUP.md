# Building and Running on Physical iPhone

## Method 1: Using Xcode (Easiest)

1. **Connect your iPhone** to your Mac via USB cable
2. **Unlock your iPhone** and trust the computer if prompted
3. **Open the project in Xcode**:
   ```bash
   open Mindfold.xcodeproj
   ```
4. **Select your device**:
   - At the top of Xcode, click the device selector (next to the scheme)
   - Choose your connected iPhone from the list
5. **Configure Signing**:
   - Click on the project in the navigator
   - Select the "Mindfold" target
   - Go to "Signing & Capabilities" tab
   - Check "Automatically manage signing"
   - Select your Team (your Apple ID)
6. **Build and Run**:
   - Press `Cmd + R` or click the Play button
   - Xcode will build and install the app on your device

## Method 2: Using Command Line Script

Use the provided `build-and-run-device.sh` script (see below).

## First Time Setup

When you first install an app on your iPhone:

1. After installation, go to **Settings > General > VPN & Device Management** (or **Device Management**)
2. Tap on your developer certificate (your name/email)
3. Tap **Trust** and confirm

## Troubleshooting

- **"No devices found"**: Make sure your iPhone is unlocked and you've trusted the computer
- **Code signing errors**: Make sure you have a valid Apple ID added in Xcode (Preferences > Accounts)
- **"Untrusted Developer"**: Follow the "First Time Setup" steps above
- **Build fails**: Check that your iPhone's iOS version is compatible (iOS 18.2+)

