echo "Directory /tendenci/static exists. This is not a new installation."
echo "entrypoint: creating symbolic links"
rm -rf /var/www/mysite/media
rm -rf /var/www/mysite/static
rm -rf /var/www/mysite/themes
rm -rf /var/www/mysite/whoosh_index
ln -s /tendenci/media /var/www/mysite/media
ln -s /tendenci/static /var/www/mysite/static
ln -s /tendenci/themes /var/www/mysite/themes
ln -s /tendenci/whoosh_index /var/www/mysite/whoosh_index