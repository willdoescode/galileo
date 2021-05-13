require "http/web_socket"
require "json"

API_URL = "wss://api.dogehouse.tv/socket"

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

  def run
    @ws.run
  end
end
