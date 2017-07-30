#!/bin/bash

pushd `dirname $0` > /dev/null
SCRIPT_NAME=`basename $0`
SCRIPT_PATH=`pwd`
popd > /dev/null

var_stepChoice=0
var_interactionChoice=1
var_imageName="wallouf-appdirect-application"

function print_usage() {
	clear
	echo 
	echo 
	echo "AUTO INSTALL SCRIPT"
	echo 
	echo "	WARNING:"
	echo "		- You need to have apache maven > 3.5 and java 1.8 at least to build"
	echo "		- Before using this script, you need to set up your credentials into the CREDENTIALS.properties file."
	echo 
	echo "	STEPS:"
	echo 
	echo "	1 - Build components with maven"
	echo "	2 - Build docker image"
	echo "	3 - Push docker image"
	echo "	4 - Deploy image in AWS"
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
    echo "  -i,--install-only			Install only with AWS the application image."
    echo
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
if [[ ${var_stepChoice} -eq 0 ]] || [[ ${var_stepChoice} -eq 1 ]]; then
	echo
    echo "${boldOrangeEchoStyle}	-> Step 1: Build with maven...${resetEchoStyle}"
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
if [[ ${var_stepChoice} -eq 0 ]] || [[ ${var_stepChoice} -eq 2 ]]; then
	echo
    echo "${boldOrangeEchoStyle}	-> Step 2: Build with docker...${resetEchoStyle}"

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
if [[ ${var_stepChoice} -eq 0 ]] || [[ ${var_stepChoice} -eq 3 ]]; then
	echo
    echo "${boldOrangeEchoStyle}	-> Step 3: Push with docker...${resetEchoStyle}"
    echo "${boldGreenEchoStyle}	-> Step 3: Push with docker DONE!${resetEchoStyle}"
fi


#STEP 4
if [[ ${var_stepChoice} -eq 0 ]] || [[ ${var_stepChoice} -eq 4 ]]; then
	echo
    echo "${boldOrangeEchoStyle}	-> Step 4: Install with AWS...${resetEchoStyle}"

    sudo service docker start
	if [ $? -ne 0 ]; then
	    echo "${boldRedEchoStyle}        Cannot start docker service. Please fix docker and try again.${resetEchoStyle}"
	    exit -1
	fi

    sudo docker run -d -p 8080:8080 --name ${var_imageName} ${var_imageName}
	if [ $? -ne 0 ]; then
	    echo "${boldRedEchoStyle}        Deployment failed with docker. Please fix project and try again.${resetEchoStyle}"
	    exit -1
	fi

    echo "${boldGreenEchoStyle}	-> Step 4: Install with AWS DONE!${resetEchoStyle}"
fi


echo
echo "${boldOrangeEchoStyle}End of auto installation!${resetEchoStyle}"
echo
