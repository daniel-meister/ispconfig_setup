#---------------------------------------------------------------------
# Function: InstallWebServer Debian 9
#    Install and configure Apache2, php + modules
#---------------------------------------------------------------------
InstallWebServer() {
  
  if [ $CFG_WEBSERVER == "apache" ]; then
  CFG_NGINX=n
  CFG_APACHE=y
  echo -n "Installing Apache and Modules... "
	echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2" | debconf-set-selections
	# - DISABLED DUE TO A BUG IN DBCONFIG - echo "phpmyadmin phpmyadmin/dbconfig-install boolean false" | debconf-set-selections
	echo "dbconfig-common dbconfig-common/dbconfig-install boolean false" | debconf-set-selections
	apt-get -yqq install apache2 apache2-data apache2-doc apache2-utils libapache2-mod-php7.0 libapache2-mod-fcgid apache2-suexec-pristine libapache2-mod-passenger libapache2-mod-python libexpat1 ssl-cert libruby > /dev/null 2>&1  
	echo -e "[${green}DONE${NC}]\n"
	echo -n "Installing PHP and Modules... "
	apt-get -yqq install php7.0 php7.0-common php7.0-dev php7.0-gd php7.0-mysqlnd php7.0-imap php7.0-cli php7.0-cgi php-pear php-auth-sasl php7.0-fpm php7.0-mcrypt php7.0-imagick php7.0-curl php7.0-intl php7.0-memcached php7.0-pspell php7.0-recode php7.0-snmp php7.0-sqlite php7.0-tidy php7.0-xmlrpc php7.0-xsl > /dev/null 2>&1
	echo -e "[${green}DONE${NC}]\n"
	echo -n "Installing needed Programs for PHP and Apache... "
	apt-get -yqq install mcrypt imagemagick memcached curl tidy snmp > /dev/null 2>&1
    	echo -e "[${green}DONE${NC}]\n"
	
  if [ $CFG_PHPMYADMIN == "yes" ]; then
	echo "==========================================================================================="
	echo "Attention: When asked 'Configure database for phpmyadmin with dbconfig-common?' select 'NO'"
	echo "Due to a bug in dbconfig-common, this can't be automated."
	echo "==========================================================================================="
	echo "Press ENTER to continue... "
	read DUMMY
	echo -n "Installing phpMyAdmin... "
	apt-get -y install phpmyadmin
	echo -e "[${green}DONE${NC}]\n"
  fi
	
  if [ "$CFG_XCACHE" == "yes" ]; then
	echo -n "Installing XCache... (not available in Debian Stretch)"
	echo -e "[${gred}FAIL${NC}]\n"
  fi
	
	echo -n "Activating Apache2 Modules... "
	a2enmod suexec > /dev/null 2>&1
	a2enmod rewrite > /dev/null 2>&1
	a2enmod ssl > /dev/null 2>&1
	a2enmod actions > /dev/null 2>&1
	a2enmod include > /dev/null 2>&1
	a2enmod dav_fs > /dev/null 2>&1
	a2enmod dav > /dev/null 2>&1
	a2enmod auth_digest > /dev/null 2>&1
	a2enmod fastcgi > /dev/null 2>&1
	a2enmod alias > /dev/null 2>&1
	a2enmod fcgid > /dev/null 2>&1
	service apache2 restart > /dev/null 2>&1
	echo -e "[${green}DONE${NC}]\n"
	
	echo -n "Installing Lets Encrypt... "	
	apt-get -yqq install python-certbot-apache
	certbot &
	echo -e "[${green}DONE${NC}]\n"
  
  else
	
  CFG_NGINX=y
  CFG_APACHE=n
	echo -n "Installing NGINX and Modules... "
	service apache2 stop
	update-rc.d -f apache2 remove
	apt-get -yqq install nginx > /dev/null 2>&1
	service nginx start 
	apt-get -yqq install php7.0-fpm php7.0-mysqlnd php7.0-curl php7.0-gd php7.0-intl php-pear php7.0-imagick php7.0-imap php7.0-mcrypt php7.0-memcache php7.0-memcached php7.0-pspell php7.0-recode php7.0-snmp php7.0-sqlite php7.0-tidy php7.0-xmlrpc php7.0-xsl memcached php-apc > /dev/null 2>&1
	sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/7.0/fpm/php.ini
	sed -i "s/;date.timezone =/date.timezone=\"Europe\/Rome\"/" /etc/php/7.0/fpm/php.ini
	echo -n "Installing needed Programs for PHP and NGINX... "
	apt-get -yqq install mcrypt imagemagick memcached curl tidy snmp > /dev/null 2>&1
	#sed -i "s/#/;/" /etc/php/7.0/conf.d/ming.ini
	service php7.0-fpm reload
	apt-get -yqq install fcgiwrap
  
  if [ $CFG_PHPMYADMIN == "yes" ]; then
	echo "==========================================================================================="
	echo "Attention: When asked 'Configure database for phpmyadmin with dbconfig-common?' select 'NO'"
	echo "Due to a bug in dbconfig-common, this can't be automated."
	echo "==========================================================================================="
	echo "Press ENTER to continue... "
	read DUMMY
	echo -n "Installing phpMyAdmin... "
	apt-get -y install phpmyadmin
	echo -e "[${green}DONE${NC}]\n"
  fi
  
  	echo -n "Installing Lets Encrypt... "	
	apt-get -yqq install certbot
	certbot &
	echo -e "[${green}DONE${NC}]\n"
  
  fi
  echo -e "[${green}DONE${NC}]\n"
}
