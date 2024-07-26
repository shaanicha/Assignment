#!/bin/bash

# Variables
SOURCE_DIR="/home/username/data"  
S3_BUCKET="my-backup-bucket-2024"  
BACKUP_NAME="backup_$(date +'%Y%m%d%H%M%S').tar.gz"
LOG_FILE="/var/log/backup.log"
EMAIL="chaudharishraddha126@gmail.com"  
HOSTNAME=$(hostname)

# Function to send email notifications
send_email() {
    SUBJECT="$1"
    MESSAGE="$2"
    echo "$MESSAGE" | mail -s "$SUBJECT" $EMAIL
}

# Function to log messages
log_message() {
    MESSAGE="$1"
    echo "$(date): $MESSAGE" | tee -a $LOG_FILE
}

# Function to perform backup
perform_backup() {
    log_message "Starting backup of $SOURCE_DIR to $S3_BUCKET"
    
    tar -czf /tmp/$BACKUP_NAME -C $SOURCE_DIR .
    if [ $? -ne 0 ]; then
        log_message "Error: Failed to create tarball"
        send_email "Backup Failed on $HOSTNAME" "Error: Failed to create tarball of $SOURCE_DIR"
        return 1
    fi

    aws s3 cp /tmp/$BACKUP_NAME s3://$S3_BUCKET/
    if [ $? -ne 0 ]; then
        log_message "Error: Failed to upload backup to S3"
        send_email "Backup Failed on $HOSTNAME" "Error: Failed to upload backup $BACKUP_NAME to S3 bucket $S3_BUCKET"
        rm /tmp/$BACKUP_NAME
        return 1
    fi

    log_message "Backup $BACKUP_NAME successfully uploaded to S3"
    send_email "Backup Successful on $HOSTNAME" "Backup $BACKUP_NAME of $SOURCE_DIR successfully uploaded to S3 bucket $S3_BUCKET"
    
    rm /tmp/$BACKUP_NAME
    return 0
}

# Run the backup function
perform_backup
