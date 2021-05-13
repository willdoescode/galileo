require "./spec_helper"

describe DogehouseCr do
  it "auths" do
    client = DogehouseCr.new ENV["ACCESS_TOKEN"], ENV["REFRESH_TOKEN"]
    client.join_room ENV["ROOM_ID"]

    client.on_message do |msg|
      puts msg
    end

    spawn do
      x = 0
      loop do
        x += 1
        client.send_message x.to_s
      end
    end
    client.run
  end
end
