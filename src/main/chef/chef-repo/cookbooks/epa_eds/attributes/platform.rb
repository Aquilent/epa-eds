#
# Cookbook Name:: epa_eds
# Attributes:: platform
#
# Copyright 2015, Aquilent, Inc
# See https://github.com/Aquilent/drug-adverse-event-browser/blob/test/LICENSE.txt
#
# 
#

default['epa_eds']['architecture'] = 'x86_64'
default['epa_eds']['home_dir'] = "/opt/epa-eds"
default['epa_eds']['iptables']['enabled'] = true
default['epa_eds']['epel_repo']['file_name'] = 'epel-release-6-8.noarch.rpm'
default['epa_eds']['epel_repo']['url'] = 
    'http://download.fedoraproject.org/pub/epel/6/x86_64'
default['epa_eds']['yum_extra_repo_names']['redhat']['rhel_server_releases_optional'] = 
    'rhui-REGION-rhel-server-releases-optional'

