require "http/web_socket"
require "spec"
require "json"
require "./user.cr"
require "./utils/tokenizer.cr"
require "./entity.cr"

API_URL = "wss://api.dogehouse.tv/socket"
PING_TIMEOUT = 8

class DogehouseCr::Client < DogeEntity
  property ws : HTTP::WebSocket
  property message_callback : (Context, String -> Nil)?
  property ping_callback : (Context -> Nil)?

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

  def raw_send(msg)
    @ws.send msg
  end

  def on_message(&block : Context, String -> Nil)
    @message_callback = block
  end

  def on_ping(&block : Context -> Nil)
    @ping_callback = block
  end

  def setup_run
    @ws.on_message do |msg|
      if msg == "ping"
        if !@ping_callback.nil?
          @ping_callback.not_nil!.call Context.new(@ws)
        end
        next
      end

      if !@message_callback.nil?
        @message_callback.not_nil!.call Context.new(@ws), msg
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
