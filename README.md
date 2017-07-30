# appDirect
AppDirect bootstrap webapp automated docker & AWS project:

	=> 4 steps from maven Java project to EC2 online project!

	-> Description:
		- Web app in JAVA with Maven and spring:
			- Bootstrap as UI Framework
			- Project with assembly and init script ( status / start / stop )
			- Project with UI and servlet
		- Automated steps:
			- Build with maven
			- Build with docker
			- Push on docker hub
			- Deploy on local computer or create a new EC2 and deploy app on it.
		- Script to manage all actions
		- Dockerfile to describe container

	-> Requirements:
		- An UNIX computer
		- A docker hub account
		- A docker repository
		- An AWS programmatic access with:
			- Access key ID
			- Secret Key ID
			- EC2 full rights
			- A security group with port 80 open from all IP ( note the sg-xxxxxx id)
			- A subnet in your VPC ( note the subnet-xxxxxx id)
			- An SSH key. ( Note the name on AWS )

		- On your computer for the build part:
			- Git
			- Docker
			- Maven > 3.5
			- Java 1.8	
		- On your computer for the deploy part:
			- Java 1.8	
			- /apps folder
			- Tomcat 8 in /apps/tomcat location

	-> How-to:
		1 - Clone this repository
		1 - Download your SSH key into the project root folder where the script AUTO_INSTALL.sh is
		2 - Edit the CONFIGURATION.properties file to set up your values
		3 - Run the AUTO_INSTALL.sh script within a console:
			- Use "./AUTO_INSTALL.sh -cf" for a full flow and deploy in AWS Cloud
			- Use "./AUTO_INSTALL.sh" for a full flow  and deploy in your computer
			- Use "./AUTO_INSTALL.sh --help" for more information

