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
require 'test/unit'
require 'chef'

Chef::Config[:solo] = true
Chef::Config[:why_run] = true
Chef::Config[:data_bag_path] = "#{File.dirname(__FILE__)}/data/data_bags"

# # need to stub require.
module Kernel
  alias_method :original_require, :require
  def require name
    if $missing_gems && $missing_gems.include?(name)
      raise LoadError, "cannot load such file -- #{name}"
    else
      original_require name
    end
  end

  def with_raising_require(*missing_gems)
    $missing_gems = missing_gems
    yield
    $missing_gems = nil
  end
end

class MyStubWorks < Test::Unit::TestCase
  def test_require_works
    #no load error
    require 'ostruct'
    assert OpenStruct
  end

  def test_require_raises_exception
    with_raising_require('ostruct') do
      assert_raise(LoadError) { require 'ostruct' }
      require 'fileutils'
    end
  end
end

class WithWhyrun < Test::Unit::TestCase
  def search(*args, &block)
    Chef::Search::Query.new.search(*args, &block)
  end

  def load_search
    load File.expand_path('../../libraries/search.rb', __FILE__)
  end

  def test_doesnt_fail_without_treetop
    with_raising_require('treetop') { load_search }
    assert search(:users) == []
  end


  def test_runs_with_treetop_if_possible
    load_search
    assert search(:users).length == 4
  end
end