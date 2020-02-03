Elasticsearch cluster with Terraform on AWS

This document describes how to setup an elasticsearch cluster of EC2 instances using Terraform.

Initial setup on AWS console:
Created a user “swaraj” under IAM and provided Administrator access.
Downloaded the credentials.csv file and extracted access_key & secret_key from it

EC2 Discovery Plugin:
The EC2 Discovery Pluging is used by Elasticsearch to find nodes in AWS. The EC2 discovery plugin uses the AWS API for discovery. EC2 discovery requires making a call to the EC2 service. So, a IAM Role is necessary for this plugin to find other nodes in the cluster.
Since we are using Terraform, we will need to create few things for our cluster to work properly. First of all, our cluster will have 3 instances running Elasticsearch 5.6.3 + EC2 Discovery Plugin. Also, this instance needs to be able to call the AWS API to find other nodes, for that we will use an IAM Role. Those instances will stay under a security group named elasticsearch_cluster_sg that has exposed port 22 (SSH), 9200 (Elasticsearch API endpoint) and 9300 (Elasticsearch internal communication).

Attaching roles to instances with Terraform:
We created a aws_iam_policy_document that describes our policy, this policy document is used by an aws_iam_policy. This policy will then be attached to an aws_iam_role using aws_iam_role_policy_attachment. Then, we create an aws_iam_instance_profile that will reference our IAM Role. Finally, our instances can reference iam_instance_profile and will be able to reach out the AWS API.
aws_iam_policy_document -> aws_iam_policy -> aws_iam_role_policy_attachment to aws_iam_role -> aws_iam_instance_profile

Elasticsearch setup script:
The elasticsearch-node-setup.sh scripts installs Java 8 and Elasticsearch 5.6.3 on Red-Hat based machines. Also, it configures some other flags in order for the node to be properly setup. Those flags are:
•	discovery.zen.hosts_provider: discovery mechanism in Elasticsearch (for it to work in AWS, this flag is set to ec2
•	cloud.aws.region: AWS region where the cluster will be deployed
•	network.host: currently using the private IP address of the instance (_ec2_), but there are few options available. Check out the EC2 Network Host documentation for more information.
All those flags are set in /etc/elasticsearch/elasticsearch.yml.


Source Files included:

elasticsearch-node-setup.sh 
-	Shell script to setup the elasticsearch node. This script will install Java, elasticsearch and discovery ec2 plugin on each node
elasticsearch-instance.tf 
-	This terraform file will create the aws instance for elasticsearch
variables.tf  
-	This file contains the terraform variables
Main.tf
-	define provider
-	create ec2 instances
-	Create security groups
-	Create aws_iam_roles, aws_iam_policy, aws_iam_instance_profile etc 

