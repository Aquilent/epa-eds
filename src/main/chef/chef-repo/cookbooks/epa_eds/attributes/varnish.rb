#
# Varnish webserver attributes
#
# Setting the following attribute triggers the addition of the X-Server
# header in the response to allow identification of the responding server
# when using a load balancer.
# The default (empty string) does NOT add the header

default['epa_eds']['server_type'] = "web"

default['epa_eds']['varnish']['server_id'] = '';
default['epa_eds']['varnish']['proxy_url'] = 'http://localhost';
default['epa_eds']['varnish']['memory'] = '2G';
