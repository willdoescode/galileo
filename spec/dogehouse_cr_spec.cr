require "./spec_helper"

describe DogehouseCr do
  it "auths" do
    client = DogehouseCr.new ENV["ACCESS_TOKEN"], ENV["REFRESH_TOKEN"]
    client.join_room ENV["ROOM_ID"]

    client.on_message do |context, msg|
      if msg.starts_with? "/echo "
        context.send_message msg[5..]
      end
      puts "MSG: #{msg}"
    end

    client.on_ping do |context|
      puts "ping"
    end

    client.on_room_join do |context, room|
      puts "Joined room: #{room.name}"
    end

    # spawn do
    #   loop do
    #     client.send_message "@IvanCodes"
    #   end
    # end
    client.run
  end
end
