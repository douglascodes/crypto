require 'crypto'
require 'spec_helper'

class TestSolver

  describe Solver do

    before do
      @ts = Solver.new
      @test_feed = Document.new(@ts.get_feed('http://threadbender.com/rss.xml'))
      @test_root = @test_feed.root
      @ts.p_list.clear
    end

    it "should take a string" do
      @test_feed.should be_true
    end

    it "should exist" do
      @ts.should be_true
    end

    it "should read the XML stream items" do
      @test_root.each_element('//item') { |item|
        desc = item.delete_element('description').to_s
      }
    end

    it "should break up the Puzzles" do
      x = @ts.p_list.length
      @ts.p_list = @ts.conform_puzzles(@test_root)
      y = @ts.p_list.length
      x.should < y
    end

    it "should create A list of puzzle objects" do
      @ts.p_list = @ts.conform_puzzles(@test_root)
      @ts.p_list[0].should be_an_instance_of(Puzzle)
    end


    it "should create puzzle objects with Crypto/Author/Date attribs" do
      @ts.p_list = @ts.conform_puzzles(@test_root)
      @ts.p_list[0].publ_date.should be_true
      @ts.p_list[0].author.should be_true
      @ts.p_list[0].crypto.should be_true
    end

    it "should split the string at the /[?.!] -/ point" do
      a, b = @ts.seperate_author("UWDC W FXWYFC! WII IREC RA W FXWYFC. UXC QWY LXB MBCA EVZUXCAU RA MCYCZWIIH UXC BYC LXB RA LRIIRYM UB TB WYT TWZC. - TWIC FWZYCMRC")
      a.should eq("UWDC W FXWYFC WII IREC RA W FXWYFC UXC QWY LXB MBCA EVZUXCAU RA MCYCZWIIH UXC BYC LXB RA LRIIRYM UB TB WYT TWZC".downcase)
      b.should eq("TWIC FWZYCMRC".downcase)
      #also converts to downcase for puzzle... UPCASE reserved for solved letters
    end

    it "should correctly test if words are present" do
      @ts.poss('BUG').should be_true
      @ts.poss('UNITED').should be_true
      @ts.poss('AXE').should be_true
      @ts.poss('RPPTEAT').should_not be_true
      @ts.poss('REPEAT').should be_true
      @ts.poss('WRITABLE').should be_true
      @ts.poss('WRITTENWRE').should_not be_true
    end

    it "should start a puzzle by splitting and sorting words" do
      @ts.p_list = @ts.get_puzzles()
      puzz = @ts.p_list[1]
      puzz.crypto_broken.length.should be > 0
      puzz.crypto_broken[0].length.should < puzz.crypto_broken[-1].length
      puzz.crypto_broken[1].length.should < puzz.crypto_broken[-2].length
      puzz.crypto_broken[2].length.should <= puzz.crypto_broken[3].length
      puzz.crypto_broken[3].length.should <= puzz.crypto_broken[4].length
    end

    it "should find a letter object based on its name" do
      @ts.set_letters()
      letter = @ts.get_lett_obj('r')
      letter.name.should eq('r')
      letter.possible.include?('r').should_not be_true
    end

    it "should append successful words to a given list" do
    p_words = %w( A B C D E F IN BED NECK I TURF SPELLING )
    true_words = []
    p_words.each { |w|
        @ts.append_true(w.upcase, true_words)
      }
    true_words.length.should eq(7)

    true_words = []
    @ts.set_letters()
    @ts.let_list.each { |w|
          @ts.append_true(w.name.upcase, true_words)
        }
    true_words.length.should eq(2)
    end

    it "should remove words created from overlap" do
      p_words = %w( BAT TAB CAT STAB COUNT PEP PET )
      @ts.remove_badly_formed(p_words, 3)
      p_words.length.should eq(4)
    end

    it "should condense and update the possible letters of each encrypted letter" do
      @ts.set_letters()
      p_words = %w( BAT TAB CAT PET CAB )
      key = "xyz"
      @ts.condense_true(key, p_words)
      first_letter = @ts.get_lett_obj('x')
      second_letter = @ts.get_lett_obj('y')
      third_letter = @ts.get_lett_obj('z')
      true_1st = %w( B T C P )
      true_2nd = %w( A E )
      true_3rd = %w( T B )
      first_letter.possible.should eq(true_1st)
      second_letter.possible.should eq(true_2nd)
      third_letter.possible.should eq(true_3rd)
      second_letter.possible.should_not eq(true_3rd)
    end

    it "should loop over each letter in a word creating possible permutations" do
      @ts.set_letters()
      list = []
      word = "xz"
      u_word = unique_ify(word)
      count = u_word.length
      @ts.word_looper(0, u_word, word, list)
      list.length.should eq(48)

      list = []
      word = "xzq"
      u_word = unique_ify(word)
      count = u_word.length
      @ts.word_looper(0, u_word, word, list)
      list.length.should eq(480)

      # list = []
      # word = "xjzq"
      # u_word = unique_ify(word)
      # count = u_word.length
      # @ts.word_looper(0, u_word, word, list)
      # list.length.should eq(1764)

    end

  end
end

class TestPuzzle

  describe Puzzle do

    it "should intiate with Crypto/Author/Date" do
      p = Puzzle.new("H TJAHJBJ IOFI VWFMUJK IMVIO FWK VWXLWKHIHLWFA ALBJ SHAA OFBJ IOJ DHWFA SLMK HW MJFAHIN. IOFI HP SON MHZOI, IJUYLMFMHAN KJDJFIJK, HP PIMLWZJM IOFW JBHA IMHVUYOFWI",
      "UFMIHW AVIOJM GHWZ CM",
      Date.parse("Thu, 27 Sep 2012 23:45:00 -0400"))
      p.should be_true
      p.publ_date.should be_true
      p.crypto.should be_true
      p.author.should be_true
    end

    it "should have a list of unique letters" do
      p = Puzzle.new("ABCDDDDDD",
        "DDDEEEEEF",
        Date.parse("Thu, 27 Sep 2012 23:45:00 -0400"))
      p.uniques.should be_true
      p.uniques.should be == "ABCD"
      p.uniques.length.should eq(4)
      p.full_uniques.length.should eq(6)
    end



  end
end

class TestLetter
  describe Letter do
    before do
      @let_list = []
      for l in 'a'..'z'
        @let_list << Letter.new(l)
      end
    end

    it "should not have itself in possible list" do
        for x in @let_list
          x.possible.include?(x.name).should_not be_true
        end
    end

  end
end