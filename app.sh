#!/usr/bin/env bash

. .env

container="${COMPOSE_PROJECT_NAME}_app"
docker exec -ti ${container} bash
