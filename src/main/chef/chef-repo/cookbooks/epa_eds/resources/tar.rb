#
# Cookbook Name:: epa_eds
# Resource:: tar
#
# Copyright 2015, Aquilent, Inc.  All rights reserved.
# See https://github.com/Aquilent/drug-adverse-event-browser/blob/test/LICENSE.txt

actions :unpack

attribute :name, :kind_of => String, :name_attribute => true
attribute :source, :kind_of => String
attribute :destination, :kind_of => String
attribute :owner, :kind_of => String, :default => 'root'
attribute :group, :kind_of => String, :default => 'root'
attribute :mode, :kind_of => String, :default => "600"
attribute :extension, :kind_of => String, "default" => "tar.gz"
attribute :options, :kind_of => String, :default => ""

