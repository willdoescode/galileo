require "http/web_socket"
require "json"

class DogehouseCr::User
  property ws : HTTP::WebSocket

  def initialize(@ws : HTTP::WebSocket)
  end
end