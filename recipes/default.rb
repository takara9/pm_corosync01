# -*- coding: utf-8 -*-
#
# Cookbook Name:: pm_corosync01
# Recipe:: default
#

#
# Pacemaker + Corosync 　
# パッケージのインストール
#
case node['platform']
###
when 'ubuntu'
  execute 'apt-get update' do
    command 'apt-get update'
    action :run
  end

  %w{
    corosync
    pacemaker
    ntp
  }.each do |pkgname|
    package "#{pkgname}" do
      action :install
    end
  end

  execute 'ubuntu service' do
    command 'update-rc.d pacemaker defaults'
    action :run
  end

  execute 'default_corosync' do
    command 'echo "START=yes" > /etc/default/corosync'
    action :run
  end

###
when 'centos','redhat'
  execute 'yum update' do
    command 'yum update -y'
    ignore_failure true
    action :run
  end
  %w{
      corosync 
      pacemaker 
      cman
      pcs
      ntp
  }.each do |pkgname|
    package "#{pkgname}" do
      action :install
    end
  end
end # node['platform']

service 'corosync' do
  supports :start => true, :restart => true, :stop => true
  action [ :enable, :nothing ]
end

service 'pacemaker' do
  supports :start => true, :restart => true, :stop => true
  action [ :enable, :nothing ]
end


#
# CentOS 7 はディレクトリ無いのでとばす
#
if node['platform_version'].to_i != 7 then
  template "/etc/corosync/service.d/pcmk" do
    owner "root"
    group "root"
    mode 0644
    source "pcmk.erb"
    action :create
  end
end

#
# Ubuntu14.04 CentOS 6 共通
#
template "/etc/corosync/corosync.conf" do
  owner "root"
  group "root"
  mode 0644
  source "corosync.conf.erb"
  variables({
    :network_addr => node["network_addr"],
    :multicast_addr => node["multicast_addr"],
    :multicast_port => node["multicast_port"]
  })
  action :create
  notifies :start, 'service[corosync]', :immediately
  notifies :start, 'service[pacemaker]', :immediately
end


#
# RedHat/CentOS では、crmが無くなりpcsとなっている
# オプション等も異なるのでファイルを別ける
#
case node['platform']
when 'ubuntu'
  resource = "crm_config"
when 'centos','redhat'
  resource = "pcs_config"
end

template "/root/#{resource}" do
  owner "root"
  group "root"
  mode 0744
  source "#{resource}.erb"
  variables({
    :vip_ipaddr => node["vip_ipaddr"],
    :vip_netmask => node["vip_netmask"]
  })
  action :create
end



#
# クラスタのリソース管理コマンドを実行
#
case node['platform']
when 'ubuntu'
  execute "crm_execute" do
    command "/usr/sbin/crm -f /root/#{resource} configure"
    action :run
    ignore_failure true
  end

when 'centos','redhat'
  #execute "pcs_execute" do
  #  command "/root/#{resource}"
  #  action :run
  #  ignore_failure true
  #end

  template "/root/pcs_config_mysql_act_standby" do
    owner "root"
    group "root"
    mode 0744
    source "pcs_config_mysql_act_standby.erb"
    action :create
  end

  template "/root/pcs_config_mysql_mst_repl" do
    owner "root"
    group "root"
    mode 0744
    source "pcs_config_mysql_mst_repl.erb"
    action :create
  end

end



