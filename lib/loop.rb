   words = IO.readlines('.\bin\english.0')
    #smith = IO.readlines('.\bin\smith.txt')
    #words.concat(smith)
    dicts = Array.new(20)
    words.concat( ['A', 'I', "I'M", "I'D", "I'LL"] )
    #The used dictionary does not include these
    words.each { |w|
    #if w.include? "'" then next end
      w.chomp!
      w.upcase!
      if w[0] == 'X' then next end
        #Removes the roman numerals starting with X. Not needed
      dicts[w.length] ||= Hash.new
      dicts[w.length].merge!({w => w.length})

    }

if dicts[3].has_key?("I'M") then  puts dicts[3].keys end