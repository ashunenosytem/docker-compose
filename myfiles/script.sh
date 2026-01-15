#!/bin/bash

CONTAINER_NAME=$(docker ps --filter "ancestor=mongo:latest" --format "{{.Names}}")          # Matches your service name
DB_NAME="expense_db"    
S3_BUCKET="s3://my-container-mongo-backup/backups/mongo"
TIMESTAMP=$(date +%Y-%m-%d_%H%M%S)
BACKUP_FILENAME="$DB_NAME-$TIMESTAMP.gz"
TEMP_PATH="/tmp/$BACKUP_FILENAME"

echo "[$TIMESTAMP] Starting backup of $DB_NAME..."

# 1. Perform dump using the 'db' service name
# Using --archive and --gzip for efficiency and a single file output
docker exec $CONTAINER_NAME mongodump --db $DB_NAME --archive --gzip > $TEMP_PATH

# Check if the dump was successful
if [ $? -eq 0 ]; then
    echo "Dump successful. Uploading to S3..."
    
    # 2. Upload to S3
    aws s3 cp $TEMP_PATH $S3_BUCKET/$BACKUP_FILENAME

    if [ $? -eq 0 ]; then
        echo "Upload complete: $S3_BUCKET/$BACKUP_FILENAME"
        rm $TEMP_PATH
    else
        echo "Error: S3 upload failed."
        exit 1
    fi
else
    echo "Error: mongodump failed."
    exit 1
fi