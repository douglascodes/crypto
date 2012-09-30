popularity_list = IO.readlines('.\lib\popular_words.txt')
popularity_list.each { |x| 
  x.chomp!
}

puts popularity_list
popularity_list.delete('')
puts popularity_list.length