require "./spec_helper"

describe DogehouseCr do
  it "works" do
    client = DogehouseCr.new ENV["ACCESS_TOKEN"], ENV["REFRESH_TOKEN"]
    client.join_room ENV["ROOM_ID"]
    client.run
  end
end
