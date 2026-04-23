# SmartNursery YouTube Music Setup Script
# This script helps you set up YouTube Data API integration

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "YouTube Music Setup" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Check if Firebase CLI is installed
$firebaseCheck = Get-Command firebase -ErrorAction SilentlyContinue
if (-not $firebaseCheck) {
    Write-Host "Firebase CLI not found. Please install it first:" -ForegroundColor Red
    Write-Host "   npm install -g firebase-tools"
    exit 1
}

Write-Host "Firebase CLI found" -ForegroundColor Green
Write-Host ""

# Get API Key from user
$apiKey = Read-Host "Enter your YouTube Data API Key"

# Validate input
if ([string]::IsNullOrEmpty($apiKey)) {
    Write-Host "YouTube API Key is required" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Configuring Firebase environment variables..." -ForegroundColor Yellow

# Set environment variables
firebase functions:config:set youtube.api_key="$apiKey"

Write-Host "Environment variables configured!" -ForegroundColor Green
Write-Host ""

# Create .env.local for local development
Write-Host "Creating functions.env.local for local development..." -ForegroundColor Yellow
$envContent = @"
YOUTUBE_API_KEY=$apiKey
"@

$envContent | Out-File -FilePath "functions\.env.local" -Encoding UTF8

Write-Host "functions.env.local created!" -ForegroundColor Green
Write-Host ""

# Install dependencies
Write-Host "Installing Cloud Functions dependencies..." -ForegroundColor Yellow
Set-Location functions
npm install
Set-Location ..

Write-Host "Dependencies installed!" -ForegroundColor Green
Write-Host ""

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Setup Complete!" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Deploy: firebase deploy --only functions" -ForegroundColor White
Write-Host "2. Test: Open app and try music search" -ForegroundColor White
Write-Host ""
