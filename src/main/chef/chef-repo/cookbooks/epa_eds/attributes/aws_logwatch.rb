
default['epa_eds']['aws_logwatch']['agent_setup_py'] = 
    "https://s3.amazonaws.com/aws-cloudwatch/downloads/latest/awslogs-agent-setup.py"

default['epa_eds']['aws_logwatch']['default_files']["messages"]['path'] = "/var/log/messages" 
default['epa_eds']['aws_logwatch']['default_files']["secure"]['path'] = "/var/log/secure" 
default['epa_eds']['aws_logwatch']['default_files']["boot"]['path'] = "/var/log/boot.log" 
default['epa_eds']['aws_logwatch']['default_files']["audit"]['path'] = "/var/log/audit/audit.log" 
default['epa_eds']['aws_logwatch']['default_files']["cfn-init"]['path'] = "/var/log/cfn-init.log" 
default['epa_eds']['aws_logwatch']['default_files']["cfn-init-cmd"]['path'] = "/var/log/cfn-init-cmd.log" 
default['epa_eds']['aws_logwatch']['default_files']["epa-eds/bootstrap"]['path'] = "/var/log/epa-eds/bootstrap.log" 
default['epa_eds']['aws_logwatch']['default_files']["epa-eds/launch"]['path'] = "/var/log/epa-eds/launch.log" 
# default['epa_eds']['aws_logwatch']['default_files']["epa-eds/baseline"]['path'] = "/var/log/epa-eds/baseline.log"
