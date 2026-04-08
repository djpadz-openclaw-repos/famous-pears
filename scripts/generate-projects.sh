#!/bin/bash

# Generate Xcode projects for Famous Pears

set -e

echo "🔨 Generating Famous Pears Xcode projects..."

# Check if xcodegen is installed
if ! command -v xcodegen &> /dev/null; then
    echo "❌ xcodegen not found. Install it with: brew install xcodegen"
    exit 1
fi

# Generate iOS project
echo "📱 Generating iOS project..."
cd FamousPearsIOS
xcodegen generate
cd ..

# Generate tvOS project
echo "📺 Generating tvOS project..."
cd FamousPearsTVOS
xcodegen generate
cd ..

echo "✅ Projects generated successfully!"
echo ""
echo "Next steps:"
echo "  iOS:  open FamousPearsIOS/FamousPearsIOS.xcodeproj"
echo "  tvOS: open FamousPearsTVOS/FamousPearsTVOS.xcodeproj"
