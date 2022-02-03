#!/usr/bin/env bash

# Exit immediately with error
set -e

while test $# -gt 0; do
        case "$1" in
                --skip-config-check)
                    SKIP_CONFIG_CHECK="1"
                    shift
                    ;;
                --skip-backup)
                    SKIP_BACKUP="1"
                    shift
                    ;;
                *)
                    break
                    ;;
        esac
done

DEPLOY_TAG="$@"
if [ ! "${DEPLOY_TAG}" ]; then
        echo "Usage: ./deploy-prod.sh [--skip-config-check] <git_tag_name>"
        echo ""
        echo "  --skip-config-check - Deploy when Drupal configuration changes are present"
        echo "                        WARNING: This will override all database changes"
        echo ""
        echo "  --skip-backup       - Do not make a database backup before the deployment"
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

if [ -z "${SKIP_CONFIG_CHECK}" ]; then
        # Test for existing Drupal configuration changes
        echo 'Testing for Drupal configuration changes ...'
        CONFIG_STATUS=$(docker exec "${APP_CONTAINER_NAME}" ./vendor/bin/drush config:status -n 2>&1)
        echo "${CONFIG_STATUS}" | grep -i -q -s "No differences"
        echo "No changes, moving on ..."
else
        echo -e "\033[1;33mWARNING: Skip check for configuration changes\033[0m"
fi

if [ -z "${SKIP_BACKUP}" ]; then
        echo "Doing a database backup ..."
        docker exec $APP_CONTAINER_NAME ./vendor/bin/robo sql:dump
else
        echo -e "\033[1;33mWARNING: Skip database backup\033[0m"
fi

APP_VERSION="${CONTAINER_APP_VERSION}"
echo -e "\033[0;32mCurrent version : $APP_VERSION\033[0m"

# Compute new version
REPO=$(echo "$APP_VERSION" | awk -F: '{print $1}')
APP_VERSION_NEW="${REPO}:${DEPLOY_TAG}"


# Replace new tag in .env
echo -e "\033[0;31mNew version     : ${APP_VERSION_NEW}\033[0m"
sed -i.bak "s+${APP_VERSION}+${APP_VERSION_NEW}+g" .env

echo "Pulling latest changes ..."
docker-compose pull

echo "Re-creating containers ..."
docker-compose up -d --force-recreate

echo "Deployment started ..."
docker exec $APP_CONTAINER_NAME ./vendor/bin/robo site:update

echo "Deployment done ..."
