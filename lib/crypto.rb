require 'net/http'
require 'rexml/document'
require 'action_view'
require 'spellchecker'
require 'date' 
include REXML
include ActionView::Helpers::SanitizeHelper

class Solver
  attr_accessor :p_list, :solved, :current_puzzle, :pop_w
  
  def initialize
    @p_list = []
    @solved = 0
    @pop_w = get_1000_words()
    @dict = get_full_dict()
  end
  
  def get_feed(xmlfeed='http://www.threadbender.com/rss.xml')
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
    return pop_w_list
  end 
  
  def find_puzzles
      
  end
    
  
  def find_puzzles
    
  end
  
  def conform_puzzles(root)
    root.each_element('//item') { |item|
      desc, author, date = break_up_puzzle(item)
      @p_list << Puzzle.new(desc, author, date)
    }
    return @p_list
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
    a, b = unbroken.split(". - ")
    a.delete!(".,!?':;&()")
    a.strip!
    a.downcase!
    b.delete!(".,!?':;&()")
    b.strip!
    b.downcase!
    return a, b 

    def solve(puzzle)
      
      if true then puzzle.set_solve_date() end
    end

    def generate_possible 
      
    end
    
    def check_word_in_dict(word)
      
    end

  end
end
  
class Puzzle
  attr_accessor :crypto, :solution, :author_sol, :author, :publ_date, :solve_time
  
  def initialize(crypto='ABCDEF', author="Bace Troncons", publ_date=Time.now)
    @crypto = crypto
    @author = author
    @publ_date = publ_date
    @solve_time = nil
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
  attr_accessor :name, :not_possible
    
    def initialize(itself)
      @name = @not_possible = itself
          
    end  

end
#s = Solver.new()
#f = s.get_feed()
#f = Document.new(f)
#s.conform_puzzles(f)
#s.p_list.each { |x|
#  p x
#}

#Break the first part into words.

#option 1
#Do each variation for each vowel... 
#check those possibilties against the dictionaries using regular expressions

#option 2
#Create a set of all letters in the puzzle excluding the author...
#this is a limited number, much smaller than all possible


#techniques
# utilize lowercase letters for puzzle, Upcase for solutions to prevent overlap
# run the program against the smallest words... up to 4 letters, as a shield for
# 