require 'set'
require 'json'
class User
  attr_accessor :login
  def initialize(login, password)
    @login = login
    @password = password
  end
  def get_posts
    unless (File.exists?("./Data/Posts/#{@login}.json"))
      doc = File.open("./Data/Posts/#{@login}.json", mode: "w+")
      doc.write('{"posts": []}')
      doc.close
    end
    document = File.open("./Data/Posts/#{@login}.json").read
    my_hash = JSON.parse(document)
    my_hash["posts"]
  end
  def add_post post
    document = File.open("./Data/Posts/#{@login}.json", mode: "r")
    my_hash = JSON.parse(document.read)
    my_hash["posts"].push(post.to_h)
    document = File.open("./Data/Posts/#{@login}.json", mode: "w")
    data = JSON.pretty_generate(my_hash)
    document.write(data)
    document.close
  end
  def delete_post id
    document = File.open("./Data/Posts/#{@login}.json", mode: "r")
    my_hash = JSON.parse(document.read)
    my_hash["posts"].delete_at(id)
    data = JSON.pretty_generate(my_hash)
    document = File.open("./Data/Posts/#{@login}.json", mode: "w")
    document.write(data)
    document.close
  end
  def get_subs
    unless (File.exists?("./Data/Subs/#{@login}.txt"))
      doc = File.open("./Data/Subs/#{@login}.txt", mode: "w+")
      doc.close
    end
    document_data = File.open("./Data/Subs/#{@login}.txt", mode: "r").read
    document_data.split("\n")
  end
  def add_sub username
    unless (File.exists?("./Data/Subs/#{@login}.txt"))
      doc = File.open("./Data/Subs/#{@login}.txt", mode: "w+")
      doc.close
    end
    doc = File.open("./Data/Subs/#{@login}.txt", mode: "a")
    doc.write(username + "\n")
    doc.close
  end
  def delete_sub username
    unless (File.exists?("./Data/Subs/#{@login}.txt"))
      doc = File.open("./Data/Subs/#{@login}.txt", mode: "w+")
      doc.close
    end
    doc = File.open("./Data/Subs/#{@login}.txt", mode: "r")
    data = doc.read.split(' ')
    doc.close
    data.delete username
    doc = File.open("./Data/Subs/#{@login}.txt", mode: "w")
    data.each {|x| doc.write(x+"\n")}
    doc.close
  end
  def get_dialogs
    unless (File.exists?("./Data/Messages/#{@login}.json"))
      doc = File.open("./Data/Messages/#{@login}.json", mode: "w+")
      doc.write("{}")
      doc.close
    end
    doc = File.open("./Data/Messages/#{@login}.json", mode: "r")
    dialogs = JSON.parse(doc.read)
    doc.close
    dialogs
  end
  def add_message message
    unless (File.exists?("./Data/Messages/#{@login}.json"))
      doc = File.open("./Data/Messages/#{@login}.json", mode: "w+")
      doc.write("{}")
      doc.close
    end
    doc = File.open("./Data/Messages/#{@login}.json", mode: "r")
    dialogs = JSON.parse(doc.read)
    doc.close
    if (dialogs[message.dialog] == nil)
      dialogs[message.dialog] = []
    end
    hash = {
      "message" => message.to_h
    }
    dialogs[message.dialog].push(hash)
    doc = File.open("./Data/Messages/#{@login}.json", mode: "w")
    doc.write JSON.pretty_generate(dialogs)
    doc.close
  end
  def exists?
    File.foreach("./Data/Users.txt") do |line|
      user = line.split(' ')
      if (@login == user[0] && @password == user[1])
        return true
      end
    end
    false
  end
  def login_already_taken?
    File.foreach("./Data/Users.txt") do |line|
      user = line.split(' ')
      if (user[0].downcase == @login.downcase)
        return true
      end
    end
    false
  end
end
class Users
  @@users = Set.new
  @@tokens = Hash.new
  @@user_token = Hash.new
  def initialize(user)
    @@users.add(user)
  end
  def Users.set_token(user, token)
    if (user!=nil && @@user_token[user.login] != nil)
      @@tokens[@@user_token[user.login]] = nil
    end
    if (user != nil)
      @@user_token[user.login] = token.token.to_sym
    else
      @@user_token[@@tokens[token.token.to_sym]] = nil
    end
    @@tokens[token.token.to_sym] = user
  end

  def Users.find_user_by_token(token)
    @@tokens[token.token.to_sym]
  end
  def Users.print_all
    @@tokens.each {|x,y| p x + " " + y.login}
  end
  def Users.get_all_messages
    res = Set.new
    @@tokens.each do |token,user|
      dialogs = user.get_dialogs
      dialogs.each do |dialog,messages|
        messages.each do |message|
          res << message
        end
      end
    end
    res
  end
  def Users.get_all_users
    res = []
    @@tokens.each do |token,user|
      res << user
    end
    res
  end
end
