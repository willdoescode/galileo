require "http/web_socket"
require "spec"
require "json"

API_URL = "wss://api.dogehouse.tv/socket"
PING_TIMEOUT = 8

class DogehouseCr::Client
  property ws : HTTP::WebSocket

  def initialize(@token : String, @refreshToken : String)
    @ws = HTTP::WebSocket.new(URI.parse(API_URL))

    @ws.send(
      {
        "op" => "auth", 
        "d" => {
          "accessToken" => @token, 
          "refreshToken" => @refreshToken
        }, 
        "reconnectToVoice" => false,
        "muted" => true,
        "platform" => "dogehouse-cr"
      }.to_json
    )

    spawn do
      loop do
        @ws.send "ping"
        sleep PING_TIMEOUT
      end
    end
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

  def raw_send(msg)
    @ws.send msg
  end

  def run
    @ws.run
  end

  def test_run(time : Int)
    spawn do
      @ws.run
    end

    sleep time
    return
  end
end
