# Next.js + Strapi + Postgres + Nginx + Certbot Docker Boilerplate

This archive scaffolds a reusable client website stack for deployment on a fresh Ubuntu VPS.

Folders of interest:

- deploy/: helper scripts to install docker, scaffold a project, seed Strapi, and start the stack.
- cms/: Strapi application scaffold (schemas, components, bootstrap seeder).
- frontend/: Next.js frontend scaffold.
- nginx/: nginx conf for reverse proxy and ACME challenge.
- docker-compose.yml & docker-compose.override.yml: compose stacks (edit {DOMAIN} placeholders).

Quickstart (example, run as root or with sudo where noted):

1. Run `deploy/00-install-deps.sh` to install Docker & Compose plugin.
2. Run `sudo ./deploy/01-generate-project.sh example.com` to scaffold under `/var/www/example.com`.
3. Edit credentials and confirm docker-compose.yml values.
4. Run `sudo ./deploy/02-seed-strapi.sh /var/www/example.com` to copy seeder into the cms folder.
5. Run `sudo ./deploy/03-start-stack.sh /var/www/example.com` to build & start.

Notes:

- Replace placeholder passwords and secrets in docker-compose.yml before production.
- Review certbot/init command and set the real email and domain.
- This is a boilerplate. Test and adjust to match Strapi and Next.js versions in use.
