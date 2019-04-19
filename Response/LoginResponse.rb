require './Models/User.rb'
class LoginResponse
  attr_accessor :is_logged
  def initialize (login, password)
    user = User.new(login, password)
    if user.exists?
      @is_logged = true
    else
      @is_logged = false
    end
  end
end
