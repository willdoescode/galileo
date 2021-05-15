require "galileo"

client = Galileo.new ENV["ACCESS_TOKEN"], ENV["REFRESH_TOKEN"]
client.join_room ENV["ROOM_ID"]

client.on_user_joined_room do |user|
  client.send "#{user.display_name} joined the room"
end

client.run
