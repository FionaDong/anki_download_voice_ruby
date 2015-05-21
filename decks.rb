# require 'pry'

class Decks
  attr_accessor :decks_list, :decks_file_name
  # @@decks_array = ["fiona_dong", "greek_mythology", "literature", "ruby", "ted_documentary", "wikipedia"]

  def initialize(file_name)
    @decks_file_name = file_name
    @decks_list = get_decks_list_from_file
  end

  def get_decks_list_from_file
    list = {}
    deck_name = ""
    deck_id = ""

    if File.exist?(@decks_file_name)
      File.open(@decks_file_name,'r').each_line do |line|
        deck_name = line.split(":")[0]
        deck_id = line.split(":")[1].chomp
        list[deck_name.to_sym] = deck_id
      end
    else
      raise StandardError, "FileNotFound: Cannot find deck list file!"
    end
    return list
  end

  def add_deck(deck_name, deck_id)
    @decks_list[deck_name.to_sym] = deck_id.to_s
    add_to_file("#{deck_name}:#{deck_id}")
  end

  def delete_deck(deck_name)
    @decks_list.delete(deck_name.to_sym)
    delete_from_file(deck_name)
  end

  # def check_decks
  #   @@decks_array.each do |deck_name|
  #     return false if not @decks_list.keys.include?(deck_name.to_sym)
  #   end
  #   @decks_list.each_key do |deck_name|
  #     return false if not @@decks_array.include?(deck_name.to_s)
  #   end
  # end

  def add_to_file(new_item)
    File.open(@decks_file_name,'a') do |f|
      f.puts new_item + "\r\n"
    end
  end

  def delete_from_file(deck_name)
    dir = File.dirname(@decks_file_name)
    begin
      f = File.open(dir + "/temp",'w')
      File.open(@decks_file_name,'r').each_line do |line|
        f.write(line) if not line.include?(deck_name)
      end
    ensure
      f.close
    end
    File.rename( dir + "/temp", dir + "/decks_id_list")
  end
end