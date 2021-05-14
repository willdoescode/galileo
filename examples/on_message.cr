require "dogehouse_cr"

client = DogehouseCr.new ENV["ACCESS_TOKEN"], ENV["REFRESH_TOKEN"]
client.join_room ENV["ROOM_ID"]

client.on_message do |context, msg|
  if msg.content.starts_with? "/echo "
    context.send_message msg.content[5..]
  end
  p! "MSG: #{msg}"
end

client.run
