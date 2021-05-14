require "dogehouse_cr"

client = DogehouseCr.new ENV["ACCESS_TOKEN"], ENV["REFRESH_TOKEN"]
client.join_room ENV["ROOM_ID"]

client.on_room_join do |room|
  p! "Joined room: #{room}"
end

client.run
