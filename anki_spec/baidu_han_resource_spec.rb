require './spec_helper.rb'
require 'pry'

describe BaiduHanResource do 
  before :each do
    @card = Card.new "弢\u001F\u001Ftao1<div>弢，读音tāo，原指装弓或剑使用的套子、袋子，可话用为动词，通“韬”，隐藏的意思，如韬光养晦。"
    @resource = BaiduHanResource.new @card
    @card.split
    @mp3_file = "/Users/Fiona/anki_ruby/collection.media/弢.mp3"
  end  

  describe "#open_url" do
    it "should open a page with no error." do
      html = @resource.open_url
      expect{ html.at_css("title") }.to_not raise_exception 
    end
    it "should get a title from the page passed in." do
      html = @resource.open_url
      expect(html.at_css("title").text).to be == "百度词典搜索_弢"
    end
  end
  
  describe "#download_phonetic_symbol" do
    it "should parse pinyin symbol from webpage." do
      @resource.download_phonetic_symbol
      expect(@card.phonetic_symbol).to be == "[tāo]"
    end
  end
  describe "#download_back" do
    it "should parse meaning of this character from webpage." do
      @card.refresh("弢\u001F\u001F")
      @card.split
      binding.pry
      @resource.download_back
      expect(@card.back).to_not be nil
    end
  end  
  describe "#parse_audio_value" do
    it "should get audio link from the webpage." do
      @resource.open_url
      expect(@resource.parse_audio_value).to be == "tao1"
    end

  end

  describe "#write_to_file" do
    it "should download mp3 files when no file already in folder." do
      File.delete(@mp3_file) if File.exist?(@mp3_file)
      @resource.open_url
      @resource.write_to_file(@resource.parse_audio_value, %Q[/Users/Fiona/anki_ruby/collection.media/])
      expect(File.exist?(@mp3_file)).to be == true
    end
  end


end