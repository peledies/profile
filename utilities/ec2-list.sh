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

while getopts ":p:r:" opt; do
  case ${opt} in
    p )
      PROFILE=$OPTARG
      ;;
    r )
      REGION=$OPTARG
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

IFS=$'\n'

scan_region() {
    INSTANCES=($(aws ec2 describe-instances \
        --query 'Reservations[*].Instances[*].{InstanceId:InstanceId,Status:State.Name,Tags:Tags[?Key == `Name`] | [0].Value}' \
        --region $REGION \
        --profile $PROFILE \
        --output text))

    if [[ ${INSTANCES[@]} ]];then
        echo -e "\n${gold}Instances found in region [${magenta}$REGION${gold}]${default}\n"
        for INSTANCE in ${INSTANCES[@]}
        do
            echo $INSTANCE | awk \
                -v red=$red \
                -v yellow=$gold \
                -v green=$green \
                -v reset=$default \
                -v cyan=$cyan \
                -v magenta=$magenta \
                '{
                    if ($2=="stopped") color=red; else color=cyan;
                    printf "%-20s %s %-10s %s%s%s\n", $1, color, $2, magenta, $3, reset
                }'
        done
    fi
}

if [ -z "$REGION" ];then
    for REGION in ${awsRegions[@]}
    do
        scan_region $REGION $PROFILE
    done
else
    scan_region $REGION $PROFILE
fi