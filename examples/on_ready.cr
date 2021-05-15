require "galileo"

client = Galileo.new ENV["ACCESS_TOKEN"], ENV["REFRESH_TOKEN"]
client.join_room ENV["ROOM_ID"]

client.on_ready do |bot|
  puts bot.display_name
  puts bot.username
end

client.run
