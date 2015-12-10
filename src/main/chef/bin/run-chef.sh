#!/bin/sh

SCRIPT_NAME=$0

LOG_DIR="/var/log/epa-eds"
LOG_FILE="${LOG_DIR}/bootstrap.log"

BOOTSTRAP_HOME="/var/tmp/epa-eds"

mkdir -p "${LOG_DIR}"

if [ ! -f "${LOG_FILE}" ]; then
  echo "" > "${LOG_FILE}"
fi  

function error_exit {
  local message="$1"
  echo "${SCRIPT_NAME}: ${message}" 1>&2
  exit 1
}

function log {
  local now="$(date +'%Y-%m-%d %H:%M:%S,%3N')"
  echo $now $*
  echo $now $* >> "${LOG_FILE}"
}

function log_section {
  local section="$1"
  local separator="---------------------------------------------------------------------"
  log $separator
  log "          ${section}"
  log $separator
}

# Set defaults
log_location="--logfile ${LOG_FILE}" 
log_level=info

while test $# -gt 0; do
  case $1 in
    --yum-security-only) 
        yum_security_only="true"
        ;;
    --yum-suppress) 
        yum_suppress="true"
        ;;
    --log-stdout)
        log_location=
        ;;
    --log-debug)
        log_level=debug
        ;;
    --config-file)
        shift
        configFile=$1
        ;;
    *)
        if [ "${configFile}" == "" ]; then
          configFile=$1
        else
          log "Ignoring $1. JSON attribute file already set to '${configFile}'"
        fi
        ;;
  esac
  shift
done  

if [ ! -f $configFile ];  then
    error_exit "No chef json-attributes file given"
fi

SOLO_CONFIG_FILE="${BOOTSTRAP_HOME}/chef/chef/solo.rb"
if [ ! -f "${SOLO_CONFIG_FILE}" ]; then
    error_exit "Chef Solo configuration file ${SOLO_CONFIG_FILE} not found!"
fi

${BOOTSTRAP_HOME}/chef/bin/install-chef.sh

log_section "Updating system"
if [ "${yum_suppress}" == "true" ]; then
  log "----- Not running yum at all"
else   
  log  "----- Updating system with all updates"
  yum -y update
fi  


if [[ "${configFile}" != *.json ]];  then
    configFile="${configFile}.json"
fi

if [ -f $configFile ];  then
  log_section "Run Chef"
  PATH=${PATH}:/opt/chef/bin
  log "----- configuration: json-attributes file=${configFile}"
  log "----- logging: location=${log_location}, level=${log_level}"
  chef-client --local-mode -c $SOLO_CONFIG_FILE $log_location --json-attributes $configFile \
    --log_level "${log_level}"
else
    error_exit "Chef json-attributes file '${configFile}'' not found!"
fi
