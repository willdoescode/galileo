require "./dogehouse_cr/*"

module DogehouseCr
  # Create a new client with yoru token and refreshToken
  # ```
  # client = DogehouseCr "token", "refreshToken"
  # ```
  def self.new(token : String, refreshToken : String)
    Client.new token, refreshToken
  end
end
