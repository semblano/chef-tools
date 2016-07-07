#!/usr/bin/ruby

require 'getoptlong'
require File.join(File.dirname(__FILE__), 'common')

$domain = 'your.company.domain' ##default domain
$node_list = []
$install_script = "https://omnitruck.chef.io/install.sh"

## flow control flags ##
# default FALSE flags
node_list_flag = false
yes_flag = false
domain_flag =  false

opts = GetoptLong.new(
  [ '--help', '-h', GetoptLong::NO_ARGUMENT ],
  [ '--environment', '-e', GetoptLong::REQUIRED_ARGUMENT ],
  [ '--node-list', '-n', GetoptLong::REQUIRED_ARGUMENT ],
  [ '--yes', '-y', GetoptLong::NO_ARGUMENT ],
  [ '--domain', '-d', GetoptLong::REQUIRED_ARGUMENT ]
)

def puts(str)
  Common.puts(str)
end

def usage(exit=true)
  print "Usage: chef-tools bootstrap [-n|--node-list <node_list>]"
  print " [-d|--domain <domain>]"
  print " [-y|--yes]"
  print " [-h|--help]\r\n"
  exit 1 if exit == true
end

def usage_description
  usage(false)
  puts ""
  puts "USAGE DESCRIPTION:"
  puts "\t-n | --node-list <node_list>"
  puts "\t-d | --domain <domain> [Optional]"
  puts "\t-y | --yes [Optional]"
  puts "\t-h | --help"

  puts ""
  puts "EXAMPLES:"
  puts "\tchef-tools bootstrap -n \"webserver01 webserver02\" --yes"
  puts "\tchef-tools bootstrap -n \"webserver01 webserver02\" --domain my.domain.net --yes"
  puts "\tchef-tools bootstrap --help"
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
      when '--node-list'
        $node_list = arg.split(' ')
        node_list_flag = true
      when '--domain'
        domain_flag = true
        $domain = arg
      when '--yes'
        yes_flag = true
    end
  end
rescue GetoptLong::MissingArgument
  #puts "Missing Argument. Please use --help to check the usage"
  #exit 1
  raise GetoptLong::MissingArgument, "Missing Argument. Please use --help to check the usage"
rescue GetoptLong::InvalidOption
  #puts "Invalid option. Please use --help to check the usage"
  #exit 1
  raise GetoptLong::InvalidOption, "Invalid option. Please use --help to check the usage"
end

if domain_flag == false
  puts "*** WARNING *** Using default domain [#{$domain}] for bootstrap"
  if yes_flag == false
    print "Do you want to proceed [y/n]: "
    input = gets
    input = input.chomp
    exit 1 if input == 'n'
  end
else
  puts "*** INFO *** Using domain [#{$domain}] for bootstrap"
end

puts "-------------------------------------------------"
puts "Check reachable nodes"
puts ""

nodes_out = []
$node_list.each do |node|
  fqdn = node + '.' + $domain
  if not Common.node_exists?(fqdn)
    puts "#{fqdn} is NOT reachable"
    nodes_out << node
  else
    puts "#{fqdn} is reachable"
  end
end

nodes_out.each do |node|
  $node_list.delete(node)
end

if not nodes_out.empty?
  puts ""
  puts "************************ WARNING ***************************"
  puts "The following node(s) were not reachable"
  nodes_out.each do |node|
    puts "  -> #{node}"
  end
  puts "These node(s) will NOT be deployed"
end

puts ""
puts "-------------------------------------------------"
puts "Running bootstrap: "

result = 0
$node_list.each do |node|
  puts ""
  puts "--------------------========== #{node} ==========--------------------"
  if yes_flag == true
    system "knife bootstrap -N #{node} #{node}.#{$domain} --sudo --bootstrap-url=#{$install_script} --yes 2>&1"
  else
    system "knife bootstrap -N #{node} #{node}.#{$domain} --sudo --bootstrap-url=#{$install_script} 2>&1"
  end
  result = $?.to_i
  exit result if result != 0
end
