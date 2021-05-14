require "http/web_socket"
require "./base.cr"

class Context < BaseEntity
  property ws : HTTP::WebSocket

  def initialize(@ws : HTTP::WebSocket)
  end
end
