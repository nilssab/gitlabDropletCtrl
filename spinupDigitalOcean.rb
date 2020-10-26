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

#get ssh keys
ssh_keys= client
drople

#check persisted dropletID of the server, if avaiable
if File.exists?("dropletID")
  puts "droplet already exists"
  file = File.open("dropletID")
  droplet_id = file.read.chomp
  client.droplets.delete(id: droplet_id)
else
  puts "Creating new droplet"
  droplet = DropletKit::Droplet.new(name: 'gitlabDroplet', region: 'fra1', image: 'ubuntu-20-04-x64', size: 's-2vcpu-4gb')
  created = client.droplets.create(droplet)
  puts "droplet ID is " + droplet.id.to_s
  File.write('dropletID', created.id)
end
