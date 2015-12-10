#
# Copyright 2011, edelight GmbH
#
# Authors:
#       Markus Korn <markus.korn@edelight.de>
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

require "test/unit"
require "chef"

# mocking chef such that it thinks it's running as chef-solo and knows about
# the location of the data_bag
Chef::Config[:solo] = true
Chef::Config[:role_path] = "tests/data/roles"

module SearchNodeTests
  def test_list_roles
    roles = search(:role)
    assert_equal Chef::Role, roles.find{ |n| n.name == "master" }.class
    assert_equal "This is just a master role, no big deal.", roles.find{ |n| n.name == "master" }.description
    assert_equal Chef::Role, roles.find{ |n| n.name == "slave" }.class
    assert_equal "This is just a slave role, no big deal.", roles.find{ |n| n.name == "slave" }.description
    assert_equal Chef::Role, roles.find{ |n| n.name == "other" }.class
    assert_equal "AN Other Role", roles.find{ |n| n.name == "other" }.description
    assert_equal 3, roles.length
  end
end

class TestRoles < Test::Unit::TestCase
  include SearchNodeTests

  def search(*args, &block)
    # wrapper around creating a new Recipe instance and calling search on it
    node = Chef::Node.new()
    cookbooks = Chef::CookbookCollection.new()
    run_context = Chef::RunContext.new(node, cookbooks, nil)
    return Chef::Recipe.new("test_cookbook", "test_recipe", run_context).search(*args, &block)
  end
end
