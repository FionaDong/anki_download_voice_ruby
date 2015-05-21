require 'sqlite3'
# require 'pry'
class DB
  attr_reader :db_link, :db_type, :db

  def initialize(db_link, db_type = "sqlite3")
    @db_link = db_link
    @db_type = db_type
    @db = nil
    @smt = nil
  end

  def connect
    @db = SQLite3::Database.new @db_link
  end

  def close
    
    # @smt.close if @smt
    @db.close if @db

  end

  def run_select_notes(deck_id)
    rs = []
    begin
      smt = @db.prepare(%Q[select flds from notes where id in (select nid from cards where did = ?)])
      smt.bind_param(1, deck_id)
      result = smt.execute
      result.each do |line|
        rs << line
      end 
      
    rescue SQLite3::Excpetion => e
      puts "DB select note failed."
      raise e
    ensure
      smt.close if smt
    end
    return rs
  end

  def run_update_note(note, face)
    rs = []
    begin
      smt = @db.prepare(%Q[update notes set flds = ? where sfld = ?])
      smt.bind_param(1, note)
      smt.bind_param(2, face)
      smt.execute
    rescue => e
      puts "DB update note failed"
      raise e
    ensure
      smt.close if smt
    end
  end
end