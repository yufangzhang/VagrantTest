#
# Cookbook Name:: chef-repo
# Recipe:: default
#
# Copyright (C) 2015 YOUR_NAME
#
# All rights reserved - Do Not Redistribute
# 
group 'admin'
user 'foo' do
  group 'admin'
  system true
  shell '/bin/bash'
end
