require "./spec_helper"

describe DogehouseCr do
  it "auth" do
    client = DogehouseCr.new ENV["ACCESS_TOKEN"], ENV["REFRESH_TOKEN"]
    client.join_room ENV["ROOM_ID"]
    client.test_run
  end
end
