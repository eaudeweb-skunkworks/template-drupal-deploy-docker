# A template project to deploy Docker Drupal projects

Deployment recipe for Drupal projects. Used for image-based, non-Kubernetes deployments.

# Usage

1. Clone this repository
2. echo a **HASH OF RANDOM 80 CHARACTERS** > ./var/default/drupal-hash-salt.txt
3. `cp examples/example.env .env` # Customize variables
4. `cp examples/example.app.env .app.env` # Customize variables
5. `docker-compose up`
6. Configure NGINX/Apache on the host to forward traffic to this stack

Notes: 
- When pulling in this repo look for changes the two env files
- `docker-compose.override.yml` is optional and can be used for debugging or extra mounts.

# Notes

* Multiple services can be started using `-f` switch and refer to appropriate YAML files:

```
docker-compose -f docker-compose.yml -f examples/docker-service-cache.yml -f examples/docker-service-db.yml -f examples/docker-service-memcache.yml up
```

Or create file `start.sh` and `stop.sh` wrapper around the command.