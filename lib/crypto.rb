require 'net/http'
require 'rexml/document'
require 'action_view'
require 'date' 
include REXML
include ActionView::Helpers::SanitizeHelper

class Solver
  attr_accessor :p_list, :solved, :current_puzzle, :pop_w,
    :pop_l, :dict, :short_dict, :crypto, :puzz_letters, :let_list
  
  def initialize
    @p_list = get_puzzles()
    @solved = 0
    @pop_w = get_1000_words()
    @dict, @short_dict = get_dicts()
  end

  def get_puzzles
    f = Document.new(get_feed())
    r = f.root
    return conform_puzzles(r)
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
    pop_w_list.sort!{ |a,b|
      a.length <=> b.length
    }
    return pop_w_list
  end 

  def get_dicts(file='.\bin\english.0')
    s_words = []
    words = IO.readlines(file)
    words.each { |w| 
      if w.include? "'" 
        w.clear
      end
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
    p_list = []
    root.each_element('//item') { |item|
      desc, author, date = break_up_puzzle(item)
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
    unbroken.downcase!
    a, b = unbroken.split(". - ")
    a.delete!(".,!?':;&()")
    a.strip!
    b.delete!(".,!?':;&()")
    b.strip!
    return a, b 
  end

  def solve(crypto)
    run_singles(crypto)
    
    if true then puzzle.set_solve_date() end
  end
  
  def run_singles(crypto)
    crypto.each { |word|
      if word.length == 1
      
      word.chars { |c|
        while c == c.downcase || 
          
        end
      }
          
        
      end      
    }
  end
  
  def set_up_puzzle(puzz)
    @crypto = []
    @current_puzzle = puzz
    set_letters()
    @crypto = (puzz.crypto.split).sort!{ |a,b|
    a.length <=> b.length
  }  
  end
  
  def set_letters()
    @let_list = []
      for l in "A".."Z"
        @let_list << Letter.new(l)
      end
  end
  
  def poss(word)
    if @pop_w.include? word then return true end
    if @short_dict.include? word then return true end
    if @dict.include? word then return true end
      return false
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
  attr_accessor :name, :not_possible, :possible
  @@pop_l = %w( E T A O I N S H R D L C U M W F G Y P B V K J X Q Z ) 

    def initialize(itself)
      @name = itself.downcase
      @not_possible = itself.upcase
      @possible = @@pop_l
      @possible.delete(itself.upcase)       
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