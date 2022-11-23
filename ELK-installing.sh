#!/bin/bash

#Update repo
apt-get update -y
apt-get upgrade -y

#Installing dependencies
apt-get install openjdk-11-jdk wget apt-transport-https curl gpgv gpgsm gnupg-l10n gnupg dirmngr -y

#Install and configure Java
sudo apt -y install openjdk-11-jdk
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64

#Adding Elastic search repo
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -

echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-7.x.list

#Installing Elasticsearch
apt-get update
apt-get install elasticsearch -y

#restarting elasticsearch service
sudo systemctl stop elasticsearch
systemctl enable elasticsearch

#Configuring elastic transport host
echo 'transport.host: localhost' >> /etc/elasticsearch/elasticsearch.yml
echo 'transport.tcp.port: 9300' >> /etc/elasticsearch/elasticsearch.yml
echo 'network.host: localhost' >> /etc/elasticsearch/elasticsearch.yml
echo 'http.port: 9200' >> /etc/elasticsearch/elasticsearch.yml
echo 'discovery.type: single-node' >> /etc/elasticsearch/elasticsearch.yml
echo 'setup.ilm.overwrite: true' >> /etc/elasticsearch/elasticsearch.yml

#Adding JVM heaps
echo '-Xms512m' >> /etc/elasticsearch/jvm.options
echo '-Xmx512m' >> /etc/elasticsearch/jvm.options

#Reloading the service
systemctl daemon-reload
systemctl start elasticsearch
systemctl restart elasticsearch

#list service status
systemctl status elasticsearch
sleep 10
#Installing log stash
sudo apt install logstash -y

systemctl daemon-reload
systemctl enable logstash
systemctl start logstash

systemctl status logstash
sleep 10
#Installing Kibana
sudo apt install kibana -y
systemctl stop kibana
systemctl enable kibana

echo -e "server.port: 5601" >> /etc/kibana/kibana.yml
echo -e "server.host: $HOSTNAME" >> /etc/kibana/kibana.yml
echo -e 'elasticsearch.hosts: ["http://localhost:9200"]' >> /etc/kibana/kibana.yml
systemctl daemon-reload
systemctl start kibana

systemctl status kibana
