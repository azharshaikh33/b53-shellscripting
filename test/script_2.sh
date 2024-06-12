#!/bin/bash

# Script two

# Name of the API endpoint URL
API_URL="http://universities.hipolabs.com/search?country=India"

# Perform HTTP GET request to the API
response=$(curl -s "$API_URL")

# Check if the response is empty
if [ -z "$response" ]; then
    echo "Error: Empty response from the API."
    exit 1
fi

data=$(echo "$response" | jq '.')

# Display the results
echo "API Response:"
echo "$data"