require './spec_helper'

describe Card do
  
  before :each do
    @card = Card.new "walk out on&nbsp;\u001F英[]美[]\u001FMy wife just walk out on me."
  end

  describe "#new" do
    it "creates a new card object by passing raw_note with 3 fields." do
      card = Card.new "walk out on&nbsp;\u001F英[]美[]\u001FMy wife just walk out on me."
      expect(card).to be_an_instance_of Card
    end
    it "creates a new card object by passing raw_note with 1 fields." do
      card = Card.new "walk out on&nbsp;"
      expect(card).to be_an_instance_of Card
    end    
  end

  describe "#set_card" do
    it "returns the card with new features." do
      @card.set_card("reconstitute", "", "英 [ˌri:'kɒnstɪtju:t] 美 [riˈkɑnstɪˌtut, -ˌtjut]", "再构成", nil)
      expect(@card).to be_an_instance_of Card
      expect(@card.raw_face).to eq "reconstitute"
      expect(@card.face).to eq ""
      expect(@card.phonetic_symbol).to eq "英 [ˌri:'kɒnstɪtju:t] 美 [riˈkɑnstɪˌtut, -ˌtjut]"
      expect(@card.back).to eq "再构成"
      expect(@card.to_update).to eq nil
    end
  end

  describe "#is_special_face?" do
    it "doesn't has a specail face." do
      expect(@card.is_special_face?).to_not eq true
    end
    it "does has a specail face." do
      @card.face = "walk+out+on"
      expect(@card.is_special_face?).to_not eq false
    end    
  end

  describe "#clean_face" do
    it "returns a legal word after clearness." do
      @card.raw_face = "walk out on&nbsp;"
      @card.clean_face
      expect(@card.face).to eq "walk+out+on"
    end
  end

  describe "#split" do
    it "has face value after split the raw note." do
      @card.split
      expect(@card.face).to eq "walk+out+on"
    end
    it "returns a card with phonetic value" do
      @card.split
      expect(@card.phonetic_symbol).to eq "英[]美[]"
    end
    it "returns a card with back value" do
      @card.split
      expect(@card.back).to eq "My wife just walk out on me."
    end
  end

  describe "#refresh" do
    it "should clear the face value." do
      @card.split
      @card.refresh("reconstitute\u001F英 [ˌri:'kɒnstɪtju:t] 美 [riˈkɑnstɪˌtut, -ˌtjut]\u001F再构成")
      expect(@card.face).to eq ""
    end
    it "should clear the phonetic value." do
      @card.split
      @card.refresh("reconstitute\u001F英 [ˌri:'kɒnstɪtju:t] 美 [riˈkɑnstɪˌtut, -ˌtjut]\u001F再构成")
      expect(@card.phonetic_symbol).to eq ""
    end
    it "should clear the back value." do
      @card.split
      @card.refresh("reconstitute\u001F英 [ˌri:'kɒnstɪtju:t] 美 [riˈkɑnstɪˌtut, -ˌtjut]\u001F再构成")
      expect(@card.back).to eq ""
    end    
  end   

  describe "#set_update_to_database_status" do
    it "should return true if called." do
      @card.set_update_to_database_status
      expect(@card.to_update).to be == true
    end
  end

  describe "#update_to_db" do
    it "should upate to db" do
      db = DB.new '/Users/Fiona/anki_ruby/collection.anki2'
      db.connect
      card = Card.new("yield\u001F英 [jiːld]美 [jild]\u001FThe field yields many carrots this year.")
      card.split
      card.clean_face
      #clear phonetic symbol in DB

      db.run_update("yield\u001F\u001FThe field yields many carrots this year.", "yield")

      original = db.run_select("select flds from notes where sfld = 'yield'")

      card.to_update = true
      card.update_to_db(db)  

      expect(db.run_select("select flds from notes where sfld = 'yield'")).to_not be original
    end
  end
end