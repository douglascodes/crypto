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
    dicts = Array.new(20) {|i| Array.new}
    words = IO.readlines('.\bin\english.0')
    dicts[1] = ['A', 'I']
    words.each { |w|
      if w.include? "'" then next end
      w.chomp!
      w.upcase!
      dicts[w.length] ||= Set.new
      dicts[w.length] << w
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
    a.delete!(".,!?':;&()")
    a.strip!
    b.delete!(".,!?':;&()")
    b.strip!
    return a, b
  end

  def go_to_work()
      p = @p_list.first
      solve(p)
      print_solution(p)

   end

  def print_solution(puzz)
    @let_list.each { |l|
      if puzz.crypto.include? l.possible[0]
        puzz.crypto.gsub!(/#{l.name}/, l.possible[1].to_s)
      else
        puzz.crypto.gsub!(/#{l.name}/, l.possible[0].to_s)
      end
    }
    puts puzz.crypto
  end

  def solve(puzz)
    c = puzz.crypto_broken
    set_letters()
    for z in 1..3
      for x in 1..c[-1].length
      c.each { |w|
        word = w
        if word.length > x then next end
        passable_words = Set.new
        u_word = unique_ify(word)
        count = u_word.length
        passable_words = word_looper(0, u_word, word, passable_words)
        remove_badly_formed(passable_words, count)
        passable_words.each { |w| puts w}
        condense_true(u_word, passable_words)
        }
      end
    end
  end

  def word_looper(counter, u_word, word, list)
    if counter == u_word.length
      append_true(word, list)
      return
    end
    sub_z = get_lett_obj(u_word[counter])
    alphabet = sub_z.possible
    counter += 1
    alphabet.each { |z|
          z_word = word.gsub(/#{sub_z.name}/, z.to_s)
          word_looper(counter, u_word, z_word, list)
          }
    return list
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
      letter = get_lett_obj(key[position])
      letter.possible.clear
      words.each { |word|
        if letter.possible.include?(word[position]) then next end
        letter.possible << word[position]
      }
    kill_known_letters_from_other_possibles()
    end

  end

  def append_true(word, list)
    #Simply adds the word to the passed list when it is verified by the dictionary.
    if poss(word)
      list << word
    end
  end

  def get_lett_obj(letter)
    #Returns the letter object that matches the passed string. Returns false otherwise
    @let_list.each { |o|
      if o.name != letter then next end
      return o
    }
    return false
  end

  def kill_known_letters_from_other_possibles()
    singulars = Set.new

    @let_list.each { |l|
      if l.possible == 1 then singulars << l end
    }

    singulars.each { |p|
     @let_list.each { |l|
       if l.possible == 1 then next end
       l.possible.delete(p.possible)
     }
    }

  end

  def set_letters()
    #Creates an alphabetical list of LETTER objects
    @let_list = Set.new
      for l in "a".."z"
        @let_list << Letter.new(l)
      end
  end

  def poss(word)
    #Checks each succesively large dictionary for presence of the passed string
    if @dicts[word.length].include?(word) then return true end
    return false
#    if @pop_w.include? word then return true end
#    if word.length < 5
#      if @short_dict.include? word then return true end
#    else
#      if @dict.include? word then return true end
#    end
#    return false
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
    if @solve_date
      return
    end
    @solve_time = Time.now
  end

  def set_up_puzzle()
    #Breaks PUZZ into the crypto array sorted by word size
    @crypto_broken = Set.new
    @crypto_broken = @crypto.split
    @crypto_broken = @crypto_broken.each.sort { |a,b|  #Sorts words by size
    a.length <=> b.length
  }
  end

  def to_s
    print 'Code: ', @crypto,  "\nAuthor: ", @author, "\nDate: ", @publ_date, "\nCompleted: ", @solve_time, "\n"
  end
end

class Letter
  #Letter objects that contain their own NAME, and a list of POSSIBLE interpretations
  #It is assumed that by the rules of the cryptogram that they cannot end up being themself
  attr_accessor :name, :not_possible, :possible

  def initialize(itself)
    #Sets the possible list, and the self.name
    #lowercase letters are the unchanged letters, upcase is solved letters
    @name = itself.downcase
    @not_possible = [itself.upcase]
    @possible = Set.new
    @possible = %w[ E T A O I N S H R D L C U M W F G Y P B V K J X Q Z ]
    @possible.delete(itself.upcase)
  end

end
