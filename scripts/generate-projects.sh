#!/bin/bash

# Generate Xcode projects for Famous Peers

set -e

echo "🔨 Generating Famous Peers Xcode projects..."

# Check if xcodegen is installed
if ! command -v xcodegen &> /dev/null; then
    echo "❌ xcodegen not found. Install it with: brew install xcodegen"
    exit 1
fi

# Generate iOS project
echo "📱 Generating iOS project..."
cd FamousPeersIOS
xcodegen generate
cd ..

# Generate tvOS project
echo "📺 Generating tvOS project..."
cd FamousPeersTVOS
xcodegen generate
cd ..

echo "✅ Projects generated successfully!"
echo ""
echo "Next steps:"
echo "  iOS:  open FamousPeersIOS/FamousPeersIOS.xcodeproj"
echo "  tvOS: open FamousPeersTVOS/FamousPeersTVOS.xcodeproj"
