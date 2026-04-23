#!/bin/bash

# SmartNursery Spotify Setup Script
# This script helps you set up Spotify integration

set -e

echo "========================================="
echo "🎵 SmartNursery Spotify Setup"
echo "========================================="
echo ""

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    echo "❌ Firebase CLI not found. Please install it first:"
    echo "   npm install -g firebase-tools"
    exit 1
fi

echo "✅ Firebase CLI found"
echo ""

# Get credentials from user
read -p "Enter your Spotify Client ID: " CLIENT_ID
read -sp "Enter your Spotify Client Secret: " CLIENT_SECRET
echo ""

# Validate input
if [ -z "$CLIENT_ID" ] || [ -z "$CLIENT_SECRET" ]; then
    echo "❌ Both Client ID and Secret are required"
    exit 1
fi

echo ""
echo "📝 Configuring Firebase environment variables..."

# Set environment variables
firebase functions:config:set spotify.client_id="$CLIENT_ID" spotify.client_secret="$CLIENT_SECRET"

echo "✅ Environment variables configured!"
echo ""

# Create .env.local for local development
echo "📝 Creating .env.local for local development..."
cat > functions/.env.local << EOF
SPOTIFY_CLIENT_ID=$CLIENT_ID
SPOTIFY_CLIENT_SECRET=$CLIENT_SECRET
EOF

echo "✅ .env.local created (remember: DON'T commit this file!)"
echo ""

# Install dependencies
echo "📦 Installing Cloud Functions dependencies..."
cd functions
npm install
cd ..

echo "✅ Dependencies installed!"
echo ""

echo "========================================="
echo "✅ Setup Complete!"
echo "========================================="
echo ""
echo "Next steps:"
echo "1. Test locally: firebase emulators:start --only functions"
echo "2. Deploy to Firebase: firebase deploy --only functions"
echo "3. In Flutter, remove this line (in your main.dart):"
echo "   FirebaseFunctions.instance.useFunctionsEmulator('localhost', 5001);"
echo ""
echo "See SPOTIFY_SETUP.md for detailed instructions."
