# template-drupal-docker

Deployment recipe for Drupal projects. Used for image-based, non-Kubernetes deployments.

# Usage

1. Clone this repository
2. echo "SECURE HASH OF RANDOM 80 CHARACTERS LONG" > ./var/default/drupal-hash-salt.txt
3. `cp example.env .env` # Customize variables
4. `cp example.app.env .app.env` # Customize variables
5. `docker-compose up`

Note: Future updates means to git pull changes and look into the two files for changes.