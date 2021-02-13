#!/usr/bin/env bash

# Exit immediately with error
set -e

# Load environment
if [ ! -f ".env" ]; then
    echo "Cannot find .env file, aborting ..."
    exit 1
fi
. .env

# Find container
APP_CONTAINER_NAME="${COMPOSE_PROJECT_NAME}_app"
if [ ! "$(docker ps -a | grep $APP_CONTAINER_NAME)" ]; then
        echo "Cannot find app container: ${APP_CONTAINER_NAME}, aborting ...";
        exit 1;
fi

echo "Pulling latest changes ..."
docker-compose pull

echo "Re-creating containers ..."
docker-compose up -d --force-recreate

echo "Deployment started ..."
docker exec $APP_CONTAINER_NAME ./vendor/bin/robo site:update

echo "Deployment done ..."
