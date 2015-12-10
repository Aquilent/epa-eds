default['yum']['mysql-connectors-community']['repositoryid'] = 'mysql-connectors-community'
default['yum']['mysql-connectors-community']['gpgkey'] = 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-mysql'
#default['yum']['mysql-connectors-community']['gpgkey'] = 'http://pgp.mit.edu/pks/lookup?op=get&search=0x8C718D3B5072E1F5'
default['yum']['mysql-connectors-community']['description'] = 'MySQL Connectors Community'
default['yum']['mysql-connectors-community']['failovermethod'] = 'priority'
default['yum']['mysql-connectors-community']['enabled'] = true
default['yum']['mysql-connectors-community']['gpgcheck'] = true

case node['platform']
when 'redhat'
  default['yum']['mysql-connectors-community']['baseurl'] = 'http://repo.mysql.com/yum/mysql-connectors-community/el/$releasever/$basearch/'
when 'centos'
  default['yum']['mysql-connectors-community']['baseurl'] = 'http://repo.mysql.com/yum/mysql-connectors-community/el/$releasever/$basearch/'
when 'fedora'
  default['yum']['mysql-connectors-community']['baseurl'] = 'http://repo.mysql.com/yum/mysql-connectors-community/fc/$releasever/$basearch/'
end
