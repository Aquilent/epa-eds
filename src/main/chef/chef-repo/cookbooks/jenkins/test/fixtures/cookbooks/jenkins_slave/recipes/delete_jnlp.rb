include_recipe 'jenkins::master'

# Include the create recipe so we have something to delete
include_recipe 'jenkins_slave::create_jnlp'

%w(builder executor smoke).each do |name|
  jenkins_jnlp_slave name do
    action :delete
  end
end
