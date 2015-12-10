#
# Cookbook Name:: epa_eds
# Recipe:: platform
#
# Copyright 2015, Aquilent, Inc
# See https://github.com/Aquilent/drug-adverse-event-browser/blob/test/LICENSE.txt
#
# 
#

OS_PLATFORM_INFO = <<PLATFORM_INFO
Installing epa-eds platform on the following OS:
    os=#{node['platform']}
    os_family=#{node['platform_family']}
    os_version=#{node['platform_version']}
PLATFORM_INFO

Chef::Log.info(OS_PLATFORM_INFO)

epa_eds_platform "platform" do
    action :install
end

