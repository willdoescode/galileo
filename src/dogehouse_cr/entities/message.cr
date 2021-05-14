class DogehouseCr::Message
  getter user_id : String
  getter sent_at : String
  getter is_whisper : Bool
  getter content : String

  def initialize(@user_id : String, @sent_at : String, @is_whisper : Bool, @content : String)
  end
end
