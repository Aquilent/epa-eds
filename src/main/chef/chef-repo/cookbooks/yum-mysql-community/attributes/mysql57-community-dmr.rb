default['yum']['mysql57-community-dmr']['repositoryid'] = 'mysql57-community-dmr'
default['yum']['mysql57-community-dmr']['gpgkey'] = 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-mysql'
#default['yum']['mysql57-community-dmr']['gpgkey'] = 'http://pgp.mit.edu/pks/lookup?op=get&search=0x8C718D3B5072E1F5'
default['yum']['mysql57-community-dmr']['description'] = 'MySQL 5.7 Community Server Development Milestone Release'
default['yum']['mysql57-community-dmr']['failovermethod'] = 'priority'
default['yum']['mysql57-community-dmr']['enabled'] = false
default['yum']['mysql57-community-dmr']['gpgcheck'] = true

case node['platform']
when 'redhat'  
  default['yum']['mysql57-community-dmr']['baseurl'] = 'http://repo.mysql.com/yum/mysql-5.7-community/el/$releasever/$basearch/'
when 'centos'
  default['yum']['mysql57-community-dmr']['baseurl'] = 'http://repo.mysql.com/yum/mysql-5.7-community/el/$releasever/$basearch/'
when 'fedora'
  default['yum']['mysql57-community-dmr']['baseurl'] = 'http://repo.mysql.com/yum/mysql-5.7-community/fc/$releasever/$basearch/'
end
