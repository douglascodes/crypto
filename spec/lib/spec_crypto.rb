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

    it "should default to http://www.threadbender.com/rss.xml" do
      @test_feed.should be_true
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

    it "should initialize with a 1000 word array" do
      @ts.pop_w.length.should eq(1000)
    end
    
    it "should have two dictionaries (small, regular)" do
      @ts.dict.should be_true
      @ts.short_dict.should be_true
      @ts.dict.empty?.should == false
      @ts.short_dict.empty?.should == false
      @ts.short_dict.length.should < @ts.dict.length
    end
    
    it "should correctly test if words are present" do
      @ts.dict.should include('BUG')
      @ts.short_dict.should include('BUG')
      @ts.dict.should include('UNITED')
      @ts.short_dict.should_not include('UNITED')
      @ts.poss('AXE').should be_true
      @ts.poss('RPPTEAT').should_not be_true
      @ts.poss('REPEAT').should be_true
      @ts.poss('WRITABLE').should be_true
      @ts.poss('WRITTENWRE').should_not be_true                                           
    end
    
    it "should start a puzzle by splitting and sorting words" do
      @ts.p_list = @ts.get_puzzles()
      @ts.set_up_puzzle(@ts.p_list[1])
      @ts.crypto.length.should be > 0 
      @ts.crypto[0].length.should < @ts.crypto[-1].length
      @ts.crypto[1].length.should < @ts.crypto[-2].length
      @ts.crypto[2].length.should <= @ts.crypto[3].length 
      @ts.crypto[3].length.should <= @ts.crypto[4].length
      @ts.let_list.length.should eq(26)
       
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