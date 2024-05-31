#!/usr/bin/env bash

# This script installs dependencies and runs the project
# Run this with root user on Linux Machines(Rocky Linux)

# Start apache
service apache2 start
service apache2 enable

mysql -h $DB_SERVER -u $DB_USERNAME -p$DB_PASSWORD < /var/www/html/bluebirdhotel.sql

cat > /etc/apache2/mods-enabled/dir.conf <<EOF
<IfModule mod_dir.c>
    DirectoryIndex index.php
</IfModule>
EOF

# restart apache
service apache2 start && tail -f /dev/null