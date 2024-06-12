#!/bin/bash

# Name and path of the CSV file
CSV_FILE="users_data.csv"

# Read the CSV file and filter users by department
while IFS=, read -r name email department; do
    case "$department" in
        "Finance"|"IT")
            echo "User: $name"
            ;;
        *)
            # Ignore other departments
            ;;
    esac
done < "$CSV_FILE"