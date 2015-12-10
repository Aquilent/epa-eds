#
# Cookbook Name:: epa_eds
# Resource:: iptables
#
# Copyright 2015, Aquilent, Inc.  All rights reserved.
# See https://github.com/Aquilent/drug-adverse-event-browser/blob/test/LICENSE.txt

actions :install

attribute :name, :kind_of => String, :name_attribute => true
attribute :rules, "kind_of" => Hash
attribute :recipe, "kind_of" => String, :default => "platform"

