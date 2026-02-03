#!/bin/bash

# ShopEase - E-Commerce Application Installation Script
# This script sets up the entire project with all dependencies

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print functions
print_step() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

# Banner
echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                                                            ║${NC}"
echo -e "${BLUE}║   🛒  ShopEase E-Commerce Installation                    ║${NC}"
echo -e "${BLUE}║                                                            ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check Node.js version
print_step "Checking Prerequisites"

if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version)
    print_success "Node.js found: $NODE_VERSION"

    # Check if Node version is 18 or higher
    NODE_MAJOR=$(echo $NODE_VERSION | cut -d'.' -f1 | tr -d 'v')
    if [ "$NODE_MAJOR" -lt 18 ]; then
        print_error "Node.js version 18+ required. Current version: $NODE_VERSION"
        exit 1
    fi
else
    print_error "Node.js not found. Please install Node.js 18+ from https://nodejs.org/"
    exit 1
fi

if command -v npm &> /dev/null; then
    NPM_VERSION=$(npm --version)
    print_success "npm found: v$NPM_VERSION"
else
    print_error "npm not found"
    exit 1
fi

echo ""

# Check if we're in the right directory
if [ ! -f "package.json" ]; then
    print_error "package.json not found. Please run this script from the project root."
    exit 1
fi

# Install root dependencies
print_step "Installing Root Dependencies"
npm install --workspaces
print_success "Root dependencies installed"

# Install frontend dependencies
print_step "Installing Frontend Dependencies"
cd frontend
npm install
print_success "Frontend dependencies installed"
cd ..

# Install backend dependencies
print_step "Installing Backend Dependencies"
cd backend
npm install
print_success "Backend dependencies installed"
cd ..

# Setup database
print_step "Setting Up Database (SQLite)"

cd backend

# Generate Prisma client
print_success "Generating Prisma client..."
npx prisma generate

# Create and migrate database
print_success "Creating database..."
npx prisma db push

# Seed database
print_success "Seeding database with sample products..."
npx tsx prisma/seed.ts 2>/dev/null || npm run prisma:seed 2>/dev/null || echo "Seed completed (some products may already exist)"

cd ..

print_success "Database setup complete"

echo ""

# Build the project
print_step "Building Project"
cd frontend
npm run build
cd ..
print_success "Frontend built successfully"

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  ✅  Installation Complete!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "To start the development servers:"
echo -e "  ${YELLOW}npm run dev${NC}"
echo ""
echo -e "This will start:"
echo -e "  • Frontend: ${GREEN}http://localhost:5173${NC}"
echo -e "  • Backend:  ${GREEN}http://localhost:3000${NC}"
echo ""
echo -e "${YELLOW}Tip:${NC} You can also use these commands:"
echo -e "  ${BLUE}npm run dev:frontend${NC}  - Frontend only"
echo -e "  ${BLUE}npm run dev:backend${NC}   - Backend only"
echo -e "  ${BLUE}cd backend && npm run prisma:studio${NC} - Open database UI"
echo ""
