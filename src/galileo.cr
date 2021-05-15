require "./galileo/*"

module Galileo
  # Create a new client with yoru token and refreshToken
  # ```
  # client = DogehouseCr.new "token", "refreshToken"
  # ```
  def self.new(token : String, refreshToken : String)
    Client.new token, refreshToken
  end
end
