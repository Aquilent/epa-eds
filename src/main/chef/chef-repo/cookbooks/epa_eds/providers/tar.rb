#
# Cookbook Name:: epa_eds
# Provider:: platform
#
# Copyright 2015, Aquilent, Inc.
# See https://github.com/Aquilent/drug-adverse-event-browser/blob/test/LICENSE.txt
#

def whyrun_supported?
  false
end


action :unpack do
    platform_tar_unpack(new_resource.name, new_resource.source, new_resource.destination, 
        new_resource.owner, new_resource.group, new_resource.mode, new_resource.extension,
        new_resource.options)
end


def platform_tar_unpack (name, source, destination, owner, group, mode, extension, options)
    if extension.nil? then
        extension = 'tar.gz'
    end
    file = "#{Chef::Config[:file_cache_path]}/#{name}.#{extension}"
    cookbook_file "#{file}" do
       source "#{source}"
       mode 0600
       owner 'root'
       group 'root'
    end
    ruby_block "platform-tar-unpack" do
        block do
            Chef::Log.info("Unpacking file #{source} into #{destination}")
            if options.nil? then
              options = ""
            end
            arguments = "#{options}xf"
            if extension == 'tar.gz' then
               arguments = "z#{arguments}"
            end
            do_bash("extract-#{name}", "tar #{arguments} '#{file}' --directory #{destination}")
            do_bash("set-#{name}-privileges", "chmod -R #{mode} #{destination}")
            do_bash("set-#{name}-ownership", "chown -R #{owner}:#{group} #{destination}")
            Chef::Log.info("Removing source file")
            do_bash("delete-#{name}-archive", "rm -f #{file}");
        end
    end
end

