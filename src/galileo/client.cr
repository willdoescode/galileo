require "http/web_socket"
require "spec"
require "json"
require "./message.cr"
require "./user.cr"
require "./room.cr"
require "./ops.cr"

API_URL      = "wss://api.dogehouse.tv/socket"
PING_TIMEOUT = 8

# Base dogehouse cilent to interface with api with
class Galileo::Client
  # Message queue to send withing message delays
  @message_queue = Array(String).new

  @myself : User? = nil

  # The chat delay withing rooms (measured in nanoseconds)
  property delay = 1000000

  # True if bot is muted, False if not
  property muted : Bool = true

  # True if bot in room, False if not
  property in_room : Bool = false

  # Returns all the available rooms in array
  # Updated every 2 seconds
  getter rooms : Array(Room) = Array(Room).new

  # If bot is speaking will be true else will be false
  getter speaking : Bool = false

  # Websocket connection state
  property ws : HTTP::WebSocket

  # Optional on ready callback property
  # ```
  # client.on_ready do |user|
  #   puts user.display_name
  # end
  # ```
  property ready_callback : (User -> Nil)?

  # Optional message_callback property
  # Add a message callback function with .on_message
  # ```
  # client.on_message do |msg|
  #   puts msg
  # end
  # ```
  property message_callback : (Message -> Nil)?

  # All messages will be sent through this callback.
  # ```
  # client.on_all do |msg|
  #   puts msg
  # end
  # ```
  property all_callback : (String -> Nil)?

  # When room is joined this callback will be called
  # ```
  # client.on_room_join do |room|
  #   puts room.name
  # end
  # ```
  property join_room_callback : (Room -> Nil)?

  # If newtokens are passed this callback will be called
  # ```
  # client.on_new_tokens do |token, refresh_token|
  #   puts token
  # end
  # ```
  property new_tokens_callback : (String, String -> Nil)?

  # If a user joins a room this callback will be called
  # ```
  # client.on_user_joined_room do |user|
  #   puts user.display_name
  # end
  # ```
  property user_joined_room_callback : (User -> Nil)?

  def auth
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

  # Takes a role "raised_hand", "listener", "speaker" and an optional userId which will default to the bot userId
  def set_role(role : String, userId : String?)
    @ws.send(
      {
        "op" => SET_ROLE,
        "p"  => {
          "role"   => role,
          "userId" => userId.nil? ? @myself.not_nil!.id : userId.not_nil!,
        },
        "v"   => "0.2.0",
        "ref" => "[uuid]",
      }.to_json
    )
  end

  # Client takes your dogehouse token and refreshToken in order to auth
  def initialize(@token : String, @refresh_token : String)
    @ws = HTTP::WebSocket.new(URI.parse(API_URL))

    auth
  end

  # Send raw messages api without wrapper
  def raw_send(msg)
    @ws.send msg
  end

  # Add a message callback
  # on_message takes block with context parameter and String parameter
  # ```
  # client.on_message do |msg|
  #   puts msg
  # end
  # ```
  def on_message(&block : Message -> Nil)
    @message_callback = block
  end

  # Add all callback
  # All messages recieved in the client will be sent through this callback
  # ```
  # client.on_all do |msg|
  #   puts msg
  # end
  # ```
  def on_all(&block : String -> Nil)
    @all_callback = block
  end

  # Add room join callback
  # ```
  # client.on_room_join do |room|
  #   puts room.name
  # end
  # ```
  def on_room_join(&block : Room -> Nil)
    @room_join_callback = block
  end

  # Add ready callback
  # ```
  # client.on_ready do |user|
  #   puts user.display_name
  # end
  # ```
  def on_ready(&block : User -> Nil)
    @ready_callback = block
  end

  # Add new tokens callback
  # ```
  # client.on_new_tokens do |token, refresh_token|
  #   puts token
  # end
  # ```
  def on_new_tokens(&block : String, String -> Nil)
    @new_tokens_callback = block
  end

  # Add user joined room callback
  # ```
  # client.on_user_joined_room do |user|
  #   puts user.display_name
  # end
  # ```
  def on_user_joined_room(&block : User -> Nil)
    @user_joined_room_callback = block
  end

  # Sends message to whatever room currently in
  # ```
  # client.send_message "msg"
  # ```
  def send(message : String)
    @message_queue << message
  end

  def set_speaking(b : Bool)
    @ws.send(
      {
        "op" => SET_SPEAKER,
        "p"  => {
          "active" => b,
        },
        "v"       => "0.2.0",
        "fetchId" => "speaking_res",
      }.to_json
    )

    @speaking = b
  end

  private def ping_loop
    spawn do
      loop do
        @ws.send "ping"
        sleep PING_TIMEOUT
      end
    end
  end

  private def message_loop
    spawn do
      loop do
        if @message_queue[0]?
          @ws.send(
            {
              "op" => "chat:send_msg",
              "d"  => {
                "tokens" => Message.encode @message_queue[0],
              },
              "v" => "0.2.0",
            }.to_json
          )
          @message_queue = @message_queue[1..]
        end
        sleep Time::Span.new nanoseconds: @delay
      end
    end
  end

  # Join room will join the room associated with a roomId
  # ```
  # client.join_room "roomid"
  # ```
  def join_room(roomId : String)
    @ws.send(
      {
        "op" => "room:join",
        "p"  => {
          "roomId" => roomId,
        },
        "ref" => "join_response",
        "v"   => "0.2.0",
      }.to_json
    )
    @joined_room = true
  end

  # Ask to speak will request to speak in whatever room the bot is in
  def ask_to_speak
    json = JSON.build do |j|
      j.object do
        j.field "op", ASK_TO_SPEAK
        j.field "d" do
          j.object do
          end
        end
      end
    end

    @ws.send(json)
  end

  # Will toggle mute on and off
  def toggle_mute
    @ws.send(
      {
        "op" => MUTE,
        "d"  => {
          "value" => !@muted,
        },
      }.to_json
    )

    @muted = !@muted
  end

  # Will mute
  def mute
    @ws.send(
      {
        "op" => MUTE,
        "d"  => {
          "value" => true,
        },
      }.to_json
    )

    @muted = true
  end

  # Will unmute
  def unmute
    @ws.send(
      {
        "op" => MUTE,
        "d"  => {
          "value" => false,
        },
      }.to_json
    )

    @muted = false
  end

  def get_rooms
    @ws.send(
      {
        "op" => TOP_ROOMS,
        "p"  => {
          "data" => 0,
        },
        "version" => "0.2.0",
        "ref"     => "room_response",
      }.to_json
    )
  end

  # Will create room with given name description and privacy option
  # Privacy options are limited to "public" and "private"
  def create_room(
    name : String,
    description : String = "",
    privacy : String = "public"
  )
    @ws.send(
      {
        "op" => CREATE_ROOM,
        "p"  => {
          "name"        => name,
          "description" => description,
          "privacy"     => privacy,
        },
        "version" => "0.2.0",
        "ref"     => "[uuid]",
      }.to_json
    )
  end

  private def room_loop
    spawn do
      loop do
        get_rooms
        sleep 2
      end
    end
  end

  private def setup_run
    room_loop

    @ws.on_message do |msg|
      if !@all_callback.nil?
        @all_callback.not_nil!.call msg
      end

      if msg == "pong"
        next
      end

      msg_json = Hash(String, JSON::Any).from_json msg
      if msg_json["op"]?
        if msg_json["op"] == "auth-good"
          m = msg_json["d"]
            .as_h["user"]
            .as_h
          user = User.from_json(m)
          if !@ready_callback.nil?
            @ready_callback.not_nil!.call user
          end
          @myself = user
        elsif msg_json["op"] == "room:get_top:reply"
          @rooms = msg_json["p"]
            .as_h["rooms"]
            .as_a.map { |room| Room.from_json room.as_h }
        elsif msg_json["op"] == "new_user_join_room"
          m = msg_json["d"]
            .as_h["user"]
            .as_h

          if !@user_joined_room_callback.nil?
            @user_joined_room_callback.not_nil!.call User.from_json m
          end
        elsif msg_json["op"] == "new-tokens"
          m = msg_json["d"]
            .as_h

          if !@new_tokens_callback.nil?
            @new_tokens_callback.not_nil!.call(
              m["accessToken"].as_s,
              m["refreshToken"].as_s
            )
          end
        elsif msg_json["op"] == "new_chat_msg"
          if !@message_callback.nil?
            m = msg_json["d"]
              .as_h["msg"]
              .as_h
            @message_callback.not_nil!.call(
              Message.new(
                m["userId"].as_s,
                m["sentAt"].as_s,
                m["isWhisper"].as_bool,
                Message.decode(
                  msg_json["d"]
                    .as_h["msg"]
                    .as_h["tokens"]
                    .as_a.map &.as_h
                )
              )
            )
          end
        elsif msg_json["op"] == "room-created"
          join_room msg_json["d"].as_h["roomId"].as_s
        elsif msg_json["op"] == "room:join:reply"
          payload = msg_json["p"]
            .as_h
          if !@room_join_callback.nil?
            @room_join_callback.not_nil!.call Room.from_json payload
          end
          # @delay = payload["chatThrottle"].as_i * 1000000
          @in_room = true
        end
      end
    end

    ping_loop
    message_loop
  end

  # Run the client
  # This will start the message loop
  def run
    setup_run

    @ws.run
  end
end
