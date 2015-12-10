#
# Cookbook Name:: epa_eds
# Provider:: aws_logwatch
#
# Copyright 2015, Aquilent, Inc.
# See https://github.com/Aquilent/drug-adverse-event-browser/blob/test/LICENSE.txt
#

def whyrun_supported?
  false
end

action :install do
    awslogwatch_install(new_resource.name, new_resource.region, new_resource.log_group, 
        new_resource.files)
end

def awslogwatch_install (name, region, log_group, files)
    Chef::Log.info("Installing '#{name}' for '#{log_group}'") 
    directory "/var/awslogs" do
        owner 'root'
        group 'root'
        mode '0600'
    end
    directory "/var/awslogs/state" do
        owner 'root'
        group 'root'
        mode '0600'
    end
    directory "/etc/awslogs" do
        owner 'root'
        group 'root'
        mode '0600'
    end
    # Use the aws.logs erb template to install aws logs now
    template "/etc/awslogs/awslogs.conf" do
        source "aws_logwatch/platform/templates/awslogs.conf.erb"
        owner 'root'
        group 'root'
        mode 0400
        variables ({
          :prefix => name, 
          :log_group => log_group, 
          :files => files 
        })
    end
    # Use the aws.logs erb template to install aws logs as a platform template
    # Note that the prefix is set as a the SERVER-TYPE placeholder only, 
    # as each environment will have its own aws log group
    # The Log group will be set as the AWS_LOGGROUP placeholder
    # The placeholders are replaced during configuration at launch, when running launch.sh
    # The values are taken from /opt/epa-eds/conf/launch.conf
    [ "awslogs.conf" ].each do |name|
        epa_eds_platform "#{name}" do
            type "aws_logwatch"
            template_source_dir "aws_logwatch/platform/templates"
            action :install_template
            variables ({
              :prefix => "SERVER_TYPE", 
              :log_group => "AWS_LOGGROUP", 
              :files => files 
            })
        end
    end
    if node['platform'] == 'amazon' then
        Chef::Log.info("Simple install on Amazon linux")
        package "awslogs" do
        end
    else 
        remote_file "awslogs-agent-setup.py" do
          source "#{node['epa_eds']['aws_logwatch']['agent_setup_py']}"
          path "/tmp/awslogs-agent-setup.py"
          group 'root'
          owner 'root'
          mode 0700
        end
        ruby_block "awslogs-installer" do
            block do
                Chef::Log.info("Setup awslogs-agent (on Linux platform other than Amazon Linux)") 
                awslogs_installer = "python /tmp/awslogs-agent-setup.py --non-interactive \
                        --region #{region} --configfile /etc/awslogs/awslogs.conf
                    rm -f  /tmp/awslogs-agent-setup.py"
                do_bash("awslogs-installer", awslogs_installer)
            end
        end
    end

    service "awslogs" do
        supports :restart => true, :reload => true
        subscribes :reload, "template[/etc/awslogs/awslogs]", :immediately
        action [:enable, :start]
    end

end



