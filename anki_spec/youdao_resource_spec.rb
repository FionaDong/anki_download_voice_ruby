require './spec_helper'
require 'pry'
describe YouDaoResource do
  before :each do
    @card = Card.new("sorbet")
    @card.raw_face = "sorbet"
    @card.face = "sorbet"
    @resource = YouDaoResource.new(@card)
    # binding.pry
    @resource.open_url("http://dict.youdao.com/search?q=#{@card.face}")
  end
  before :all do
    # binding.pry
    doc = Nokogiri::HTML(open("http://dict.youdao.com/search?q=sorbet"))
    # binding.pry
    if doc.at_css("title").text == "有道反馈"
      puts "NetWork Error, change the VPN." 
      exit
    end
  end

  describe "#new" do
    it "creates a new resource object." do
      resource = YouDaoResource.new(@card)
      expect(resource).to be_an_instance_of YouDaoResource
    end
  end

  describe "#open_url" do
    it "returns an object of Nokogiri::HTML::Document." do
      expect(@resource.open_url("http://dict.youdao.com/search?q=#{@card.face}")).to be_an_instance_of Nokogiri::HTML::Document 
    end
  end

  describe "#parse_audio_eng" do
    it "parses English audio resource name." do
      # binding.pry
      expect(@resource.parse_audio_eng).to eq "sorbet&type=1"
      # expect(File.exist?(@resource.to_folder + audio_eng + ".mp3")).to eq true
    end
    it "should parse phrase separated by whitespace if the card face is a phrase with multiple words in it." do
      card = Card.new "walk out on&nbsp;\u001F英[]美[]\u001FMy wife just walk out on me."
      card.split
      resource = YouDaoResource.new(card)
      resource.open_url("http://dict.youdao.com/search?q=#{card.face}")
      expect(resource.parse_audio_eng).to be == "walk out on"
    end
  end
  describe "#parse_audio_usa" do
    it "parses American audio resource name." do
      expect(@resource.parse_audio_usa).to eq "sorbet&type=2"
    end
  end

  describe "#download_audio"  do
    it "downloads usa mp3 from internet and save to local." do
      @resource.download_audio("#{@card.raw_face}&type=2", "/Users/Fiona/anki_ruby/collection.media/")
      # expect(File.exist?("/Users/Fiona/anki_ruby/collection.media/" + @resource.parse_audio_usa + ".mp3")).to eq true
      expect(File.exist?("/Users/Fiona/anki_ruby/collection.media/#{@card.face}&type=2.mp3")).to eq true
    end

    it "downloads eng mp3 from internet and save to local." do
      @resource.download_audio("#{@card.raw_face}&type=1", "/Users/Fiona/anki_ruby/collection.media/")
      expect(File.exist?("/Users/Fiona/anki_ruby/collection.media/#{@card.face}&type=1.mp3")).to eq true
    end    
  end

  describe "#download_phonetic_symbol" do 
    it "should update phonetic_symbol in card object." do
      # binding.pry
      @card.phonetic_symbol = ""
      @resource.download_phonetic_symbol
      # binding.pry
      expect(@card.phonetic_symbol).to be == "英['sɔːbeɪ; -bɪt]美['sɔbɛi]"
    end

    it "should update phonetic_symbol in card object." do
      # binding.pry
      @card.phonetic_symbol = ""
      @resource.download_phonetic_symbol
      # binding.pry
      expect(@card.to_update).to be == true
    end

    it "should skip this step if card has already had phonetic symbol in Database." do
      @card.phonetic_symbol = "123"
      @resource.download_phonetic_symbol
      expect(@card.phonetic_symbol).to be == "123"
    end
  end
  describe "#download_resource" do
    it "should download phonetic symbol if there is no symbol in the card." do
      @card.phonetic_symbol = ""
      @resource.download_resource("/Users/Fiona/anki_ruby/collection.media/")
      expect(@card.phonetic_symbol).to_not eq ""
    end

    it "should skip to next word if there is already file found in media folder." do
      @resource.html_doc = nil
      File.new("/Users/Fiona/anki_ruby/collection.media/#{@card.face}&type=1.mp3", 'w')
      @resource.download_resource("/Users/Fiona/anki_ruby/collection.media/")  
      expect(@resource.html_doc).to be == nil
    end    
    it "should download mp3 file if there is no file found in media folder." do
      File.delete("/Users/Fiona/anki_ruby/collection.media/#{@card.face}&type=1.mp3")
      @resource.download_resource("/Users/Fiona/anki_ruby/collection.media/")
      expect(File.exist?("/Users/Fiona/anki_ruby/collection.media/#{@card.face}&type=1.mp3")).to be == true
    end
    it "should download for composite word." do
      card = Card.new("off-the-shelf\u001F\001F<div>We've all used the off-the-shelf framework and libraries.</div>现成的，不用定制的<div><br /></div>")
      resource = YouDaoResource.new card
      card.split
      resource.download_resource("/Users/Fiona/anki_ruby/collection.media/")
    end
  end
end