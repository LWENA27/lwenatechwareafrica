#!/bin/bash

# Lwena TechWareAfrica Website - Quick Setup Script
# This script will install dependencies and start the development server

echo "🚀 Lwena TechWareAfrica Website Setup"
echo "======================================"
echo ""

# Check if Node.js is installed
if ! command -v node &> /dev/null
then
    echo "❌ Node.js is not installed. Please install Node.js 18+ first."
    echo "Visit: https://nodejs.org/"
    exit 1
fi

echo "✅ Node.js version: $(node --version)"
echo "✅ npm version: $(npm --version)"
echo ""

# Navigate to project directory
cd "$(dirname "$0")"

echo "📦 Installing dependencies..."
echo "This may take a few minutes on first run..."
echo ""

npm install

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Installation successful!"
    echo ""
    echo "🎉 Setup complete!"
    echo ""
    echo "To start the development server, run:"
    echo "  cd next-app"
    echo "  npm run dev"
    echo ""
    echo "Then visit: http://localhost:3000"
    echo ""
    echo "📚 Documentation:"
    echo "  - README.md - Project overview"
    echo "  - SETUP_GUIDE.md - Detailed setup guide"
    echo "  - PROJECT_SUMMARY.md - Complete summary"
    echo ""
    echo "Happy coding! 🎨"
else
    echo ""
    echo "❌ Installation failed. Please check the error messages above."
    exit 1
fi
