#
# Cookbook Name:: epa_eds
# Resource:: platform
#
# Copyright 2015, Aquilent, Inc.  All rights reserved.
# See https://github.com/Aquilent/drug-adverse-event-browser/blob/test/LICENSE.txt

actions :install, :install_binary, :install_configuration, :install_template

attribute :name, :kind_of => String, :name_attribute => true
attribute :type, :kind_of => String, :default => nil
attribute :template_source_dir, :kind_of => String, :default => nil
attribute :variables, :kind_of => Hash, :default => nil

