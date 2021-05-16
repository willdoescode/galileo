class Galileo::Message
  getter user_id : String
  getter sent_at : String
  getter is_whisper : Bool
  getter content : String

  def initialize(
    @user_id : String,
    @sent_at : String,
    @is_whisper : Bool,
    @content : String
  )
  end

  def self.encode(message : String)
    message.split(" ").map do |word|
      if word.starts_with? "@"
        {type: "mention", value: word[1..]}
      elsif word.starts_with? "https"
        {type: "link", value: word}
      else
        {type: "text", value: word}
      end
    end
  end

  def self.decode(message : Array(Hash(String, JSON::Any))) : String
    message.map do |word|
      if word["t"] == "mention"
        "@#{word["v"].as_s}"
      elsif word["t"] == "link"
        word["v"].as_s
      else
        word["v"].as_s
      end
    end.join " "
  end
end
