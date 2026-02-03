#!/bin/bash

# ShopEase - Quick Start Script
# Starts both frontend and backend development servers

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo ""
echo -e "${YELLOW}🛒 Starting ShopEase Development Servers...${NC}"
echo ""

# Check if already running
if lsof -i :3000 &> /dev/null; then
    echo -e "${YELLOW}⚠ Backend already running on port 3000${NC}"
else
    echo "Starting backend..."
    cd backend && npm run dev:sqlite &
fi

if lsof -i :5173 &> /dev/null; then
    echo -e "${YELLOW}⚠ Frontend already running on port 5173${NC}"
else
    echo "Starting frontend..."
    cd frontend && npm run dev &
fi

echo ""
echo -e "${GREEN}✅ Servers starting...${NC}"
echo ""
echo "Access:"
echo "  • Frontend: http://localhost:5173"
echo "  • Backend:  http://localhost:3000"
echo ""
echo "Press Ctrl+C to stop all servers"
echo ""

wait
