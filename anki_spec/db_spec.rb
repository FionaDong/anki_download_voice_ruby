require './spec_helper'

describe DB do
  before :each do
    @anki_db = DB.new '/Users/Fiona/anki_ruby/collection.anki2'
  end

  describe "#new" do
    it "creates db object with db file passed in." do
     db = DB.new '/User/Fiona/anki_ruby/collection.anki2'
     expect(db).to be_an_instance_of DB
    end
  end
  describe "#connect" do
    it "connect to the db file." do
      @anki_db.connect
      expect(@anki_db.db).to be_an_instance_of SQLite3::Database
    end
  end
  describe "#run_select" do
    it "run select sql for the keyword passed in." do
      @anki_db.connect
      rs = @anki_db.run_("select * from notes limit 1")
      expect(rs).to be_an_instance_of Array
    end
  end

  describe "#run_update" do
    it "has been tested in card_spec.rb" do
    end
  end
end