require "json"

class Galileo::Room
  property id : String
  property name : String
  property description : String
  property is_private : Bool

  def initialize(
    @id : String,
    @name : String,
    @description : String,
    @is_private : Bool,
  )
  end

  def self.from_json(payload : Hash(String, JSON::Any))
    Room.new(
      payload["id"].as_s,
      payload["name"].as_s,
      payload["description"].as_s,
      payload["isPrivate"].as_bool,
    )
  end
end
