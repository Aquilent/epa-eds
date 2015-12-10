default['yum']['mysql-tools-community']['repositoryid'] = 'mysql-tools-community'
default['yum']['mysql-tools-community']['gpgkey'] = 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-mysql'
#default['yum']['mysql-tools-community']['gpgkey'] = 'http://pgp.mit.edu/pks/lookup?op=get&search=0x8C718D3B5072E1F5'
default['yum']['mysql-tools-community']['description'] = 'MySQL Tools Community'
default['yum']['mysql-tools-community']['failovermethod'] = 'priority'
default['yum']['mysql-tools-community']['enabled'] = true
default['yum']['mysql-tools-community']['gpgcheck'] = true

case node['platform']
when 'redhat'
  default['yum']['mysql-tools-community']['baseurl'] = 'http://repo.mysql.com/yum/mysql-tools-community/el/$releasever/$basearch/'
when 'centos'
  default['yum']['mysql-tools-community']['baseurl'] = 'http://repo.mysql.com/yum/mysql-tools-community/el/$releasever/$basearch/'
when 'fedora'
  default['yum']['mysql-tools-community']['baseurl'] = 'http://repo.mysql.com/yum/mysql-tools-community/fc/$releasever/$basearch/'
end
