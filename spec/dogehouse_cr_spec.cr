require "./spec_helper"

describe DogehouseCr do
  it "auths" do
    client = DogehouseCr.new ENV["ACCESS_TOKEN"], ENV["REFRESH_TOKEN"]
    client.join_room ENV["ROOM_ID"]

    client.on_ready do |context, bot|
      puts bot.display_name
    end

    client.on_message do |context, msg|
      if msg.content.starts_with? "/echo "
        context.send_message msg.content[5..]
      end
      p! "MSG: #{msg}"
    end

    client.on_new_tokens do |context, token, refresh_token|
      puts "Received new tokens"
    end

    client.on_user_joined_room do |context, user|
      context.send_message "#{user.display_name} joined the room"
    end

    # client.on_ping do |context|
    #   puts "ping"
    # end

    client.on_room_join do |context, room|
      p! "Joined room: #{room}"
    end

    client.on_all do |context, msg|
      puts msg
    end

    # spawn do
    #   loop do
    #     client.send_message "@IvanCodes"
    #   end
    # end
    client.run
  end
end
