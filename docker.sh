#!/bin/bash
docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q)
docker run --restart="always" --name mysql-server -t -e MYSQL_DATABASE="zabbix" -e MYSQL_USER="zabbix" -e MYSQL_PASSWORD="###" -e MYSQL_ROOT_PASSWORD="###" -d mysql:5.7 --character-set-server=utf8 --collation-server=utf8_bin
docker run --restart="always" --name zabbix-java-gateway -t -d zabbix/zabbix-java-gateway:latest
docker run --restart="always" --name zabbix-server-mysql -t -e DB_SERVER_HOST="mysql-server" -e MYSQL_DATABASE="zabbix" -e MYSQL_USER="zabbix" -e MYSQL_PASSWORD="###" -e MYSQL_ROOT_PASSWORD="###" -e ZBX_JAVAGATEWAY="zabbix-java-gateway" --link mysql-server:mysql --link zabbix-java-gateway:zabbix-java-gateway -p 10051:10051 -d zabbix/zabbix-server-mysql:latest
docker run --restart="always" --name zabbix-web-nginx-mysql -t -e DB_SERVER_HOST="mysql-server" -e MYSQL_DATABASE="zabbix" -e MYSQL_USER="zabbix" -e MYSQL_PASSWORD="###" -e MYSQL_ROOT_PASSWORD="###" --link mysql-server:mysql --link zabbix-server-mysql:zabbix-server -p 80:80 -d zabbix/zabbix-web-nginx-mysql:latest
docker run --restart="always" -d --name=grafana -p 3000:3000 grafana/grafana:latest
docker run --restart="always" --name zabbix-agent -e ZBX_HOSTNAME="Zabbix Server" -e ZBX_SERVER_HOST="zabbix-server-mysql"  --link zabbix-server-mysql:zabbix-server -d zabbix/zabbix-agent:latest
docker ps -a