#!/bin/bash

# Build and Run script for Mindfold iOS app
# This script builds the app and runs it on the iOS Simulator

set -e  # Exit on error

# Configuration
SCHEME="Mindfold"
PROJECT_PATH="Mindfold.xcodeproj"
BUNDLE_ID="Evandabest.Mindfold"
PREFERRED_SIMULATOR="iPhone 16 Pro"  # Change this to your preferred simulator (iPhone 16, iPhone 16 Pro, etc.)
BUILD_DIR="build"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Building Mindfold app...${NC}"

# Find available iPhone simulator
echo -e "${BLUE}🔍 Finding available iPhone simulator...${NC}"

# Use xcrun simctl to get available simulators (more reliable than xcodebuild)
# Try to find preferred simulator first
if [ -n "$PREFERRED_SIMULATOR" ]; then
    SIMULATOR_LINE=$(xcrun simctl list devices available | grep "iPhone" | grep "$PREFERRED_SIMULATOR" | head -n 1)
    if [ -n "$SIMULATOR_LINE" ]; then
        SIMULATOR_NAME="$PREFERRED_SIMULATOR"
        SIMULATOR_ID=$(echo "$SIMULATOR_LINE" | grep -o '[0-9A-F]\{8\}-[0-9A-F]\{4\}-[0-9A-F]\{4\}-[0-9A-F]\{4\}-[0-9A-F]\{12\}' | head -n 1)
        echo -e "${GREEN}✅ Using preferred simulator: $SIMULATOR_NAME${NC}"
    else
        echo -e "${YELLOW}⚠️  Preferred simulator '$PREFERRED_SIMULATOR' not found, using first available iPhone...${NC}"
    fi
fi

# If preferred not found or not set, use first available iPhone
if [ -z "$SIMULATOR_NAME" ]; then
    SIMULATOR_LINE=$(xcrun simctl list devices available | grep "iPhone" | head -n 1)
    if [ -n "$SIMULATOR_LINE" ]; then
        # Extract simulator name (format: iPhone 16 (D4E34792-AF59-485F-899C-AA6BADC8CA78) (Available))
        SIMULATOR_NAME=$(echo "$SIMULATOR_LINE" | sed -E 's/^[[:space:]]*([^(]+) \(.*/\1/' | xargs)
        SIMULATOR_ID=$(echo "$SIMULATOR_LINE" | grep -o '[0-9A-F]\{8\}-[0-9A-F]\{4\}-[0-9A-F]\{4\}-[0-9A-F]\{4\}-[0-9A-F]\{12\}' | head -n 1)
        echo -e "${GREEN}✅ Using simulator: $SIMULATOR_NAME${NC}"
    fi
fi

# Final fallback - use xcodebuild destinations if simctl fails
if [ -z "$SIMULATOR_NAME" ]; then
    echo -e "${YELLOW}⚠️  Could not find simulator via simctl, trying xcodebuild destinations...${NC}"
    DESTINATIONS=$(xcodebuild -project "$PROJECT_PATH" -scheme "$SCHEME" -showdestinations 2>/dev/null | grep "iOS Simulator" | grep "iPhone" | grep -v "placeholder")
    if [ -n "$DESTINATIONS" ]; then
        SIMULATOR_DEST=$(echo "$DESTINATIONS" | head -n 1)
        # Extract simulator name from destination string (format: ... name:iPhone 16, ...)
        SIMULATOR_NAME=$(echo "$SIMULATOR_DEST" | sed -E 's/.*name:([^,]+).*/\1/' | xargs)
        SIMULATOR_ID=$(echo "$SIMULATOR_DEST" | grep -o '[0-9A-F]\{8\}-[0-9A-F]\{4\}-[0-9A-F]\{4\}-[0-9A-F]\{4\}-[0-9A-F]\{12\}' | head -n 1)
        echo -e "${GREEN}✅ Using simulator: $SIMULATOR_NAME${NC}"
    fi
fi

# Error if still no simulator found
if [ -z "$SIMULATOR_NAME" ]; then
    echo -e "${YELLOW}❌ Error: No available iPhone simulator found${NC}"
    exit 1
fi

# Clean previous build (optional - comment out if you want incremental builds)
# echo -e "${YELLOW}Cleaning previous build...${NC}"
# xcodebuild clean -project "$PROJECT_PATH" -scheme "$SCHEME" -configuration Debug

# Build the app
echo -e "${BLUE}Building app...${NC}"

# Use ID if available (more reliable), otherwise use name
if [ -n "$SIMULATOR_ID" ]; then
    DESTINATION="platform=iOS Simulator,id=$SIMULATOR_ID"
else
    DESTINATION="platform=iOS Simulator,name=$SIMULATOR_NAME"
fi

xcodebuild build \
    -project "$PROJECT_PATH" \
    -scheme "$SCHEME" \
    -configuration Debug \
    -destination "$DESTINATION" \
    -derivedDataPath "$BUILD_DIR" \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO

# Find the built .app file
APP_PATH=$(find "$BUILD_DIR/Build/Products/Debug-iphonesimulator" -name "*.app" -type d | head -n 1)

if [ -z "$APP_PATH" ]; then
    echo -e "${YELLOW}❌ Could not find built app. Trying alternative path...${NC}"
    APP_PATH=$(find "$BUILD_DIR" -name "Mindfold.app" -type d | head -n 1)
fi

if [ -z "$APP_PATH" ]; then
    echo -e "${YELLOW}❌ Error: Could not find built app file${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Build successful!${NC}"
echo -e "${BLUE}App location: $APP_PATH${NC}"

# Get or boot simulator
echo -e "${BLUE}📱 Setting up simulator...${NC}"

# Check if simulator is already booted
BOOTED_DEVICE=$(xcrun simctl list devices | grep "(Booted)" | head -n 1 | grep -o '[0-9A-F]\{8\}-[0-9A-F]\{4\}-[0-9A-F]\{4\}-[0-9A-F]\{4\}-[0-9A-F]\{12\}' | head -n 1)

if [ -z "$BOOTED_DEVICE" ]; then
    # Use the simulator ID we already found, or find it by name
    if [ -n "$SIMULATOR_ID" ]; then
        DEVICE_UDID="$SIMULATOR_ID"
    else
        # Find available simulator for the device name
        DEVICE_UDID=$(xcrun simctl list devices available | grep "$SIMULATOR_NAME" | head -n 1 | grep -o '[0-9A-F]\{8\}-[0-9A-F]\{4\}-[0-9A-F]\{4\}-[0-9A-F]\{4\}-[0-9A-F]\{12\}' | head -n 1)
        
        if [ -z "$DEVICE_UDID" ]; then
            echo -e "${YELLOW}⚠️  Simulator '$SIMULATOR_NAME' not found. Using first available iPhone simulator...${NC}"
            DEVICE_UDID=$(xcrun simctl list devices available | grep "iPhone" | head -n 1 | grep -o '[0-9A-F]\{8\}-[0-9A-F]\{4\}-[0-9A-F]\{4\}-[0-9A-F]\{4\}-[0-9A-F]\{12\}' | head -n 1)
        fi
    fi
    
    if [ -z "$DEVICE_UDID" ]; then
        echo -e "${YELLOW}❌ Error: No available simulator found${NC}"
        exit 1
    fi
    
    echo -e "${BLUE}Booting simulator $DEVICE_UDID ($SIMULATOR_NAME)...${NC}"
    xcrun simctl boot "$DEVICE_UDID" 2>/dev/null || true
    sleep 2
    BOOTED_DEVICE="$DEVICE_UDID"
else
    echo -e "${GREEN}Simulator already booted${NC}"
fi

# Open Simulator app (if not already open)
open -a Simulator

# Install the app
echo -e "${BLUE}📦 Installing app on simulator...${NC}"
xcrun simctl install "$BOOTED_DEVICE" "$APP_PATH"

# Launch the app
echo -e "${BLUE}🚀 Launching app...${NC}"
xcrun simctl launch "$BOOTED_DEVICE" "$BUNDLE_ID"

echo -e "${GREEN}✅ App launched successfully!${NC}"
echo -e "${GREEN}The app should now be running on the iOS Simulator${NC}"

