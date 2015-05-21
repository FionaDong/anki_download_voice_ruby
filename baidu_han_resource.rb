require 'nokogiri'
require 'open-uri'
require_relative 'phrase'
require 'pry'

class BaiduHanResource

  def initialize(card)
    @card = card
  end

  def open_url
    begin
      @html_doc = Nokogiri::HTML(open(URI.encode("http://dict.baidu.com/s?wd=#{@card.face}")))
    rescue
      raise "OpenURL - Cannot find this word."
    end
  end

  def clear
    @html_doc = nil
  end

  def download_resource(to_folder)
    download_phonetic_symbol if @card.phonetic_symbol.nil_or_empty?
    download_back if @card.back.nil_or_empty?
# binding.pry
    return if File.exist?("#{to_folder}#{@card.raw_face}.mp3")
    write_to_file(parse_audio_value, to_folder) if !parse_audio_value.nil_or_empty?
  end

  def download_back
    open_url if !@html_doc
    @card.back =  basic_mean + "\n" + detail_mean + "\n" + baike_mean
    @card.set_update_to_database_status if !@card.back.nil_or_empty?
  end

  def download_phonetic_symbol
    open_url if !@html_doc
    @card.phonetic_symbol = phonetic_symbol
    @card.set_update_to_database_status if !@card.phonetic_symbol.nil_or_empty?
  end

  def phonetic_symbol
    begin
      @html_doc.at_css("#pronounce b").text
    rescue
      return ""
    end
  end
  
  def basic_mean
    begin
      @html_doc.at_css("#cn-basicmean").text
    rescue
      puts "#{@card.raw_face} can not find basic mean."
      return ""
    end
  end
  
  def detail_mean
    begin
      @html_doc.at_css("#cn-detailmean").text
    rescue
      puts "#{@card.raw_face} can not find detail mean."
      return ""
    end
  end  

  def baike_mean
    begin
      @html_doc.at_css("#cn-baike-mean").text
    rescue
      puts "#{@card.raw_face} can not find baike mean."
      return ""
    end
  end  
  def parse_audio_value
    open_url if !@html_doc
    begin
      @html_doc.at_css("#pronounce a").attributes["url"].value.sub("http://bs.baidu.com/handian/","").sub(".mp3","")
    rescue
      puts "#{@card.raw_face} can not find audio file."
      return ""
    end 
  end

  def write_to_file(audio_value, to_folder)
    audio_link =  URI.encode("http://bs.baidu.com/handian/#{audio_value}.mp3")
    retry_count = 0
    begin
      open(audio_link,'rb') do |mp3|
        File.open("#{to_folder}#{@card.raw_face}.mp3",'wb') do |file|
          file.write(mp3.read)
        end
      end
    rescue => e
      retry_count += 1
      if retry_count < 3
        retry
      else
        raise e
      end
    end
  end      
end