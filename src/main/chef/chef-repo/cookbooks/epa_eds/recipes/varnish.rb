#
# Cookbook Name:: epa_eds
# Recipe:: varnish
#
# Copyright 2015, Aquilent, Inc
# See https://github.com/Aquilent/drug-adverse-event-browser/blob/test/LICENSE.txt
#
# 
#

#------------------------------------------------------------------------------
#             Install rsynch
#------------------------------------------------------------------------------

include_recipe "rsync"

#------------------------------------------------------------------------------
#             Install Apache
#------------------------------------------------------------------------------

epa_eds_httpd "varnish" do
    listen_ports %w[8080]
    modules_no_config %w[proxy]
    modules_custom_config %w[proxy_http]
    action :install
end


#------------------------------------------------------------------------------
#             Install Varnish
#------------------------------------------------------------------------------

# override standard Varnish attributes
node.default['varnish']['storage'] = 'malloc';
case node[:platform_family]
when "rhel"
    node.default['varnish']['dir']     = "/etc/varnish"
    node.default['varnish']['default'] = "/etc/sysconfig/varnish"
end
node.default['varnish']['version'] = '3.0';
node.default['varnish']['listen_port'] = '80';

include_recipe "varnish"

override_template "#{node['varnish']['dir']}/#{node['varnish']['vcl_conf']}" do
    recipe_name "varnish"
end

[ "proxy_http.conf" ].each do |name|
  epa_eds_platform "#{name}" do
      type "varnish"
      template_source_dir "varnish/platform/templates"
      action :install_template
  end
end

template "#{node['varnish']['dir']}/no_cache.vcl" do
    source "varnish/no_cache.vcl.erb"
    owner node['varnish']['user']
    group node['varnish']['group']
end

