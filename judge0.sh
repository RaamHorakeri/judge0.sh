#!/bin/bash

set -e

# Function to check and install required packages
install_if_missing() {
    if ! command -v "$1" &> /dev/null; then
        echo "$1 not found. Installing..."
        sudo apt update && sudo apt install -y "$1"
    else
        echo "$1 is already installed."
    fi
}

# Check required tools
install_if_missing unzip
install_if_missing openssl

# Check for Docker
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker and try again."
    exit 1
fi

# Check for Docker Compose plugin
if ! docker compose version &> /dev/null; then
    echo "❌ Docker Compose plugin not found. Please install Docker Compose v2+."
    exit 1
fi

# Download and unzip
ZIP_URL="https://github.com/judge0/judge0/releases/download/v1.13.1/judge0-v1.13.1.zip"
ZIP_FILE="judge0-v1.13.1.zip"

echo "📦 Downloading Judge0 release..."
if [ ! -f "$ZIP_FILE" ]; then
    wget -q "$ZIP_URL"
else
    echo "📄 Zip file already exists: $ZIP_FILE"
fi

echo "📂 Extracting Judge0 (overwrite existing)..."
unzip -o -q "$ZIP_FILE"

# Move into extracted directory
JUDGE0_DIR=$(unzip -Z1 "$ZIP_FILE" | head -n1 | cut -d/ -f1)
cd "$JUDGE0_DIR"

# Step 3: Handle configuration file
if [ -f judge0.conf.example ]; then
    echo "📄 Found judge0.conf.example, creating judge0.conf..."
    cp judge0.conf.example judge0.conf
elif [ -f judge0.conf ]; then
    echo "📄 judge0.conf already exists. Using it as is."
else
    echo "❌ No judge0.conf or judge0.conf.example found!"
    echo "Please check the contents of the extracted directory."
    exit 1
fi

# Step 4: Generate random passwords
REDIS_PASSWORD=$(openssl rand -base64 12)
POSTGRES_PASSWORD=$(openssl rand -base64 16)

echo "🔑 Generated Redis Password: $REDIS_PASSWORD"
echo "🔑 Generated Postgres Password: $POSTGRES_PASSWORD"

# Step 5: Update config with passwords (safe delimiter)
sed -i "s|^REDIS_PASSWORD=.*|REDIS_PASSWORD=${REDIS_PASSWORD}|" judge0.conf
sed -i "s|^POSTGRES_PASSWORD=.*|POSTGRES_PASSWORD=${POSTGRES_PASSWORD}|" judge0.conf

# Step 6: Start Docker services
echo "🚀 Starting db and redis services..."
docker compose up -d db redis

echo "⏳ Waiting 10 seconds for services to initialize..."
sleep 10s

echo "🚀 Starting all remaining services..."
docker compose up -d

echo "⏳ Waiting 5 seconds for final initialization..."
sleep 5s

# ✅ Success Message
echo -e "\n✅ Judge0 is up and running!"
echo "----------------------------------------"
echo "🔐 Redis Password:    $REDIS_PASSWORD"
echo "🔐 Postgres Password: $POSTGRES_PASSWORD"
echo "📁 Directory:         $(pwd)"
echo "🧪 Test with:         docker compose logs api"
echo "----------------------------------------"
