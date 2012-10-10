require 'net/http'
require 'rexml/document'
require 'action_view'
require 'date' 
include REXML
include ActionView::Helpers::SanitizeHelper

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

class Solver   #The problem solver class. Gets puzzles, parses em, Solves em. Saves em.
  attr_accessor :p_list, :solved, :current_puzzle, :pop_w,
    :pop_l, :dict, :short_dict, :crypto, :puzz_letters, :let_list
  def initialize
    @p_list = get_puzzles() #List of puzzle objects
    @solved = 0             #Simple enumerator for number of solved puzzles
    @pop_w = get_1000_words() #Sets the possible dictionaries. POP_W is the top 1000 English words 
    @dict, @short_dict = get_dicts()  #Sets a small and full dictionary
  end

  def get_puzzles
    #Loads puzzles for the solver class to work on
    f = Document.new(get_feed())
    r = f.root
    return conform_puzzles(r)
  end
    
  def get_feed(xmlfeed='http://www.threadbender.com/rss.xml')
    #Downloads an XML feed. The default is the test one.
      feed = URI(xmlfeed)
      feed = Net::HTTP.get(feed)
      return feed
  end
 
  def get_1000_words(file='.\lib\popular_words.txt')  #Gets an array of the top 100 used English words
    pop_w_list = IO.readlines(file)
    pop_w_list.each { |x| 
      x.chomp!
    }
    pop_w_list.delete('')
    pop_w_list.sort!{ |a,b|
      a.length <=> b.length
    }
    return pop_w_list
  end 

  def get_dicts(file='.\bin\english.0') #Uses the included open source dictionary of english words
    #Returns two versions, a small one (4 <= letters) and a full one. Stripped of possesive versions.
    s_words = []
    words = IO.readlines(file)
    words.each { |w| 
      if w.include? "'" then next end
      w.chomp!
      w.upcase!
      if w.length <= 4
        s_words << w
      end
    }
    words.delete('')
    s_words.delete('')
  return words, s_words
  end 
  
  def conform_puzzles(root)
    #Strips XML tags and creates a list of Puzzle objects
    p_list = []
    root.each_element('//item') { |item|
      desc, author, date = break_up_puzzle(item)  #Seperates the extracted puzzle into three parts
      p_list << Puzzle.new(desc, author, date)
    }
    return p_list
  end
  
  def break_up_puzzle(p)
    desc = p.delete_element('description').to_s
    desc = strip_tags(desc)
    desc, author = seperate_author(desc)
    date = p.delete_element('pubDate').to_s
    date = Date.parse(strip_tags(date))
    return desc, author, date
  end
  
  def seperate_author(unbroken)
    #Sets puzzle to unsolved letters (downcase) and removes punctuation
    unbroken.downcase!
    a, b = unbroken.split(/[.?!] - /)
    a.delete!(".,!?':;&()")
    a.strip!
    b.delete!(".,!?':;&()")
    b.strip!
    return a, b 
  end

  def solve(crypto)
    crypto.each { |word|
      if word.length != 1 then break end
      
      letter1 = get_lett_obj(word[0])
      letter1.possible.each { |z|
        p_word = word.gsub(/#{letter1.name}/, z.to_s)
      }
    }
  end
  
  def get_lett_obj(letter)
    @let_list.each { |o|
      if o.name != letter then next end
      return o
    }
    return false
  end  
  
#  def brute_thru_word(word)
#    u_letters = word.squeeze()
#    count = u_letters.length
#    letters = @let_list.select { |let|
#      u_letters.include?(let.name)
#    }
#    brute_thru_letters(word, u_letters, letters, count)
#  end
#  
#  def brute_thru_letters(word="xyz", u_letters, letters, count)
#    for x in 0..count
#      word_x = word
#      max_possible = letters[x].possible.length
#      for y in 0..max_possible
#        word_y = word_x
#        
#      end
#      
#  end

  
  def set_up_puzzle(puzz)
    #Breaks PUZZ into the crypto array sorted by word size
    @crypto = []
    @current_puzzle = puzz
    set_letters()
    @crypto = (puzz.crypto.split).sort!{ |a,b|
    a.length <=> b.length
  }  
  end
  
  def set_letters()
    #Creates an alphabetical list of LETTER objects
    @let_list = []
      for l in "a".."z"
        @let_list << Letter.new(l)
      end
  end
  
  def poss(word)
    #Checks each succesively large dictionary for presence of the passed string 
    if @pop_w.include? word then return true end
    if @short_dict.include? word then return true end
    if @dict.include? word then return true end
      return false
  end
end

class Puzzle
  attr_accessor :crypto, :solution, :author_sol, :author, :publ_date, :solve_time,
    :uniques, :full_uniques
  def initialize(crypto='ABCDEF', author="Bace Troncons", publ_date=Time.now)
    @crypto = crypto          #The seperated cryptogram from the author section
    @author = author          #The seperated author section for the crpytogram
    @publ_date = publ_date    #The seperated date value
    @solve_time = nil         #Var for the date/time the solution was first made
    @uniques = unique_ify(@crypto)
    @full_uniques = unique_ify((@crypto + @author))
  end
  
  def set_solve_date
    if @solve_date
      return
    end    
    @solve_time = Time.now 
  end

  def to_s
    print 'Code: ', @crypto,  "\nAuthor: ", @author, "\nDate: ", @publ_date, "\nCompleted: ", @solve_time, "\n"
  end
end

class Letter
  #Letter objects that contain their own NAME, and a list of POSSIBLE interpretations
  #It is assumed that by the rules of the cryptogram that they cannot end up being themself
  attr_accessor :name, :not_possible, :possible
  @@pop_l = %w( E T A O I N S H R D L C U M W F G Y P B V K J X Q Z ) 
  

  def initialize(itself)
      #Sets the possible list, and the self.name
      #lowercase letters are the unchanged letters, upcase is solved letters
      @name = itself.downcase
      @not_possible = itself.upcase
      @possible = @@pop_l
      @possible.delete(itself.upcase)       
    end  

end
