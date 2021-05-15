require "http/web_socket"
require "json"

class DogehouseCr::User
  getter id : String
  getter username : String
  getter avatar_url : String
  # If there is no banner url given this will be an empty string
  getter banner_url : String
  getter bio : String
  getter online : Bool
  getter staff : Bool
  getter last_online : String
  # If there is no current room id given this will be an empty string
  getter current_room_id : String
  getter display_name : String
  getter num_following : Int32
  getter num_followers : Int32
  getter contributions : Int32
  getter you_are_following : Bool
  getter follows_you : Bool
  # If user is not a bot this will be an empty string
  getter bot_owner_id : String

  def initialize(
    @id : String,
    @username : String,
    @avatar_url : String,
    @banner_url : String,
    @bio : String,
    @online : Bool,
    @staff : Bool,
    @last_online : String,
    @current_room_id : String,
    @display_name : String,
    @num_following : Int32,
    @num_followers : Int32,
    @contributions : Int32,
    @you_are_following : Bool,
    @follows_you : Bool,
    @bot_owner_id : String
  )
  end

  def self.from_json(m : Hash(String, JSON::Any)) : User
    User.new(
      m["id"].as_s,
      m["username"].as_s,
      m["avatarUrl"].as_s,
      m["bannerUrl"].as_s? ? m["bannerUrl"].as_s : "",
      m["bio"].as_s,
      m["online"].as_bool,
      m["staff"].as_bool,
      m["lastOnline"].as_s,
      m["currentRoomId"].as_s? ? m["currentRoomId"].as_s : "",
      m["displayName"].as_s,
      m["numFollowing"].as_i,
      m["numFollowers"].as_i,
      m["contributions"].as_i,
      m["youAreFollowing"].as_bool? ? true : false,
      m["followsYou"].as_bool? ? true : false,
      m["botOwnerId"].as_s? ? m["botOwnerId"].as_s : ""
    )
  end
end
