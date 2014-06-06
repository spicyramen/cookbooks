#
# Cookbook Name:: openvpn
# Recipe:: default
#
# Copyright 2014, Ramen Labs
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
execute "apt-get update" do
  command "apt-get update"
end

package "ntp" do
  case node[:platform]
  when "debian","ubuntu"
    package_name "ntp"
  end 
  action :install
end

package "openvpn" do
  case node[:platform]
  when "debian","ubuntu"
    package_name "openvpn"
  end 
  action :install
end

package "openssl" do
  case node[:platform]
  when "debian","ubuntu"
    package_name "openssl"
  end 
  action :install
end

package "easy-rsa" do
  case node[:platform]
  when "debian","ubuntu"
    package_name "easy-rsa"
  end 
  action :install
end

script "copy_easy-rsa" do
  interpreter "bash"
  user "root"
  cwd "/tmp"
  code <<-EOH
    mkdir /etc/openvpn/easy-rsa
    cp -r /usr/share/easy-rsa/* /etc/openvpn/easy-rsa/
    cp /etc/openvpn/easy-rsa/openssl-1.0.0.cnf /etc/openvpn/easy-rsa/openssl.cnf
  EOH
end

cookbook_file "/etc/openvpn/server.conf" do
	source "server.conf"
	mode 0644
	owner "root"
	group "root"
end

remote_directory "/etc/openvpn/server" do
	source "server"
	files_owner "root"
	files_group "root"
	files_mode 0644 
	mode 0644
	owner "root"
	group "root"
end

script "update_permissions" do
  interpreter "bash"
  user "root"
  cwd "/tmp"
  code <<-EOH
    chmod 0600 /etc/openvpn/server/vpnserver.key
  EOH
end

script "update_ipforwarding" do
  interpreter "bash"
  user "root"
  cwd "/tmp"
  code <<-EOH
    echo 1 > /proc/sys/net/ipv4/ip_forward
  EOH
end

script "update_iptables" do
  interpreter "bash"
  user "root"
  cwd "/tmp"
  code <<-EOH
    iptables -t nat -A INPUT -i eth0 -p udp -m udp --dport 1194 -j ACCEPT
  EOH
end

service "openvpn" do
	action [:enable,:start]
	supports  :reload => true
end