#!/bin/bash

apache_config_file="/etc/apache2/envvars"
php_config_file="/etc/php5/apache2/php.ini"
xdebug_config_file="/etc/php5/conf.d/xdebug.ini"
mysql_config_file="/etc/mysql/my.cnf"
default_apache_index="/var/www/html/index.html"

# This function is called at the very bottom of the file
main() {
	update_go
	tools_go
	apache_go
	mysql_go
	phpmyadmin_go
	php_go
	mail_go
	autoremove_go
}


update_go() {
	# Update the server
	sudo apt-get update
	# apt-get -y upgrade
}

autoremove_go() {
	sudo apt-get -y autoremove
}

tools_go() {
	# Install basic tools
	sudo apt-get install -y curl
	sudo apt-get install -y openssl
	sudo apt-get install -y unzip
	sudo apt-get install -y vim
	sudo apt-get install -y tree
	sudo apt-get install -y git
}

apache_go() {
	# Install Apache

	echo "[vagrant provisioning] Installing apache2..."
	sudo apt-get install -y apache2 # installs apache and some dependencies
	sudo service apache2 restart # restarting for sanities' sake
	echo "[vagrant provisioning] Applying Apache vhost conf..."
	sudo rm -f /etc/apache2/sites-available/default
	sudo rm -f /etc/apache2/sites-enabled/000-default

	if [ ! -f "/etc/apache2/sites-available/default" ]; then
		cat << EOF > "/etc/apache2/sites-available/default"
<VirtualHost *:80>
	ServerAdmin webmaster@localhost
	DocumentRoot /var/www
	<Directory />
		Options FollowSymLinks
		AllowOverride All
	</Directory>
	<Directory /var/www/>
		Options Indexes FollowSymLinks MultiViews
		AllowOverride All
		Order allow,deny
		allow from all
	</Directory>
	ScriptAlias /cgi-bin/ /usr/lib/cgi-bin/
	<Directory /usr/lib/cgi-bin>
		AllowOverride All
		Options +ExecCGI -MultiViews +SymLinksIfOwnerMatch
		Order allow,deny
		Allow from all
	</Directory>
    ErrorLog /var/log/apache2/error.log
    LogLevel warn
    CustomLog /var/log/apache2/access.log combined
    Alias /doc/ /usr/share/doc/
    <Directory /usr/share/doc/>
        Options Indexes MultiViews FollowSymLinks
        AllowOverride All
        Order deny,allow
        Deny from all
        Allow from 127.0.0.0/255.0.0.0 ::1/128
    </Directory>
</VirtualHost>
EOF
	fi
	sudo ln -s /etc/apache2/sites-available/default /etc/apache2/sites-enabled/000-default
	a2enmod rewrite
	a2enmod actions
	a2enmod ssl
	ln -s /etc/apache2/sites-available/default-ssl /etc/apache2/sites-enabled/

	sudo service apache2 restart
}

php_go() {
	sudo apt-get -y install php5 php5-curl php5-mysql php5-cli php5-mcrypt php5-imagick

	sudo sed -i "s/display_startup_errors = Off/display_startup_errors = On/g" ${php_config_file}
	sudo sed -i "s/display_errors = Off/display_errors = On/g" ${php_config_file}
	php5enmod mcrypt
 	php5enmod curl

	sudo service apache2 restart

}
mysql_go() {
	# Install MySQL
	chmod -R 777 /var/lib/mysql
	echo "mysql-server mysql-server/root_password password root" | debconf-set-selections
	echo "mysql-server mysql-server/root_password_again password root" | debconf-set-selections
	sudo apt-get -y install mysql-client mysql-server
	chown -R mysql:mysql /var/lib/mysql

	sudo service mysql restart
}

mail_go() {
	echo "postfix postfix/mailname string php53" | debconf-set-selections
	echo "postfix postfix/main_mailer_type select Internet Site" | debconf-set-selections
	apt-get -y install mailutils postfix

	service apache2 restart
}

phpmyadmin_go() {
	APP_PASS="root"
	ROOT_PASS="root"
	APP_DB_PASS="root"

	echo "phpmyadmin phpmyadmin/dbconfig-install boolean true" | debconf-set-selections
	echo "phpmyadmin phpmyadmin/app-password-confirm password $APP_PASS" | debconf-set-selections
	echo "phpmyadmin phpmyadmin/mysql/admin-pass password $ROOT_PASS" | debconf-set-selections
	echo "phpmyadmin phpmyadmin/mysql/app-pass password $APP_DB_PASS" | debconf-set-selections
	echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2" | debconf-set-selections
	apt-get	 -y install phpmyadmin
	echo "Include /etc/phpmyadmin/apache.conf" >> /etc/apache2/apache2.conf

	service apache2 restart
}
main
exit 0
