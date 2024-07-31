#!/bin/bash

# Function to display help message
show_help() {
    echo "Usage: $0 [-h|--help] [-i|--input <input_file>] [-o|--output <output_file>]"
    echo ""
    echo "Options:"
    echo "  -h, --help        Show this help message and exit"
    echo "  -i, --input       Input file with a list of domain names (default: domains.txt)"
    echo "  -o, --output      Output file to write the results (default: output.txt)"
}

# Default input and output files
input_file="domains.txt"
output_file="output.txt"

# Parse command-line arguments
while [[ "$1" != "" ]]; do
    case $1 in
        -h | --help )   show_help
                        exit 0
                        ;;
        -i | --input )  shift
                        input_file="$1"
                        ;;
        -o | --output ) shift
                        output_file="$1"
                        ;;
        * )             echo "Unknown option: $1"
                        show_help
                        exit 1
                        ;;
    esac
    shift
done

# Check if the input file exists
if [[ ! -f "$input_file" ]]; then
    echo "Input file $input_file not found!"
    exit 1
fi

# Create or clear the output file
> "$output_file"

# Read the input file line by line
while IFS= read -r domain; do
    # Perform DNS lookup and filter for IPv4 addresses
    result=$(nslookup -query=A "$domain" 2>/dev/null)
    
    # Check if the lookup was successful
    if [[ $? -eq 0 ]]; then
        # Extract the relevant information from the nslookup output
        ip=$(echo "$result" | grep 'Address:' | grep -v '#' | awk '{print $2}')
        
        # If IP is not found, set to "No A record"
        if [[ -z $ip ]]; then
            ip="No A record"
        fi
    else
        ip="Lookup failed"
    fi
    
    # Write the result to the output file
    echo "$domain -> $ip" >> "$output_file"
done < "$input_file"

echo "DNS lookup completed. Results saved to $output_file"

