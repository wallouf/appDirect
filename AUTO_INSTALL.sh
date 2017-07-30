#!/bin/bash

pushd `dirname $0` > /dev/null
SCRIPT_NAME=`basename $0`
SCRIPT_PATH=`pwd`
popd > /dev/null

#DOCKER PARAMS
var_imageName="wallouf-appdirect-application"
var_dockerIdUser="wallouf"
#AWS PARAMS
var_amiId="ami-a7aa15c3"
var_sshKeyName="BOC-SSH-KEY"
var_subnetId="subnet-4434c13f"
var_securityGroupId="sg-7688df1f"
var_computeType="t2.micro"

#DO NOT CHANGE
var_instanceId=""
var_stepChoice=0
var_interactionChoice=1

function print_usage() {
	clear
	echo 
	echo 
	echo "AUTO INSTALL SCRIPT"
	echo 
	echo "	WARNING:"
	echo "		- You need to have python > 2.7 at least to deploy"
	echo "		- You need to have apache maven > 3.5 and java 1.8 at least to build"
	echo "		- You need a docker account and a docker repository with the following name: ${var_imageName}"
	echo "		- Before using this script, you need to set up your credentials into the CREDENTIALS.properties file."
	echo 
	echo "	STEPS:"
	echo 
	echo "	1 - Build components with maven"
	echo "	2 - Build docker image"
	echo "	3 - Push docker image"
	echo "	4 - Deploy image in AWS"
	echo "	[Optional]"
	echo "	c - Deploy image in AWS Cloud"
	echo 
	echo "	USAGE:"
	echo 
    echo "$SCRIPT_NAME [options]"
    echo
    echo "Options: If no options is used, all steps will be executed."
    echo
    echo "  -h,--help					Show this help message and exit."
    echo
    echo "  -a,--no-interaction			Do not ask confirmation."
    echo
    echo "  -b,--build-maven-only		Build only with maven the application."
    echo
    echo "  -d,--build-docker-only		Build only with docker the application."
    echo
    echo "  -p,--push-docker-only		Push only with docker the application image."
    echo
    echo "  -i,--install-only			Install the application image on this computer."
    echo
    echo "  -c,--cloud-only				Install only with AWS the application image."
    echo
    echo "  -cf,--cloud-full			All steps and deploy to cloud with AWS the application image."
    echo
}

function stopAWS_EC2(){
	aws ec2 terminate-instances --instance-ids ${var_instanceId}
	if [ $? -ne 0 ]; then
	    echo "${boldRedEchoStyle}        Termination of EC2 ${var_instanceId} failed.${resetEchoStyle}"
	    return -1
	else
		return 0
	fi
}

print_usage

while :; do
    case $1 in
        -a|--no-interaction)
            var_interactionChoice=0
            ;;
        -b|--build-maven-only)
            var_stepChoice=1
            var_interactionChoice=0
            ;;
        -d|--build-docker-only)
            var_stepChoice=2
            var_interactionChoice=0
            ;;
        -p|--push-docker-only)
            var_stepChoice=3
            var_interactionChoice=0
            ;;
        -i|--install-only)
            var_stepChoice=4
            var_interactionChoice=0
            ;;
        -c|--cloud-only)
            var_stepChoice=5
            var_interactionChoice=0
            ;;
        -cf|--cloud-full)
            var_stepChoice=6
            var_interactionChoice=0
            ;;

        -h|-\?|--help)
            print_usage
            exit 0
            ;;

        # End of all options.
        --)
            shift
            break
            ;;

        -?*)
            echo "[ERROR] Unknown option (ignored): $1"
            exit 1
            ;;

        # Default case: If no more options then break out of the loop.
        *)
            break
            ;;
    esac

    shift
done

#STYLE PART
resetEchoStyle=$(tput sgr0)
boldRedEchoStyle="$resetEchoStyle$(tput bold)$(tput setaf 1)"
boldOrangeEchoStyle="$resetEchoStyle$(tput bold)$(tput setaf 3)"
boldGreenEchoStyle="$resetEchoStyle$(tput bold)$(tput setaf 2)"

if [[ ${var_interactionChoice} -eq 1 ]]; then
	echo
	while true; do
	    while read -r -t 0; do read -r; done

	    echo "${boldOrangeEchoStyle}[WARN] This script will follow all steps described above. Do you want to continue. ? ${boldGreenEchoStyle}Y/N ${resetEchoStyle}"

	    read -p "" i_continue

	    case $i_continue in
	        [Yy]* ) break;;
	        [Nn]* ) echo "End of script."; exit;;
	        * ) echo "Please answer yes or no.";;
	    esac
	done
fi

echo
echo "${boldOrangeEchoStyle}Launch auto installation...${resetEchoStyle}"
echo

#STEP 1
if [[ ${var_stepChoice} -eq 0 ]] || [[ ${var_stepChoice} -eq 1 ]] || [[ ${var_stepChoice} -eq 6 ]]; then
	echo
    echo "${boldOrangeEchoStyle}	-> Step 1: Build with maven...${resetEchoStyle}"
    echo
	#CHECK MAVEN
	mvn --version > install.log 2>&1
	if [ $? -ne 0 ]; then
	    echo "${boldRedEchoStyle}        Cannot find maven. Please install it before.${resetEchoStyle}"
	    exit -1
	fi
	#CHECK JAVA
	java -version > install.log 2>&1
	if [ $? -ne 0 ]; then
	    echo "${boldRedEchoStyle}        Cannot find java. Please install it before.${resetEchoStyle}"
	    exit -1
	fi

	cd "${SCRIPT_PATH}/wallouf-appdirect/"

	mvn clean install
	if [ $? -ne 0 ]; then
	    echo "${boldRedEchoStyle}        Build failed with maven. Please fix project and try again.${resetEchoStyle}"
	    exit -1
	fi
    echo "${boldGreenEchoStyle}	-> Step 1: Build with maven DONE!${resetEchoStyle}"
fi



#STEP 2
if [[ ${var_stepChoice} -eq 0 ]] || [[ ${var_stepChoice} -eq 2 ]] || [[ ${var_stepChoice} -eq 6 ]]; then
	echo
    echo "${boldOrangeEchoStyle}	-> Step 2: Build with docker...${resetEchoStyle}"
    echo

    sudo service docker start
	if [ $? -ne 0 ]; then
	    echo "${boldRedEchoStyle}        Cannot start docker service. Please fix docker and try again.${resetEchoStyle}"
	    exit -1
	fi

    sudo docker build -t ${var_imageName} ${SCRIPT_PATH}/wallouf-appdirect/
	if [ $? -ne 0 ]; then
	    echo "${boldRedEchoStyle}        Build failed with docker. Please fix project and try again.${resetEchoStyle}"
	    exit -1
	fi

    echo "${boldGreenEchoStyle}	-> Step 2: Build with docker DONE!${resetEchoStyle}"
fi


#STEP 3
if [[ ${var_stepChoice} -eq 0 ]] || [[ ${var_stepChoice} -eq 3 ]] || [[ ${var_stepChoice} -eq 6 ]]; then
	echo
    echo "${boldOrangeEchoStyle}	-> Step 3: Push with docker...${resetEchoStyle}"
    echo

    sudo docker login -u ${var_dockerIdUser}
	if [ $? -ne 0 ]; then
	    echo "${boldRedEchoStyle}        Cannot log to docker service. Please fix docker and try again.${resetEchoStyle}"
	    exit -1
	fi

    sudo docker tag ${var_imageName} ${var_dockerIdUser}/${var_imageName}
	if [ $? -ne 0 ]; then
	    echo "${boldRedEchoStyle}        Cannot tag image with docker. Please fix docker and try again.${resetEchoStyle}"
	    exit -1
	fi

    sudo docker push ${var_dockerIdUser}/${var_imageName}
	if [ $? -ne 0 ]; then
	    echo "${boldRedEchoStyle}        Cannot push image to docker. Please fix docker and try again.${resetEchoStyle}"
	    exit -1
	fi
    echo "${boldGreenEchoStyle}	-> Step 3: Push with docker DONE!${resetEchoStyle}"
fi


#STEP 4
if [[ ${var_stepChoice} -eq 0 ]] || [[ ${var_stepChoice} -eq 4 ]]; then
	echo
    echo "${boldOrangeEchoStyle}	-> Step 4: Install locally...${resetEchoStyle}"
    echo

    sudo service docker start
	if [ $? -ne 0 ]; then
	    echo "${boldRedEchoStyle}        Cannot start docker service. Please fix docker and try again.${resetEchoStyle}"
	    exit -1
	fi

    sudo docker run -d -p 80:80 ${var_imageName}
	if [ $? -ne 0 ]; then
	    echo "${boldRedEchoStyle}        Deployment failed with docker. Please fix project and try again.${resetEchoStyle}"
	    exit -1
	fi

    echo "${boldGreenEchoStyle}	-> Step 4: Install locally DONE!${resetEchoStyle}"
fi


#STEP 5 - CLOUD
if [[ ${var_stepChoice} -eq 0 ]] || [[ ${var_stepChoice} -eq 5 ]] || [[ ${var_stepChoice} -eq 6 ]]; then
	echo
    echo "${boldOrangeEchoStyle}	-> Step Cloud: Install with AWS...${resetEchoStyle}"
    echo

    #INSTALL AWS CLI
    echo "			Install AWS CLI${resetEchoStyle}"
    pip install awscli --upgrade --user
	if [ $? -ne 0 ]; then
	    echo "${boldRedEchoStyle}        Installation of AWS CLI failed. Please try again.${resetEchoStyle}"
	    exit -1
	fi

	echo "export PATH=~/.local/bin:$PATH" >> ~/.profile

	source ~/.profile

	aws --version
	if [ $? -ne 0 ]; then
	    echo "${boldRedEchoStyle}        Installation of AWS CLI failed. Please try again.${resetEchoStyle}"
	    exit -1
	fi

    echo "			Configure AWS CLI${resetEchoStyle}"
	aws configure
	if [ $? -ne 0 ]; then
	    echo "${boldRedEchoStyle}        Configuration of AWS CLI failed. Please try again.${resetEchoStyle}"
	    exit -1
	fi

	varNameTag=${var_imageName}-$(date +%s)
	rm ec2_creation.log  > /dev/null 2>&1

	#CREATE INSTANCE
    echo "			Create EC2 in AWS${resetEchoStyle}"
	aws ec2 run-instances --image-id ${var_amiId} --count 1 --instance-type ${var_computeType} --key-name ${var_sshKeyName} --security-group-ids ${var_securityGroupId} --subnet-id ${var_subnetId} > ec2_creation.log
	if [ $? -ne 0 ]; then
	    echo "${boldRedEchoStyle}        Creation of EC2 failed. Please try again.${resetEchoStyle}"
	    exit -1
	fi

	var_instanceId=$(grep -Po '"InstanceId":.*?[^\\]",' ec2_creation.log)
	var_instanceId=${var_instanceId#\"InstanceId\": \"}
	var_instanceId=${var_instanceId%\",}
	if [ ! "${var_instanceId}" ]; then
	    echo "${boldRedEchoStyle}        Cannot get id of EC2 instance. Please terminate it manually and try again.${resetEchoStyle}"
		exit -1
	fi
	#ADD TAG
    echo "			Add tag to EC2 in AWS${resetEchoStyle}"
	aws ec2 create-tags --resources ${var_instanceId} --tags Key=Name,Value=${varNameTag}

	#RETRIEVE PUBLIC IP
    echo "			Retrieve EC2 public IP${resetEchoStyle}"
	var_try=0
	var_instanceIP=$(aws ec2 describe-instances --instance-ids ${var_instanceId} --query "Reservations[*].Instances[*].PublicIpAddress" --output=text)

	while [ ${var_try} -lt 30 ] && [ ! "${var_instanceIP}" ]
	do
	   var_try=$((var_try+1))
	   sleep 1
		var_instanceIP=$(aws ec2 describe-instances --instance-ids ${var_instanceId} --query "Reservations[*].Instances[*].PublicIpAddress" --output=text)
	done

	if [ ! "${var_instanceIP}" ]; then
		varResult=$(stopAWS_EC2)
		if [ $varResult -eq 0 ]; then
		    echo "${boldRedEchoStyle}        Cannot get public ip of EC2 instance. Please try again.${resetEchoStyle}"
		else
		    echo "${boldRedEchoStyle}        Cannot get public ip of EC2 instance. Termination of instance failed. Please close it manually and try again.${resetEchoStyle}"
		fi
		exit -1
	fi

    echo "			Change right of PEM key${resetEchoStyle}"
	chmod 600 ${SCRIPT_PATH}/${var_sshKeyName}.pem

    echo "			Trying to connect to ec2 instance${resetEchoStyle}"
	var_try=0
	var_sshResult="FALSE"
	while [ ${var_try} -lt 5 ] && [[ "${var_sshResult}" == "FALSE" ]]
	do
	   var_try=$((var_try+1))
	   ssh -oStrictHostKeyChecking=no -i "${SCRIPT_PATH}/${var_sshKeyName}.pem" ec2-user@${var_instanceIP} date
		if [ $? -ne 0 ]; then
    		echo "				Connection fail. Continue...${resetEchoStyle}"
		else
    		echo "				Connection successful. Continue...${resetEchoStyle}"
			var_sshResult="TRUE"
			break
		fi
	   sleep 5
	done

	if [[ "${var_sshResult}" == "FALSE" ]]; then
		varResult=$(stopAWS_EC2)
		if [ $varResult -eq 0 ]; then
		    echo "${boldRedEchoStyle}        Connection to EC2 failed. Please try again.${resetEchoStyle}"
		else
		    echo "${boldRedEchoStyle}        Connection to EC2 failed. Termination of instance failed. Please close it manually and try again.${resetEchoStyle}"
		fi
		exit -1
	fi

    echo "			Install docker${resetEchoStyle}"
	ssh -oStrictHostKeyChecking=no -i "${SCRIPT_PATH}/${var_sshKeyName}.pem" ec2-user@${var_instanceIP} sudo yum install -y docker
	if [ $? -ne 0 ]; then
		varResult=$(stopAWS_EC2)
		if [ $varResult -eq 0 ]; then
		    echo "${boldRedEchoStyle}        Docker installation failed. Please try again.${resetEchoStyle}"
		else
		    echo "${boldRedEchoStyle}        Docker installation failed. Termination of instance failed. Please close it manually and try again.${resetEchoStyle}"
		fi
		exit -1
	fi

    echo "			Start docker service${resetEchoStyle}"
	ssh -oStrictHostKeyChecking=no -i "${SCRIPT_PATH}/${var_sshKeyName}.pem" ec2-user@${var_instanceIP} sudo service docker start
	if [ $? -ne 0 ]; then
		varResult=$(stopAWS_EC2)
		if [ $varResult -eq 0 ]; then
		    echo "${boldRedEchoStyle}        Docker failed to start. Please try again.${resetEchoStyle}"
		else
		    echo "${boldRedEchoStyle}        Docker failed to start. Termination of instance failed. Please close it manually and try again.${resetEchoStyle}"
		fi
		exit -1
	fi

    echo "			Run application in docker${resetEchoStyle}"
    ssh -oStrictHostKeyChecking=no -i "${SCRIPT_PATH}/${var_sshKeyName}.pem" ec2-user@${var_instanceIP} sudo docker run -d -p 80:80 ${var_dockerIdUser}/${var_imageName}
    if [ $? -ne 0 ]; then
		varResult=$(stopAWS_EC2)
		if [ $varResult -eq 0 ]; then
		    echo "${boldRedEchoStyle}        Application failed to start. Please try again.${resetEchoStyle}"
		else
		    echo "${boldRedEchoStyle}        Application failed to start. Termination of instance failed. Please close it manually and try again.${resetEchoStyle}"
		fi
		exit -1
	fi

    echo "${boldGreenEchoStyle}	-> Step Cloud: Install with AWS DONE! You can try your new application at the following url http://${var_instanceIP}${resetEchoStyle}"
fi


echo
echo "${boldOrangeEchoStyle}End of auto installation!${resetEchoStyle}"
echo
