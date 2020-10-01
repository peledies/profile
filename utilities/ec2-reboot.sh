#!/bin/bash

PROJECT_ROOT=$(pwd)

green=$(tput setaf 2)
gold=$(tput setaf 3)
magenta=$(tput setaf 5)
cyan=$(tput setaf 6)
red=$(tput setaf 1)
default=$(tput sgr0)

awsRegions=(
    'us-east-1'
    'us-east-2'
    'us-west-1'
    'us-west-2'
    'ca-central-1'
    'eu-central-1'
    'eu-west-1'
    'eu-west-2'
    'eu-west-3'
    'eu-north-1'
    'sa-east-1'
)

while getopts ":p:r:n:" opt; do
  case ${opt} in
    p )
      PROFILE=$OPTARG
      ;;
    r )
      REGION=$OPTARG
      ;;
    n )
      NAME=$OPTARG
      ;;
    \? )
      echo "Invalid option: $OPTARG" 1>&2
      ;;
    : )
      echo "Invalid option: $OPTARG requires an argument" 1>&2
      ;;
  esac
done
shift $((OPTIND -1))

if [ -z "$NAME" ];then
    echo "${red}You must specify an EC2 instances Name tag value [-n].${default}"
    exit 1
fi

if [ -z "$PROFILE" ];then
    PROFILE='default'
fi

if [ -z "$REGION" ];then
    displayRegion='all'
else
    displayRegion=$REGION
fi

echo -e "\nUsing profile: [${gold}$PROFILE${default}]"
echo -e "Using region:  [${gold}$displayRegion${default}]\n"

reboot_instance() {
    echo -e "\tREBOOTING: [${red}$1${default}]"

    $(aws ec2 reboot-instances \
        --instance-ids $INSTANCEID \
        --region $REGION \
        --profile $PROFILE)
}

scan_region() {

    nameFilter="Name=tag:Name,Values=$NAME"

    INSTANCEID=$(aws ec2 describe-instances \
        --filters $nameFilter \
        --query 'Reservations[*].Instances[*].[InstanceId]' \
        --profile $PROFILE \
        --region $REGION \
        --output text)

    if [ ! -z "$INSTANCEID" ]
    then
        echo "Found ${cyan}$NAME${default} in region [${magenta}$REGION${default}]"
        echo -e "\tFOUND:     [${red}$INSTANCEID${default}]"
        reboot_instance $INSTANCEID $REGION $PROFILE
    fi

}

if [ -z "$REGION" ];then
    for REGION in ${awsRegions[@]}
    do
        scan_region $REGION $NAME $PROFILE
    done
else
    scan_region $REGION $NAME $PROFILE
fi