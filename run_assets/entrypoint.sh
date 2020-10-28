#!/bin/bash

source /srv/mysite/bin/activate
cd /var/www/mysite/
python /home/tendenci/retrieve_settings.py

[ -d "/tendenci/static" ] &&  /bin/bash /home/tendenci/symlink.sh
[ ! -d "/tendenci/static" ] && /bin/bash /home/tendenci/bootstrap.sh

if [ "$1" = 'prod' ]; 
then
    /srv/mysite/bin/gunicorn --workers 4 --bind=0.0.0.0:8000 --pid=/run/mysite.pid --pythonpath=/var/www/mysite --access-logfile=/var/log/mysite/access.log --error-logfile=/var/log/mysite/server.log --capture-output conf.wsgi
fi

if [ "$1" = 'dev' ]; 
then
    python manage.py runserver 0.0.0.0:8000
else
    python manage.py $1
fi

