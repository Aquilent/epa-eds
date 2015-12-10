#
# Cookbook Name:: epa_eds
# Recipe:: bastion
#
# Copyright 2015, Aquilent, Inc.  All rights reserved.
# See https://github.com/Aquilent/drug-adverse-event-browser/blob/test/LICENSE.txt
#
# 
#


#------------------------------------------------------------------------------
#             Install rsynch
#------------------------------------------------------------------------------

include_recipe "rsync"


#------------------------------------------------------------------------------
#             Install PHP (for unit testing)
#------------------------------------------------------------------------------

epa_eds_php "bastion" do
    packages %w[php-mbstring php-gd php-pdo php-dom php-mysql php-devel 
        php-openssl php-mcrypt php-tokenizer]
    action :install
end

#------------------------------------------------------------------------------
#             Install Apache
#------------------------------------------------------------------------------

epa_eds_httpd "bastion" do
    modules_default %w[dir]
    modules_no_config %w[proxy]
    modules_custom_config %w[proxy_http]
    action :install
end


#------------------------------------------------------------------------------
#             Install life-cycle management
#------------------------------------------------------------------------------

package "git" do
end

[ "manage-code", "synchronize", "setup-jenkins"].each do |name|
  epa_eds_platform "#{name}" do
      template_source_dir "bastion/platform/bin"
      action :install_binary
  end
end

[ "manage.conf" ].each do |name|
  epa_eds_platform "#{name}" do
      template_source_dir "bastion/platform/conf"
      action :install_configuration
  end
end

#------------------------------------------------------------------------------
#             Install Jenkins
#------------------------------------------------------------------------------


node.default['jenkins']['master']['install_method'] = 'package'

include_recipe "jenkins::java"
include_recipe "jenkins::master"

jenkins_user "jenkins-admin" do
    password "ChangeMeNow"
end

%w[int test prod].each do |env|

  config_file = File.join(Chef::Config[:file_cache_path], "deploy-#{env}.xml")
  template config_file do
    source "bastion/jenkins/deploy-#{env}.xml.erb"
  end

  jenkins_job "deploy-to-#{env}" do
    config config_file
    action :create
  end

end  

[ "setup-jenkins", "setup-jenkins-credentials" ].each do |name|
    epa_eds_platform "#{name}" do
        template_source_dir "bastion/platform/bin"
        action :install_binary
    end
end

message = <<EOH

=============================================================================
Jenkins uses script to install new version of the code on the web server.
To do so securely Jenkis needs to have access to security keys that enable
access to the remote web servers.

Once the Chef provisioinng completes, use ssh to connect to this server 
and run the following command to setup those keys:
        sudo /opt/epa-eds/bin/setup-jenkins
Verify the signatures of the hosts when prompted.
If asked for a password, simply click the <Enter> key"

NOTE: We not deploying using Vagrant, you must copy the keys to the ~/.ssh
   directory of the user used to run the Chef scripts.
=============================================================================

EOH
Chef::Log.warn(message)


#------------------------------------------------------------------------------
#             Install Selenium and PhantomJS
#------------------------------------------------------------------------------

# case node['kernel']['machine'].to_s
# when 'x86_64' 
#     PHANTOMJS_ARCH = "x86_64"
# when 'i386'   
#     PHANTOMJS_ARCH = "i386"
# else 
#     PHANTOMJS_ARCH=nil
# end

# if PHANTOMJS_ARCH.nil? then
#   message = <<EOH

# =============================================================================
# We currently do not support PhantomJS for your kernel type (#{node['kernel']['machine']}).
# PhantomJS will not be provisioned, such that it is not possible to run 
# Selenium tests.
# =============================================================================
# EOH
#   Chef::Log.warn(message)
# else
#   directory "/opt/phantomjs/" do
#       mode "755"
#       owner "root"
#       group "root"
#   end 

#   directory "/opt/phantomjs/bin" do
#       mode "755"
#       owner "root"
#       group "root"
#   end 

#   cookbook_file "/opt/phantomjs/bin/phantomjs" do
#       source "bastion/phantomjs-#{PHANTOMJS_ARCH}"
#       mode "755"
#       owner "root"
#       group "root"
#   end

#   # ensure phantomjs JS is on the (standard) path, such that the selenium 
#   # PhantomJS webdriver can find the executable
#   link "/usr/bin/phantomjs" do
#       link_type "symbolic"
#       to "/opt/phantomjs/bin/phantomjs"
#   end

  [ 'firefox', 'xorg-x11-server-Xvfb' ].each do |name|
    yum_package "#{name}"
  end

  [ "run-selenium-tests" ].each do |name|
    epa_eds_platform "#{name}" do
        template_source_dir "bastion/platform/bin"
        action :install_binary
    end
  end


# end

