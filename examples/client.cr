require "dogehouse_cr"

client = DogehouseCr.new ENV["ACCESS_TOKEN"], ENV["REFRESH_TOKEN"]

client.on_message do |msg|
  puts msg
end

client.join_room ENV["ROOM_ID"]

client.run