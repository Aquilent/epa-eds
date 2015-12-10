#!/bin/sh

function log {
  local now="$(date +'%Y-%m-%d %H:%M:%S,%3N')"
  echo $now $*
  echo $now $* >> /var/log/cfn-init.log
}

function log_section {
  local section="$1"
  local separator="---------------------------------------------------------------------"
  log $separator
  log "          ${section}"
  log $separator
}

log_section "Installing chef"

if [ ! -d /opt/chef ] ; then
	# Limiting Chef to the latest stable version 11 
	# Chef 12 currently has problems. This should be revisited in the future.
	curl -L https://www.opscode.com/chef/install.sh | bash  -s -- -v 11
else 
	log "Chef already installed; Skipping"	
fi	
