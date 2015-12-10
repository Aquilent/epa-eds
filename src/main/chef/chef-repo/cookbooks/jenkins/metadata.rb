name             'jenkins'
maintainer       'Chef Software, Inc.'
maintainer_email 'releng@chef.io'
license          'Apache 2.0'
description      'Installs and configures Jenkins CI master & slaves'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '2.3.1'

recipe 'master', 'Installs a Jenkins master'

depends 'apt',   '~> 2.0'
depends 'runit', '~> 1.5'
depends 'yum',   '~> 3.0'
