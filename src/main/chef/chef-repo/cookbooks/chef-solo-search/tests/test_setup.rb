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

class TestSetup < Test::Unit::TestCase
  def load_search
    load File.expand_path('../../libraries/search.rb', __FILE__)
  end

  def test_keep_encrypted_data_bag_key_if_good
    path = "#{File.dirname(__FILE__)}/data/encrypted_data_bag_secret"
    Chef::Config[:encrypted_data_bag_secret] = path
    load_search
    assert_equal Chef::Config[:encrypted_data_bag_secret], path
  end

  def test_reset_encrypted_data_bag_key_if_bad
    Chef::Config[:encrypted_data_bag_secret] = 'foo'
    load_search
    assert_nil Chef::Config[:encrypted_data_bag_secret]
  end
end