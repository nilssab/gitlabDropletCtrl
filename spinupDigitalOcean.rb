#!/usr/bin/ruby

=begin
spinupDigitalOcean.rb

This script is for creating a droplet for gitlab.
ATM it assumes you only want one.
=end

require 'droplet_kit'

#load token from file. Please put your API token in the tokenDO file or change the code.
if File.exists?("tokenDO")
  file = File.open("tokenDO")
  token = file.read.chomp
else
  puts "No token file found"
end
#connect client and get interface object
client= DropletKit::Client.new(access_token: token)

#check persisted dropletID of the server, if avaiable
if File.exists?("dropletID")
  puts "droplet already exists"
  file = File.open("dropletID")
  droplet_id = file.read.chomp
  droplet = client.droplets.find(id: droplet_id)
  if droplet[id] == droplet_id
     puts "droplet is running"
  else
    puts "droplet ID mismatch, please cull or take down"
  end
else
  puts "Creating new droplet"
  my_ssh_keys = client.ssh_keys.all.collect {|key| key.fingerprint}
  droplet = DropletKit::Droplet.new(name: 'gitlabDroplet', region: 'fra1', image: 'ubuntu-20-04-x64', size: 's-2vcpu-4gb', ssh_keys: my_ssh_keys, monitoring: 'true')
  created = client.droplets.create(droplet)
  puts "droplet ID is " + droplet.id.to_s
  File.write('dropletID', created.id)
end
