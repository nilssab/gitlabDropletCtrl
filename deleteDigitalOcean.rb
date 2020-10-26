#!/usr/bin/ruby

=begin
deleteDigitalOcean.rb

This script is for deleting the tracked Gitlab droplet
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
  file = File.open("dropletID")
  droplet_id = file.read.chomp
  client.droplets.delete(id: droplet_id)
else
  puts "no persisted droplet is tracked"
end
