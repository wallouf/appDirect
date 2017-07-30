# appDirect
AppDirect bootstrap webapp automated docker & AWS project:

#4 steps from maven Java project to EC2 online project!

##Description:
*Web app in JAVA with Maven and spring:
	*Bootstrap as UI Framework
	*Project with assembly and init script ( status / start / stop )
	*Project with UI and servlet
*Automated steps:
	*Build with maven
	*Build with docker
	*Push on docker hub
	*Deploy on local computer or create a new EC2 and deploy app on it.
*Script to manage all actions
*Dockerfile to describe container

##Requirements:
*An UNIX computer
*A docker hub account
*A docker repository
*An AWS programmatic access with:
	*Access key ID
	*Secret Key ID
	*EC2 full rights
	*A security group with port 80 open from all IP ( note the sg-xxxxxxxx id)
	*A subnet in your VPC ( note the subnet-xxxxxxxx id)
	*An SSH key. ( Note the name on AWS )

*On your computer for the build part:
	*Git
	*Docker
	*Maven > 3.5
	*Java 1.8	
*On your computer for the deploy part:
	*Java 1.8	
	*/apps folder
	*Tomcat 8 in /apps/tomcat location

##How-to:
1.	Clone this repository
1.	Download your SSH key into the project root folder where the script AUTO_INSTALL.sh is
1.	Edit the CONFIGURATION.properties file to set up your values:
	1.	FILE_SSH_KEY_NAME : File name of your AWS SSH key on your disk.
	1.	AWS_SSH_KEY_NAME : Name of your AWS SSH key.
	1.	AWS_SUBNET_ID : Id of the subnet in AWS. Like subnet-xxxxxxxx
	1.	AWS_SECURITYGROUP_ID : id of the security group in AWS. Like sg-xxxxxxxx
	1.	DOCKER_IMAGE_ID : Docker image name AND docker repository name.
	1.	DOCKER_USER_ID : Username of your docker account
1.	Run the AUTO_INSTALL.sh script within a console:
	1.	Use "./AUTO_INSTALL.sh -cf" for a full flow and deploy in AWS Cloud
	1.	Use "./AUTO_INSTALL.sh" for a full flow  and deploy in your computer
	1.	Use "./AUTO_INSTALL.sh --help" for more information

