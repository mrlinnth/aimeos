#!/bin/bash
set -e

echo "Generating .env from .env.example template..."

EXAMPLE_FILE="/var/www/html/.env.example"
ENV_FILE="/var/www/html/.env"

while IFS= read -r line || [[ -n "$line" ]]; do
    # Pass through comments and blank lines unchanged
    if [[ "$line" =~ ^[[:space:]]*# || -z "$line" ]]; then
        echo "$line"
        continue
    fi

    # Extract the key (everything before the first =)
    key="${line%%=*}"

    # If the container has an env var for this key, use it; else keep the .env.example default
    if [[ -v "$key" ]]; then
        value="${!key}"
        # Quote values containing whitespace
        if [[ "$value" =~ [[:space:]] ]]; then
            printf '%s="%s"\n' "$key" "$value"
        else
            printf '%s=%s\n' "$key" "$value"
        fi
    else
        echo "$line"
    fi
done < "$EXAMPLE_FILE" > "$ENV_FILE"

echo "Generated .env file"
