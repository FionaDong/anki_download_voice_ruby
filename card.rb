# require 'pry'

class Card
  attr_accessor :face, :phonetic_symbol, :back, :raw_note, :raw_face, :to_update

  def initialize(note_string = "")
    @raw_note = note_string
  end

  def refresh(note_string)
    @raw_note = note_string
    @raw_face = ""
    @face = ""
    @phonetic_symbol = ""
    @back = ""
    @to_update = nil
  end

  def split
    feilds = []
    fields = @raw_note.split("\u001F")
    set_card(fields[0], "", fields[1], fields[2], nil)  
    clean_face
  end

  def clean_face
    begin
      word = @raw_face
      word.strip!
      word.sub!(/&nbsp;/,"")
      words = word.split(" ")
      new_word = words.inject("") do |w, word|
        w + "#{word.strip}+"
      end
      @face = new_word.chomp!("+")
    rescue => e
      raise e + " #{__FILE__}: line #{__LINE__}"
    end
  end  

  def update_to_db(db)
    if @to_update
      note = [raw_face, phonetic_symbol, back].join("\u001F")
      db.run_update_note(note, raw_face)
    end
  end
  # def get_card
  #   {face: "#{@face}", phonetic_symbol: "#{@phonetic_symbol}", back: "#{@back}"}
  # end

  def set_card(raw_face, face, phonetic_symbol, back, to_update)
    @raw_face, @face, @phonetic_symbol, @back, @to_update = raw_face, face, phonetic_symbol, back, to_update
  end

  def set_update_to_database_status
    @to_update = true
  end

  def is_special_face?
    @face =~ /\+|\-/
  end

end
