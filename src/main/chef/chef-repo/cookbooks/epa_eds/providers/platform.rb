#
# Cookbook Name:: epa_eds
# Provider:: platform
#
# Copyright 2015, Aquilent, Inc.
# See https://github.com/Aquilent/drug-adverse-event-browser/blob/test/LICENSE.txt
#

def whyrun_supported?
  false
end


action :install do
   platform_install(run_context)
end

action :install_binary do
   platform_install_binary(new_resource.name, new_resource.template_source_dir, 
      new_resource.variables)
end

action :install_configuration do
   platform_install_configuration(new_resource.name, new_resource.template_source_dir, 
      new_resource.variables)
end

action :install_template do
   platform_install_template(new_resource.name, new_resource.type, new_resource.template_source_dir, 
      new_resource.variables)
end


def platform_install (context)
    home_dir = node['epa_eds']['home_dir']
    [ "#{home_dir}",
      "#{home_dir}/bin",
      "#{home_dir}/conf",
      "#{home_dir}/templates"
    ].each do |path|
        directory path do
          owner 'root'
          group 'root'
          mode '0755'
          action :create
        end
    end

    platform_install_binary "functions"
    platform_install_additional_repos
    platform_install_ntp

    iptables_info = node['epa_eds']['iptables']
    if iptables_info['enabled'] then
        epa_eds_iptables "platform-iptables" do
            recipe "platform"
            rules iptables_info['rules']
            action :install
        end
    else
        Chef::Log.warn("Firewall (iptables) is not enabled")
    end

    platform_harden
end


def platform_install_binary (name, source_dir = nil, variables = nil)
    home_dir = node['epa_eds']['home_dir']
    if source_dir.nil? then
        source_dir = "platform/bin"
    end
    template "#{home_dir}/bin/#{name}" do
       source "#{source_dir}/#{name}.erb"
       mode 0755
       owner "root"
       group "root"
       variables variables
    end
end   

def platform_install_configuration (name, source_dir = nil, variables = nil)
    if source_dir.nil? then
        source_dir = "platform/conf"
    end
    home_dir = node['epa_eds']['home_dir']
    template "#{home_dir}/conf/#{name}" do
       source "#{source_dir}/#{name}.erb"
       mode 0655
       owner "root"
       group "root"
       variables variables
    end
end 

def platform_install_template (name, type, source_dir = nil, variables = nil)
    Chef::Application.fatal!("No 'type' specified ", 1) if type.nil?
    if source_dir.nil? then
        source_dir = "platform/templates"
    end
    home_dir = node['epa_eds']['home_dir']
    directory "#{home_dir}/templates/#{type}" do
        owner 'root'
        group 'root'
        mode '0755'
        action :create
    end
    template "#{home_dir}/templates/#{type}/#{name}" do
        source "#{source_dir}/#{name}.erb"
        mode 0655
        owner "root"
        group "root"
        variables variables
    end
end


def platform_install_additional_repos
    if node['platform_family'] == 'rhel' then

        epel_rpm_file_name = node['epa_eds']['epel_repo']['file_name']
        epel_rpm_file_path = "#{Chef::Config[:file_cache_path]}/#{epel_rpm_file_name}"

        cookbook_file "#{epel_rpm_file_name}" do
            path "#{epel_rpm_file_path}"
            source "platform/#{epel_rpm_file_name}"
            owner 'root'
            group 'root'
        end

        ruby_block "install-epel" do
            block do
                Chef::Log.info("Install #{epel_rpm_file_path}")
                do_bash("install-epel", "/bin/rpm -Uvh #{epel_rpm_file_path}")
                do_bash("remove-epel-rpm", "rm -f #{epel_rpm_file_path}")
            end
        end

        package "policycoreutils-python" do
        end

    end

    current_platform = node['platform']
    extra_repo_platforms = node['epa_eds']['yum_extra_repo_names']
    Chef::Log.info("Checking '#{extra_repo_platforms}' for current platform 'current_platform'")
    extra_repo_names = extra_repo_platforms[current_platform]
    if extra_repo_names.nil? then
         Chef::Log.info("No extra repos foudnd for platform '#{current_platform}'")
    else 
        extra_repo_names.each do |repo_name, actual_name|
            # Note: Must embed variable in string, because closure
            ruby_block "enable-#{repo_name}" do
                block do 
                    Chef::Log.info("Enabling yum repo '#{actual_name}'")
                    do_bash("enable-#{repo_name}", "yum-config-manager --enable #{actual_name}")
                end
            end
        end
    end
end


def platform_install_ntp
    # See https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/6/html/
    #    Deployment_Guide/
    #    sect-Date_and_Time_Configuration-Command_Line_Configuration-Network_Time_Protocol.html
    # See also http://www.team-cymru.org/secure-ntp-template.html
    package "ntp" do
    end
    # Unnecessary, as this is the CentOS/RHEL default
    #template "/etc/ntp.conf" do
    #  source "platform/ntp/ntp.conf.erb"
    #  owner 'root'
    #  group 'root'
    #  mode '0644'
    #end
    ruby_block "platform-install-ntpd" do
        block do
            Chef::Log.info("Install Network Time Protocol service")
            do_bash("ntpd-service-start", "service ntpd restart")
            do_bash("ntpd-service-persist", "chkconfig ntpd on")
        end
    end
end

def platform_harden
    ruby_block "platform-uninstall-postfix" do
        block do
            Chef::Log.info("Uninstall Postfix/Master service")
            do_bash("postfix-service-stop", "service postfix stop")
            do_bash("postfix-service-persist", "chkconfig postfix off")
        end
    end
end
