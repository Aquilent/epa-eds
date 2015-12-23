# -*- mode: ruby -*-
# vi: set ft=ruby :

def isEmpty(value) 
   return value.nil? || value.strip == ""
end

module Common

  APPLICATION_HOME="/var/www/epa-eds"
  
  # Environment variables. 
  # These must be set as environment variables in the calling command shell
  PROJECT_HOME = ENV['PROJECT_HOME']
  BRANCH_NAME = isEmpty(ENV['BRANCH_NAME']) ? 'master' : ENV['BRANCH_NAME']
  BRANCH_PATH = "#{PROJECT_HOME}/branches/#{BRANCH_NAME}"
  SOURCE_PATH = "#{BRANCH_PATH}/src/main"
  CHEF_SOURCE_PATH = "#{SOURCE_PATH}/chef"
  PROJECT_CHEF_HOME = "/var/tmp/epa-eds/chef"

  # IP_PREFIX is used to provide the private network IP prefix
  # Should be used in Vagrantfiles 
  # Ideally servers created use the standard IP address used for servers in AZ1 in the AWS VPC,
  # to simplify remembering the private network IP for servers
  # App and Web servers should use the Integration environment IP (51.x)
  IP_PREFIX = "192.168"

  # See http://opscode.github.io/bento/ for Vagrant boxes
  puts "--- ENV[DEFAULT_VAGRANT_BOX] = #{ENV['DEFAULT_VAGRANT_BOX']}"
  DEFAULT_VAGRANT_BOX = isEmpty(ENV['DEFAULT_VAGRANT_BOX']) ? "bento/centos-6.7" : 
  # strip string to avoid preceeding or trailing whitespace that cause the name to 
  # be incorrect, but it can be hard to determine why. Spaces can come from setting 
  # a variable in a command script, e.g. trailing spaces are included
     ENV['DEFAULT_VAGRANT_BOX'].strip

  puts "USERPROFILE=#{ENV["USERPROFILE"]}"
  VAGRANT_HOME = (isEmpty(ENV["VAGRANT_HOME"]) ? "#{ENV["USERPROFILE"]}/.vagrant.d" : 
    ENV["VAGRANT_HOME"]).gsub(/\\/, "/")

  puts "---------------------------------------------------------"
  puts " PROJECT_HOME          : #{PROJECT_HOME}"
  puts " BRANCH_NAME           : #{BRANCH_NAME}"
  puts " DEFAULT_VAGRANT_BOX   : #{DEFAULT_VAGRANT_BOX}"
  puts "---------------------------------------------------------"
  puts " WARNING: Running a virtual machine inside another "
  puts "     virtual machine may or may not work. "
  puts "     E.g. AWS WorkSpaces allows 32-bit Vagrant boxes, "
  puts "     but not 64-bit boxes! "
  puts "     You should switch to a i386 box, like bento/centos-6.7-i386"
  puts "---------------------------------------------------------"

end
