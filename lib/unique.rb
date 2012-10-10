module Unique
  def unique_ify(word)
    u = ''
    word.each_char { |c| 
    if u.include? c then next end
      u << c
    }
    return u
  end
end