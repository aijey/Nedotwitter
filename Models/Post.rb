class Post
  def initialize(author,date,content)
    @author = author
    @date = date
    @content = content
  end
  def to_h
    hash = {
      "author" => @author,
      "date" => @date,
      "content" => @content
    }
    hash
  end
end
