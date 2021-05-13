require "./spec_helper"

describe DogehouseCr do
  it "auths" do
    client = DogehouseCr.new ENV["ACCESS_TOKEN"], ENV["REFRESH_TOKEN"]
    client.test_run 3
  end

  it "joins room" do
    client = DogehouseCr.new ENV["ACCESS_TOKEN"], ENV["REFRESH_TOKEN"]
    client.join_room ENV["ROOM_ID"]
    client.test_run 3
  end

  it "receives messages" do
    client = DogehouseCr.new ENV["ACCESS_TOKEN"], ENV["REFRESH_TOKEN"]

    client.on_message do |msg|
      puts msg
    end

    client.test_run 3
  end
end
