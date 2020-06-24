#cloud-boothook
#!/bin/sh
yum update -y
yum install epel-release -y 
cat > /etc/yum.repo.d/nginx.repo <<EOF
[nginx-stable]
name=nginx stable repo
baseurl=http://nginx.org/packages/centos/$releasever/$basearch/
gpgcheck=1
enabled=1
gpgkey=https://nginx.org/keys/nginx_signing.key
module_hotfixes=true

[nginx-mainline]
name=nginx mainline repo
baseurl=http://nginx.org/packages/mainline/centos/$releasever/$basearch/
gpgcheck=1
enabled=0
gpgkey=https://nginx.org/keys/nginx_signing.key
module_hotfixes=true
EOF
yum install nginx -y
yum install yum-utils -y
systemctl start nginx
yum install https://rpms.remirepo.net/enterprise/remi-release-7.rpm -y
yum-config-manager --enable remi-php72
yum install php72
yum -y install php php-fpm php-cli -y
cd /var
mkdir www2 && cd www2
cat > /var/www2/index.php <<EOF
<?php
phpinfo();
?>
EOF
rm -rf /etc/nginx/nginx.conf
touch /etc/nginx/nginx.conf
cat > /etc/nginx/nginx.conf <<EOF
worker_processes  1;

events {
    worker_connections  1024;
}


http {
    include       mime.types;
    default_type  application/octet-stream;


    sendfile        on;

    keepalive_timeout  65;


    server {
        listen       80;
        server_name  localhost;

        root /var/www2;

        location / {
            root   /var/www2;
            index index.php  index.html index.htm;
        }


        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   html;
        }


        location ~ \.php$ {
            root           /var/www2;
            fastcgi_pass   127.0.0.1:9000;
            fastcgi_index  index.php;
            fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
            include        fastcgi_params;
        }

    }
}
EOF
service nginx restart && service php-fpm restart
yum install nano -y
yum install setools -y
#audit2allow --all
#audit2allow -a -M testmodule
#semodule -i testmodule.pp


