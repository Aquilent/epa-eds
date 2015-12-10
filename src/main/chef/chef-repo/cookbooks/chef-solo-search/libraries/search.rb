#
# Copyright 2011, edelight GmbH
#
# Authors:
#       Markus Korn <markus.korn@edelight.de>
#       Seth Chisamore <schisamo@opscode.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

if Chef::Config[:solo]

  # add currrent dir to load path
  $: << File.dirname(__FILE__)

  # All chef/solr_query/* classes were removed in Chef 11; Load vendored copy
  # that ships with this cookbook
  $: << File.expand_path("vendor", File.dirname(__FILE__)) if Chef::VERSION.to_i >= 11

  # Ensure the treetop gem is installed and available
  treetop_loadable = false
  begin
    gem 'treetop', '=1.5.1'
    require 'treetop'
    treetop_loadable = true
  rescue LoadError
    run_context = Chef::RunContext.new(Chef::Node.new, {}, Chef::EventDispatch::Dispatcher.new)
    chef_gem = Chef::Resource::ChefGem.new("treetop", run_context)
    chef_gem.version('= 1.5.1')
    chef_gem.run_action(:install)
    #chef gem isn't run in whyrun mode
    treetop_loadable = !Chef::Config[:why_run]
  end

  # Ensure encrypted_data_bag_secret is available (or not)
  if Chef::Config[:encrypted_data_bag_secret] && 
    !File.exist?(Chef::Config[:encrypted_data_bag_secret])

    Chef::Log.warn "encrypted_data_bag_Secret is set but file does not exist. Unsetting"
    Chef::Config[:encrypted_data_bag_secret] = nil
  end

  PARSER_LOADED = false
  if treetop_loadable
    require 'search/overrides'
    require 'search/parser'
    PARSER_LOADED = true
  end

  module Search; class Helper; end; end

  # The search and data_bag related methods moved form `Chef::Mixin::Language`
  # to `Chef::DSL::DataQuery` in Chef 11.
  if Chef::VERSION.to_i >= 11
    module Chef::DSL::DataQuery
      def self.included(base)
        base.send(:include, Search::Overrides) if PARSER_LOADED
      end
    end
    Search::Helper.send(:include, Chef::DSL::DataQuery)
  else
    module Chef::Mixin::Language
      def self.included(base)
        base.send(:include, Search::Overrides) if PARSER_LOADED
      end
    end
    Search::Helper.send(:include, Chef::Mixin::Language)
  end

  class Chef
    class Search
      class Query
        def initialize(*args)
        end
        def search(*args, &block)
          if PARSER_LOADED
            ::Search::Helper.new.search(*args, &block)
          else
            Chef::Log.warn("In whyrun mode, so can't perform search unless you manually install treetop in chef environment.")
            []
          end
        end
      end
    end
  end
end
