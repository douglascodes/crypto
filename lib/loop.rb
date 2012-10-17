array_of_dicts = Array.new(20, Array.new())
#    @dicts << 'I'
#    @dicts << 'A'

dicts = Array.new(20)
h_dicts = Array.new(20)
words = IO.readlines('.\bin\english.0')
words.each { |w|
  if w.include? "'" then next end
  w.chomp!
  w.upcase!
  dicts[w.length] ||= Hash.new
  dicts[w.length].merge!({w => w.length})
}
puts dicts[2]