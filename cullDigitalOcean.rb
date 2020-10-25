#!/usr/bin/ruby

=begin
cullDigitalOcean.rb

This script is for checking if anyunused droplets are spun up, and if so, delete them.
Can be used to just check that the main droplet is online.
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
  puts droplet_id
else
  droplet_id = []
end

#check each droplet ID that is online, and remove everything not the persisted dropletID 
droplets = client.droplets.all()
drop_nr = 0
droplets.each do |n|
  drop_nr +=1
  print drop_nr.to_s + " " + n.id.to_s + "\n\n"
  if n.id.to_s != droplet_id
    puts n.id.to_s + "isn't main server, not = to " + droplet_id.to_s + " lets destroy it"
    client.droplets.delete(id: n.id)
  else
    puts n.id.to_s + "is the main server, lets keep it"
  end
  
end
