
#
# Cookbook Name:: epa_eds
# Definition:: override-template
#

define :override_template, :name => nil, :recipe_name => 'default' do
	cookbook = "epa_eds"
	recipe = params[:recipe_name]
    r = resources(:template => "#{params[:name]}")
    r.cookbook cookbook
    if  recipe != '' then
    	r.source "#{recipe}/#{r.source}"
    end
  	Chef::Log.debug("Override #{params[:name]} with #{cookbook} #{r.source} template")
end

