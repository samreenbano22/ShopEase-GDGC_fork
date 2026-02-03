#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

get_db_type() {
    grep "^DATABASE_TYPE=" backend/.env | cut -d'"' -f2 || echo "postgresql"
}

DB_TYPE=$(get_db_type)

get_full_type() {
    local db_type="$1"
    if [ "$db_type" = "pg" ]; then
        echo "postgresql"
    else
        echo "sqlite"
    fi
}

get_db_name() {
    local db_type="$1"
    if [ "$db_type" = "pg" ]; then
        echo "PostgreSQL"
    else
        echo "SQLite"
    fi
}

show_help() {
    echo "🛒 E-commerce App - Run Script"
    echo ""
    echo "Current Database: $DB_TYPE"
    echo ""
    echo "Usage: ./run.sh <command> [db-type]"
    echo ""
    echo "Database Commands:"
    echo "  setup [pg|sqlite]  - Setup database (generates client, migrates, seeds)"
    echo "  dev [pg|sqlite]    - Start both frontend & backend development servers"
    echo "  backend [pg|sqlite]- Start only the backend server"
    echo "  seed [pg|sqlite]   - Seed database with sample products"
    echo "  migrate [pg|sqlite]- Run database migrations"
    echo "  studio [pg|sqlite] - Open Prisma Studio"
    echo ""
    echo "Other Commands:"
    echo "  frontend           - Start only the frontend server"
    echo "  build              - Build for production"
    echo "  start [pg|sqlite]  - Start production server"
    echo "  switch <pg|sqlite> - Switch database type"
    echo "  status             - Show current configuration"
    echo "  help               - Show this help message"
    echo ""
    echo "Current Database Type: $DB_TYPE"
    echo ""
}

switch_db() {
    local new_type="$1"
    if [ "$new_type" != "pg" ] && [ "$new_type" != "sqlite" ]; then
        echo "❌ Invalid database type. Use 'pg' or 'sqlite'"
        exit 1
    fi

    local full_type="$([ "$new_type" = "pg" ] && echo "postgresql" || echo "sqlite")"
    sed -i "s/^DATABASE_TYPE=\".*\"/DATABASE_TYPE=\"$full_type\"/" backend/.env

    echo "✅ Switched to $full_type"
    echo ""
    echo "⚠️  Important: If switching databases, you need to:"
    echo "   1. Run migrations: ./run.sh migrate $new_type"
    echo "   2. Re-seed data: ./run.sh seed $new_type"
    echo ""
}

run_backend_cmd() {
    local cmd="$1"
    local db_type="${2:-$DB_TYPE}"
    local full_type="$([ "$db_type" = "pg" ] && echo "postgresql" || echo "sqlite")"

    cd backend
    DATABASE_TYPE="$full_type" npm run "$cmd"
    cd ..
}

CMD="${1:-}"
DB_ARG="${2:-}"

case "$CMD" in
  setup)
    db_type="${DB_ARG:-$DB_TYPE}"
    db_name=$(get_db_name "$db_type")
    echo "🔧 Setting up $db_name database..."
    run_backend_cmd "setup" "$db_type"
    echo ""
    echo "✅ Database setup complete!"
    ;;
  dev)
    db_type="${DB_ARG:-$DB_TYPE}"
    db_name=$(get_db_name "$db_type")
    echo "🚀 Starting development servers with $db_name..."
    echo ""
    echo "Frontend: http://localhost:5173"
    echo "Backend:  http://localhost:3000"
    echo "Database: $db_name"
    echo ""
    full_type=$(get_full_type "$db_type")
    DATABASE_TYPE="$full_type" npx concurrently "cd backend && npm run dev" "cd frontend && npm run dev"
    ;;
  backend)
    db_type="${DB_ARG:-$DB_TYPE}"
    db_name=$(get_db_name "$db_type")
    echo "🚀 Starting backend server with $db_name..."
    run_backend_cmd "dev" "$db_type"
    ;;
  frontend)
    echo "🚀 Starting frontend server..."
    cd frontend
    npm run dev
    ;;
  build)
    echo "🔨 Building application..."
    echo "Building backend..."
    cd backend
    npm run build
    cd ..
    echo "Building frontend..."
    cd frontend
    npm run build
    cd ..
    echo "✅ Build complete!"
    ;;
  start)
    db_type="${DB_ARG:-$DB_TYPE}"
    db_name=$(get_db_name "$db_type")
    echo "🚀 Starting production server with $db_name..."
    run_backend_cmd "start" "$db_type"
    ;;
  seed)
    db_type="${DB_ARG:-$DB_TYPE}"
    db_name=$(get_db_name "$db_type")
    echo "🌱 Seeding $db_name database..."
    run_backend_cmd "prisma:seed" "$db_type"
    ;;
  migrate)
    db_type="${DB_ARG:-$DB_TYPE}"
    db_name=$(get_db_name "$db_type")
    echo "📦 Running migrations for $db_name..."
    run_backend_cmd "prisma:migrate" "$db_type"
    ;;
  studio)
    db_type="${DB_ARG:-$DB_TYPE}"
    db_name=$(get_db_name "$db_type")
    echo "🎨 Opening Prisma Studio for $db_name..."
    run_backend_cmd "prisma:studio" "$db_type"
    ;;
  switch)
    switch_db "$2"
    ;;
  status)
    echo "📊 Current Configuration"
    echo "======================="
    echo "Database Type: $DB_TYPE"
    echo ""
    if [ "$DB_TYPE" = "postgresql" ]; then
        echo "PostgreSQL URL:"
        grep "^DATABASE_URL=" backend/.env | cut -d'"' -f2
    else
        echo "SQLite Database Path:"
        grep "^SQLITE_DB_PATH=" backend/.env | cut -d'"' -f2
    fi
    echo ""
    ;;
  install)
    echo "📦 Running install script..."
    chmod +x install.sh
    ./install.sh
    ;;
  help|--help|-h)
    show_help
    ;;
  "")
    show_help
    ;;
  *)
    echo "Unknown command: $1"
    show_help
    exit 1
    ;;
esac
