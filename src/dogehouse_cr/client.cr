require "http/web_socket"
require "spec"
require "json"
require "./user.cr"
require "./utils/tokenizer.cr"

API_URL = "wss://api.dogehouse.tv/socket"
PING_TIMEOUT = 8

class DogehouseCr::Client
  property ws : HTTP::WebSocket
  property message_callback : (String -> Nil)?

  def initialize(@token : String, @refresh_token : String)
    @ws = HTTP::WebSocket.new(URI.parse(API_URL))

    @ws.send(
      {
        "op" => "auth", 
        "d" => {
          "accessToken" => @token, 
          "refreshToken" => @refresh_token
        }, 
        "reconnectToVoice" => false,
        "muted" => true,
        "platform" => "dogehouse_cr"
      }.to_json
    )
  end

  def join_room(roomId : String)
    @ws.send(
      {
        "op" => "room:join",
         "d" => {
           "roomId" => roomId
         },
         "ref" => "[uuid]",
         "v" => "0.2.0"
      }.to_json
    ) 
  end

  def send_message(message : String)
    @ws.send(
      {
        "op" => "chat:send_msg",
        "d" => {
          "tokens" => encode_message message
        },
        "v" => "0.2.0"
      }.to_json
    )
  end

  def raw_send(msg)
    @ws.send msg
  end

  def on_message(&block : String -> Nil)
    @message_callback = block
  end

  def setup_run
    if !@message_callback.nil?
      @ws.on_message do |msg|
        @message_callback.not_nil!.call msg
      end
    end

    spawn do
      loop do
        @ws.send "ping"
        sleep PING_TIMEOUT
      end
    end
  end

  def run
    setup_run

    @ws.run
  end

  def test_run(time : Int)
    setup_run

    spawn do
      @ws.run
    end

    sleep time
    return
  end
end
