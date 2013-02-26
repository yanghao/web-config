# You may add here your
# server {
#	...
# }
# statements for each of your virtual hosts to this file

##
# You should look at the following URL's in order to grasp a solid understanding
# of Nginx configuration files in order to fully unleash the power of Nginx.
# http://wiki.nginx.org/Pitfalls
# http://wiki.nginx.org/QuickStart
# http://wiki.nginx.org/Configuration
#
# Generally, you will want to move this file somewhere, and start with a clean
# file but keep this around for reference. Or just disable in sites-enabled.
#
# Please see /usr/share/doc/nginx-doc/examples/ for more detailed examples.
##

upstream uwsgi_cluster {
        server 127.0.0.1:3031;
        #server unix:/tmp/uwsgi-app.sock;
}

upstream uwsgi_cluster_single {
        server 127.0.0.1:3032;
}

upstream uwsgi_cluster_ui {
        server 127.0.0.1:3033;
}

upstream uwsgi_cluster_tyan6 {
        server 127.0.0.1:3051;
}

upstream uwsgi_cluster_zhahang {
        server 127.0.0.1:3052;
}

upstream uwsgi_cluster_yangwan1 {
        server 127.0.0.1:3053;
}

server {
	listen   80; ## listen for ipv4; this line is default and implied
	#listen   [::]:80 default ipv6only=on; ## listen for ipv6

	root /srv/www;
	index index.html index.htm;

	# Make site accessible from http://localhost/
	server_name cvos.xa.intel.com localhost 127.0.0.1;

	location / {
		# First attempt to serve request as file, then
		# as directory, then fall back to index.html
		try_files $uri $uri/ /index.html;
		# Uncomment to enable naxsi on this location
		# include /etc/nginx/naxsi.rules
	}

        location /app {
                rewrite ^/app/(.*)$ /$1 break;
                include uwsgi_params;
                uwsgi_param UWSGI_CHDIR /home/cvos/uwsgi/app/;
                uwsgi_param UWSGI_PYHOME /home/cvos/virtualenv/app/;
                uwsgi_param UWSGI_SCRIPT main;
                uwsgi_pass uwsgi_cluster;
        }

        location /tyan6 {
                rewrite ^/tyan6/(.*)$ /$1 break;
                include uwsgi_params;
                uwsgi_param UWSGI_CHDIR /home/tyan6/uwsgi/app/;
                uwsgi_param UWSGI_PYHOME /home/tyan6/virtualenv/app/;
                uwsgi_param UWSGI_SCRIPT main;
                uwsgi_pass uwsgi_cluster_tyan6;
        }

        location /zhahang {
                rewrite ^/zhahang/(.*)$ /$1 break;
                include uwsgi_params;
                uwsgi_param UWSGI_CHDIR /home/zhahang/uwsgi/app/;
                uwsgi_param UWSGI_PYHOME /home/zhahang/virtualenv/app/;
                uwsgi_param UWSGI_SCRIPT main;
                uwsgi_pass uwsgi_cluster_zhahang;
        }

        location /yangwan1 {
                rewrite ^/yangwan1/(.*)$ /$1 break;
                include uwsgi_params;
                uwsgi_param UWSGI_CHDIR /home/yangwan1/uwsgi/app/;
                uwsgi_param UWSGI_PYHOME /home/yangwan1/virtualenv/app/;
                uwsgi_param UWSGI_SCRIPT main;
                uwsgi_pass uwsgi_cluster_yangwan1;
        }

        location /single {
                rewrite ^/single/(.*)$ /$1 break;
                include uwsgi_params;
                uwsgi_param UWSGI_CHDIR /home/cvos/uwsgi/single/;
                uwsgi_param UWSGI_PYHOME /home/cvos/virtualenv/app/;
                uwsgi_param UWSGI_SCRIPT main;
                uwsgi_pass uwsgi_cluster_single;
        }

        location /ui {
                rewrite ^/ui/?$ / break;
                rewrite ^/ui/(.*)$ /$1 break;
                include uwsgi_params;
                uwsgi_param UWSGI_CHDIR /home/cvos/uwsgi/ui/;
                uwsgi_param UWSGI_PYHOME /home/cvos/virtualenv/app/;
                uwsgi_param UWSGI_SCRIPT main;
                uwsgi_pass uwsgi_cluster_ui;
        }

	location /doc/ {
		alias /usr/share/doc/;
		autoindex on;
		allow 127.0.0.1;
		deny all;
	}

	# Only for nginx-naxsi : process denied requests
	#location /RequestDenied {
		# For example, return an error code
		#return 418;
	#}

	#error_page 404 /404.html;

	# redirect server error pages to the static page /50x.html
	#
	#error_page 500 502 503 504 /50x.html;
	#location = /50x.html {
	#	root /usr/share/nginx/www;
	#}

	# pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000
	#
	#location ~ \.php$ {
	#	fastcgi_split_path_info ^(.+\.php)(/.+)$;
	#	# NOTE: You should have "cgi.fix_pathinfo = 0;" in php.ini
	#
	#	# With php5-cgi alone:
	#	fastcgi_pass 127.0.0.1:9000;
	#	# With php5-fpm:
	#	fastcgi_pass unix:/var/run/php5-fpm.sock;
	#	fastcgi_index index.php;
	#	include fastcgi_params;
	#}

	# deny access to .htaccess files, if Apache's document root
	# concurs with nginx's one
	#
	#location ~ /\.ht {
	#	deny all;
	#}
########location /gerrit2/ {
########	proxy_pass        http://xasubt242.xa.intel.com:8081;
########	proxy_set_header  X-Forwarded-For $remote_addr;
########	proxy_set_header  Host $host;
########}
########location /gitweb/ {
########        proxy_pass      http://xasubt242.xa.intel.com:81;
########        proxy_set_header X-Forwarded-For $remote_addr;
########        proxy_set_header Host $host;
########}
}


# another virtual host using mix of IP-, name-, and port-based configuration
#
#server {
#	listen 8000;
#	listen somename:8080;
#	server_name somename alias another.alias;
#	root html;
#	index index.html index.htm;
#
#	location / {
#		try_files $uri $uri/ /index.html;
#	}
#}


# HTTPS server
#
#server {
#	listen 443;
#	server_name localhost;
#
#	root html;
#	index index.html index.htm;
#
#	ssl on;
#	ssl_certificate cert.pem;
#	ssl_certificate_key cert.key;
#
#	ssl_session_timeout 5m;
#
#	ssl_protocols SSLv3 TLSv1;
#	ssl_ciphers ALL:!ADH:!EXPORT56:RC4+RSA:+HIGH:+MEDIUM:+LOW:+SSLv3:+EXP;
#	ssl_prefer_server_ciphers on;
#
#	location / {
#		try_files $uri $uri/ /index.html;
#	}
#}
