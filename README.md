# A template project to deploy Docker Drupal projects

Deployment recipe for Drupal projects. Used for image-based, non-Kubernetes deployments.

# Usage

1. Clone this repository
2. echo a **HASH OF RANDOM 80 CHARACTERS** > ./var/default/drupal-hash-salt.txt
3. `cp etc/example.env .env` # Customize variables
4. `cp etc/example.app.env .app.env` # Customize variables
5. `cp etc/docker-compose.override.yml docker-compose.override.yml`
6. `docker-compose up`
7. Configure NGINX/Apache on the host to forward traffic to this stack

Notes: 
- When pulling in this repo look for changes the two env files
- `docker-compose.override.yml` is optional and can be used for debugging or extra mounts.


# Accessing docker as non-root

If you need to execute the commands using `sudo`, you can create a file to enable sudo without password in `/etc/sudoers.d/drupal-deploy-project`

```
ALL ALL = NOPASSWD:/path/to/project/folder/deploy-test.sh
ALL ALL = NOPASSWD:/path/to/project/folder/deploy-prod.sh
ALL ALL = NOPASSWD:/path/to/project/folder/sql-dump.sh
```


# Notes

* Multiple services can be started using `-f` switch and refer to appropriate YAML files:

```
docker-compose -f docker-compose.yml -f etc/service.cache.yml -f etc/service.db.yml -f etc/service.memcache.yml up
```

Or create file `start.sh` and `stop.sh` wrapper around the command.


# Host new project using this repository

1. The hosted Drupal project must have the actions configured, see https://github.com/eaudeweb-skunkworks/template-drupal-deploy-docker
2. Create a new Docker HUB repository to host images
3. Configure secrets in the Drupal repository, i.e. https://github.com/ORG/PROJECT/settings/secrets/actions: `DOCKERHUB_REPOSITORY`, `DOCKERHUB_TOKEN`, `DOCKERHUB_USERNAME`
4. Merge to `test` to create test image, add a new tag to create `prod` image