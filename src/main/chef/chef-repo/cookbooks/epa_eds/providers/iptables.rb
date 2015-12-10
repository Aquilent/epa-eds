#
# Cookbook Name:: epa_eds
# Provider:: iptables
#
# Copyright 2015, Aquilent, Inc.
# See https://github.com/Aquilent/drug-adverse-event-browser/blob/test/LICENSE.txt
#

def whyrun_supported?
  false
end


action :install do
    platform_install_iptables(run_context, new_resource.name, new_resource.recipe,
        new_resource.rules)
end

def platform_install_iptables (context, name, recipe, rules)
    Chef::Log.info("Setup #{recipe} iptables service")
    context.include_recipe "iptables"
    ruby_block "#{name}-rules" do
        block do
            platform_iptables_install_rules(recipe, rules)
            platform_iptables_persist_service
        end
    end
end
def platform_iptables_install_rules (recipe, rules)
    Chef::Log.info("Setup #{recipe} iptable rules")
    # Use index to cause iptable rules to be ordered in order in which they are declared
    rule_i = 1

    # Setup default rules
    iptables_rule platform_iptables_rule_name("default", rule_i) do
        source "#{recipe}/iptables/default.erb"
    end
    rule_i += 1

    if ! rules.nil? then
        Chef::Application.fatal!("epa_eds.iptables.rules is not a Hash", 1) if 
            !rules.is_a?(Hash)
        rules.keys.each do | rule |
            file = rules[rule]
            Chef::Log.info("Adding server specific iptables rule '#{rule}'")
            iptables_rule platform_iptables_rule_name(rule, rule_i) do
                source "#{file}.erb"
            end
            rule_i += 1
        end
    else 
        Chef::Log.info("No server specific iptables rules define")
    end

    # Cause all other (undefined) traffic  to be rejected
    iptables_rule platform_iptables_rule_name("drop", rule_i) do
        source "#{recipe}/iptables/reject.erb"
    end
end

def platform_iptables_persist_service ()
    do_bash("iptables-service-persist", "chkconfig --level 2345 iptables on")
end

def platform_iptables_rule_name (name, index)
    return "platform_rule_%03d_%s" % [index, name]
end

