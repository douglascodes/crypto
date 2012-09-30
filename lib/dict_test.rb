pop_w_list = IO.readlines('.\bin\english.0')
pop_w_list.each { |x| 
  if x.include? "'" 
    x.clear
  end
  x.chomp!
  
}
pop_w_list.delete('')
puts pop_w_list