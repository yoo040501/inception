FROM debian:bullseye

RUN apt-get update && \
    apt-get install -y nginx openssl vim && \
    apt-get clean

RUN openssl req -x509 -nodes -days 365 -newkey \
	rsa:2048 -keyout /etc/ssl/private/server_pkey.pem \
	-out /etc/ssl/certs/server.crt \
	-subj "/C=KR/ST=Seoul/L=Seoul/O=42Seoul/OU=Unit/CN=localhost"

COPY ./requirements/nginx/tools/nginx.conf /etc/nginx/conf.d/default.conf
COPY ./requirements/nginx/tools/nginx.conf /etc/nginx/sites-available/default

EXPOSE 443

ENTRYPOINT ["sh", "-c", "nginx -t && nginx -g 'daemon off;'"]
