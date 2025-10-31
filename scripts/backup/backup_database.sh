#!/bin/bash

# Automated Supabase Database Backup Script
# This script creates a backup of the Supabase database

set -e

# Configuration
BACKUP_DIR="${BACKUP_DIR:-./backups}"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="supabase_backup_${TIMESTAMP}.sql"

# Supabase credentials (set these as environment variables)
SUPABASE_PROJECT_REF="${SUPABASE_PROJECT_REF:-}"
SUPABASE_DB_PASSWORD="${SUPABASE_DB_PASSWORD:-}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."
    
    if ! command -v pg_dump &> /dev/null; then
        log_error "pg_dump not found. Please install PostgreSQL client tools."
        exit 1
    fi
    
    if [ -z "$SUPABASE_PROJECT_REF" ]; then
        log_error "SUPABASE_PROJECT_REF environment variable is not set."
        exit 1
    fi
    
    if [ -z "$SUPABASE_DB_PASSWORD" ]; then
        log_error "SUPABASE_DB_PASSWORD environment variable is not set."
        exit 1
    fi
    
    log_info "Prerequisites check passed."
}

# Create backup directory
create_backup_dir() {
    if [ ! -d "$BACKUP_DIR" ]; then
        log_info "Creating backup directory: $BACKUP_DIR"
        mkdir -p "$BACKUP_DIR"
    fi
}

# Perform backup
perform_backup() {
    log_info "Starting database backup..."
    
    local db_host="db.${SUPABASE_PROJECT_REF}.supabase.co"
    local db_port="5432"
    local db_name="postgres"
    local db_user="postgres"
    local backup_path="${BACKUP_DIR}/${BACKUP_FILE}"
    
    # Export password for pg_dump
    export PGPASSWORD="$SUPABASE_DB_PASSWORD"
    
    # Perform backup
    pg_dump \
        -h "$db_host" \
        -p "$db_port" \
        -U "$db_user" \
        -d "$db_name" \
        --no-owner \
        --no-acl \
        --clean \
        --if-exists \
        -f "$backup_path"
    
    # Unset password
    unset PGPASSWORD
    
    if [ $? -eq 0 ]; then
        log_info "Backup completed successfully: $backup_path"
        
        # Compress backup
        log_info "Compressing backup..."
        gzip "$backup_path"
        log_info "Backup compressed: ${backup_path}.gz"
        
        # Get file size
        local file_size=$(du -h "${backup_path}.gz" | cut -f1)
        log_info "Backup size: $file_size"
    else
        log_error "Backup failed!"
        exit 1
    fi
}

# Clean old backups (keep last 7 days)
cleanup_old_backups() {
    log_info "Cleaning up old backups (keeping last 7 days)..."
    
    find "$BACKUP_DIR" -name "supabase_backup_*.sql.gz" -type f -mtime +7 -delete
    
    local remaining=$(ls -1 "$BACKUP_DIR"/supabase_backup_*.sql.gz 2>/dev/null | wc -l)
    log_info "Remaining backups: $remaining"
}

# Generate backup metadata
generate_metadata() {
    log_info "Generating backup metadata..."
    
    local metadata_file="${BACKUP_DIR}/backup_metadata_${TIMESTAMP}.json"
    
    cat > "$metadata_file" << EOF
{
  "timestamp": "$(date -Iseconds)",
  "backup_file": "${BACKUP_FILE}.gz",
  "project_ref": "${SUPABASE_PROJECT_REF}",
  "script_version": "1.0.0"
}
EOF
    
    log_info "Metadata saved: $metadata_file"
}

# Main execution
main() {
    log_info "Starting Supabase backup process..."
    
    check_prerequisites
    create_backup_dir
    perform_backup
    generate_metadata
    cleanup_old_backups
    
    log_info "Backup process completed successfully!"
}

# Run main function
main
