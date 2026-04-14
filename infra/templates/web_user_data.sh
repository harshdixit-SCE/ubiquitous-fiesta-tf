#!/bin/bash
set -e

# Install web server
dnf install -y nginx

# Configure nginx to proxy traffic to the app layer ALB
cat > /etc/nginx/conf.d/app-proxy.conf <<NGINX
server {
    listen 80;
    server_name _;

    location /health {
        return 200 'Web layer healthy';
        add_header Content-Type text/plain;
    }

    location / {
        proxy_pass http://${app_alb_dns};
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}
NGINX

# Remove default config to avoid conflict
rm -f /etc/nginx/conf.d/default.conf

# Enable and start nginx
systemctl enable nginx
systemctl start nginx
