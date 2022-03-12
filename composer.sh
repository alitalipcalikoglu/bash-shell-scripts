################### install composer ############################
sudo apt install php7.4 php7.4-mysql php-mbstring php-xml php-curl php-zip -y
curl -sS https://getcomposer.org/installer -o composer-setup.php
sudo php composer-setup.php --version=1.10.17 --install-dir=/usr/local/bin --filename=composer
php composer-setup.php
php -r "unlink('composer-setup.php');"
chmod +x composer.phar
sudo mv composer.phar /usr/bin/composer
###############################################################
