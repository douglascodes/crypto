require 'crypto'
require 'spec_helper'

class TestSolver
 
  describe Solver do

    before do
      @test_solver = Solver.new
      @test_feed = Document.new(@test_solver.get_feed('http://threadbender.com/rss.xml'))
      @test_root = @test_feed.root
    end

    it "should take a string" do
      @test_feed.should be_true
    end
    
    it "should exist" do
      @test_solver.should be_true
    end

    it "should default to http://www.threadbender.com/rss.xml" do
      @test_feed = Document.new(@test_solver.get_feed())
      @test_feed.should be_true
    end

    it "should read the XML stream items" do
      @test_root.each_element('//item') { |item|
        desc = item.delete_element('description').to_s
      }
    end
   
    it "should break up the Puzzles" do
      x = @test_solver.p_list.length
      y = @test_solver.conform_puzzles(@test_root)
      y = y.length
      x.should < y
    end
  
    it "should create A list of puzzle objects" do
      @test_solver.conform_puzzles(@test_root)
      @test_solver.p_list[1].should be_an_instance_of(Puzzle)
    end

    
    it "should create puzzle objects with Crypto/Author/Date attribs" do
      @test_solver.conform_puzzles(@test_root)
      @test_solver.p_list[2].publ_date.should be_true
      @test_solver.p_list[3].author.should be_true
      @test_solver.p_list[1].crypto.should be_true
    end
    
    it "should split the string at the '. -' point" do
      a, b = @test_solver.seperate_author("UWDC W FXWYFC! WII IREC RA W FXWYFC. UXC QWY LXB MBCA EVZUXCAU RA MCYCZWIIH UXC BYC LXB RA LRIIRYM UB TB WYT TWZC. - TWIC FWZYCMRC")
      a.should eq("UWDC W FXWYFC WII IREC RA W FXWYFC UXC QWY LXB MBCA EVZUXCAU RA MCYCZWIIH UXC BYC LXB RA LRIIRYM UB TB WYT TWZC".downcase)
      b.should eq("TWIC FWZYCMRC".downcase)
      #also converts to downcase for puzzle... UPCASE reserved for solved letters
    end

    it "should initialize with a 1000 word array" do
      @test_solver.pop_w.length.should eq(1000)
    end
    
    it "should initialize with a list of letters sorted by popularity" do
      @test_solver.pop_l[0].should eq('E')
      @test_solver.pop_l[6].should eq('S')
      @test_solver.pop_l[-1].should eq('Z')
    end
    
    it "should have two dictionaries (small, regular)" do
      @test_solver.dict.should be_true
      @test_solver.short_dict.should be_true
      @test_solver.dict.empty?.should == false
      @test_solver.short_dict.empty?.should == false
    end
    
    it "should correctly test if words are present" do
      @test_solver.dict.should include('BUG')
      @test_solver.short_dict.should include('BUG')
      @test_solver.dict.should include('UNITED')
      @test_solver.short_dict.should_not include('UNITED')
       
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
  
  end
end

class TestLetter
end