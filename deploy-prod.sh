#!/usr/bin/env bash

# Exit immediately with error
set -e

DEPLOY_TAG="$@"
if [ ! "${DEPLOY_TAG}" ]; then
        echo "Usage: ./deploy-prod.sh <git_tag_name>"
        exit 1;
fi

# Load environment
if [ ! -f ".env" ]; then
    echo "Cannot find .env file, aborting ..."
    exit 1
fi
. .env

# Find the app container
APP_CONTAINER_NAME="${COMPOSE_PROJECT_NAME}_app"
if [ ! "$(docker ps -a | grep $APP_CONTAINER_NAME)" ]; then
        echo "Cannot find app container: ${APP_CONTAINER_NAME}, aborting ...";
        exit 1;
fi

# Test for existing changes
echo 'Testing for Drupal configuration changes ...'
CONFIG_STATUS=$(docker exec -ti "${APP_CONTAINER_NAME}" ./vendor/bin/drush config:status -n)
echo "$CONFIG_STATUS"
echo "$CONFIG_STATUS" | grep -q "No differences"
echo $?

echo "No changes, moving on ..."
APP_VERSION="${CONTAINER_APP_VERSION}"
echo "Current app version: $APP_VERSION ..."

# Compute new version
REPO=$(echo "$APP_VERSION" | awk -F: '{print $1}')
APP_VERSION_NEW="${REPO}:${DEPLOY_TAG}"

echo "Doing a database backup ..."
docker exec $APP_CONTAINER_NAME ./vendor/bin/robo sql:dump

# Replace new tag in .env
echo "Setting new version in .env: ${APP_VERSION_NEW}"
sed -i.bak "s+${APP_VERSION}+${APP_VERSION_NEW}+g" .env

echo "Pulling latest changes ..."
docker-compose pull

echo "Re-creating containers ..."
docker-compose up -d --force-recreate

echo "Deployment started ..."
docker exec $APP_CONTAINER_NAME ./vendor/bin/robo site:update

echo "Deployment done ..."
