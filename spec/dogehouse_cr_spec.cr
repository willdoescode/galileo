require "./spec_helper"

describe DogehouseCr do
  it "auths" do
    client = DogehouseCr.new ENV["ACCESS_TOKEN"], ENV["REFRESH_TOKEN"]
    client.join_room ENV["ROOM_ID"]

    client.on_message do |context, msg|
      puts msg
    end

    client.on_ping do |context|
      puts "ping"
    end

    # spawn do
    #   loop do
    #     client.send_message "@IvanCodes"
    #   end
    # end
    client.run
  end
end
