class DogehouseCr::Room
  getter id : String
  getter name : String
  getter description : String
  getter is_private : Bool

  def initialize(@id : String, @name : String, @description : String, @is_private : Bool)
  end
end
