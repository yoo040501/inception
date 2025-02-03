FROM debian:bullseye

RUN apt-get update -y && \
	apt-get upgrade -y && \
	apt-get -y install mariadb-server \
		vim && \
	apt-get clean && rm -rf /var/lib/apt/lists/*

COPY ./requirements/mariadb/tools/init.sh /

RUN chmod +x /init.sh

EXPOSE 3306

ENTRYPOINT ["bash", "/init.sh"]