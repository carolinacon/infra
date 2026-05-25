# Pangolin Ansible Role

Ansible role for deploying Pangolin Community Edition with Docker Compose following security best practices.

## Description

This role installs and manages a self-hosted Pangolin deployment using Docker Compose. It handles:

- Installation and configuration of Pangolin Community Edition
- Deployment using Docker Compose with three containers:
  - `pangolin`: Main application container
  - `gerbil`: Supporting service container
  - `traefik`: Reverse proxy with automatic Let's Encrypt SSL
- Security hardening with proper file permissions
- Idempotent deployment that supports upgrades

## Requirements

- Ansible 2.15 or higher
- Docker Engine and Docker Compose plugin (can be installed by role)
- Target host running Debian 12+ or Ubuntu 22.04+

### Required Ansible Collections

```yaml
collections:
  - community.docker
  - ansible.posix
```

Install with:

```bash
ansible-galaxy collection install -r requirements.yaml
```

## Role Variables

### Required Variables

```yaml
pangolin_domain: pangolin.example.com      # Domain for Pangolin (supports wildcards like *.pang.example.com)
pangolin_email: admin@example.com          # Email for Let's Encrypt notifications
```

### Optional Variables

```yaml
pangolin_install_dir: /opt/pangolin                          # Installation directory
pangolin_timezone: UTC                                       # Container timezone
pangolin_uid: 1000                                           # Container user ID
pangolin_gid: 1000                                           # Container group ID

# Docker images
pangolin_pangolin_image: docker.io/fosrl/pangolin
pangolin_pangolin_version: "1.0.0"
pangolin_gerbil_image: docker.io/fosrl/gerbil
pangolin_gerbil_version: "1.0.0"
pangolin_traefik_image: docker.io/library/traefik
pangolin_traefik_version: "v3.1"

# Feature flags
pangolin_enable_auto_updates: false                          # Enable automatic image updates
pangolin_install_docker: false                               # Install Docker (set to true if not present)

# Configuration
pangolin_compose_project_name: pangolin                      # Docker Compose project name
pangolin_log_level: INFO                                     # Application log level
pangolin_container_restart_policy: unless-stopped            # Container restart policy
pangolin_docker_network: pangolin                            # Docker network name

# Ports
pangolin_exposed_ports:
  - "80:80"
  - "443:443"

# Ownership
pangolin_owner: root                                         # File owner
pangolin_group: docker                                       # File group
```

## Dependencies

None.

## Example Playbook

### Basic Usage

```yaml
- hosts: pangolin_servers
  become: true
  roles:
    - role: pangolin
      vars:
        pangolin_domain: pangolin.example.com
        pangolin_email: admin@example.com
```

### With Wildcard Domain

```yaml
- hosts: pangolin_servers
  become: true
  roles:
    - role: pangolin
      vars:
        pangolin_domain: "*.pang.example.com"
        pangolin_email: admin@example.com
        pangolin_install_docker: true
```

### Advanced Configuration

```yaml
- hosts: pangolin_servers
  become: true
  roles:
    - role: pangolin
      vars:
        pangolin_domain: pangolin.example.com
        pangolin_email: admin@example.com
        pangolin_install_dir: /opt/pangolin
        pangolin_pangolin_version: "1.1.0"
        pangolin_timezone: America/New_York
        pangolin_log_level: DEBUG
```

## Security

### File Permissions

The role enforces strict file permissions:

```text
/opt/pangolin                      0750  (root:docker)
/opt/pangolin/config               0750  (root:docker)
/opt/pangolin/config/traefik       0750  (root:docker)
/opt/pangolin/config/db            0750  (root:docker)
/opt/pangolin/config/logs          0750  (root:docker)
/opt/pangolin/config/letsencrypt   0700  (root:docker)
acme.json                          0600  (root:docker)
```

### Security Features

- No privileged containers
- No host network mode
- Read-only mounts where possible
- `no-new-privileges` security option enabled
- TLS 1.2+ only
- Automatic HTTPS redirect
- Security headers middleware
- Let's Encrypt automatic SSL certificates

## Upgrade Strategy

To upgrade Pangolin:

1. Update version variables in your playbook:
   ```yaml
   pangolin_pangolin_version: "1.1.0"
   pangolin_gerbil_version: "1.1.0"
   ```

2. Re-run the playbook:
   ```bash
   ansible-playbook site.yml
   ```

The role will pull new images and restart containers with minimal downtime. Database files and configuration are preserved.

### Rollback

To rollback to a previous version:

1. Set version variables to the previous version
2. Re-run the playbook

## Backup

Important files to backup:

```text
/opt/pangolin/config/db/db.sqlite       # Application database
/opt/pangolin/config/config.yml         # Configuration file
/opt/pangolin/config/letsencrypt/       # SSL certificates
```

Recommended backup strategy:

```bash
tar -czf pangolin-backup-$(date +%Y%m%d).tar.gz /opt/pangolin/config/
```

## Testing

The role supports check mode:

```bash
ansible-playbook site.yml --check
```

## Tags

Available tags:

- `pangolin`: All Pangolin tasks
- `validate`: Validation tasks only
- `docker`: Docker installation only
- `directories`: Directory creation only
- `config`: Configuration tasks only
- `compose`: Docker Compose deployment only

Example:

```bash
ansible-playbook site.yml --tags config
```

## Limitations

This role handles ONLY installation and lifecycle management. It does NOT:

- Configure Pangolin via API
- Manage users, organizations, or sites
- Install or manage Newt agents
- Configure backups
- Manage external DNS
- Configure firewall rules

## Troubleshooting

### Check container status

```bash
cd /opt/pangolin
docker compose ps
docker compose logs
```

### Verify SSL certificates

```bash
ls -la /opt/pangolin/config/letsencrypt/acme.json
```

### Check Traefik configuration

```bash
docker compose exec traefik cat /etc/traefik/traefik.yml
```

### View container logs

```bash
docker compose logs -f pangolin
docker compose logs -f traefik
```

## License

MIT

## Author

elreydetoda
