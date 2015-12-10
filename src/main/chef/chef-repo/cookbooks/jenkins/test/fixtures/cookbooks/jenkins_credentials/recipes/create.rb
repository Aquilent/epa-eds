require 'openssl'

include_recipe 'jenkins::master'

# Test basic password credentials creation
jenkins_password_credentials 'schisamo' do
  description 'passwords are for suckers'
  password 'superseekret'
end

# Test specifying a UUID-based ID
jenkins_password_credentials 'schisamo2' do
  id '63e11302-d446-4ba0-8aa4-f5821f74d36f'
  password 'superseekret'
end

# Test specifying a string-based ID
jenkins_password_credentials 'schisamo3' do
  id 'schisamo3'
  password 'superseekret'
end

# Test basic private key credentials creation
jenkins_private_key_credentials 'jenkins' do
  description 'this is more like it'
  private_key File.read(File.expand_path('../../../../../data/data/test_id_rsa', __FILE__))
end

# Test private key credentials with passphrase
jenkins_private_key_credentials 'jenkins2' do
  private_key OpenSSL::PKey::RSA.new(File.read(File.expand_path('../../../../../data/data/test_id_rsa_with_passphrase', __FILE__)), 'secret').to_pem
  passphrase 'secret'
end

# Test basic private key credentials creation
jenkins_private_key_credentials 'jenkins3' do
  description 'I specified an ID'
  id '766952b8-e1ea-4ee1-b769-e159681cb893'
  private_key File.read(File.expand_path('../../../../../data/data/test_id_rsa', __FILE__))
end

# Test creating a password with a dollar sign in it
jenkins_password_credentials 'dollarbills' do
  password '$uper$ecret'
end
