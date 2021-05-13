def encode_message(message : String)
  message.split(" ").map do |word|
    if word.starts_with? "@"
      {"type": "mention", "value": word[1..]}
    elsif word.starts_with? "https"
      {"type": "link", value: word}
    else
      {"type": "text", value: word}
    end
  end
end
