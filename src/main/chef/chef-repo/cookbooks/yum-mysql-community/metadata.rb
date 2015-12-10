name             'yum_mysql_community'
maintainer       'Bryan Taylor'
maintainer_email 'bcptaylor@gmail.com'
license          'MIT'
description      'Installs/Configures yum_mysql_community'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.0.4'

depends 'yum', '~> 3.1.0'

provides 'yum_mysql_community::default'
provides 'yum_mysql_community::remove'

recommends 'mysql', '~> 4.0.0'
suggests 'mysql', '~> 4.0.0'

supports 'centos'
supports 'fedora'
supports 'redhat'
