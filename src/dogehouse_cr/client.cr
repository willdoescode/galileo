require "http/web_socket"
require "spec"
require "json"
require "./utils/*"
require "./entities/*"

API_URL      = "wss://api.dogehouse.tv/socket"
PING_TIMEOUT = 8

# Base dogehouse cilent to interface with api with
class DogehouseCr::Client < BaseEntity
  # Websocket connection state
  property ws : HTTP::WebSocket

  # Optional on ready callback property
  # ```
  # client.on_ready do |context, user|
  #   puts user.display_name
  # end
  # ```
  property ready_callback : (Context, User -> Nil)?

  # Optional message_callback property
  # Add a message callback function with .on_message
  # ```
  # client.on_message do |context, msg|
  #   puts msg
  # end
  # ```
  property message_callback : (Context, Message -> Nil)?

  # Optional ping_callback property
  # Add a message callback function with .on_ping
  # ```
  # client.on_ping do |context|
  #   puts "ping"
  # end
  # ```
  property ping_callback : (Context -> Nil)?

  # All messages will be sent through this callback.
  # ```
  # client.on_all do |context, msg|
  #   puts msg
  # end
  # ```
  property all_callback : (Context, String -> Nil)?

  # When room is joined this callback will be called
  # ```
  # client.on_room_join do |context, room|
  #   puts room.name
  # ```
  property join_room_callback : (Context, Room -> Nil)?

  # Client takes your dogehouse token and refreshToken in order to auth
  def initialize(@token : String, @refresh_token : String)
    @ws = HTTP::WebSocket.new(URI.parse(API_URL))

    @ws.send(
      {
        "op" => "auth",
        "d"  => {
          "accessToken"  => @token,
          "refreshToken" => @refresh_token,
        },
        "reconnectToVoice" => false,
        "muted"            => true,
        "platform"         => "dogehouse_cr",
      }.to_json
    )
  end

  # Send raw messages api without wrapper
  def raw_send(msg)
    @ws.send msg
  end

  # Add a message callback
  # on_message takes block with context parameter and String parameter
  # ```
  # client.on_message do |context, msg|
  #   puts msg
  # end
  # ```
  def on_message(&block : Context, Message -> Nil)
    @message_callback = block
  end

  # Add a ping callback
  # on_ping takes block with context parameter
  # ```
  # client.on_ping do |context|
  #   puts "ping"
  # end
  # ```
  def on_ping(&block : Context -> Nil)
    @ping_callback = block
  end

  # Add all callback
  # All messages recieved in the client will be sent through this callback
  # ```
  # client.on_all do |context, msg|
  #   puts msg
  # end
  # ```
  def on_all(&block : Context, String -> Nil)
    @all_callback = block
  end

  # Add room join callback
  # ```
  # client.on_room_join do |context, room|
  #   puts room.name
  # ```
  def on_room_join(&block : Context, Room -> Nil)
    @room_join_callback = block
  end

  # Add ready callback
  # ```
  # client.on_ready do |context, user|
  #   puts user.display_name
  # end
  # ```
  def on_ready(&block : Context, User -> Nil)
    @ready_callback = block
  end

  def setup_run
    @ws.on_message do |msg|
      if !@all_callback.nil?
        @all_callback.not_nil!.call Context.new(@ws), msg
      end

      if msg == "pong"
        if !@ping_callback.nil?
          @ping_callback.not_nil!.call Context.new(@ws)
        end
        next
      end

      msg_json = Hash(String, JSON::Any).from_json msg
      if msg_json["op"]?
        if msg_json["op"] == "auth-good"
          m = msg_json["d"]
            .as_h["user"]
            .as_h
          if !@ready_callback.nil?
            @ready_callback.not_nil!.call(
              Context.new(@ws),
              User.new(
                m["id"].as_s,
                m["username"].as_s,
                m["avatarUrl"].as_s,
                m["bannerUrl"].as_s? ? m["bannerUrl"].as_s : "",
                m["bio"].as_s,
                m["online"].as_bool,
                m["staff"].as_bool,
                m["lastOnline"].as_s,
                m["currentRoomId"].as_s? ? m["currentRoomId"].as_s : "",
                m["displayName"].as_s,
                m["numFollowing"].as_i,
                m["numFollowers"].as_i,
                m["contributions"].as_i,
                m["youAreFollowing"].as_bool? ? true : false,
                m["followsYou"].as_bool? ? true : false,
                m["botOwnerId"].as_s
              )
            )
          end
        elsif msg_json["op"] == "new_chat_msg"
          if !@message_callback.nil?
            m = msg_json["d"]
              .as_h["msg"]
              .as_h
            @message_callback.not_nil!.call(
              Context.new(@ws),
              Message.new(
                m["userId"].as_s,
                m["sentAt"].as_s,
                m["isWhisper"].as_bool,
                decode_message(
                  msg_json["d"]
                    .as_h["msg"]
                    .as_h["tokens"]
                    .as_a.map { |a| a.as_h }
                )
              )
            )
          end
        elsif msg_json["op"] == "room:join:reply"
          payload = msg_json["p"].as_h
          if !@room_join_callback.nil?
            @room_join_callback.not_nil!.call(
              Context.new(@ws),
              Room.new(
                payload["id"].as_s,
                payload["name"].as_s,
                payload["description"].as_s,
                payload["isPrivate"].as_bool
              )
            )
          end
        end
      end
    end

    spawn do
      loop do
        @ws.send "ping"
        sleep PING_TIMEOUT
      end
    end
  end

  # Run the client
  # This will start the message loop
  def run
    setup_run

    @ws.run
  end

  # This function should only be used for testing purposes
  def test_run(time : Int)
    setup_run

    spawn do
      @ws.run
    end

    sleep time
    return
  end
end
