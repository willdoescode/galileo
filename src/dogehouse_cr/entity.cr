require "http/web_socket"
require "json"

class DogeEntity
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
end

class Context < DogeEntity
  property ws : HTTP::WebSocket

  def initialize(@ws : HTTP::WebSocket)
  end
end
