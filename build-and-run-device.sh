#!/bin/bash

# Build and Run script for Almanac-clone iOS app on Physical Device
# This script builds the app and runs it on a connected iPhone

set -e  # Exit on error

# Configuration
SCHEME="Almanac-clone"
PROJECT_PATH="Almanac-clone.xcodeproj"
BUNDLE_ID="Evandabest.Almanac-clone"
BUILD_DIR="build"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Building Almanac-clone app for physical device...${NC}"

# Find connected iOS device
echo -e "${BLUE}🔍 Finding connected iOS device...${NC}"

# Use xcrun devicectl or instruments to find devices
DEVICE_INFO=$(xcrun xctrace list devices 2>/dev/null | grep -i "iphone" | grep -v "Simulator" | head -n 1)

if [ -z "$DEVICE_INFO" ]; then
    # Try alternative method
    DEVICE_INFO=$(system_profiler SPUSBDataType 2>/dev/null | grep -A 11 "iPhone\|iPad" | grep "Serial Number" | head -n 1)
fi

# Use xcodebuild to list devices
DEVICES=$(xcodebuild -project "$PROJECT_PATH" -scheme "$SCHEME" -showdestinations 2>/dev/null | grep "iOS Device" | grep -v "Generic")

if [ -z "$DEVICES" ]; then
    echo -e "${RED}❌ Error: No connected iOS device found${NC}"
    echo -e "${YELLOW}Please:${NC}"
    echo -e "  1. Connect your iPhone via USB"
    echo -e "  2. Unlock your iPhone"
    echo -e "  3. Trust this computer if prompted"
    echo -e "  4. Make sure your device appears in Xcode's device list"
    exit 1
fi

# Extract device name and UDID
DEVICE_NAME=$(echo "$DEVICES" | head -n 1 | sed -E 's/.*name:([^,]+).*/\1/' | xargs)
DEVICE_UDID=$(echo "$DEVICES" | head -n 1 | grep -o '[0-9A-F]\{8\}-[0-9A-F]\{4\}-[0-9A-F]\{4\}-[0-9A-F]\{4\}-[0-9A-F]\{12\}' | head -n 1)

if [ -z "$DEVICE_NAME" ]; then
    DEVICE_NAME="iOS Device"
fi

echo -e "${GREEN}✅ Found device: $DEVICE_NAME${NC}"

# Build the app for device
echo -e "${BLUE}Building app for device...${NC}"

if [ -n "$DEVICE_UDID" ]; then
    DESTINATION="platform=iOS,id=$DEVICE_UDID"
else
    DESTINATION="generic/platform=iOS"
fi

# Build with automatic code signing
xcodebuild build \
    -project "$PROJECT_PATH" \
    -scheme "$SCHEME" \
    -configuration Debug \
    -destination "$DESTINATION" \
    -derivedDataPath "$BUILD_DIR" \
    DEVELOPMENT_TEAM="" \
    CODE_SIGN_IDENTITY="Apple Development" \
    CODE_SIGNING_REQUIRED=YES \
    CODE_SIGNING_ALLOWED=YES

# Find the built .app file
APP_PATH=$(find "$BUILD_DIR/Build/Products/Debug-iphoneos" -name "*.app" -type d | head -n 1)

if [ -z "$APP_PATH" ]; then
    echo -e "${YELLOW}❌ Could not find built app. Trying alternative path...${NC}"
    APP_PATH=$(find "$BUILD_DIR" -name "Almanac-clone.app" -type d | head -n 1)
fi

if [ -z "$APP_PATH" ]; then
    echo -e "${RED}❌ Error: Could not find built app file${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Build successful!${NC}"
echo -e "${BLUE}App location: $APP_PATH${NC}"

# Install and run using xcodebuild
echo -e "${BLUE}📦 Installing and launching app on device...${NC}"

xcodebuild \
    -project "$PROJECT_PATH" \
    -scheme "$SCHEME" \
    -configuration Debug \
    -destination "$DESTINATION" \
    -derivedDataPath "$BUILD_DIR" \
    DEVELOPMENT_TEAM="" \
    CODE_SIGN_IDENTITY="Apple Development" \
    CODE_SIGNING_REQUIRED=YES \
    CODE_SIGNING_ALLOWED=YES \
    install

echo -e "${GREEN}✅ App installed successfully!${NC}"
echo -e "${YELLOW}Note: If this is the first time, you may need to:${NC}"
echo -e "  1. Go to Settings > General > VPN & Device Management on your iPhone"
echo -e "  2. Trust your developer certificate"
echo -e "  3. Then launch the app from your home screen"

