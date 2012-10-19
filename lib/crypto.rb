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
  attr_accessor :p_list, :solved, :let_list, :dicts
  def initialize
    @p_list = get_puzzles() #List of puzzle objects
    @solved = 0             #Simple enumerator for number of solved puzzles
    @dicts = set_size_dicts(@dicts)
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

  def set_size_dicts(dicts)
    words = IO.readlines('./bin/english.0')
    #smith = IO.readlines('./bin/smith.txt')
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

    return dicts
  end

  def conform_puzzles(root)
    #Strips XML tags and creates a list of Puzzle objects
    p_list = Array.new
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
    a.delete!(".,!?:;&()")
    a.strip!
    b.delete!(".,!?:;&()")
    b.strip!
    return a, b
  end

  def go_to_work(which=nil)
    #takes the passed argument from main.rb
      if which
       p = @p_list[which]
         solve(p)
         create_solution(p)
         puts p.solution
      else
      @p_list.each { |p|
         solve(p)
         create_solution(p)
         p.set_solve_date
         p.to_s
      }
      end
  end

  def create_solution(puzz)
    mask = %w[ E T A O I N S H R D L C U M W F G Y P B V K J X Q Z ' -]
    puzz.solution = (puzz.crypto << "\n" << puzz.author)
    @let_list.each { |k, v|
      if v.possible.frozen? then next end
      if v.possible.empty? then next end
      priority = v.possible.take_while{ |p|
        mask.include? p
      }
      puzz.solution.gsub!(k, priority.first)
    }

  end

  def solve(puzz)
    c = puzz.crypto_broken
    set_letters()
    for z in 1..3
      for x in 1..unique_ify(c[-1]).length
      c.each { |word|
        #if word.include? "'"  then next end
        #if word.include? "-"  then next end
        u_word = unique_ify(word)
        if u_word.length > x then next end
        passable_words = Set.new
        count = u_word.length
        passable_words = word_looper(0, u_word, word, passable_words)
        remove_badly_formed(passable_words, count)
        #passable_words.each { |w| puts w}
        #Debugging line to see crypto's progress.
        condense_true(u_word, passable_words)
        }
      end
    end
  end

  def word_looper(counter, u_word, word, list)
    if counter == u_word.length
      append_true(word, list)
      #puts word
      return
    end
    sub_z = @let_list[u_word[counter]]
    counter += 1
    sub_z.possible.each { |z|
          if word.include?(z.to_s) && z.to_s != "'" then next end
          # ^^ used to shorten possibilities quicker, but causes errors.
          z_word = word.gsub(/#{sub_z.name}/, z.to_s)
          word_looper(counter, u_word, z_word, list)
          }
    return list
  end

  def kill_two(list)
    check = %w( A I )
    list.each { |l|
      if l.possible != check
        l.possible.delete(check)
      end
    }

  end

  def count_known_letters(letters)
    #simple count of letters that have only one left in possible
    #therefore we KNOW that must be the key. Used to determine confidence level in puzzle
    count = 0
    letters.each { |l|
      if l.possible.length == 1 then count += 1 end
    }
    return count
  end

  def remove_badly_formed(words, count)
    #takes out words created from an overlap of letters
    #where pet and pep are both real words... they have a different unique count
    #the unique count is important for letter substitution
    words.delete_if { |w|
      unique_ify(w).length != count
    }

  end

  def condense_true(key, words)
    #For creating an array for each unique letter containing one of each possibility
    #the possible letters will shrink each time a word is tested. Till all contain just one
    #possiblity... or hilarity will ensue in having a cryptogram with an alternate possibility
    words.map! { |w| unique_ify(w) }

    for position in 0...key.length
      letter = @let_list[key[position]]
      if letter.possible.frozen? then next end
      letter.possible.clear
      words.each { |word|
        if letter.possible.include?(word[position]) then next end
        letter.possible << word[position]
      }


    end


  end

  def append_true(word, list)
    #Simply adds the word to the passed list when it is verified by the dictionary.
    if poss(word)
      list << word
    end
  end

  def kill_singles()
    singulars = Set.new

    @let_list.each { |x, l|
      if l.possible.length == 1 then singulars << l end
    }

    singulars.each { |p|
     @let_list.each { |x, l|
       if l.possible.length == 1 then next end
       l.possible.delete(p.possible)
     }
    }
  end

  def set_letters()
    #Creates an alphabetical list of LETTER objects
    @let_list = Hash.new
      for l in "a".."z"
        @let_list.merge!({l => Letter.new(l)})
      end
    @let_list.merge!({'\'' => Letter.new('\'')})
    @let_list.merge!({'-' => Letter.new('-')})
  end

  def poss(word)
    if @dicts[word.length].key?(word) then return true end
    return false
  end
end

class Puzzle
  attr_accessor :crypto, :crypto_broken, :solution, :author_sol, :author, :publ_date, :solve_time,
    :uniques, :full_uniques
  def initialize(crypto='ABCDEF', author="Bace Troncons", publ_date=Time.now)
    @crypto = crypto          #The seperated cryptogram from the author section
    @author = author          #The seperated author section for the crpytogram
    @publ_date = publ_date    #The seperated date value
    @solve_time = nil         #Var for the date/time the solution was first made
    @uniques = unique_ify(@crypto)
    @full_uniques = unique_ify((@crypto + @author))
    set_up_puzzle()
  end

  def set_solve_date
    if @solve_time
      return
    end
    @solve_time = Time.now
  end

  def set_up_puzzle()
    #Breaks PUZZ into the crypto array sorted by word size
    @crypto_broken = Set.new
    @crypto_broken = @crypto.split
    hyphens = Array.new
    @crypto_broken.each { |w|
       if w.include? '-' then hyphens += w.split(/-/) end
     }
    @crypto_broken.delete_if { |w|
      w.include? '-'
    }
    @crypto_broken += hyphens
    @crypto_broken = @crypto_broken.each.sort { |a,b|  #Sorts words by size
    unique_ify(a).length <=> unique_ify(b).length
  }
  end

  def to_s
    print 'Code: ', @crypto,  "\nDate: ", @publ_date, "\nCompleted: ", @solve_time, "\n"
  end
end

class Letter
  #Letter objects that contain their own NAME, and a list of POSSIBLE interpretations
  #It is assumed that by the rules of the cryptogram that they cannot end up being themself
  attr_accessor :name, :not_possible, :possible

  def initialize(itself)
    #Sets the possible list, and the self.name
    #lowercase letters are the unchanged letters, upcase is solved letters
    if itself == "'" || itself == '-'
      @name = itself
      @possible = Set[itself]
      @possible.freeze
    else
    @name = itself.downcase
    @not_possible = [itself.upcase]
    @possible = Set.new
    @possible = %w[ E T A O I N S H R D L C U M W F G Y P B V K J X Q Z ]
    @possible.delete(itself.upcase)
    end
  end

end
