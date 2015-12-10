
require "rubygems"
require "active_support/core_ext/object/blank"

def failWhenNotSet(value, message)
   if value.blank? then
      raise message
   end
end

def isBlank(value) 
   return value.nil? || value.blank?
end

def replaceFileSection(file, section, text)
   raise ArgumentError, "File doesn't exist" unless File.exist? file
   raise ArgumentError, "File is blank" unless (contents = File.new(file).readlines(nil)).length > 0

   beginMarker = createMarker("begin", section)
   endMarker = createMarker("end", section)
   re = Regexp.new("#{beginMarker}.*#{endMarker}", Regexp::MULTILINE)
   Chef::Log.debug("Checking #{file} for [" + re.to_s() + "] and replace 'body' with ["  + text + "]")

   # Remove RegExp markers for replacement
   beginMarkerText = markerToText(beginMarker)
   endMarkerText = markerToText(endMarker)
   newContents = contents[0].gsub(re, "#{beginMarkerText}\n#{text}\n#{endMarkerText}")

   backup_pathname = file + ".old"
   FileUtils.cp(file, backup_pathname, :preserve => true)
   File.open(file, "w") do |newfile|
      newfile.puts(newContents)
      newfile.flush
   end
end

def createMarker(prefix, label)
   return "# #{prefix}\\(#{label}\\)"
end

def markerToText(marker)
   # Note that sub only replaces the first ocurrance, so need to repeat
   return marker.sub(/\\/, "").sub(/\\/, "")
end

def do_install_build_tools(dependencies, uninstall = false)
   #do_bash("install-build-tools", "yum -y install #{dependencies.join(" ")}")
   dependencies.each do |package|
      package "#{package}" do
         action :install
      end
   end
end

def do_make_install(name, source, extension = "tar.gz", uninstall = false)
   tmpDir = "/tmp/chef"
   Chef::Log.info("Processing install #{name} from #{source}")
   do_bash("make-temp-directory", "if [ ! -d '#{tmpDir}' ];  then mkdir -p '#{tmpDir}'; fi", true)
   do_bash("download-#{name}[#{source}]", 
      "curl -L --output '#{tmpDir}/#{name}.#{extension}' #{source} ", true)
   do_bash("unpack-#{name}", "tar xvf #{tmpDir}/#{name}.#{extension} --directory='#{tmpDir}'", true)
   do_bash("make-install-#{name}",
      "pushd #{tmpDir}/#{name}; ./autogen.sh; ./configure; make; make install; popd;", true);
   if uninstall then
      do_bash("uninstall-tools[#{name}]", "yum -y erase #{tools}")
   end
   do_bash("cleanup-#{name}", 
      "rm -rf #{tmpDir}/#{name}; rm -rf #{tmpDir}/#{name}.#{extension}", true)
end



def do_bash(name, command, verbose = false, user = 0, group = 0)
   Chef::Log.info("Processing #{name}")
   command = removeWhiteSpaceFromLineStart(command)
   p = Mixlib::ShellOut.new(command, :user => user, :group => group)
   p.run_command
   Chef::Log.debug("----- Begin output of #{name} as #{user}:#{group}")
   Chef::Log.debug("COMMAND: #{command}");
   p.invalid! if p.stdout.split('\n').last =~ /^ERROR:.+/i
   Chef::Log.info("#{name} STDERR: #{p.stderr}")
   Chef::Log.info("#{name} STDOUT: #{p.stdout}")
   Chef::Log.debug("----- End output of #{name} as #{user}:#{group} -----")
end

# Removes the white space (spaces and tabs) at the beginning of each line
def removeWhiteSpaceFromLineStart(text)
   lines = text.split(/\n/);
   lines.collect! { |line| line.sub(/^[ \t]*/, "") }
   return lines.join("\n")
end



def install_build_packages(platform_packages_alternatives = nil)
   packages = ['gcc', 'libstdc++-devel', 'gcc-c++', 'curl-devel', 'zlib-devel', 'automake']
   install_packages(packages, platform_packages_alternatives)
end

def install_packages(package_names, platform_packages_alternatives = nil)
   if package_names.nil? then
      return
   end
   package_names.each do |name|
      install_package(name, platform_packages_alternatives)
   end
end

# Allow for RPM to be downloaded first for optional RedHat packages (which require a subscription)
# optional_package: Hash key:"platform name" => Hash key:"package-name" => "RPM-URL"
def install_package (name, platform_packages_alternatives = nil)
   package_node = nil
   if !platform_packages_alternatives.nil? then
      platform = node['platform']
      Chef::Log.debug("Check for optional package '#{name}' for '#{platform}' platform")
      platform_packages = platform_packages_alternatives[platform]
      if !platform_packages.nil? then
         package_node = platform_packages[name]
      end
   end
   if package_node.nil? then
      Chef::Log.info("Use #{platform} standard #{name} package resource");
      package "#{name}" do
         action :install
      end
   else 
      local_rpm_file = "#{Chef::Config[:file_cache_path]}/#{name}.rpm"
      Chef::Log.info("Use alternative #{name} package #{platform} in #{local_rpm_file}");
      if package_node['file'].nil? then
         remote_file local_rpm_file do
            source "#{package_node['url']}"
            owner 'root'
            group 'root'
            mode '700'
            action :create
         end 
      else
         cookbook_file "#{name}" do
            path "#{local_rpm_file}"
            source "#{package_node['file']}"
            owner 'root'
            group 'root'
            mode '700'
            action :create
         end 
      end
      yum_package "#{name}" do
         source "#{local_rpm_file}"
         action :install
      end
   end
end
