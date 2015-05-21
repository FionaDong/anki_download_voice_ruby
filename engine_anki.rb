require_relative 'card'
require_relative 'youdao_resource'
require_relative 'baidu_han_resource'
require_relative 'log'
require_relative 'db'
require_relative 'decks'
require 'pry'

begin
  log = Log.new $stdout, "/Users/Fiona/anki_fiona/log"
  #development env
  # db = DB.new '/Users/Fiona/anki_ruby/collection.anki2'
  #production env
  to_folder = %Q[/Users/Fiona/Documents/Anki/User 1/collection.media/]
  deck_file = %Q[/Users/Fiona/anki_fiona/decks_id_list]
  db = DB.new '/Users/Fiona/Documents/Anki/User 1/collection.anki2' 

  decks = Decks.new(deck_file)
  card = Card.new
  resource_yd = YouDaoResource.new(card)
  resource_bd = BaiduHanResource.new(card)
  record_count = 0 

  log.puts "------Batch starts at #{Time.now.year}/#{Time.now.month}/#{Time.now.day} #{Time.now.hour}:#{Time.now.min}:#{Time.now.sec}------"
  db.connect
  log.puts "DB connected."

  decks.decks_list.each_pair do |deck_name, deck_id|
    rs_notes = db.run_select_notes(deck_id) 
    # rs_notes = db.run_select_note()
    rs_notes.each do |rs_raw|
      resource_bd.clear
      resource_yd.clear
      begin
        record_count += 1
        card.refresh(rs_raw[0])
        card.split
        # binding.pry if card.face == 'wearily'
        if deck_name.to_s == "汉"
          resource_bd.download_resource(to_folder)
        else
          resource_yd.download_resource(to_folder)
        end
        card.update_to_db(db)
      rescue => e
        log.puts "****#{card.face} download error.****\n"
        log.puts e
        next
      end
    end
  end
    log.puts "------All decks #{record_count} cards were updated done. Please check Database. #{Time.now.year}/#{Time.now.month}/#{Time.now.day} #{Time.now.hour}:#{Time.now.min}:#{Time.now.sec}------"
ensure
  db.close
end
