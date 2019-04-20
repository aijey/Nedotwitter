require 'sinatra'
require 'haml'
require './Response/LoginResponse.rb'
require './Response/RegisterResponse.rb'
require './Models/User.rb'
require './Models/Token.rb'
require './Models/Post.rb'
require './Models/Message.rb'
require 'date'
require 'socket'

set :bind, '0.0.0.0'
set :public_folder, File.dirname(__FILE__) + '/secret'
# set :static_cache_control, [:public, :max_age => 300]

def print_invalid_session
  res = "<p style='color: red'>Invalid session</p>"
  res += '<br><a href="/">Return to login page</a>'
  res
end

get '/' do
  haml :login
end
post '/login' do
  login_response = LoginResponse.new(params[:login],params[:password])
  user = User.new(params[:login],params[:password])
  if login_response.is_logged
    token = Token.new(nil, params[:login].to_s)
    Users.set_token(user,token)
    # p user.login
    redirect "/home?session=" + token.token
  else
    @incorrect_data = true
    haml :login
  end
end

get '/home' do
  token = Token.new(params[:session])
  user = Users.find_user_by_token token
  if user != nil
    @token = token.token
    # p user.login
    @posts = user.get_posts.reverse
    @title = "Home page | Nedo"
    @username = user.login
    @cnt_posts = @posts.length
    @cnt_subscribers = user.get_subs_cnt

    haml :home, :layout => :logged_layout
  else
    print_invalid_session
  end
end

post '/home' do
  token = Token.new(params[:session])
  user = Users.find_user_by_token token
  if user != nil
    time = Time.now.strftime("%d.%m.%y %H:%M")
    post = Post.new(user.login, time, params[:content])
    user.add_post post
    @token = token.token
    @posts = user.get_posts
    @posts.reverse!
    @title = "Home page | Nedo"
    @username = user.login
    @cnt_subscribers = user.get_subs_cnt
    @cnt_posts = @posts.length
    haml :home, :layout => :logged_layout
  else
    print_invalid_session
  end
end

post '/delete' do
  token = Token.new(params[:session])
  user = Users.find_user_by_token token
  if user != nil
    user.delete_post(params[:id].to_i)
    redirect "/home?session=#{token.token}"
  else
    print_invalid_session
  end
end

post '/logout' do
  token = Token.new(params[:session])
  user = Users.find_user_by_token token
  if user != nil
    Users.set_token(nil,token)
    redirect '/'
  else
    print_invalid_session
  end
end

get '/register' do
  haml :register
end
post '/register' do
  register_response = RegisterResponse.new(params[:login],params[:password],params[:confirm_password])
  res = register_response.register_status
  res += "<br><a href = '/'> Return to login page </a>"
  res
  
end

get '/subs' do
  token = Token.new(params[:session])
  user = Users.find_user_by_token token
  if user != nil
    @subs = user.get_subs
    @token = token.token
    haml :subs
  else
    print_invalid_session
  end
end

get '/search/:username' do
  token = Token.new(params[:session])
  user = User.new(params[:username],nil)
  unless user.login_already_taken?
    return "User doesn't exist" + "<br><a href='/subs?session=#{token.token}'>Return to subs page</a>"
  else
    user.corectize!
    if (Users.find_user_by_token(token)!=nil &&
      user.login == Users.find_user_by_token(token).login)
      redirect "/home?session=#{token.token}"
    end
    @token = token.token
    @username =  user.login
    @posts = user.get_posts.reverse
    @cnt_subscribers = user.get_subs_cnt
    @cnt_posts = @posts.length
    logged_user = Users.find_user_by_token token
    if logged_user !=nil && logged_user.get_subs.include?(@username)
      @subscribed = true
    else
      @subscribed = false
    end
    # p @subscribed
    haml :user_posts, :layout => :logged_layout
  end
end

post '/search' do
  token = Token.new(params[:session])
  user = User.new(params[:username],nil)
  unless user.login_already_taken?
    return "User doesn't exist" + "<br><a href='/subs?session=#{token.token}'>Return to subs page</a>"
  else
    user.corectize!
    @title = "#{user.login} | Nedo"
    if (Users.find_user_by_token(token) != nil &&
      user.login == Users.find_user_by_token(token).login)
      redirect "/home?session=#{token.token}"
    end
    @token = token.token
    @username = user.login
    @posts = user.get_posts.reverse
    @cnt_subscribers = user.get_subs_cnt
    @cnt_posts = @posts.length
    logged_user = Users.find_user_by_token token
    if logged_user !=nil && logged_user.get_subs.include?(@username)
      @subscribed = true
    else
      @subscribed = false
    end
    # p @subscribed
    haml :user_posts, :layout => :logged_layout
  end
end

post '/add_sub' do
  token = Token.new(params[:session])
  user = Users.find_user_by_token token
  if user == nil
    print_invalid_session
  else
    if params[:subscribed] == "false"
      user.add_sub params[:username]
    else
      user.delete_sub params[:username]
    end
    redirect "/subs?session=#{token.token}"
  end
end

get '/feed' do
  token = Token.new(params[:session])
  user = Users.find_user_by_token token
  if (user == nil)
    print_invalid_session
  else
    @token = token.token
    subs = user.get_subs
    @posts = []
    subs.each do |sub|
      sub_user = User.new(sub,nil)
      sub_user_posts = sub_user.get_posts
      sub_user_posts.each {|post| @posts << post}
    end

    @posts = @posts.sort do |post1, post2|
      date1 = DateTime.strptime(post1["date"], "%d.%m.%y %H:%M")
      date2 = DateTime.strptime(post2["date"], "%d.%m.%y %H:%M")
      date2 <=> date1
    end

    haml :feed, :layout => :logged_layout
  end
end

get '/messages' do
  token = Token.new(params[:session])
  user = Users.find_user_by_token token
  if (user == nil)
    print_invalid_session
  else
    @token = token.token
    @dialogs = user.get_dialogs
    haml :dialogs
  end
end

get '/messages/:username' do
  token = Token.new(params[:session])
  user = Users.find_user_by_token token
  if (user == nil)
    print_invalid_session
  else
    @username = params[:username]
    @token = token.token
    @messages = user.get_dialogs[@username]
    haml :messages
  end
end


post '/send_message' do
  token = Token.new(params[:session])
  user = Users.find_user_by_token token
  if (user == nil)
    print_invalid_session
  else
    message = Message.new(user.login, params[:to], params[:to], Time.now.strftime("%d.%m.%y %H:%M"), params[:content])
    user.add_message message
    user_to = User.new(params[:to], nil)
    message.dialog = user.login
    user_to.add_message message
    redirect("/messages/#{user_to.login}?session=#{token.token}")
  end
end

__END__
