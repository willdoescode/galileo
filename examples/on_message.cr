require "galileo"

client = Galileo.new ENV["ACCESS_TOKEN"], ENV["REFRESH_TOKEN"]
client.join_room ENV["ROOM_ID"]

client.on_message do |msg|
  if msg.content.starts_with? "/echo "
    client.send msg.content[5..]
  end
  puts "MSG: #{msg}"
end

client.run
