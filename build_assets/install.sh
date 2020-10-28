#! /usr/bin/bash -x

#Make sure Ubuntu is up to date
apt update -y
apt dist-upgrade -y

#Install Dependencies
apt install -y build-essential \
  libevent-dev libpq-dev \
  libjpeg8 libjpeg-dev libfreetype6 libfreetype6-dev
apt install -y binutils libproj-dev gdal-bin

#Install Python 3.7
apt-get install -y software-properties-common
add-apt-repository -y universe
add-apt-repository -y ppa:deadsnakes/ppa
apt update
apt install -y python3.7
apt install -y python3.7-dev --upgrade
apt-get install -y python3-distutils
curl "https://bootstrap.pypa.io/get-pip.py" | python3.7

#Create VirtualENV
apt-get install -y virtualenv
mkdir -p /srv
chown "$(id -u -n)" /srv/
cd /srv/
python3.7 -m virtualenv -p python3.7 mysite
chown root /srv/

source /srv/mysite/bin/activate

apt-get install -y git

git clone https://github.com/tendenci/tendenci.git /home/tendenci/tendenci
pip install /home/tendenci/tendenci
# pip install tendenci

mkdir /var/www/
chown "$(id -u -n)" /var/www/
cd /var/www/
tendenci startproject mysite mysite
chown root /var/www/

chmod -R -x+X /var/www/mysite/media/
mkdir /var/log/mysite
chown "$(id -u -n)": /var/log/mysite/

cd /var/www/mysite/
pip install -r requirements/dev.txt --upgrade

mkdir /var/www/mysite/themes/tendenci2020
cp -r /srv/mysite/lib/python3.7/site-packages/tendenci/themes/t7-tendenci2020/* /var/www/mysite/themes/tendenci2020/

#Verify permissions
chmod -R o+rX-w /srv/mysite/
chgrp -Rh www-data /var/www/mysite/
chmod -R -x+X,g-w,o-rwx /var/www/mysite/
chown -Rh www-data:"$(id -u -n)" /var/log/mysite/
chmod -R -x+X,g+rw,o-rwx /var/log/mysite/

pip install -r requirements/prod.txt --upgrade

pip install django-aws-xray