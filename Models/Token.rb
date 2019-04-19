class Token
  attr_accessor :token
  def gen_token(login)
    rnd = Random.new
    token = rnd.rand(1e18.to_i)
    token = token.to_s + "!" + login.reverse + "!"
    token
  end

  def initialize (token = nil, login = nil)
    if token == nil
      token = gen_token(login)
    end
    @token = token
  end

end
