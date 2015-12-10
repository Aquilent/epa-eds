#
# Cookbook Name:: epa_eds
# Recipe:: aws_logwatch
#
# Copyright 2015, Aquilent, Inc
# See https://github.com/Aquilent/drug-adverse-event-browser/blob/test/LICENSE.txt
#
# 
#

PROJECT_NAME = node['epa_eds']['project_name']
ENVIRONMENT = node['epa_eds']['environment']
SERVER_TYPE=node['epa_eds']['server_type']

logwatch_files = node['epa_eds']['aws_logwatch']['default_files']
files = node['epa_eds']['aws_logwatch']['files']
logwatch_files = logwatch_files.merge(files) if !files.nil?

epa_eds_aws_logwatch "#{SERVER_TYPE}" do
    region node['epa_eds']['aws_region']
    log_group node['epa_eds']['aws_logwatch']['log_group']
    files logwatch_files 
end

