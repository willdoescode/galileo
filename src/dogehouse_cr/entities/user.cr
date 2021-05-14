require "http/web_socket"
require "json"

class DogehouseCr::User
  getter id : String
  getter username : String
  getter avatar_url : String
  getter banner_url : String
  getter bio : String
  getter online : Bool
  getter staff : Bool
  getter last_online : String
  getter current_room_id : String
  getter display_name : String
  getter num_following : Int32
  getter num_followers : Int32
  getter contributions : Int32
  getter you_are_following : Bool
  getter follows_you : Bool
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
end
