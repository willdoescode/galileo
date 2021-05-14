require "dogehouse_cr"

client = DogehouseCr.new ENV["ACCESS_TOKEN"], ENV["REFRESH_TOKEN"]
client.join_room ENV["ROOM_ID"]

client.on_user_joined_room do |context, user|
  context.send_message "#{user.display_name} joined the room"
end

client.run
