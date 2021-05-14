require "http/web_socket"
require "json"

class BaseEntity
  # Sends message to whatever room currently in
  # ```
  # client.send_message "msg"
  # ```
  def send_message(message : String)
    @ws.send(
      {
        "op" => "chat:send_msg",
        "d"  => {
          "tokens" => encode_message message,
        },
        "v" => "0.2.0",
      }.to_json
    )
  end

  # Join room will join the room associated with a roomId
  # ```
  # client.join_room "roomid"
  # ```
  def join_room(roomId : String)
    @ws.send(
      {
        "op" => "room:join",
        "d"  => {
          "roomId" => roomId,
        },
        "ref" => "[uuid]",
        "v"   => "0.2.0",
      }.to_json
    )
  end
end
