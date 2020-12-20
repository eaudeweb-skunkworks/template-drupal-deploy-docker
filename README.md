# A template project to deploy Docker Drupal projects

Deployment recipe for Drupal projects. Used for image-based, non-Kubernetes deployments.

# Deployment

1. Clone the repository
2. Rename `example.docker-compose.override.yml` to `docker-compose.override.yml`
3. Create a new file `drupal-hash-salt-default.txt` and add inside a secret hash, around 80 characters
4. Copy `example.env` to `.env`
5. Enable the proper components in `docker-compose.override.yml` and adjust ports as necessary.
6. Start the stack: `docker-compose up -d`
7. Configure NGINX/Apache on the host to forward traffic to this stack
