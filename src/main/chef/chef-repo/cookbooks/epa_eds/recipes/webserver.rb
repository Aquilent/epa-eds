#
# Cookbook Name:: epa_eds
# Recipe:: webserver
#
# Copyright 2015, Aquilent, Inc
# See https://github.com/Aquilent/drug-adverse-event-browser/blob/test/LICENSE.txt
#
# 
#

require "rubygems"
require "active_support/core_ext/object/blank"

#------------------------------------------------------------------------------
#             Install rsynch
#------------------------------------------------------------------------------

include_recipe "rsync"

#------------------------------------------------------------------------------
#             Install PHP
#------------------------------------------------------------------------------

epa_eds_php "webserver" do
    packages %w[php-mbstring php-gd php-pdo php-dom php-mysql php-devel 
        php-openssl php-mcrypt php-tokenizer]
    action :install
end

#------------------------------------------------------------------------------
#             Install Apache
#------------------------------------------------------------------------------

APPLICATION_HOME=node['epa_eds']['webserver']['application_home']

USE_VARNISH = (node['epa_eds']['webserver']['use_varnish'])
HTTPD_PORT = (USE_VARNISH ? "8080" : "80")

directory "#{APPLICATION_HOME}" do 
    owner node['apache']['apache']
    group node['apache']['apache']
    mode '0755'
end

epa_eds_httpd "webserver" do
    listen_ports ["#{HTTPD_PORT}"]
    doc_root "#{APPLICATION_HOME}/public"
    modules_default %w[dir expires rewrite]
    action :install
end

[ "start-services", "stop-services", "verify-services", "set-permissions",
  "install-php-composer"
].each do |name|
  epa_eds_platform "#{name}" do
      template_source_dir "webserver/platform/bin"
      action :install_binary
  end
end



#------------------------------------------------------------------------------
#             Install Varnish
#------------------------------------------------------------------------------
if (USE_VARNISH) then

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

    template "#{node['varnish']['dir']}/no_cache.vcl" do
        source "varnish/no_cache.vcl.erb"
        owner node['varnish']['user']
        group node['varnish']['group']
    end

end
