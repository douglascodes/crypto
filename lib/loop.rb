array_of_dicts = Array.new(20, Array.new()) 
#    @dicts << 'I'
#    @dicts << 'A'

dicts = Array.new(20) { |i| Array.new }    
words = IO.readlines('.\bin\english.0')
words.each { |w| 
  if w.include? "'" then next end
  w.chomp!
  w.upcase!
  dicts[w.length] ||= Array.new
  dicts[w.length] << w
}
puts dicts[2]