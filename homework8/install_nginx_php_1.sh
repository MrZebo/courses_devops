#cloud-boothook
#!/bin/sh
cat > /tmp/text.txt <<TRY
yum update -y
yum install epel-release -y
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

        root /var/www/html;

        location / {
            root   /var/www/html;
            index index.php  index.html index.htm;
        }


        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   html;
        }


        location ~ \.php$ {
            root           /var/www/html;
            fastcgi_pass   127.0.0.1:9000;
            fastcgi_index  index.php;
            fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
            include        fastcgi_params;
        }

    }
}
EOF
service nginx restart && service php-fpm restart
TRY
set -e
filename='/tmp/text.txt'
n=1
while read line; do
echo "Line No. $n : $line"
n=$((n+1))
if [ $? -eq 0 ]; then
    echo "Line $i fall with exception"
    $line 2>> /var/log/fail-install.txt
else
    echo "Line $i  worked fine"
fi
done < $filename


