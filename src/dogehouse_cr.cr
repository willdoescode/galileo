require "./dogehouse_cr/*"

module DogehouseCr
  def self.new(token : String, refreshToken : String)
    Client.new token, refreshToken
  end
end
