word = "paper"
sqz = "paper".squeeze()
s = sqz.squeeze()
count = word.length
alphabet = ('a'..'z')
print sqz
print s
print "paper".squeeze()
for x in 'a'..'z'
  sub_x = sqz[0]
  x_word = word.sub(/#{sub_x}/, x)
  for y in 'a'..'z'
    sub_y = sqz[1]
    y_word = x_word.sub(/#{sub_y}/, y)
    alphabet.each { |z|
      sub_z = sqz[2]
      z_word = y_word.sub(/#{sub_z}/, z.to_s)
      }
  end
end
