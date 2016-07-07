# default methods

require 'open3'
require 'yaml'

module Common
  def Common.get_user_valid_node_list(node_list, user_node_list)
    nodes_out = []
    user_node_list.each do |node|
      if not node_list.include?(node)
        nodes_out << node
      end
    end
    nodes_out.each do |node|
      user_node_list.delete(node)
    end
    return user_node_list, nil if nodes_out.empty?
    return user_node_list, nodes_out
  end
  def Common.get_nodes_list(env, *args)
    zone, role = *args
    zone ||= nil
    role ||= nil
    nodes_list=[]
    nodes_out=[]
    query = "chef_environment:#{env}"
    query += " AND zone:#{zone}" if ! zone.nil?
    query += " AND role:#{role}" if ! role.nil?
    nodes_list = `knife search "#{query}" -i 2> /dev/null | sort`
    nodes_list = nodes_list.split

    query_out = "chef_environment:#{env}"
    query_out += " AND -zone:#{zone}" if ! zone.nil?
    query_out += " AND -role:#{role}" if ! role.nil?
    nodes_out = `knife search "#{query_out}" -i 2> /dev/null | sort` if ! zone.nil? or ! role.nil?
    nodes_out = nodes_out.split if ! zone.nil? or ! role.nil?
    return nodes_list, nodes_out
  end
  def Common.run_command(cmd=nil, err_msg=nil)
    return 255 if cmd.nil?
    Open3.popen3(cmd) do |stdin, stdout, stderr, status|
      while line = stdout.gets
        puts line
      end
      while line = stderr.gets
        puts line
      end
      err_msg = "ERROR - Someting went wrong with the command '#{cmd}'" if err_msg.nil?
      raise "#{err_msg.gsub(/\n/,'')}\r\n"  if status.to_i != 0
    end
    return 0
  end
  def Common.parse_args(arg_list)
    (1..(arg_list.length-1)).each do |idx|
      if not arg_list[idx].index(' ').nil?
        arg_list[idx] = "\"#{arg_list[idx]}\""
      end
    end
    return arg_list
  end
  def Common.puts(str)
    if str ==  ""
      print "\r\n"
    else
      str.to_s.each_line do |s|
        print "#{s.gsub(/\n/,'')}\r\n"
      end
    end
  end
  def Common.node_exists?(fqdn)
    system "ping -c 3 #{fqdn} > /dev/null 2>&1"
    if $?.to_i == 0
      return true
    else
      return false
    end
  end
end

