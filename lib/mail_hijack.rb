class Mail::Message
  def to(val=nil)
    default :to, "jtrupiano@gmail.com"
  end
  def to=( val )
    header[:to] = "jtrupiano@gmail.com"
  end
end
