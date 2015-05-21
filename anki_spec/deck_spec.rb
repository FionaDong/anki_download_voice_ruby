require './spec_helper'

describe Decks do

  before :each do
    init_decks =<<-END
greek_mythology:1413896396636
fiona_dong:1361802008201
literature:1412998095227
ruby:1386552649419
red_documentary:1399888392177
wikipedia:1375434049355
    END

    File.new("/Users/Fiona/anki_ruby/decks_id_list",'w')    
    File.open("/Users/Fiona/anki_ruby/decks_id_list",'w') do |f|
      f.write(init_decks)
    end
  end

  before :each do
    @decks = Decks.new "/Users/Fiona/anki_ruby/decks_id_list" 
  end

  describe "#new" do
    it "creates a new object with deck list file name passed in." do
      decks = Decks.new "/Users/Fiona/anki_ruby/decks_id_list"
      expect(decks).to be_an_instance_of Decks
    end
    
    it "creates a decks hash for this new object." do
      expect(@decks.decks_list).to be_an_instance_of Hash
    end

    it "throws a StandardError when file cannot be found." do
      expect{decks = Decks.new "/Users/Fiona/anki_ruby/decks_id"}.to raise_exception StandardError
    end
  end

  describe "#add_deck" do
    it "appends new line into decks hash." do
      @decks.add_deck("newdeck", "12345678")
      expect(@decks.decks_list[:newdeck]).to eq "12345678"
    end

    it "appends new line into decks file." do
      @decks.add_deck("anothernewdeck", "87654321")
      expect(@decks.get_decks_list_from_file[:anothernewdeck]).to eq "87654321"
    end
  end

  describe "#delete_deck" do
    it "deletes deck passed in decks hash." do
      @decks.delete_deck("wikipedia")
      expect(@decks.decks_list[:wikipedia]).to eq nil
    end
    it "deletes deck passed in decks file." do
      @decks.delete_deck("wikipedia")
      expect(@decks.get_decks_list_from_file[:wikipedia]).to eq nil
    end    
  end

  # describe "#check_decks" do
  #   it "returns false as decks_array has more deck than decks_list does." do
  #     @decks.delete_deck("wikipedia")
  #     expect(@decks.check_decks).to eq false
  #   end
  # end

end
