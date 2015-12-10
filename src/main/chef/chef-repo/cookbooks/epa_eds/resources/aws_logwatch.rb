#
# Cookbook Name:: epa_eds
# Resource:: aws_logwatch
#
# Copyright 2015, Aquilent, Inc.  All rights reserved.
# See https://github.com/Aquilent/drug-adverse-event-browser/blob/test/LICENSE.txt

actions :install
default_action :install

attribute :name, :kind_of => String, :name_attribute => true
attribute :region, :kind_of => String, :default => 'us-east-1'
attribute :log_group, :kind_of => String
attribute :files, :kind_of => Hash, :default => nil

