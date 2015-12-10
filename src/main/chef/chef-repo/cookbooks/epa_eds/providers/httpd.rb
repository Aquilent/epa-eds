#
# Cookbook Name:: epa_eds
# Provider:: httpd
#
# Copyright 2015, Aquilent, Inc.
# See https://github.com/Aquilent/drug-adverse-event-browser/blob/test/LICENSE.txt
#

def whyrun_supported?
  false
end

PLATFORM_HTTPD_DEFAULT_MODULES = %w[authz_host env deflate logio log_config mime]


action :install do
    platform_httpd_install(run_context, new_resource.name, new_resource.doc_root, 
        new_resource.listen_ports, new_resource.modules_default, new_resource.modules_custom_config, 
        new_resource.modules_disabled, new_resource.modules_no_config)
end

def platform_httpd_install (context, name, doc_root, listen_ports, modules_default, 
        modules_custom_config, modules_disabled, modules_no_config)

    context.include_recipe "selinux::permissive"

    default_site_enabled = ! doc_root.nil?
    modules = [PLATFORM_HTTPD_DEFAULT_MODULES, modules_default, modules_no_config].
        compact.reduce([], :+)

    Chef::Log.info("Enabling modules [#{modules}] with default-site " + (default_site_enabled ? 
        "enabled" : "disabled"))
    # override standard Apache2 attributes
    node.default['apache']['allow_default'] = 'None'
    node.default['apache']['default_site_enabled'] = default_site_enabled
    node.default['apache']['directory_index'] = 'disabled'
    node.default['apache']['directory_options'] = 'None'
    node.default['apache']['ext_status'] = false
    node.default['apache']['keepalivetimeout'] = 15
    if default_site_enabled then
        node.default['apache']['docroot_dir'] = doc_root
        node.force_override['apache']['docroot_dir'] = doc_root

        directory doc_root do
            owner 'root'
            group 'root'
            mode '0755'
            action :create
        end
    end
    node.default['apache']['default_modules'] = modules
    node.default['apache']['listen_ports'] = listen_ports
    node.default['apache']['serversignature'] = 'Off'
    node.default['apache']['servertokens'] = 'Prod'
    node.default['apache']['timeout'] = '120'
    node.default['apache']['traceenable'] = 'Off'

    context.include_recipe "apache2"

    if default_site_enabled then
        override_template("#{node['apache']['dir']}/sites-available/default", "default-site.erb") do
             recipe_name name
        end
    end

    if ! modules_custom_config.nil? then
        modules_custom_config.each do |module_name| 
            #Chef::Log.info("Configure module #{module_name}")
            apache_module module_name do
                conf true
            end
            Chef::Log.info("Replace module #{module_name} configuration file")
            override_template "#{node['apache']['dir']}/mods-available/#{module_name}.conf" do
                recipe_name name
            end
        end
    end

    if ! modules_no_config.nil? then
        modules_no_config.each do |module_name| 
            Chef::Log.info("Remove module #{module_name} configuration file")
            file "#{node['apache']['dir']}/mods-enabled/#{module_name}.conf" do
                action :delete
            end
        end
    end

    if ! modules_disabled.nil? then
        modules_disabled.each do |module_name| 
            Chef::Log.info("Disable module #{module_name}")
            apache_module "#{module_name}" do
                enable false
            end
        end
    end

# TODO:
#    set selinux permissions
#    set selinux to enforcing


end



