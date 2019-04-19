class Message
  attr_accessor :to,:dialog
  def initialize(from,to,dialog,date,content)
    @from = from
    @to = to
    @dialog = dialog
    @date = date
    @content = content
  end
  def to_h
    hash = {
      "from" => @from,
      "date" => @date,
      "content" => @content
    }
    hash
  end
end
