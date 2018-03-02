#!/usr/bin/env ruby

require 'json'
require 'ipaddr'

ip = JSON.parse(`curl httpbin.org/ip 2>/dev/null`).fetch('origin')  # TODO: Use Net::HTTP instead of external command

office_ip = IPAddr.new('192.168.2.0/24') # FIXME: Set real company from .bitbarrc

if office_ip === ip
  puts '🏢'
else
  puts '🏠'
end
