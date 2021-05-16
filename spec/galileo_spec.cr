require "./spec_helper"

describe Galileo do
  it "auths" do
    client = Galileo.new ENV["ACCESS_TOKEN"], ENV["REFRESH_TOKEN"]
    client.join_room ENV["ROOM_ID"]

    client.on_ready do |bot|
    end

    client.on_message do |msg|
      puts "ROOMS: #{client.rooms}"
      if msg.content == "ASK TO SPEAK"
        client.ask_to_speak
      end

      if msg.content == "MUTE"
        client.toggle_mute
      end

      if msg.content == "SPEAK"
        client.set_speaking !client.speaking
      end

      if msg.content.starts_with? "/echo "
        client.send msg.content[5..]
      end
      p! "MSG: #{msg}"
    end

    client.on_new_tokens do |token, refresh_token|
      puts "Received new tokens"
    end

    client.on_user_joined_room do |user|
      client.send "@#{user.username} joined the room"
    end

    # client.on_ping do |context|
    #   puts "ping"
    # end

    client.on_room_join do |room|
      puts "Joined room: #{room.name}"
      client.ask_to_speak
      client.send "normal text test"
      # spawn do
      #   loop do
      #     client.set_role "raised_hand", "c8799756-7438-45b1-96fe-20f6d3a28b75"
      #     sleep 1
      #   end
      # end
    end

    client.on_all do |msg|
      puts msg
    end

    # spawn do
    #   loop do
    #     client.toggle_mute
    #   end
    # end
    client.run
  end
end
