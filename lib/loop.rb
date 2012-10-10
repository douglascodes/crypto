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
include Unique
word = "seperate"
sqz = unique_ify(word)
alphabet = ('a'..'z')
puts word
puts sqz

for x in 'a'..'z'
  sub_x = sqz[0]
  x_word = word.gsub(/#{sub_x}/, x)
  for y in 'a'..'z'
    sub_y = sqz[1]
    y_word = x_word.gsub(/#{sub_y}/, y)
    alphabet.each { |z|
      sub_z = sqz[2]
      z_word = y_word.gsub(/#{sub_z}/, z.to_s)
      #puts z_word
      }
  end
end
