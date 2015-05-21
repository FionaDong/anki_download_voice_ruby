require 'nokogiri'
require 'open-uri'
# require 'pry'
require_relative 'phrase'
#./collection.media


class YouDaoResource
  attr_accessor :html_doc

  def initialize(card)
    @card = card
    # @html_doc = nil
  end
  
  def open_url
    begin
      @html_doc = Nokogiri::HTML(open(URI.encode("http://dict.youdao.com/search?q=#{@card.face}")))
    rescue
      raise "OpenURL - Cannot find this word. #{__FILE__}: line #{__LINE__}"
    end        
  end
 
  def clear
    @html_doc = nil      
  end

  def download_resource(to_folder)
    download_phonetic_symbol if @card.phonetic_symbol.nil_or_empty?

    return if File.exist?("#{to_folder}#{@card.raw_face}&type=1.mp3")

    write_to_file("#{@card.raw_face}&type=1", to_folder)
    write_to_file("#{@card.raw_face}&type=2", to_folder)

    parse_and_download_mannually if !File.exist?("#{to_folder}#{@card.raw_face}&type=1.mp3")

  end

  def parse_and_download_mannually
    open_url if !@html_doc
    download_audio(parse_audio_eng, to_folder)
    download_audio(parse_audio_usa, to_folder)
  end


  def download_phonetic_symbol
    open_url if !@html_doc
    if @card.is_special_face?
      @card.phonetic_symbol = ""
    else
      @card.phonetic_symbol = parse_phonetic_eng + parse_phonetic_usa
      @card.set_update_to_database_status if @card.phonetic_symbol != ""
    end
  end

  def download_audio(audio_value, to_folder)
    if not has_audio_usa? and audio_value == ""
      return
    else
      write_to_file(audio_value, to_folder)
    end  
  end
  
  def write_to_file(audio_value, to_folder)
    open_url if !@html_doc
    audio_link =  URI.encode("http://dict.youdao.com/dictvoice?audio=#{audio_value}")
    retry_count = 0
    begin
      open(audio_link,'rb') do |mp3|
        File.open("#{to_folder}#{audio_value}.mp3",'wb') do |file|
          file.write(mp3.read)
        end
      end
    rescue => e
      retry_count += 1
      if retry_count < 3
        retry
      else
        raise e + " #{__FILE__}: line #{__LINE__}"
      end
    end
  end

  def parse_phonetic_eng
    begin
      phonetic_eng = @html_doc.at_css(".pronounce:nth-child(1)").text.sub(/\s+/,"").strip!
    rescue => e
      return ""
    end
  end

  def parse_phonetic_usa
    phonetic_usa = @html_doc.at_css(".pronounce+ .pronounce").text.sub(/\s+/,"").strip! if has_phonetic_usa? 
    if phonetic_usa
      phonetic_usa
    else
      ""
    end
  end

  def parse_audio_eng
    begin
      @html_doc.at_css(".pronounce:nth-child(1) .log-js").attributes["data-rel"].value.replace_separator(" ")
    rescue => e
      @html_doc.at_css("#phrsListTab .log-js").attributes["data-rel"].value.replace_separator(" ")
    end
  end

  def parse_audio_usa
    if has_audio_usa?
      @html_doc.at_css(".pronounce+ .pronounce .log-js").attributes["data-rel"].value.replace_separator(" ")
    else
      ""
    end    
  end

  def has_phonetic_usa?
    @html_doc.at_css(".pronounce+ .pronounce")
  end

  def has_audio_usa?
    @html_doc.at_css(".pronounce+ .pronounce .log-js") 
  end

end
