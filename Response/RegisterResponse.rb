class RegisterResponse
  attr_accessor :register_status
  def initialize(login, password, confirm_password)
    if (legit(login) && legit(password))
      if (password != confirm_password)
        @register_status = "Passwords don't equal"
        return;
      end
      unless (User.new(login,password).login_already_taken?)
        File.write("./Data/Users.txt", login + " " + password + "\n", mode:"a")
        @register_status = "You have been successfully registered"
      else
        @register_status = "Login already taken"
      end
    else
      @register_status = "Login and password should contain only latin letters and numbers"
    end
  end
  def legit(string)
    string = string.split('')
    if (string.length == 0)
      return false
    end
    string.each do |x|
      p x
      unless (x>='0' && x<='9' || x>='a' && x<='z' || x>='A' && x<='Z')
        return false
      end
    end
    true
  end
end
