# Cookbook Name:: varnish
# Recipe:: repo
# Author:: Patrick Connolly <patrick@myplanetdigital.com>
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

case node['platform_family']
when 'debian'
  include_recipe 'apt'
  apt_repository 'varnish-cache' do
    uri "http://repo.varnish-cache.org/#{node['platform']}"
    distribution node['lsb']['codename']
    components ["varnish-#{node['varnish']['version']}"]
    key "http://repo.varnish-cache.org/#{node['platform']}/GPG-key.txt"
    deb_src true
    notifies 'nothing', 'execute[apt-get update]', 'immediately'
  end
when 'rhel', 'fedora'
  # CUSTOMIZATIONS to ensure that the Amazon platform version is converted to a RHEL version of 6
  case "#{node['platform_version'].to_i}"
  when '2013', '2014', 
     platform_version = '6'
  # ------------------------------------------------------------------------------------
  #  CUSTOMIZATION START: Added Amazon LInux 2015
  # ------------------------------------------------------------------------------------
  when '2015'
     platform_version = '7'
  # ------------------------------------------------------------------------------------
  #  CUSTOMIZATION END: Added Amazon LInux 2015
  # ------------------------------------------------------------------------------------
  else 
     platform_version = "#{node['platform_version'].to_i}"
  end    
  puts "VANISH on platform redhat el#{platform_version}"
  yum_repository 'varnish' do
    description "Varnish #{node['varnish']['version']} repo (#{node['platform_version']} - $basearch)"
    url "http://repo.varnish-cache.org/redhat/varnish-#{node['varnish']['version']}/el#{platform_version}/$basearch/"
    gpgcheck false
    gpgkey 'http://repo.varnish-cache.org/debian/GPG-key.txt'
    action 'create'
  end
end
