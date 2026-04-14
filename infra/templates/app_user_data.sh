#!/bin/bash
set -e

# Install web server and MySQL client for DB connectivity validation
dnf install -y nginx mariadb105

# Create health check page
cat > /usr/share/nginx/html/index.html <<HTML
<html>
  <body>
    <h1>App Layer</h1>
    <p>Instance: $(hostname)</p>
  </body>
</html>
HTML

# Validate DB connectivity and log result
DB_CHECK=$(mysql -h ${db_endpoint} -P ${db_port} -u ${db_username} --connect-timeout=5 -e "SELECT 1;" 2>&1 && echo "SUCCESS" || echo "FAILED")
echo "$(date) DB connectivity check: $DB_CHECK" >> /var/log/db-connectivity.log

# Enable and start nginx
systemctl enable nginx
systemctl start nginx
