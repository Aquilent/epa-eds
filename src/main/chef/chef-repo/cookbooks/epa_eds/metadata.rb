name             'epa_eds'
maintainer       'Aquilent'
license          'https://github.com/Aquilent/drug-adverse-event-browser/blob/test/LICENSE.txt'
description      'Installs/Configures EPA EDS prototype'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

%w{ centos redhat }.each do |os|
  supports os
end

depends "selinux"
depends "apache2"
depends "iptables"
depends "jenkins"
depends "php"
depends "rsync"
depends "varnish"
depends "yum-mysql-community"

recipe 'epa_eds::platform', 'Install /op/epa-eds'
recipe 'epa_eds::varnish', 'Install a standard Varnish webserver'
recipe 'epa_eds::aws_logwatch', 'Install AWS CloudWatch aws_logwatch service and configuration'
recipe 'epa_eds::bastion', 'Install bastion server as a proxy for shared services'


