#!/bin/bash

# Define thresholds
CPU_THRESHOLD=80
MEMORY_THRESHOLD=80
DISK_THRESHOLD=90
LOG_FILE="/var/log/system_health.log"

# Function to check CPU usage
check_cpu() {
    CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
    if (( $(echo "$CPU_USAGE > $CPU_THRESHOLD" | bc -l) )); then
        echo "$(date): CPU usage is at ${CPU_USAGE}% (Threshold: ${CPU_THRESHOLD}%)" | tee -a $LOG_FILE
    fi
}

# Function to check memory usage
check_memory() {
    MEMORY_USAGE=$(free | grep Mem | awk '{print $3/$2 * 100.0}')
    if (( $(echo "$MEMORY_USAGE > $MEMORY_THRESHOLD" | bc -l) )); then
        echo "$(date): Memory usage is at ${MEMORY_USAGE}% (Threshold: ${MEMORY_THRESHOLD}%)" | tee -a $LOG_FILE
    fi
}

# Function to check disk space
check_disk() {
    DISK_USAGE=$(df / | grep / | awk '{print $5}' | sed 's/%//g')
    if (( $DISK_USAGE > $DISK_THRESHOLD )); then
        echo "$(date): Disk usage is at ${DISK_USAGE}% (Threshold: ${DISK_THRESHOLD}%)" | tee -a $LOG_FILE
    fi
}

# Function to check running processes
check_processes() {
    TOP_PROCESSES=$(ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head -n 6)
    echo "$(date): Top 5 CPU consuming processes:" | tee -a $LOG_FILE
    echo "$TOP_PROCESSES" | tee -a $LOG_FILE
}

# Main function to perform health checks
perform_health_check() {
    echo "$(date): Performing system health check..." | tee -a $LOG_FILE
    check_cpu
    check_memory
    check_disk
    check_processes
    echo "$(date): Health check completed." | tee -a $LOG_FILE
    echo "--------------------------------------------------" | tee -a $LOG_FILE
}

# Run the health check every minute
while true; do
    perform_health_check
    sleep 60
done
