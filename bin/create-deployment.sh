
#----------------------------------------------------------------------------
#  Create scripts
#----------------------------------------------------------------------------

#!/bin/bash

AWS="${AWS_HOME}/aws"

# ---------------------------------------------------------------------------------------------
#  Common functions
# ---------------------------------------------------------------------------------------------

function common_write {
  local text="$1"
  local level="$2"

  #echo level=${level} VERBOSE=${VERBOSE}
  if [ "${level}" == "verbose" ];  then
      if [ "${VERBOSE}" ]; then
          echo "   "$text 1>&2
      fi
  else
      echo $text 1>&2
  fi
}

function common_verbose {
  common_write "$1" "verbose"
}


function common_convertPath {
  local path=$1
  path1=`echo $path | sed 's@\\\@\/@g'`
  path2=`echo $path1 | sed 's@^\([a-zA-Z]\):@\/\1@g'`
  echo $path2
}

# ---------------------------------------------------------------------------------------------
#  Common functions
# ---------------------------------------------------------------------------------------------

function aws_get_profile {
    local profile="${AWS_PROFILE:-default}"
    echo ${profile}
}

function aws {
    local command="$1"
    local subcommand="$2"
    if [ "${AWS_PROFILE}" == "" ]; then
        local profile=`aws_get_profile`
        AWS_REGION=`aws configure get region --profile "${profile}"`
    fi
    shift; shift
    "${AWS}" deploy "${command}" "${subcommand}"--region "${AWS_REGION}" "$@"
}

function set_branch_name {
    BRANCH_NAME="$1"
}

function set_environment {
    ENVIRONMENT="$1"
    case $ENVIRONMENT in
        int|test|prod)    ;
        *)                echo "Unknwon environment '${ENVIRONMENT}'."
                          exit 1
                          ;;
    esac
}

function set_config_file {
    CONFIG_FILE=`common_convertPath $1`
    if [ ! -f "${CONFIG_FILE}" ];  then
        echo "Configuration file '${CONFIG_FILE}' not found."
        exit 1
    fi   
}

function get_parameters {
    while test $# -gt 0; do
        #echo "Checking $1 $2"
        case $1 in
          -b|--branch)          shift; set_branch_name "$1" ;;
          -c|--configfile)      shift; set_config_file "$1" ;;
          -e|--environment)     shift; set_environment "$1" ;;
          -v|--verbose)         VERBOSE='true' ;;
          -f|--force)           FORCE='true' ;;
        esac
        shift
    done

}

function get_properties {
    if [ "${CONFIG_FILE}" == "" ];  then
      echo "No configuration file provided."
      exit 1
    fi  
    if [ "${BRANCH_NAME}" == "" ]; then
        BRANCH_NAME="master"
    fi  
    BUCKET_NAME=`common_getProperty "${CONFIG_FILE}" "S3_BUCKET_NAME"`
    PROJECT=`common_getProperty "${CONFIG_FILE}" "PROJECT_NAME"`
    CHARGE_CODE=`common_getProperty "${CONFIG_FILE}" "CHARGE_CODE"`
    
    #GITHUB_REPO="Aquilent/drug-adverse-event-browser"

}
function initialize {
    get_parameters "$@"
    get_properties
}



function create_deploy_tag {
    local name="$1"
    local value="$2"
    echo "{\"Key\":${name}\",\"Value\":\"${value}\",\"Type\":\"KEY_AND_VALUE\"}"
}

function create_deploy_tags {
    local project="$1"
    local environment="$2"
    local tier="${3:-web}"
    local project_tag=`create_deploy_tag "Project", "${PROJECT}"`
    local environment_tag=`create_deploy_tag "Environment", "${environment\}"`
    local tier_tag=`create_deploy_tag "Tier", "${tier}"`
    echo "[${project_tag},${environment_tag},${tier_tag}]"
}

function create_deployment {
    local application_name="${PROJECT}-drug-adverse-event-browser"
    local config_name="${PROJECT}-deploy-config"
    aws deploy create-application --application-name "${application_name}"
    aws-deploy create-deploy-config -deployment-config-name "${config_name}" \
        --minimum-healthy-hosts "value=1,type=HOSTCOUNT"

    local deploy_group= `aws-deploy create-deployment-group \   
        --application-name "${application_name}" \
        --deployment-group-name "${PROJECT}-int" \
        --ec2-tag-filters `create_deploy_tags "${PROJECT}" "int" "web"`
        --service-role-arn "${INT_WEB_SERVER_ROLE}"`

    #aws deploy register

    # aws deploy create-deployment --application-name "${APPNAME}" \
    #     --deployment-group-name "${DEPLOY_GROUP}"\
    #     --deployment-config-name "${DEPLOY_CONFIG}"`

}


initialize "$@"
create_deployment

