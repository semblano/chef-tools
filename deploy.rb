#!/usr/bin/ruby

require 'getoptlong'
require File.join(File.dirname(__FILE__), 'common')

# Initializing variables
$zone = nil
$role = nil

## flow control flags ##
# default FALSE flags
env_flag = false
zone_flag = false
node_list_flag = false
run_paralell_flag = false

opts = GetoptLong.new(
  [ '--help', '-h', GetoptLong::NO_ARGUMENT ],
  [ '--environment', '-e', GetoptLong::REQUIRED_ARGUMENT ],
  [ '--node-list', '-n', GetoptLong::REQUIRED_ARGUMENT ],
  [ '--zone', '-z', GetoptLong::REQUIRED_ARGUMENT ],
  [ '--role', '-r', GetoptLong::REQUIRED_ARGUMENT ],
  [ '--parallel', '-p', GetoptLong::REQUIRED_ARGUMENT ],
  [ '--override-run-list', '-o', GetoptLong::REQUIRED_ARGUMENT ],
  [ '--update-version', '-u', GetoptLong::REQUIRED_ARGUMENT ]
)

def puts(str)
  Common.puts(str)
end

def usage(exit=true)
  print "Usage: chef-tools deploy -e|--environment <environment_name>"
  print " [-n|--node-list <node_list>]"
  print " [-z|--zone <zone>]"
  print " [-r|--role <role>]"
  print " [-p|--parallel <true|false>]"
  print " [-u|--update-version <true|false>]"
  print " [-o|--override-run-list <Array with roles/recipes>]"
  print " [-h|--help]\n"
  exit 1 if exit == true
end

def usage_description
  usage(false)
  puts ""
  puts "USAGE DESCRIPTION:"
  print "\t-e | --environment <environment_name>"
  print "\tRequired\n"
  print "\t-n | --node-list <node_list>"
  print "\t\tOptional\n"
  print "\t-z | --zone <zone>"
  print "\t\t\tOptional\n"
  print "\t-r | --role <role>"
  print "\t\t\tOptional\n"
  print "\t-p | --parallel <true|false>"
  print "\t\tOptional\n"
  print "\t-u | --update-version <true|false>"
  print "\tOptional\n"
  print "\t-o | --override-run-list <Array with roles/recipes>"
  print "\tOptional\n"
  print "\t-h | --help\n"

  puts ""
  puts "EXAMPLES:"
  puts "\tchef-tools deploy -e Dev -z US [-p true]"
  puts "\tchef-tools deploy -n \"webserver01 webserver03\" [-p true]"
  puts "\tchef-tools deploy --help"
  puts ""
  exit 1
end

if ARGV.length == 0
    usage_description
end

begin
  opts.each do |opt, arg|
    case opt
      when '--help'
        usage_description
      when '--environment'
        env_flag = true
        $env_name = arg
      when '--node-list'
        node_list_flag = true
        $user_node_list = arg.split(' ')
      when '--zone'
        zone_flag = true
        $zone = arg
      when '--role'
        $role = arg
      when '--parallel'
        if arg.downcase == "true":
          run_paralell_flag = true
        end
      when '--override-run-list'
        $run_list="-o #{arg}"
    end
  end 
rescue GetoptLong::MissingArgument
  puts "Missing Argument. Please use --help to check the usage"
  exit 1
rescue GetoptLong::InvalidOption
  puts "Invalid option. Please use --help to check the usage"
  exit 1
end

# check if exists option -e
if env_flag == false
puts "Option '--environment' is required. Please --help to check the usage"
  exit 1
end

$node_list, nodes_out = Common.get_nodes_list($env_name, $zone, $role)
raise "ERROR - Unable to enumerate nodes" if $node_list.nil? or $node_list.empty?

$node_list, nodes_out = Common.get_user_valid_node_list($node_list, $user_node_list) if node_list_flag == true

if not nodes_out.nil? or not nodes_out.empty?
  puts ""
  puts "************************ WARNING ***************************"
  puts "The following node(s) do NOT belong to the specified filter (#{$env_name} #{$zone} #{$role}):"
  nodes_out.each do |node|
    puts "  -> #{node}"
  end
  puts "These node(s) will NOT be deployed"
  puts ""
end

raise "No nodes to be deployed. Please, check if the environment or node list is correct." if $node_list.empty?

puts "-------------------------------------------------"
puts "Show nodes information: "
puts ""
$node_list.each do |node|
  puts ""
  puts "-------------------- #{node} --------------------"
  puts "========== uptime =========="
  system "knife ssh \"name:#{node}\" 'uptime'"
  puts "========== df -h =========="
  system "knife ssh \"name:#{node}\" 'df -h'"
  puts "========== mount =========="
  system "knife ssh \"name:#{node}\" 'mount'"
  puts "========== free =========="
  system "knife ssh \"name:#{node}\" 'free'"
end

puts "-------------------------------------------------"
puts "Running chef-client: "
puts ""
if run_paralell_flag == true
  puts ""
  puts "Paralell run for node(s):"
  $node_list.each do |node|
    puts "-> #{node}"
  end
  puts ""
  system "knife ssh -m '#{$node_list.join(' ')}' 'sudo chef-client #{$run_list} -l info'"
  result = $?.to_i
  if result != 0
    exit result
  end
else
  $node_list.each do |node|
    puts ""
    puts "--------------------========== #{node} ==========--------------------"
    system "knife ssh \"name:#{node}\" 'sudo chef-client #{$run_list} -l info'"
    result = $?.to_i
    if result != 0
      exit result
    end
  end
end

exit result
