#!/bin/bash

#Prepare database
echo "bootstrap: Prepare database for Tendenci"
apt-get update
apt-get install -y postgresql-client
source /etc/environment
export PGPASSWORD=$db_password
psql -h $db_host -U $db_user -d  $db_name -c "ALTER ROLE $db_user SET client_encoding TO 'UTF8';"
psql -h $db_host -U $db_user -d  $db_name -c "ALTER ROLE $db_user SET default_transaction_isolation TO 'read committed';"
psql -h $db_host -U $db_user -d  $db_name -c "CREATE EXTENSION plpgsql;"
psql -h $db_host -U $db_user -d  $db_name -c "CREATE EXTENSION postgis;"
psql -h $db_host -U $db_user -d  $db_name -c "CREATE EXTENSION postgis_topology;"
psql -h $db_host -U $db_user -d  $db_name -c "CREATE EXTENSION fuzzystrmatch;"
psql -h $db_host -U $db_user -d  $db_name -c "CREATE EXTENSION postgis_tiger_geocoder;"
echo "bootstrap: Database is ready"

#Run Tendenci Installation steps
echo "bootstrap: Running Tendenci Installation steps"
source /srv/mysite/bin/activate
cd /var/www/mysite/
python manage.py initial_migrate
python manage.py deploy
python manage.py load_tendenci_defaults
python manage.py update_dashboard_stats
python manage.py rebuild_index --noinput
echo "bootstrap: Tendency installation complete"

#Initialize directories in EFS
echo "bootstrap: Moving Directories to EFS"
mv /var/www/mysite/media /tendenci/media
mv /var/www/mysite/static /tendenci/static
mv /var/www/mysite/themes /tendenci/themes
mv /var/www/mysite/whoosh_index /tendenci/whoosh_index
echo "Directories Moved"

#Create symbolic links in Django directories
echo "bootstrap: Creating symbolic links"
ln -s /tendenci/media /var/www/mysite/media
ln -s /tendenci/static /var/www/mysite/static
ln -s /tendenci/themes /var/www/mysite/themes
ln -s /tendenci/whoosh_index /var/www/mysite/whoosh_index
echo "bootstrap: Symbolic links created"

#Set the site URL
echo "bootstrap: Setting site URL"
python manage.py set_setting site global siteurl $site_urls
echo "bootstrap: Site URL set"

#Create the django superuser with default credentials
echo "bootstrap: Creating superuser"
echo "from django.contrib.auth import get_user_model; User = get_user_model(); User.objects.create_superuser('admin', 'admin@myproject.com', 'password')" | python manage.py shell
echo "bootstrap: Bootstraping complete!"