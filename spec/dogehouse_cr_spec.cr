require "./spec_helper"

describe DogehouseCr do
  it "auths" do
    client = DogehouseCr.new ENV["ACCESS_TOKEN"], ENV["REFRESH_TOKEN"]
    client.join_room ENV["ROOM_ID"]

    client.on_message do |msg|
      puts msg
    end

    spawn do
      loop do
        client.send_message "@replix"
      end
    end
    client.run
  end
end
