#!/bin/bash

# Script used to set up a new node inside an Elasticsearch cluster in AWS

sudo yum -y update

# Java 8 Installation
sudo yum install -y java-1.8.0-openjdk.x86_64
JAVA_PATH=`which java`
sudo export PATH=$PATH:$JAVA_PATH

# Elasticsearch 7.5.2 Installation
sudo rpm -i https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.5.2-x86_64.rpm 

sudo bash -c 'echo ES_JAVA_OPTS="\"-Xms1g -Xmx1g\"" >> /etc/sysconfig/elasticsearch'
sudo bash -c 'echo MAX_LOCKED_MEMORY=unlimited >> /etc/sysconfig/elasticsearch'

# Discovery EC2 plugin is used for the nodes to create the cluster in AWS
echo -e "yes\n" | sudo /usr/share/elasticsearch/bin/elasticsearch-plugin install discovery-ec2

# Shortest configuration for Elasticsearch nodes to find each other
sudo bash -c 'echo "discovery.zen.hosts_provider: ec2" >> /etc/elasticsearch/elasticsearch.yml'
sudo bash -c 'echo "cloud.aws.region: sa-east" >> /etc/elasticsearch/elasticsearch.yml'
sudo bash -c 'echo "network.host: _ec2_" >> /etc/elasticsearch/elasticsearch.yml'

sudo systemctl daemon-reload

sudo systemctl enable elasticsearch.service

sudo chkconfig --add elasticsearch

sudo systemctl start elasticsearch.service

echo "Node setup finished!" > terraform.txt
