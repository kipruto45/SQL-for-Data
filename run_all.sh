#!/bin/bash
set -e

# SQL Pipeline Runner
# This script runs the complete SQL data engineering pipeline

echo "Starting SQL pipeline..."
echo "Database: $DB_NAME at $DB_HOST:$DB_PORT"

# Add your SQL initialization and pipeline commands below
# Example: psql -h $DB_HOST -U $DB_USER -d $DB_NAME -f sql/init.sql

echo "SQL pipeline completed successfully!"