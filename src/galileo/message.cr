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
    block_started = false

    message.split(" ").map do |word|
      if word.starts_with? "@"
        {type: "mention", value: word[1..]}
      elsif word.starts_with? "https"
        {type: "link", value: word}
      elsif word.starts_with? "`"
        if word.ends_with? "`"
          {type: "block", value: word[1..word[1..].rindex("`")]}
        else
          block_started = true
          {type: "block", value: word[1..]}
        end
      elsif word.ends_with? "`"
        block_started = false
        {type: "block", value: word[..word.rindex("`").not_nil! - 1]}
      elsif word.starts_with?(":") && word.ends_with? ":"
        {type: "emote", value: word[1..word.size]}
      else
        if block_started
          {type: "block", value: word}
        else
          {type: "text", value: word}
        end
      end
    end
  end

  def self.decode(message : Array(Hash(String, JSON::Any))) : String
    message.map do |word|
      if word["t"] == "mention"
        "@#{word["v"].as_s}"
      elsif word["t"] == "block"
        "`#{word["v"].as_s}`"
      elsif word["t"] == "emote"
        ":#{word["v"].as_s}:"
      else
        word["v"].as_s
      end
    end.join " "
  end
end
