#
# Author:: Bryan Taylor (<bcptaylor@gmail.com>)
# Recipe:: yum_mysql_community::default
#
# see LICENSE

# TODO: follow steps below to improve how this works
# Better:
# - do remote_file with 'http://pgp.mit.edu/pks/lookup?op=get&search=0x8C718D3B5072E1F5'
# More Better:
# - download the rpm from Oracle
# - do package with rpm provider and local file

cookbook_file '/etc/pki/rpm-gpg/RPM-GPG-KEY-mysql' do
  action :create
  owner 'root'
  group 'root'
  mode '0644'
end

%w(
  mysql56-community
  mysql-connectors-community
  mysql-tools-community
  mysql57-community-dmr
  ).each do |repo|
  yum_repository repo do
    description node['yum'][repo]['description']
    baseurl node['yum'][repo]['baseurl']
    mirrorlist node['yum'][repo]['mirrorlist']
    gpgcheck node['yum'][repo]['gpgcheck']
    gpgkey node['yum'][repo]['gpgkey']
    enabled node['yum'][repo]['enabled']
    cost node['yum'][repo]['cost']
    exclude node['yum'][repo]['exclude']
    enablegroups node['yum'][repo]['enablegroups']
    failovermethod node['yum'][repo]['failovermethod']
    http_caching node['yum'][repo]['http_caching']
    include_config node['yum'][repo]['include_config']
    includepkgs node['yum'][repo]['includepkgs']
    keepalive node['yum'][repo]['keepalive']
    max_retries node['yum'][repo]['max_retries']
    metadata_expire node['yum'][repo]['metadata_expire']
    mirror_expire node['yum'][repo]['mirror_expire']
    priority node['yum'][repo]['priority']
    proxy node['yum'][repo]['proxy']
    proxy_username node['yum'][repo]['proxy_username']
    proxy_password node['yum'][repo]['proxy_password']
    repositoryid node['yum'][repo]['repositoryid']
    sslcacert node['yum'][repo]['sslcacert']
    sslclientcert node['yum'][repo]['sslclientcert']
    sslclientkey node['yum'][repo]['sslclientkey']
    sslverify node['yum'][repo]['sslverify']
    timeout node['yum'][repo]['timeout']
    action :create
  end
end
