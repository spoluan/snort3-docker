#!/bin/sh
# author="Sevendi Eldrige Rifki Poluan"

# Define Docker Compose version
DOCKER_COMPOSE_VERSION="1.29.2"

# Variables to determine whether to reinstall Docker, Docker Compose, and dos2unix
REINSTALL_DOCKER=false
REINSTALL_DOCKER_COMPOSE=false
REINSTALL_DOS2UNIX=false

# Check if Docker is installed
if command -v docker &> /dev/null
then
    echo "Docker is installed."
else
    echo "Docker is not installed. Installing..."
    REINSTALL_DOCKER=true
fi

# Check if Docker Compose is installed
if command -v docker-compose &> /dev/null
then
    echo "Docker compose is installed."
else
    echo "Docker Compose is not installed. Installing..."
    REINSTALL_DOCKER_COMPOSE=true
fi

# Check if dos2unix is installed
if command -v dos2unix &> /dev/null
then
    echo "Dos2Unix is installed."
else
    echo "dos2unix is not installed. Installing..."
    REINSTALL_DOS2UNIX=true
fi

# Install Docker if required
if [ "$REINSTALL_DOCKER" = true ]
then
    apt install docker.io -y
fi

# Install Docker Compose if required
if [ "$REINSTALL_DOCKER_COMPOSE" = true ]
then
    curl -L "https://github.com/docker/compose/releases/download/$DOCKER_COMPOSE_VERSION/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
fi

# Install dos2unix if required
if [ "$REINSTALL_DOS2UNIX" = true ]
then
    apt install dos2unix -y
fi

# Run dos2unix on all *.sh files in subfolders
echo "Run dos2unix on all *.sh files in subfolders"
find . -type f -name "*.sh" -exec dos2unix {} \;

# Change mode executable
find . -type f -name "*.sh" -exec chmod +x {} \;

# Build and start Docker Compose services
docker-compose -f docker-compose.yml build 
docker-compose -f docker-compose.yml up -d

echo "Done"
