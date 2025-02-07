all : up

up : 
	@docker-compose -f ./srcs/docker-compose.yml up -d --build

down : 
	@docker-compose -f ./srcs/docker-compose.yml down &&\
	sudo rm -rf /home/dongeunk/data/* &&\
	mkdir /home/dongeunk/data/wordpress /home/dongeunk/data/mariadb

status : 
	@docker ps